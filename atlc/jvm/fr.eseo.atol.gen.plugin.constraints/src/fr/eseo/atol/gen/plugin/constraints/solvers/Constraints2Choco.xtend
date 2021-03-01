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
import fr.eseo.aof.extensions.AOFExtensions
import fr.eseo.atlc.constraints.CompositeExp
import fr.eseo.atlc.constraints.Constraint
import fr.eseo.atlc.constraints.ConstraintSolver
import fr.eseo.atlc.constraints.DoubleExp
import fr.eseo.atlc.constraints.Expression
import fr.eseo.atlc.constraints.IntExp
import fr.eseo.atlc.constraints.Strength
import fr.eseo.atlc.constraints.StrengthLevel
import fr.eseo.atlc.constraints.VariableExp
import fr.eseo.atlc.constraints.VariableRelationExp
import fr.eseo.atol.gen.plugin.constraints.common.Boxable
import fr.eseo.atol.gen.plugin.constraints.common.Constraints
import fr.eseo.atol.gen.plugin.constraints.common.ConstraintsHelpers
import fr.eseo.atol.gen.plugin.constraints.common.EMFBoxable
import fr.eseo.atol.gen.plugin.constraints.common.JFXBoxable
import fr.eseo.atol.gen.plugin.constraints.common.RelationBoxable
import fr.eseo.atol.gen.plugin.constraints.common.Stopwatch
import java.util.ArrayList
import java.util.Collection
import java.util.HashMap
import java.util.Map
import org.chocosolver.solver.Model
import org.chocosolver.solver.Solution
import org.chocosolver.solver.expression.discrete.arithmetic.ArExpression
import org.chocosolver.solver.expression.discrete.relational.ReExpression
import org.chocosolver.solver.search.strategy.Search
import org.chocosolver.solver.variables.IntVar
import org.eclipse.emf.ecore.EObject
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox

class Constraints2Choco implements AOFExtensions {
	extension Constraints cstrExt = new Constraints
	extension ConstraintsHelpers cstrHelp

	var Collection<Boxable> boxables
	val RelationBoxable relBox = new RelationBoxable

	val BiMap<Boxable.Property, ArExpression> cacheVar = HashBiMap.create
	val Map<Object, ArExpression> prop2Var = new HashMap
	val Map<Expression, IntVar> intermediateVariables = new HashMap
	val Map<ArExpression, ArExpression> relationVarCache = new HashMap

	private static class Suggestion {
		val Strength strength
		var int value
		val boolean stay

		new(Strength strength, int value, boolean stay) {
			this.strength = strength
			this.value = value
			this.stay = stay
		}
	}

	val Map<Object, Suggestion> suggestedValues = new HashMap

	var Model model
	var Solution solution
	var Solution lastSolution

	var Solution bestSolution
	var Double bestFitness
	var () => Double fitness

	var IBox<Expression> constraintsIn
	var IBox<Constraint> constraintsFlat

	var DOM_LB = -5000
	var DOM_UB = 5000

	var Stopwatch timer

