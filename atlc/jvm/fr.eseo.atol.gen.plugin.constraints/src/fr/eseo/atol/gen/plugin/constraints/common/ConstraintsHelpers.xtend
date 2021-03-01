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

package fr.eseo.atol.gen.plugin.constraints.common

import fr.eseo.atlc.constraints.CompositeExp
import fr.eseo.atlc.constraints.Constraint
import fr.eseo.atlc.constraints.DoubleExp
import fr.eseo.atlc.constraints.Expression
import fr.eseo.atlc.constraints.ExpressionGroup
import fr.eseo.atlc.constraints.IntExp
import fr.eseo.atlc.constraints.VariableExp
import fr.eseo.atlc.constraints.VariableRelationExp
import java.util.Collection
import java.util.HashMap
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver

import static extension fr.eseo.aof.exploration.OCLByEquivalence.*

class ConstraintsHelpers {
	extension Constraints cstrExt
	extension Collection<? extends Boxable> boxables
	val AOF = AOFFactory.INSTANCE
	// TODO: is it safe to have multiple instances of this extension ?

	new(Collection<? extends Boxable> boxables, Constraints cstrExt) {
		this.boxables = boxables
		this.cstrExt = cstrExt
	}

	def flattenConstraints(IBox<Expression> constraints) {
		val sc = constraints.select(Constraint).collect[andConstraintToExpressionGroup]
		val cg = constraints.select(ExpressionGroup).concat(sc).closure[
			 it._expressions.select(ExpressionGroup)
		].expressions.select(Constraint).collect[it as Constraint]
		cg
//		sc.concat(
//			cg.select(Constraint).collect[it as Constraint]
//		)
	}

//@begin simplifyConstraint

	//TODO: add cache
	val emptyCstr = AOF.<Constraint>createOrderedSet
	def IBox<Constraint> simplifyConstraint(Constraint c) {
		val expressions = c.arguments.map[simplifyExp]
		if (c.operatorName.isArrayPredicate) { 
			//TODO : 
			// alDiff({a,b,c}) -> allDiff(a, b, c)
			// binPAcking({a,b,c}, {x,y,z}, ..) -> binPacking({a,b,c}, {x,y,z}, ...)
				val res = Constraints.Constraint.newInstance => [
					operatorName = c.operatorName
					strength = c.strength
					arguments.addAll(expressions.get(0)) //TODO: this is not active, should it be done in a active way ? (do not forget to create a new Constraint when recreating)
				]
				AOF.createOne(res as Constraint)
			}
		else if (c.arguments.size == 0) {
			throw new RuntimeException('''No arguments''')
		}
		else if (c.arguments.size == 1) {
			expressions.get(0).collect[a |
				val res = Constraints.Constraint.newInstance => [
					operatorName = c.operatorName
					strength = c.strength //TODO : strength is not copied in a active way
					arguments.add(a)
				]
				res as Constraint
			]
		}
		else if (c.arguments.size == 2) {
			val a1 = expressions.get(0)
			val a2 = expressions.get(1)
			if (c.operatorName == "includes") {
				// includes(collection, var): ensure that var takes its value from the collection
				// thus collection should not be simplified
				a2.collect[r |
					val res = Constraints.Constraint.newInstance => [
						operatorName = c.operatorName
						strength = c.strength
						arguments.add(r)
						arguments.addAll(a1) // TODO -- it is not active !
					]
					a1.addObserver(new DefaultObserver<Expression> {
						override added(int index, Expression element) {
							res.arguments.add(element)
						}

						override moved(int newIndex, int oldIndex, Expression element) {
							// nothing to do
						}

						override removed(int index, Expression element) {
							res.arguments.remove(element)
						}

						override replaced(int index, Expression newElement, Expression oldElement) {
							removed(index, oldElement)
							added(index, newElement)
						}
					})
					res as Constraint
				]
			}
			else if (c.operatorName.isScalar) {
				a1.zipWith(a2, [l, r |
					val res = Constraints.Constraint.newInstance => [
						operatorName = c.operatorName
						strength = c.strength
						arguments.addAll(l, r)
					]
					res as Constraint
				])
			}
			else {
				a1.collectMutable[l |
					if (l === null) {
						emptyCstr
					}
					else {
						val res = a2.collect[r |
							val res = Constraints.Constraint.newInstance => [
								operatorName = c.operatorName
								strength = c.strength
								arguments.addAll(l, r)
							]
							res as Constraint
						]
						res as IBox<Constraint>
					}
				]
			}
		}
		else {
			throw new UnsupportedOperationException('''Cannot expand constraints with more than 2 arguments «c»''')
		}
	}
//@end simplifyConstraint

//@begin simplify
	def dispatch IBox<Expression> simplifyExp(Expression it) {
		throw new UnsupportedOperationException('''Cannot simplify «prettyPrint»''')
	}

