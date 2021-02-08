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
import fr.eseo.atlc.constraints.IntExp
import fr.eseo.atlc.constraints.StrengthLevel
import fr.eseo.atlc.constraints.VariableExp
import fr.eseo.atol.gen.plugin.constraints.common.Boxable
import fr.eseo.atol.gen.plugin.constraints.common.Constraints
import fr.eseo.atol.gen.plugin.constraints.common.ConstraintsHelpers
import fr.eseo.atol.gen.plugin.constraints.common.EMFBoxable
import fr.eseo.atol.gen.plugin.constraints.common.JFXBoxable
import java.util.ArrayList
import java.util.Collection
import java.util.HashMap
import java.util.List
import java.util.Map
import javafx.beans.property.DoubleProperty
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver
import org.pybee.cassowary.AbstractConstraint
import org.pybee.cassowary.Constraint
import org.pybee.cassowary.Expression
import org.pybee.cassowary.SimplexSolver
import org.pybee.cassowary.StayConstraint
import org.pybee.cassowary.Strength
import org.pybee.cassowary.Variable
import org.pybee.cassowary.VariableObserver

class Constraints2Cassowary {
	extension Constraints cstrExt = new Constraints
	extension ConstraintsHelpers cstrHelp
	extension JFXBoxable jfxBoxable
	extension EMFBoxable curBoxable

	var Collection<? extends Boxable> boxables

	val SimplexSolver solver = new SimplexSolver

	val BiMap<Boxable.Property, Variable> cacheVar = HashBiMap.create
	val Map<Object, Variable> prop2Var = new HashMap

	val Map<AbstractConstraint, List<Variable>> intermediateVariables = new HashMap

	var IBox<fr.eseo.atlc.constraints.Expression> constraintsIn
	var IBox<fr.eseo.atlc.constraints.Constraint> constraintsFlat
	var IBox<List<AbstractConstraint>> constraintsCass

	val List<Pair<Variable, Double>> suggestList = new ArrayList

	var failed = false

	val varObs = new VariableObserver {
		override onVariableChanged(Variable it) {
			if (attachedObject !== null) {
				val prop = attachedObject as DoubleProperty
//				println('''Variable «name» changed value from «prop.value» to «value»''')
				prop.set(value)
			}
		}
	}

	def sync() {
		cacheVar.forEach[prop, it |
			(attachedObject as DoubleProperty).set(value)
		]
	}

	var solving = false

	val (Object,String)=>fr.eseo.atlc.constraints.Expression fallback
	new(Object jfxMM, Object curMM) {
		this(jfxMM, curMM)[]
	}

	new(Object jfxMM, Object curMM, (Object,String)=>fr.eseo.atlc.constraints.Expression fallback) {
		jfxBoxable = new JFXBoxable(jfxMM)
		curBoxable = new EMFBoxable(curMM)
		this.fallback = fallback
		boxables = #[jfxBoxable, curBoxable].toList

		cstrHelp = new ConstraintsHelpers(boxables, cstrExt)
		solver.autosolve = true
	}

	def void solve() {
		if (!solving) {
			solving = true
			solver.solve
			solving = false
		}
	}

	def void resolve() {
		solver.resolve
	}

	def getFailed() {
		failed
	}

	def setFailed(boolean failed) {
		this.failed = failed
	}

	def void debug() {
		println('''
			*****************************
			Constraints raw :
			«FOR c : constraintsIn»
				- «c.prettyPrint»
			«ENDFOR»
			Constraints flat :
			«FOR c : constraintsFlat»
				- «c.prettyPrint»
			«ENDFOR»
			Constraints casso :
			«FOR c : constraintsCass»
				- «c»
			«ENDFOR»
			*****************************
		''')
	}

	def hasVariable(DoubleProperty p) {
		prop2Var.containsKey(p)
	}

