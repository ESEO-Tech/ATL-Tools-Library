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
import fr.eseo.atlc.constraints.Constraint
import fr.eseo.atlc.constraints.DoubleExp
import fr.eseo.atlc.constraints.Expression
import fr.eseo.atlc.constraints.IntExp
import fr.eseo.atlc.constraints.VariableExp
import fr.eseo.atol.gen.plugin.constraints.common.Constraints
import fr.eseo.atol.gen.plugin.constraints.common.ConstraintsHelpers
import fr.eseo.atol.gen.plugin.constraints.common.JFXBoxable
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.xcsp.common.IVar
import org.xcsp.common.IVar.Var
import org.xcsp.common.predicates.XNodeParent
import org.xcsp.modeler.Compiler
import org.xcsp.modeler.api.ProblemAPI

import static fr.eseo.atol.gen.plugin.constraints.solvers.Constraints2Xcsp.XcspModel.*

class Constraints2Xcsp {
	extension Constraints cstrExt = new Constraints
	extension ConstraintsHelpers cstrHelp
	extension JFXBoxable boxable

	var IBox<Expression> constraints_in
	var IBox<Constraint> constraints_flat

	var DOM_LB = -5000
	var DOM_UB = 5000

	new(Object jfxMM) {
		boxable = new JFXBoxable(jfxMM)
		cstrHelp = new ConstraintsHelpers(#[boxable], cstrExt)
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
			*****************************
		''')
	}

	val emptyCstr = AOFFactory.INSTANCE.<Constraint>createOrderedSet
	def apply(IBox<Expression> constraints) {
		constraints_in = constraints
		constraints_flat = constraints.flattenConstraints.collectMutable[
			it?.simplifyConstraint ?: emptyCstr
		]//.inspect("cstr simplified : ")
		XcspModel.boxable = boxable
		XcspModel.constraints = constraints_flat
		XcspModel.DOM_LB = DOM_LB
		XcspModel.DOM_UB = DOM_UB
		Compiler.main(#{XcspModel.name})
	}

	static class XcspModel implements ProblemAPI {
		static extension JFXBoxable boxable
		static var IBox<Constraint> constraints
		static var DOM_LB = -5000
		static var DOM_UB = 5000
		static val BiMap<Object, Var> cacheVar = HashBiMap.create

		override model() {
			cacheVar.clear
			constraints.forEach[convertCstr]
		}

		def convertCstr(Constraint it) {
			switch operatorName {
				case 'allDifferent': {
					val args = arguments.map[convertExp]
					if (args.forall[it instanceof Var]) { // if all operands are Var directly use allDifferent that uses var
						allDifferent(args.map[it as Var])
					}
					else { // otherwise "cast" Var to XNodeParent
						allDifferent(
							args.map[
								if (it instanceof XNodeParent)
									it
								else
									add(it, 0)
							]
						)
					}
				}
				case 'stay': {
					// TODO : stay constraints are ignored
				}
				default:
					intension(convert as XNodeParent<IVar>)
			}
		}

		dispatch def Object convert(Expression it) {
			throw new UnsupportedOperationException('''Cannot convert «it»''')
		}

		dispatch def Object convert(CompositeExp it) {
			switch arguments.size {
				case 1: convertUnary
				case 2: convertBinary
				default: throw new UnsupportedOperationException('''Cannot compile «it»''')
			}
		}

		def Object convertBinary(CompositeExp it) {
			val l = arguments.get(0).convert
			val r = arguments.get(1).convert
			val cstr = switch operatorName {
				case "&&",
				case "and": and(l, r)
				case "||",
				case "or": or(l, r)
				case "xor": xor(l, r)
				case "->",
				case "imp": imp(l, r)
				default: throw new UnsupportedOperationException('''Unsupported predicate «operatorName»''')
			}
			cstr
		}

		def Object convertUnary(CompositeExp it) {
			val arg = arguments.get(0).convert
			val cstr = switch operatorName {
				case "!",
				case "not": not(arg)
				default: throw new UnsupportedOperationException('''Unsupported predicate «operatorName»''')
			}
			cstr
		}

		dispatch def Object convert(Constraint it) {
			if (arguments.length > 2) {
				throw new UnsupportedOperationException("Predicate with arity > 2 are not supported yet.")
			}
			val l = arguments.get(0).convertExp
			val r = arguments.get(1).convertExp
			val cstr = switch operatorName {
				case "<=",
				case ".<=": le(l, r)
				case "<",
				case ".<": lt(l, r)
				case ">=",
				case ".>=": ge(l, r)
				case ">",
				case ".>": gt(l, r)
				case "=",
				case ".=": eq(l, r)
				case "!=",
				case ".!=",
				case "<>",
				case ".<>": ne(l, r)
				default: throw new UnsupportedOperationException('''Unsupported predicate «operatorName»''')
			}
			cstr
		}


	//@begin convertExp
		dispatch def Object convertExp(Expression it) {
			throw new UnsupportedOperationException('''Cannot process «it»''')
		}

		dispatch def Object convertExp(CompositeExp it) {
			switch arguments.size {
				case 2: convertBinaryExp
				default: convertNARYExp
			}
		}

		def Object convertNARYExp(CompositeExp it) {
			val ops = arguments.map[convertExp]
			switch operatorName {
				case 'sum': {
					ops.drop(1).fold(ops.get(0), [add($0, $1)])
				}
				case 'product': {
					ops.drop(1).fold(ops.get(0), [mul($0, $1)])
				}
				default:
					throw new UnsupportedOperationException('''Unknown operator «operatorName»''')
			}
		}

		def Object convertBinaryExp(CompositeExp it) {
			val l = arguments.get(0).convertExp
			val r = arguments.get(1).convertExp
			switch operatorName {
				case ".+",
				case "+":
					add(l, r)
				case ".-",
				case "-":
					sub(l, r)
				case ".*",
				case "*":
					mul(l, r)
				case "./",
				case "/":
					div(l, r)
				case '^',
				case 'pow':
					pow(l, r)
				case 'min':
					min(l, r) //TODO: min, max support more than 2 arguments, it could be used as unary operation on VariableVector ?
				case 'max':
					max(l, r)
				case 'dist':
					dist(l, r)
				case 'mod':
					mod(l, r)
				default:
					throw new UnsupportedOperationException('''Unknown operator «operatorName»''')
			}
		}
	
		def Object convertExp(CompositeExp it) {
			val arg = arguments.get(0).convertExp

			switch operatorName {
				case '-',
				case 'neg':
					neg(arg)
				case 'abs':
					abs(arg)
				case 'sqr':
					pow(arg, 2)
				default:
					throw new UnsupportedOperationException('''Unknown operator «operatorName»''')
			}
		}

		dispatch def Object convertExp(DoubleExp it) {
			System.err.println("Casting double to int as Xcsp does not support double variables")
			value as int
		}

		dispatch def Object convertExp(IntExp it) {
			value
		}

		dispatch def Object convertExp(VariableExp it) {
			if (isVector) {
				throw new UnsupportedOperationException('''Expressions containing VariableVector must be flattened first''')
			}
			source.createVariable(propertyName)
		}
	//@end convertExp

		def Var createVariable(Object o, String propertyName) {
			val prop = o.getProperty(propertyName).property
			if (!cacheVar.containsKey(prop)) {
				//TODO: find better range for variables
				val variable = ^var(prop.getName, dom(range(DOM_LB, DOM_UB)))

				cacheVar.put(prop, variable)
				variable
			}
			else {
				cacheVar.get(prop)
			}
		}
	}
}