	def dispatch IBox<Expression> simplifyExp(VariableExp it) {
		if (isVector) {
			simplifyVariableVector
		}
		else {
			simplifyVariable
		}
	}

	//TODO: add cache
	val simplifyVariableCache = new HashMap<VariableExp, IBox<Expression>>
	def IBox<Expression> simplifyVariable(VariableExp it) {
		if (simplifyVariableCache.containsKey(it)) {
			return simplifyVariableCache.get(it)
		}
		//TODO : make incremental ?
		if (isConstant) {
			val IBox<Expression> ret = source.toReadOnlyBox(propertyName).collect[
				v |
               val r = Constraints.DoubleExp.newInstance => [
                       value = v?.doubleValue
               ]
              r
			]
			simplifyVariableCache.put(it, ret)
			return ret
		}
		else {
			val v = Constraints.VariableExp.newInstance
			v.source = source
			v.propertyName = propertyName
			v.isConstant = isIsConstant
			val IBox<Expression> ret = AOF.createOne(v)
			simplifyVariableCache.put(it, ret)
			return ret
		}
	}

	//TODO: add cache
	def dispatch IBox<Expression> simplifyExp(VariableRelationExp it) {
		if (!isVector) {
			val v = Constraints.VariableRelationExp.newInstance
			v.source = source
			v.propertyName = propertyName
			v.relationName = relationName
			v.isVector = false
			v.isConstant = false
			AOF.createOne(v)	
		}
		else {
			val v = it
			val variables = v.source as IBox<Object>
			variables.select[
				it !== null
			].collect[s |
				val e = Constraints.VariableRelationExp.newInstance => [
					source = s
					relationName = v.relationName
					propertyName = v.propertyName
					isVector = false
					isConstant = false
				]
				e
			]
		}
	}

	def dispatch IBox<Expression> simplifyExp(DoubleExp it) {
		val d = Constraints.DoubleExp.newInstance
		d.value = value
		AOF.createOne(d)
	}

	def dispatch IBox<Expression> simplifyExp(IntExp it) {
		val d = Constraints.IntExp.newInstance
		d.value = value
		AOF.createOne(d)
	}

	//TODO: add cache
	val emptyCst = AOF.<Expression>createOrderedSet
	def IBox<Expression> simplifyVariableVector(VariableExp v) {
		//TODO generate DoubleExp if variable is constant
		val variables = v.source as IBox<Object>
		variables.collectMutable[s |
			if (s === null) {
				emptyCst
			}
			else if (v.isConstant) {
				s.toReadOnlyBox(v.propertyName).collect[
					val res = Constraints.DoubleExp.newInstance => [
						value = 0.0
					]
					res as Expression
				]
			}
			else {
				val e = Constraints.VariableExp.newInstance => [
					source = s
					propertyName = v.propertyName
					isVector = false
					isConstant = false
				]
				AOF.<Expression>createOne(e)
			}
		]
	}
	