	def suggestValue(DoubleProperty p, double value) {
		if (prop2Var.containsKey(p)) {
			suggest(prop2Var.get(p), value, Strength.STRONG)
		}
		else {
			throw new UnsupportedOperationException('''No variable found for «p» in cache''')
		}
	}

	def suggestValue(DoubleProperty p, double value, StrengthLevel strength) {
		if (prop2Var.containsKey(p)) {
			suggest(prop2Var.get(p), value, strength.toCassowaryStrength)
		}
		else {
			throw new UnsupportedOperationException('''No variable found for «p» in cache''')
		}
	}

	public val EPSILON = 1E-2
	def void suggest(Variable v, double value, Strength s) {
		// TODO : correctly handle strength here
		// TODO : what if we have multiple updates ?
		if (Math.abs(v.value - value) > EPSILON) {
			solver.addEditVar(v, s)
			solver.beginEdit
			solver.suggestValue(v, value - v.value)
			solver.endEdit
		}
	}

	val emptyCstr = AOFFactory.INSTANCE.<fr.eseo.atlc.constraints.Constraint>createOrderedSet
	def apply(IBox<fr.eseo.atlc.constraints.Expression> constraints) {
//		val transfo = new SimplifyConstraints
		// add listener on Constraint to get notified when update in children
		constraintsIn = constraints
		constraintsFlat = constraints.flattenConstraints.collectMutable[
			it?.simplifyConstraint ?: emptyCstr
//			if (it !== null) transfo.SimpleConstraint(it).t._constraints else emptyCstr 
		] //.inspect("cstr simplified : ")
		
		constraintsCass = constraintsFlat.collect[convert] //.inspect("cstr casso : ")

		// Setup observer on res
		constraintsCass.addObserver(new DefaultObserver<List<AbstractConstraint>>{
			override added(int index, List<AbstractConstraint> element) {
				element.forEach[
					failed = !solver.addConstraintNoException(it) || failed
				]
				applySuggest
			}

			override moved(int newIndex, int oldIndex, List<AbstractConstraint> element) {
			}

			override removed(int index, List<AbstractConstraint> element) {
				element.forEach[
					solver.removeConstraint(it) //TODO : check for unused variables
					//TODO: otherwise memory leak
					if (intermediateVariables.containsKey(it)) {
						//TODO: how to remove variables from cassowary ?
						intermediateVariables.remove(it)
					}
				]
			}

			override replaced(int index, List<AbstractConstraint> newElement, List<AbstractConstraint> oldElement) {
				removed(index, oldElement)
				added(index, newElement)
			}
		})
		// Manually add variables already present in res
		constraintsCass.forEach[
			if (it !== null) {
				it.forEach[
					solver.addConstraint(it)
				]
			}
		]
		applySuggest
	}

	def applySuggest() {
		suggestList.forEach[
			suggest(key, value, Strength.STRONG)
		]
		suggestList.clear
	}

	dispatch def List<AbstractConstraint> convert(Constraint it) {
		throw new UnsupportedOperationException('''Cannot convert «it»''')
	}

	dispatch def List<AbstractConstraint> convert(fr.eseo.atlc.constraints.Constraint it) {
		if (arguments.length > 2) {
			throw new UnsupportedOperationException("Wrong number of arguments")
		}
		val s = strength.strength.toCassowaryStrength
		val w = strength.weight

		if (operatorName == "stay") {
			val v = arguments.get(0).convertVar
			var ret = new ArrayList<AbstractConstraint>
			ret += new StayConstraint(v.key, s, w)
			if (v.value !== null) {
				ret += v.value
			}
			return ret
		} else if (operatorName == "suggest") {
			val variable = arguments.get(0).convertVar
			val value = arguments.get(1) as DoubleExp
			suggestList.add((variable.key -> value.value))
			return #[]
		} else {
			val l = arguments.get(0).convertExp
			val r = arguments.get(1).convertExp
			var op = switch operatorName {
				case "<=",
				case ".<=": Constraint.Operator.LEQ
				case ">=",
				case ".>=": Constraint.Operator.GEQ
				case "=",
				case ".=": Constraint.Operator.EQ

				default: throw new UnsupportedOperationException('''Unknown constraint «operatorName»''')
			}
			return #[new Constraint(l, op, r, s, w)]
		}
	}

//@begin convertExp
	def dispatch Expression convertExp(fr.eseo.atlc.constraints.Expression it) {
		throw new UnsupportedOperationException('''Cannot convert «it» to expression''')
	}