	new(Object jfxMM, Object curMM) {
		boxables = #[
			new JFXBoxable(jfxMM),
			new EMFBoxable(curMM),
			relBox
		]
		cstrHelp = new ConstraintsHelpers(boxables, cstrExt)
	}

	new(Collection<Boxable> boxables) {
		this.boxables = new ArrayList
		this.boxables += boxables
		this.boxables.add(relBox)
		cstrHelp = new ConstraintsHelpers(this.boxables, cstrExt)
	}

	def getDefaultUpperBound() {
		DOM_UB
	}

	def getDefaultLowerBound() {
		DOM_LB
	}

	def setDefaultUpperBound(int ub) {
		DOM_UB = ub
	}

	def setDefaultLowerBound(int lb) {
		DOM_LB = lb
	}

	def setTimer(Stopwatch timer) {
		this.timer = timer
	}

	def boolean solve() {
		var solved = false
		timer?.start

		postConstraints

		timer?.record('post constraints')
		timer?.start

//		model.solver.search = Search.randomSearch(cacheVar.entrySet.map[value as IntVar], System.currentTimeMillis)
//		model.solver.setRestartOnSolutions

		if (!suggestedValues.empty) {
			// we have an optimization problem, stop when search is finished
			while (model.solver.solve) {
				solution.record
				solved = true
			}
		}
		else if (fitness !== null) {
			var MAX_SEARCH_TIME = 60 * 1000

			val startOptimizing = System.currentTimeMillis
			while (model.solver.solve && System.currentTimeMillis - startOptimizing < MAX_SEARCH_TIME) {
				solution.record
				updateProperties(solution)
				if (bestSolution === null || fitness.apply > bestFitness) {
					bestSolution = solution.copySolution
					bestFitness = fitness.apply
				}
			}
			updateProperties(bestSolution)
			solution = bestSolution
			fitness.apply
			println('''Found solution with fitness «bestFitness» after examining «model.solver.solutionCount» solutions''')
		}
		else {
			// satisfaction problem, we only take the first solution
			if (model.solver.solve) {
				solution.record
				solved = true
			}
		}
		timer?.record('solving')
		timer?.start
		if (solved) {
			updateProperties(solution)
			lastSolution = solution
		}

		timer?.record('variable update propagation')
		solved
	}

	def setExternalObjective(() => Double objective) {
		fitness = objective
	}

	def void updateProperties(Solution solution) {
		cacheVar.forEach[prop, variable |
			val v = variable as IntVar
			val value = solution.getIntVal(v)
			// update current values for stayed variables
			suggestedValues.filter[$1.stay].forEach[p1, p2|
				p2.value = value
			]
			// remove old suggestions as they only apply for the next solve
			val toRemove = suggestedValues.filter[!$1.stay].keySet.clone
			toRemove.forEach[suggestedValues.remove(it)]

			val boxable = prop.boxable

			if (boxable.getPropertyValue(prop) != value) {
				boxable.setPropertyValue(prop, value)
			}
		]
	}

	def void suggest(IBox<Integer> property, int value) {
		if (prop2Var.containsKey(property)) {
			val s = Constraints.Strength.newInstance => [
				strength = StrengthLevel.STRONG //TODO: add parameter to control strength ?
				weight = 1
			]
			suggestedValues.put(property, new Suggestion(s, value, false))
		}
		else {
			throw new UnsupportedOperationException('''Cannot find variable corresponding to property «property»''')
		}
	}

	def void suggest(EObject it, String relation, EObject value) {
		if (prop2Var.containsKey(it)) {
			val s = Constraints.Strength.newInstance => [
				strength = StrengthLevel.STRONG //TODO: add parameter to control strength ?
				weight = 1
			]
			val valueId = relBox.getIdOf(value)
			suggestedValues.put(it, new Suggestion(s, valueId, false))
		}
		else {
			throw new UnsupportedOperationException('''Cannot find variable corresponding to property «it»''')
		}
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
			Choco solver:
			«model»
			Last solution:
			«lastSolution»
			Properties values:
				«IF solution.exists»
					«FOR v : cacheVar.entrySet.map[
						key.boxable.getName(key.property) -> solution.getIntVal(value as IntVar)
					]»
						«v.key» -> «v.value»
					«ENDFOR»
				«ENDIF»
			Relations Ids:
				«relBox.debug»
			*****************************
		''')
	}

	def showSolution() {
		println('''
		************ Solution ************
			«FOR v : cacheVar.entrySet.map[
				key.boxable.getName(key.property) -> solution.getIntVal(value as IntVar)
			]»
				«v.key» -> «v.value»
			«ENDFOR»
		''')
	}

	// optimized version for ConstraintSolvers
	def apply(ConstraintSolver constraintSolver) {
		constraintsIn = constraintSolver._constraints
//							.inspect("Cstr in : ")
		constraintsFlat = constraintSolver.allContents(
			Constraints.ExpressionGroup
		).expressions.select(Constraint)
//		.inspect("flat: ")
		.collectMutable[
			it?.simplifyConstraint ?: emptyCstr
		]
	}
	val emptyCstr = AOFFactory.INSTANCE.<Constraint>createOrderedSet
	def apply(IBox<Expression> constraints) {
		constraintsIn = constraints//.inspect("Cstr in : ")
		constraintsFlat = constraints.flattenConstraints.collectMutable[
			it?.simplifyConstraint ?: emptyCstr
		]//.inspect("cstr simplified: ")
	}

	def postConstraints() {
		cacheVar.clear
		prop2Var.clear
		intermediateVariables.clear
		relationVarCache.clear
		model = new Model
		solution = new Solution(model)

		val cstrs = constraintsFlat.map[cstr2Choco]
		cstrs.forEach[it?.post]

		if (!suggestedValues.empty) {
			val errors = new ArrayList<Pair<IntVar, Integer>>
			suggestedValues.forEach[prop, suggestion|
				var IntVar v
				if (prop2Var.containsKey(prop)) {
					v = prop2Var.get(prop) as IntVar
				}
				else if (intermediateVariables.containsKey(prop)) {
					v = intermediateVariables.get(prop)
				}
				else {
					throw new UnsupportedOperationException("Cannot find variable in caches")
				}

				if (suggestion.strength.strength == StrengthLevel.REQUIRED) {
					v.dist(suggestion.value).eq(0).post
				}
				else {
					val err = model.intVar("error_"+v.name, -100, 100)
					v.dist(suggestion.value).eq(err).post
					errors.add(err -> suggestion.strength.convertStrength)
				}
			]
			val errSum = model.intVar("error_sum", 0, 1000)
			model.scalar(errors.map[key], errors.map[value], '=', errSum).post
			model.setObjective(Model.MINIMIZE, errSum)
		}
	}
/*************************************/
	def cstr2Choco(Constraint it) {
		switch operatorName {
			case 'allDifferent':
				model.allDifferent(arguments.map[convertExp.intVar])
			case 'includes': {
				val ^var = arguments.get(0).convertExp.intVar
				var values = arguments.drop(1).filter(DoubleExp).map[value.intValue]
				model.member(^var, values)
			}
			case 'stay': {
				val arg = arguments.map[convertExp]
				if (arg.size > 1) {
					throw new UnsupportedOperationException("Cannot apply stay to a collection")
				}

				// TODO: check if this works for expressions
				if (lastSolution !== null) {
					val v = arg.get(0).intVar
					try {
						val value = lastSolution.getIntVal(v)
						suggestedValues.put(arguments.get(0), new Suggestion(strength, value, true))
						intermediateVariables.put(arguments.get(0), v)
					}
					catch(Exception e) {
						println("Variable has not been found in previous solution, skipping it for now.")
					}
				}
				else {
					val v = arg.get(0).intVar
					val prop = cacheVar.inverse.get(v)
					if (prop !== null) {
						val boxable = prop.boxable
						val value = boxable.getPropertyValue(prop).intValue

						suggestedValues.put(arguments.get(0), new Suggestion(strength, value, true))
						intermediateVariables.put(arguments.get(0), v)
					}
				}
				null
			}
			default: {
				convert.decompose
			}
		}
	}

	dispatch def ReExpression convert(Expression it) {
		throw new UnsupportedOperationException('''Cannot convert «it»''')
	}
	
	dispatch def ReExpression convert(CompositeExp it) {
		switch arguments.size {
			case 1: convertUnary
			case 2: convertBinary
			default: throw new UnsupportedOperationException('''Cannot convert «it»''')
		}
	}

	def ReExpression convertBinary(CompositeExp it) {
		val l = arguments.get(0).convert
		val r = arguments.get(1).convert
		val cstr = switch operatorName {
			case "&&",
			case "and": l.and(r)
			case "||",
			case "or": l.or(r)
			case "xor": l.xor(r)
			case "->",
			case "imp": l.imp(r)
			default: throw new UnsupportedOperationException('''Unsupported predicate «operatorName»''')
		}
		cstr
	}

	def ReExpression convertUnary(CompositeExp it) {
		val arg = arguments.get(0).convert
		val cstr = switch operatorName {
			case "!",
			case "not": arg.not
			default: throw new UnsupportedOperationException('''Unsupported predicate «operatorName»''')
		}
		cstr
	}

	dispatch def ReExpression convert(Constraint it) {
		if (arguments.length > 2) {
			throw new UnsupportedOperationException("Predicate with arity > 2 are not supported yet.")
		}
		val l = arguments.get(0).convertExp
		val r = arguments.get(1).convertExp
		val cstr = switch operatorName {
			case "<=",
			case ".<=": l.le(r)
			case "<",
			case ".<": l.lt(r)
			case ">=",
			case ".>=": l.ge(r)
			case ">",
			case ".>": l.gt(r)
			case "=",
			case ".=": l.eq(r)
			case "!=",
			case ".!=",
			case "<>",
			case ".<>": l.ne(r)
			default: throw new UnsupportedOperationException('''Unsupported predicate «operatorName»''')
		}
		cstr
	}

//@begin convertExp
	dispatch def ArExpression convertExp(Expression it) {
		throw new UnsupportedOperationException('''Cannot process «it»''')
	}

	dispatch def ArExpression convertExp(CompositeExp it) {
		//TODO : what if a NARY op as only 1 or 2 args ?
		if (operatorName == "reify") {
			arguments.get(0).convert.intVar
		}
		else {
			switch arguments.size {
			case 1: convertUnaryExp
			case 2: convertBinaryExp
			default: convertNaryExp
			}
		}
	}

	def ArExpression convertNaryExp(CompositeExp it) {
		val ops = arguments.map[convertExp]
		switch operatorName {
			case 'sum': {
				ops.get(0).add(ops.drop(1))
			}
			case 'product': {
				ops.get(0).mul(ops.drop(1))
			}
			default:
				throw new UnsupportedOperationException('''Unknown operator «operatorName»''')
		}
	}

	def ArExpression convertBinaryExp(CompositeExp it) {
		val l = arguments.get(0).convertExp
		val r = arguments.get(1).convertExp
		switch operatorName {
			case ".+",
			case "+":
				l.add(r)
			case ".-",
			case "-":
				l.sub(r)
			case ".*",
			case "*":
				l.mul(r)
			case "./",
			case "/":
				l.div(r)
			case '^',
			case 'pow':
				l.pow(r)
			case 'min':
				l.min(r) //TODO: min, max support more than 2 arguments, it could be used as unary operation on VariableVector ?
			case 'max':
				l.max(r)
			case 'dist':
				l.dist(r)
			case 'mod':
				l.mod(r)
			default:
				throw new UnsupportedOperationException('''Unknown operator «operatorName»''')
		}
	}
	
	dispatch def ArExpression convertExp(Constraint it) {
		convert.intVar
	}

	def ArExpression convertUnaryExp(CompositeExp it) {
		val arg = arguments.get(0).convertExp

		switch operatorName {
			case '-',
			case 'neg':
				arg.neg
			case 'abs':
				arg.abs
			case 'sqr':
				arg.sqr
			default:
				throw new UnsupportedOperationException('''Unknown operator «operatorName»''')
		}
	}

	var warnedDoubleCast = false
	dispatch def ArExpression convertExp(DoubleExp it) {
		if (!warnedDoubleCast) {
			println('''Choco does not support Double values, casting to int («it.prettyPrint»)''')
			warnedDoubleCast = true
		}
		model.intVar(value.intValue)
	}

	dispatch def ArExpression convertExp(IntExp it) {
		model.intVar(value)
	}

	dispatch def ArExpression convertExp(VariableExp it) {
		if (isVector) throw new UnsupportedOperationException('''Expressions containing VariableVector must be flattened first''')
		
		source.createVariable(propertyName)
	}

	dispatch def ArExpression convertExp(VariableRelationExp it) {
		if (isVector) throw new UnsupportedOperationException('''Expressions containing VariableReferenceVector must be flattened first''')
		
		val variable = source.createVariable('''«relationName»''')
		if (relationVarCache.containsKey(variable)) {
			return relationVarCache.get(variable)
		}
		else {
			val candidates = relBox.getCandidates(source as EObject, relationName, propertyName)
			val prop = relBox.getProperty(source, relationName)

			val relVar = model.intVar('''rel_«relBox.getName(source)».«propertyName»''', prop.lowerBound.intValue, prop.upperBound.intValue)
			//TODO: should be safe if object ids are contiguous
			model.member(variable.intVar, candidates.map[key]).post
			model.element(relVar, candidates.map[value], variable.intVar).post
			//safe method, less efficient ?
//			model.scalar(candidates.map[
//							variable.eq(key).intVar
//						],
//						candidates.map[
//							value
//						],
//						'=',
//						relVar).post

			relationVarCache.put(variable, relVar)
			relVar
		}
	}

//@end convertExp
	def createVariable(Object o, String propertyName) {
		var ArExpression variable = null
		for (b : boxables) {
			if (variable === null && b.hasProperty(o, propertyName)) {
				val prop = b.getProperty(o, propertyName)
				if (!cacheVar.containsKey(prop)) {
					if (prop.isUnbounded) {
						variable = model.intVar(b.getName(prop.property), DOM_LB, DOM_UB)
					}
					else {
						variable = model.intVar(b.getName(prop.property), prop.lowerBound.intValue, prop.upperBound.intValue)
					}
					cacheVar.put(prop, variable)
					prop2Var.put(prop.property, variable)
				}
				else {
					variable = cacheVar.get(prop)
				}
			}
		}
		if (variable === null) {
			throw new NoSuchMethodException('''No suitable method to get property «propertyName» of «o»''')
		}
		variable
	}

	def int convertStrength(Strength it) {
		return (weight as int) * switch strength {
			case REQUIRED: -1
			case STRONG: 10000
			case MEDIUM: 100
			case WEAK: 1
		}
	}
}
