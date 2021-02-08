/****************************************************************
 *  Copyright (C) 2020 ESEO, Université d'Angers 
 *
 *  This program and the accompanying materials are made
 *  available under the terms of the Eclipse Public License 2.0
 *  which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 *  Contributors:
 *    - Frédéric Jouault
 *    - Théo Le Calvar
 *
 *  version 1.0
 *
 *  SPDX-License-Identifier: EPL-2.0
 ****************************************************************/

package fr.eseo.atol.gen.plugin.constraints.solvers

import com.google.common.collect.BiMap
import com.google.common.collect.HashBiMap
import fr.eseo.atlc.constraints.CompositeExp
import fr.eseo.atlc.constraints.DoubleExp
import fr.eseo.atlc.constraints.Expression
import fr.eseo.atlc.constraints.IntExp
import fr.eseo.atlc.constraints.VariableExp
import fr.eseo.atol.gen.plugin.constraints.common.Constraints
import fr.eseo.atol.gen.plugin.constraints.common.ConstraintsHelpers
import fr.eseo.atol.gen.plugin.constraints.common.JFXBoxable
import javafx.beans.property.DoubleProperty
import javafx.beans.property.IntegerProperty
import minicp.engine.core.Constraint
import minicp.engine.core.IntVar
import minicp.engine.core.Solver
import minicp.search.DFSearch
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver

import static minicp.cp.BranchingScheme.*
import static minicp.cp.Factory.*

class Constraints2Minicp {
	extension Constraints cstrExt = new Constraints
	extension ConstraintsHelpers cstrHelp
	extension JFXBoxable boxable

	val BiMap<Object, IntVar> cacheVar = HashBiMap.create

	val Solver solver = makeSolver
	val DFSearch search

	var IBox<Expression> constraints_in
	var IBox<fr.eseo.atlc.constraints.Constraint> constraints_flat
	var IBox<Constraint> constraints_minicp

	var solving = false

	static val DOM_UB = 5000