	def dispatch Expression convertExp(CompositeExp it) {
		if (operatorName == "sum") {
			convertSum
		}
		else
			switch arguments.size {
				case 1: convertUnaryExp
				case 2: convertBinaryExp
			}
	}

	def Expression convertSum(CompositeExp it) {
		val ops = arguments.map[convertExp]
		ops.fold(new Expression(0), [$0.plus($1)])
	}

	def Expression convertBinaryExp(CompositeExp it) {
		val l = arguments.get(0).convertExp
		val r = arguments.get(1).convertExp
		switch operatorName {
			case ".+",
			case "+":
				l.plus(r)
			case ".-",
			case "-":
				l.minus(r)
			case ".*",
			case "*":
				l.times(r)
			case "./",
			case "/":
				l.divide(r)
			default:
				throw new UnsupportedOperationException('''Unknown operator «operatorName»''')
		}
	}

	def Expression convertUnaryExp(CompositeExp it) {
		val arg = arguments.get(0).convertExp
		switch operatorName {
			case '-',
			case 'neg':
				arg.times(-1)
			default:
				throw new UnsupportedOperationException('''Unknown operator «operatorName»''')
		}
	}

	def dispatch Expression convertExp(DoubleExp it) {
		new Expression(value)
	}

	def dispatch Expression convertExp(IntExp it) {
		new Expression(value)
	}

	def dispatch Expression convertExp(VariableExp it) {
		if (isVector)
			throw new UnsupportedOperationException('''Expressions containing VariableVector must be flattened first''')
	
		var Expression ret = null
		var v = convertVar
		if(v !== null) {
			ret = new Expression(v.key)
			if (v.value !== null) throw new UnsupportedOperationException("Converting an atlc variable to cassowary variable should not introduce any new contraints")
		}
		if(ret === null) {
			ret = fallback.apply(source, propertyName)?.convertExp
		}
		if (ret === null) {
			throw new UnsupportedOperationException('''No suitable method to get property «propertyName» of «source»''')
		}
		ret
	}

//@end convertExp

//@begin convertVar
	def dispatch Pair<Variable,AbstractConstraint> convertVar(CompositeExp exp) {
		val inter = new Variable => [
			name = '''var.inter.«exp.hashCode»'''
		]
		val cstr = new Constraint(inter, Constraint.Operator.EQ, exp.convertExp)

		intermediateVariables.put(cstr, #[inter])

		(inter -> cstr)
	}

	def dispatch Pair<Variable,AbstractConstraint> convertVar(VariableExp it) {
		(source.createVariable(propertyName) -> null)
	}
//@end convertVar
	//TODO: this is ugly, ask Fred for help
	def createVariable(Object o, String propertyName) {
		var Variable variable = null
		for (b : boxables) {
			if (variable === null && b.hasProperty(o, propertyName)) {
				val prop = b.getProperty(o, propertyName)
				if (!cacheVar.containsKey(prop)) {
					variable = new Variable => [
						attachedObject = prop.property
						name = b.getName(attachedObject)
						observer = varObs
					]
					prop2Var.put(prop.property, variable)
					cacheVar.put(prop, variable)
				}
				else {
					variable = cacheVar.get(prop)
				}
			}
		}
		variable
	}

	static def toCassowaryStrength(StrengthLevel it) {
		switch it {
			case REQUIRED: Strength.REQUIRED
			case STRONG: Strength.STRONG
			case MEDIUM: Strength.MEDIUM
			case WEAK: Strength.WEAK
		}
	}

}