	def dispatch IBox<Expression> simplifyExp(CompositeExp it) {
		switch arguments.size {
			case 1: simplifyUnary
			case 2: simplifyBinary
			default:
				throw new UnsupportedOperationException('''Cannot compile expression with arity > 2 («prettyPrint»)''')
		}
	}
	
	def dispatch IBox<Expression> simplifyExp(Constraint it) {
		simplifyConstraint as IBox<?> as IBox<Expression>
	}

	//TODO: add cache
	public static var RIGHT_LEFT_DEP = false
	val emptyExp = AOF.<Expression>createOrderedSet
	def IBox<Expression> simplifyBinary(CompositeExp e) {
		val left = e.arguments.get(0).simplifyExp
		val right = e.arguments.get(1).simplifyExp
		if (e.operatorName.isScalar) {
			// FIXME: this works for Curriculum transfo but won't in the general case
			// right now I don't have any better idea ...
			//TODO: do dynamic analysis, if there is an intersection between properties used in operands then we have a left->right dependency
			left.zipWith(right, RIGHT_LEFT_DEP, [l, r |
				val ret = Constraints.CompositeExp.newInstance => [
					arguments.addAll(l, r)
					operatorName = e.operatorName
				]
				return ret
			], [])
		}
		else {
			left.collectMutable[l |
				if (l === null) {
					emptyExp
				}
				else {
					right.collect[r |
						val b = Constraints.CompositeExp.newInstance => [
							arguments.addAll(l, r)
							operatorName = e.operatorName
						]
						return b as Expression
					]
				}
			]
		}
	}

	//TODO: add cache
	def IBox<Expression> simplifyUnary(CompositeExp e) { //TODO: fix me
		val arg = e.arguments.get(0).simplifyExp
		if (e.operatorName.isArrayPredicate) {
			val res = AOF.<Expression>createOption()
			res.set(Constraints.CompositeExp.newInstance => [
				operatorName = e.operatorName
				arguments.addAll(arg)
			])

			arg.addObserver(new DefaultObserver<Expression>() {
					override added(int index, Expression element) {
						recreate
					}

					override moved(int newIndex, int oldIndex, Expression element) {
						recreate
					}

					override removed(int index, Expression element) {
						recreate
					}

					override replaced(int index, Expression newElement, Expression oldElement) {
						recreate
					}

					def recreate() {
						res.set(Constraints.CompositeExp.newInstance => [
							operatorName = e.operatorName
							arguments.addAll(arg)
						])
					}
				})
			return res
		}
		else {
			arg.collect[a |
				val r = Constraints.CompositeExp.newInstance => [
					operatorName = e.operatorName
					arguments.add(a)
				]
				r
			]
		}
	}
//@end simplify

	def toReadOnlyBox(Object o, String propertyName) {
		var IBox<Number> r = null
		for (b : boxables) {
			if (r === null &&
				b.hasProperty(o, propertyName)
			) {
				r = b.toReadOnlyBox(o, propertyName)
			}
		}
		if (r === null) {
			throw new NoSuchMethodException('''Cannot convert property «propertyName» of «o.class.simpleName» to constant''')
		}
		else {
			r
		}
	}

	def isScalar(String op) { //TODO: +,-,*,/ and =,>,<,>=,>= have opposite meaning with scalar/cartesian
		op.startsWith(".")
	}

	def isArrayPredicate(String pred) {
		switch pred {
			case 'sum',
			case 'product',
			case 'allDifferent': true

			default: false
		}
	}

	// TODO: not incremental if lhs or rhs change
	private def ExpressionGroup andConstraintToExpressionGroup(Constraint it) {
		val eg = Constraints.ExpressionGroup.newInstance
		if (operatorName == "and") {
			val left = it.arguments.get(0) as Constraint
			val right = it.arguments.get(1) as Constraint
			eg.expressions.add(left.andConstraintToExpressionGroup)
			eg.expressions.add(right.andConstraintToExpressionGroup)
		}
		else {
			eg.expressions.add(it)
		}
		return eg
	}
}