	new(Object jfxMM) {
		boxable = new JFXBoxable(jfxMM)
		cstrHelp = new ConstraintsHelpers(#[boxable], cstrExt)

		search = makeDfs(solver, firstFail(cacheVar.values)) //TODO : very unoptimized search strategy
		search.onSolution[updateProperties]
	}

	def void solve() {
		if (!solving) {
			solving = true

			search.solve[stats | stats.numberOfSolutions == 1] //stop at first solution

			solving = false
		}
	}

	def void updateProperties() {
		cacheVar.values.forEach[v |
			val prop = cacheVar.inverse.get(v)
			val value = v.min //TODO : might throw exception if var is not an integer var

			switch (prop) {
				IntegerProperty: {
					prop.set(value)
				}
				DoubleProperty: {
					prop.set(value)
				}
				default: {
					throw new UnsupportedOperationException
				}
			}
		]
	}

	def void debug() {
		println('''
			*****************************
			Constraints raw :
			«FOR c : constraints_in»
				- «c.prettyPrint»
			«ENDFOR»
			Constraints flat :
			«FOR c : constraints_flat»
				- «c.prettyPrint»
			«ENDFOR»
			Constraints minicp :
			«FOR c : constraints_minicp»
				- «c»
			«ENDFOR»
			Minicp solver:
			«solver»
			*****************************
		''')
	}

	val emptyCstr = AOFFactory.INSTANCE.<fr.eseo.atlc.constraints.Constraint>createOrderedSet
	def apply(IBox<Expression> constraints) {
		constraints_in = constraints
		constraints_flat = constraints.flattenConstraints.collectMutable[
			it?.simplifyConstraint ?: emptyCstr
		]//.inspect("cstr simplified : ")
		constraints_minicp = constraints_flat.collect[cstr2Minicp]//.inspect("cstr casso : ")
		constraints_minicp.addObserver(new DefaultObserver<Constraint>() {
			override added(int index, Constraint element) {
				element?.post
			}

			override moved(int newIndex, int oldIndex, Constraint element) {}

			override removed(int index, Constraint element) {
				throw new UnsupportedOperationException("Cannot remove constraint from minicp")
			}

			override replaced(int index, Constraint newElement, Constraint oldElement) {
				removed(index, oldElement)
				added(index, newElement)
			}
		})
		constraints_minicp.forEach[it?.post]
	}


/*************************************/
	def cstr2Minicp(fr.eseo.atlc.constraints.Constraint it) {
		//TODO: this is ugly
		switch operatorName {
			case "allDifferent":
				allDifferent(arguments.map[convertExp])
			default:
				convert
		}
	}

	dispatch def Constraint convert(Expression it) {
		throw new UnsupportedOperationException('''Cannot convert «it»''')
	}

	dispatch def Constraint convert(fr.eseo.atlc.constraints.Constraint it) {
		if (arguments.length > 2) {
			throw new UnsupportedOperationException("Predicate with arity > 2 are not supported yet.")
		}

		var IntVar l
		var IntVar r
		var IntExp l_
		var IntExp r_
		if (arguments.get(0) instanceof IntExp) {
			l_ = arguments.get(0) as IntExp
		}
		else {
			l = arguments.get(0).convertExp
		}
		if (arguments.get(1) instanceof IntExp) {
			r_ = arguments.get(1) as IntExp
		}
		else {
			r = arguments.get(1).convertExp
		}

		if (l === null && r === null)
			throw new UnsupportedOperationException('''Cannot handle constraints with only constants''')

		val cstr = switch operatorName {
			case "<=",
			case ".<=":
				if (l === null) { // -r <= -l
					lessOrEqual(minus(r), -l_.value)
					null
				}
				else if (r === null) {
					lessOrEqual(l, r_.value)
					null
				}
				else
					lessOrEqual(l, r)
			case "<",
			case ".<":
				if (l === null) { // l <= r - 1 <=> -r <= -l - 1
					lessOrEqual(minus(r), -l_.value - 1)
					null
				}
				else if (r === null) {
					lessOrEqual(l, r_.value - 1)
					null
				}
				else
					lessOrEqual(l, minus(r, 1))
			case ">=",
			case ".>=": 
				if (l === null) { // r <= l
					lessOrEqual(r, l_.value)
					null
				}
				else if (r === null) { // -l <= -r
					lessOrEqual(minus(l), -r_.value)
					null
				}
				else
					lessOrEqual(r, l)
			case ">",
			case ".>":
				if (l === null) { // r < l <=> r + 1 <= l
					lessOrEqual(plus(r, 1), l_.value)
					null
				}
				else if (r === null) { // -l < -r <=> -l <= -r - 1
					lessOrEqual(minus(l), -r_.value - 1)
					null
				}
				else // l >= r + 1 <=> r + 1 <= l
					lessOrEqual(plus(r, 1), l)
			case "=",
			case ".=":
				if (l === null) {
					equal(r, l_.value)
					null
				}
				else if(r === null) {
					equal(l, r_.value)
					null
				}
				else {
					sum(#{l}, r)
				}
			case "!=",
			case ".!=",
			case "<>",
			case ".<>":
				if (l === null) {
					notEqual(r, l_.value)
					null
				}
				else if (r === null) {
					notEqual(l, r_.value)
					null
				}
				else {
					notEqual(l, r)
				}
			default: throw new UnsupportedOperationException('''Unsupported predicate «operatorName»''')
		}
		cstr
	}

//@begin convertExp
	dispatch def IntVar convertExp(Expression it) {
		throw new UnsupportedOperationException('''Cannot process «it»''')
	}
	
	dispatch def IntVar convertExp(CompositeExp it) {
		switch arguments.size {
			case 1: convertUnaryExp
			case 2: convertBinaryExp
		}
	}

	def IntVar convertBinaryExp(CompositeExp it) {
		var IntVar l
		var IntVar r
		val Expression left = arguments.get(0)
		val Expression right = arguments.get(1)
		if (!(left instanceof IntExp)) l = left.convertExp
		if (!(right instanceof IntExp)) r = right.convertExp

		switch operatorName {
			case ".+",
			case "+":
				if (l === null && r === null)
					sum(left.convertExp, right.convertExp)
				else if (l === null)
					plus(r, (left as IntExp).value)
				else
					plus(l, (right as IntExp).value)
			case ".-",
			case "-":
				if (l === null && r === null)
					sum(left.convertExp, minus(right.convertExp))
				else if (l === null)
					minus(r, (left as IntExp).value)
				else
					plus(minus(l), (right as IntExp).value)
			case ".*",
			case "*":
				if (left instanceof IntExp)
					mul(r, (left as IntExp).value)
				else if(right instanceof IntExp)
					mul(l, (right as IntExp).value)
				else
					throw new UnsupportedOperationException("Multiplying two variables is not supported in MiniCP")
			case 'min':
				minimum(l, r)
			case 'max':
				maximum(l, r)
			default:
				throw new UnsupportedOperationException('''Unknown operator «operatorName»''')
		}
	}

	def IntVar convertUnaryExp(CompositeExp it) {
		val arg = arguments.get(0).convertExp

		switch operatorName {
			case '-',
			case 'neg':
				minus(arg)
			case 'abs':
				abs(arg)
			default:
				throw new UnsupportedOperationException('''Unknown operator «operatorName»''')
		}
	}

	dispatch def IntVar convertExp(DoubleExp it) {
		throw new UnsupportedOperationException('''Double not supported by Minicp''')
	}

	dispatch def IntVar convertExp(IntExp it) {
		throw new UnsupportedOperationException('''IntExp not supported by Minicp''')
	}

	dispatch def IntVar convertExp(VariableExp it) {
		if (isVector)
			throw new UnsupportedOperationException('''Expressions containing VariableVector must be flattened first''')
		
		source.createVariable(propertyName)
	}
//@end convertExp
	def IntVar createVariable(Object o, String propertyName) {
		val prop = o.getProperty(propertyName).property
		if (!cacheVar.containsKey(prop)) {
			//TODO: find better range for variables
			val variable = makeIntVar(solver, DOM_UB)

			cacheVar.put(prop, variable)
			variable
		}
		else {
			cacheVar.get(prop)
		}
	}
}
