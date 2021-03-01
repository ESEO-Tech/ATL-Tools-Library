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

package fr.eseo.aof.extensions

import java.util.ArrayList
import java.util.Iterator
import java.util.function.Consumer
import java.util.function.Function
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.IObserver
import org.eclipse.papyrus.aof.core.IOne
import org.eclipse.papyrus.aof.core.ISequence
import org.eclipse.papyrus.aof.core.IUnaryFunction
import org.eclipse.papyrus.aof.core.impl.BaseDelegate
import org.eclipse.papyrus.aof.core.impl.operation.Operation
import org.eclipse.xtend.lib.annotations.Data

// TODO:
//	- create specific projects to regroup all active operations (& utils) created outside of AOF
//		- fr.eseo.aof.core.extensions, for:
//			- includes, selectBy, groupBy
//				- from incquery/viatra benchmark solution
//			- sortedBy, sum, take, drop, reverse, OpaqueOperation
//				- from this project (i.e., AOF solution to TTC 2018 live contest)
//			- linked box
//				- from AOC SequenceDiagram example
//			- possibly part of OclByEquivalence...
//			- aligned zipWith
//				- possibly also active map
//			- add emtpy{Option,One,Bag,OrderedSet,Sequence,Set} methods
//		- fr.eseo.aof.emf.extensions, for:
//			- allContents
//				- from this project
//			- Resource contents
//			- ...
//		- fr.eseo.aof.core.extensions.tests, for:
//			- BoxFuzzer
//			- operations from fr.eseo.aof.core.extensions
//			- core operations, using fuzzing
//				- all the more important for core operations that are currently not tested
//					- concat
//					- others?
//		- fr.eseo.aof.core.extensions.tests, for:
//			- operations from fr.eseo.aof.emf.extensions
// TODO: TTC2018 & beyond (i.e., not just for SortedBy):
//	- give initialCapacity to arrayList constructor (when creating boxes)
//		- but currently no way to pass this info to BaseFactory.createBox except
//		when giving it an array of elements
//	- reduce memory usage
//		- Operation creates a lot of Constraints, whereas it could simply extend Constraints
//			=> tried to address it by copying code from Constraint into Operation
//			=> should be shared instead of copied, but not by creating a new Constraint object on each method call
//			- same for FeatureDelegate
//		- each Operation has a list of observers that should no longer be necessary once DisablableObserver is generalized
//			- unless maybe for order-preserving CollectBox
//		- Singletons should not use ListDelegate
//		- using per-transformation cache would make HashMap possible for cache instead of WeakKeysWeakValues caches
//			- although this may be a problem when many elements are removed and others added into a model
//			- possibly use a StrongKeysStrongValuesCache (i.e., a HashMap) for elements that are still in the source or target models,
//			and move them to a Weak cache if they are removed from source and target models
//	- create all variants of boxes and operations for primitive types
//		- e.g., using an active operation that derives them automatically
//	- implement aligned zip for when it works
//		- failing when not working
//		=> started to do it in ActiveMap project
//	- extract the weighted-balanced tree from the SortedBy class so that it can be reused
//	- try adding virtual result boxes everywhere (possibly also for property boxes)
//		- virtual boxes could start storing an actual list if the downstream operation attempts random access
//			- ideally, requiring storage should be discovered by static analysis, but this approach should work for AOF1
//			- possibly using other kinds of collections such as HashSets
//			- some boxes such as ListFeatureDelegate.proxyBox could work in the same way, but enable random access during
//			initialization and only forbidding it during propagation
//	- try adding some properties to boxes such as:
//		- supports random-access
//			- or rely on the scheme by which virtual boxes start using a list when one random access is attempted
//		- computed with order preserved
//			- and make optimized operations that do not preserve order
//				- e.g., computeMutable, select{,Mutable}
//		- read-only
//			- and fail if a write is attempted
//		- complexity per type of computation, so that end-to-end complexity can be computed
//			- more an operation-level type of information, but operations cannot be easily
//			retrieved from boxes in AOF1
//			- for the following types of computations:
//				- initial
//				- added
//				- removed
//				- replaced
//				- moved
//			- warning, a change on one box may trigger other kinds of changes in downstream boxes
//				- either encode this type of dependencies
//					- at least for later propagation graph performance modeling
//				- or use the worst possible complexity
//			- with notably the following types of complexities:
//				- constant		:	O(1)
//				- logarithmic	:	O(ln(n))
//				- linear		:	O(n)
//				- quadratic		:	O(n²)
//			=> implement complexity tests for all operation, all kinds of computations
//	- add a drop method on boxes that detaches it from its source boxes recursively, until it reaches a box that is necessary for another reason (e.g., it is
//	observed by another Operation)
//		- notably for tests for which snapshot is not enough
// TODO:
//	- virtual box indexOf
//	- silencing the observers takes a relatively large amount of time, being O(n) in the number of elements...
//		=> ideally doing this for all operations
//	- fix remaining balancing issues
//	- it may be more efficient to store the outputs of bodies in the tree
//		- makes it possible to find an element by its old bodies values (for inner box replace), instead of temporarily setting the inner box to its old value
//	- improve tests
//	- currently a reversed sort... add a parameter for direction
//	- make non-API methods private
// DONE:
//	- Node.remove
//	- observe inner boxes: need to pass the old value for removal...
//	- remove checkConsistency in "production"
//	- balanced tree
//		- we already have the size of each node, so we should be able to add the balancing of a
//		https://en.wikipedia.org/wiki/Weight-balanced_tree
//		- we could (almost) use Java TreeSet
//			- advantage: already implemented and tested
//			- drawbacks:
//				- adding an element does not return its index
//					- one can get the index by calling .headSet().size() (being careful to the case where the element may not be in the tree, when possible)
//						- but headSet creates a new object on each call
//				- no get(i)
//					=> must use O(n) access
//	- make result box wrap the tree instead of using a default ArrayList
//	- silencing the observers takes a relatively large amount of time, being O(n) in the number of elements...
//		=> try using regular observers + a single boolean
//		=> ideally not using a separate SilentObserver and actual observer
//			e.g., by making silentObserver use original method names, and subclasses
//			use different ones
//	- weak binary cache could have a single Map with a pair of WeakReferences
//		- better than one nested WeakHashMap per different K1
class SortedBy<E, C extends Comparable<?>> extends Operation<E> {
	val IBox<E> sourceBox
	val IUnaryFunction<E, IOne<C>>[] bodies
	var Function<E, C>[] passiveBodiesCache = null

	var Node<E> root = null

	def passiveBodies() {
		if(this.passiveBodiesCache === null) {
			passiveBodiesCache = bodies.map[body | [body.apply(it).get] as Function<E, C>]
		}
		passiveBodiesCache
	}

	static class MutableBoolean {
		var value = false

		new() {}

		new(boolean value) {
			this.value = value
		}
	}

	// warning: methods child classes calling each other should call the _ variants of the operations
	// (e.g., replaced_ should call added_, and removed_ instead of added and removed) 
	@Data
	static abstract class DisablableObserver<E> implements IObserver<E> {
		val MutableBoolean enabled

		final override added(int index, E element) {
			if(enabled.value) {
				enabled.value = false
				added_(index, element)
				enabled.value = true
			}
		}

		def void added_(int index, E element)

		final override moved(int newIndex, int oldIndex, E element) {
			if(enabled.value) {
				enabled.value = false
				moved_(newIndex, oldIndex, element)
				enabled.value = true
			}
		}

		def void moved_(int newIndex, int oldIndex, E element)

		final override removed(int index, E element) {
			if(enabled.value) {
				enabled.value = false
				removed_(index, element)
				enabled.value = true
			}
		}

		def void removed_(int index, E element)

		final override replaced(int index, E newElement, E oldElement) {
			if(enabled.value) {
				enabled.value = false
				replaced_(index, newElement, oldElement)
				enabled.value = true
			}
		}

		def void replaced_(int index, E newElement, E oldElement)

		override setDisabled(boolean disabled) {
			throw new UnsupportedOperationException("not supporting this kind of disabled")
		}

		final override isDisabled() {
			false
		}
	}

	val observersEnabled = new MutableBoolean(true)

	def add(E it) {
		for(body : bodies) {
			val b = body.apply(it)
			b.addObserver(new DisablableObserver<C>(observersEnabled) {
				override added_(int index, C element) {
					throw new IllegalStateException
				}
				override moved_(int newIndex, int oldIndex, C element) {
					throw new IllegalStateException
				}
				override removed_(int index, C element) {
					throw new IllegalStateException
				}
				override replaced_(int index, C newElement, C oldElement) {
					b.set(oldElement)	// TODO: avoid doing this
					var i = remove(it, passiveBodies)
					if(virtualBox) {
						notifyRemoval(i, it)
					} else {
						result.removeAt(i)
					}
					checkConsistency
					b.set(newElement)
					i = add(it, passiveBodies)
					if(virtualBox) {
						notifyAddition(i, it)
					} else {
						result.add(i, it)
					}
					checkConsistency
				}
			})
		}
		add(it, passiveBodies)
	}

	// TODO: keep reference to virtual box delegate so that calling its fireAdded and fireRemoved methods can be called
	// see virtualBox.add
	def notifyAddition(int index, E elem) {
		result.observers.forEach[e |
			if (!e.isDisabled()) {
				e.added(index, elem)
			}
		]
	}

	// see virtualBox.removeAt
	def notifyRemoval(int index, E elem) {
		result.observers.forEach[e |
			if (!e.isDisabled()) {
				e.removed(index, elem)
			}
		]
	}

	val boolean virtualBox

	new(IBox<E> sourceBox, IUnaryFunction<E, IOne<C>>...bodies) {
		this(sourceBox, true, bodies)
	}

	new(IBox<E> sourceBox, boolean virtualBox, IUnaryFunction<E, IOne<C>>...bodies) {
		this.virtualBox = virtualBox
		this.sourceBox = sourceBox
		if(virtualBox) {
			result = (AOFFactory.INSTANCE as AOFFactory).createBox(this, new BaseDelegate<E> {
				// BaseDelegate.indexOf is linear, if we want log(n) access, then we need to search for the element using bodies (which are used to sort the tree) 
//				override indexOf(E element) {
//					root.
//				}
//				override contains(E element) {
//					root.
//				}
				override get(int index) {
					root.get(index)
				}
				override length() {
					if(root === null) {
						0
					} else {
						root.size
					}
				}
				override iterator() {
					new Iterator<E> {
						var nextNode = init
						def init() {
							var ret = root
							if(ret !== null) {
								while(ret.lower !== null) {
									ret = ret.lower
								}
							}
							return ret
						}
						override hasNext() {
							nextNode !== null
						}
						override next() {
							val r = nextNode
							if(nextNode.upper !== null) {
								nextNode = nextNode.upper 
								while(nextNode.lower !== null) {
									nextNode = nextNode.lower
								}
								return r.value
							}
							while(true) {
								if(nextNode.parent === null) {
									nextNode = null 
									return r.value
								}
								if(nextNode.parent.lower === nextNode) {
									nextNode = nextNode.parent 
									return r.value
								}
								nextNode =nextNode.parent 
							}
						}
					}
				}
				override add(int index, E element) {
					// no need to add: additions from this operations are already taken into account by additions to the tree
					// and reverse additions are not supported (yet)
					// DONE: move this out of this class, like for removeAt, so that reverse changes can be detected and
					// an exception thrown

					// reverse change
					if(element.anyNull) {
						throw new IllegalArgumentException('''inconsistency: trying to add a target element with at least one null sorting criterion to sortedBy''')
					}
					val nodeAtNext = root.getNode(index)
					val ok =
						element.le(nodeAtNext.value) ||  
						if(index > 0) {
							val nodeAtPrev = root.getNode(index - 1)
							nodeAtPrev.value.le(element)
						} else {
							true
						}
					if(ok) {
//						val v = nodeAtOld.value
//						nodeAtOld.value = nodeAtNew.value
//						nodeAtNew.value = v
						// TODO: actually move
					} else {
						throw new IllegalArgumentException('''inconsistency: trying to move a sortedBy output element in an inconsistent manner''')
					}
				}
				def anyNull(E e) {
					passiveBodies.exists[
						apply(e) === null
					]
				}
				def le(E v1, E v2) {
					passiveBodies.forall[
						(apply(v1) as Comparable<Object>).compareTo(
							apply(v2) as Object
						) <= 0
					]
				}
				override move(int newIndex, int oldIndex) {
					// SortedBy never moves its output
					// it could in theory, but it currently removes then re-adds when the index of an element changes

					// reverse move, but first check if move is valid 
					val nodeAtOld = root.getNode(oldIndex)
					val nodeAtNew = root.getNode(newIndex)	// will be next
					val ok =
						nodeAtOld.value.le(nodeAtNew.value) ||  
						if(newIndex > 0) {
							val nodeAtNewMinusOne = root.getNode(newIndex - 1)	// will be previous
							nodeAtNewMinusOne.value.le(nodeAtOld.value)
						} else {
							true
						}
					if(ok) {
//						val v = nodeAtOld.value
//						nodeAtOld.value = nodeAtNew.value
//						nodeAtNew.value = v
						// TODO: actually move
					} else {
						throw new IllegalArgumentException('''inconsistency: trying to move a sortedBy output element in an inconsistent manner''')
					}
				}
				override removeAt(int index) {
					// the assert in Box makes it fail in some cases before we reach here,
					// so we have to notify removal from somewhere else
					// plus getting the removed element from here would be tricky

					// reverse removal
					SortedBy.this.remove(root.get(index), passiveBodies)
				}
				override set(int index, Object element) {
					throw new UnsupportedOperationException
				}
			})
		}
		this.bodies = bodies
		for(e : sourceBox) {
			add(e)
		}
		if(!virtualBox) {
			infix[result.add(it)]
		}
		checkConsistency
		sourceBox.addObserver(new DisablableObserver<E>(observersEnabled) {
			override added_(int index, E e) {
				val i = add(e)
//				assertEquals("", e, root.get(i))
				if(virtualBox) {
					notifyAddition(i, e)
				} else {
					result.add(i, e)
				}
//				assertEquals("", e, result.get(i))
				checkConsistency
			}
			override moved_(int newIndex, int oldIndex, E element) {
				// nothing to do
			}
			override removed_(int index, E element) {
				val i = remove(element, passiveBodies)
				if(virtualBox) {
					notifyRemoval(i, element)
				} else {
					result.removeAt(i)
				}
				checkConsistency
			}
			override replaced_(int index, E newElement, E oldElement) {
				removed_(index, oldElement)
				added_(index, newElement)
			}
		})
	}

	override isOptional() {
		sourceBox.isOptional
	}

	override isSingleton() {
		sourceBox.isSingleton
	}

	override isOrdered() {
		true
	}

	override isUnique() {
		sourceBox.isUnique
	}

	override getResultDefautElement() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	def infix(Consumer<E> consumer) {
		if(root !== null) {
			root.infix(consumer)
		}
	}

	def add(E e, Function<E, ? extends Comparable<?>>...bodies) {
		if(root === null) {
			root = new Node<E>(e, null)
			0
		} else {
			root.add(e, bodies)
		}
	}

	def remove(E e, Function<E, ? extends Comparable<?>>...bodies) {
		if(e == root.value) {
			if(root.lower === null) {
				if(root.upper === null) {
					root = null
				} else {
					root = root.upper
					root.parent = null
					root.checkConsistency(bodies)
				}
				return 0
			} else {
				val pos = root.lowerSize
				if(root.upper === null) {
					root = root.lower
					root.parent = null
				} else {
					if(root.lower.size < root.upper.size) {
						val m = root.upper.min
						root.value = m.value
						m.replaceInParent(m.upper)
//						root.balanceR
					} else {
						val m = root.lower.max
						root.value = m.value
						m.replaceInParent(m.lower)
//						root.balanceL
					}
				}
				root.checkConsistency(bodies)
				return pos
			}
		} else {
			root.remove(e, bodies)
		}
	}

	static val debug =
//		true
		SortedBy.desiredAssertionStatus	// use the fact that asserts are enabled

	def checkConsistency() {
		if(debug) {
			assertEquals("root.parent", null, root?.parent)
			root?.checkConsistency(passiveBodies)
			val l = new ArrayList
			infix[l.add(it)]
			assertEquals("result vs. tree", result, l)
			if(balance && root !== null) {
//				assertTrue("unbalanced tree", root.isBalanced)	// why does this fail?
				assertTrue("really unbalanced tree", root.depth <= root.size.log2 + 4)
			}
		}
	}

	static var balance = true

	def static log2(int it) {
		Math.log(it) / Math.log(2)
	}

	static class Node<E> {
		var E value
		var Node<E> parent = null

		var size = 1
		var Node<E> lower = null
		var Node<E> upper = null

		new(E value, Node<E> parent) {
			this.value = value
			this.parent = parent
		}

		def void checkConsistency(Function<E, ? extends Comparable<?>>...bodies) {
			if(debug) {
				if(parent === null) {
					println('''size=«size», log2(size)=«Math.log(size) / Math.log(2)», depth=«depth»''')
				}
				if(lower !== null) {
					assertTrue("", value.lt(lower.value, bodies) || lower.value.eq(value, bodies))
					assertEquals("lower.parent", lower.parent, this)
					lower.checkConsistency(bodies)
				}
				if(upper !== null) {
					assertTrue("", upper.value.lt(value, bodies) || upper.value.eq(value, bodies))
					assertEquals("upper.parent", upper.parent, this)
					upper.checkConsistency(bodies)
				}
				checkSize
			}
		}

		def checkSize() {
			assertEquals("", lowerSize + upperSize + 1, size)
		}

		// https://yoichihirai.com/bst.pdf
		static val delta = 3
		static val gamma = 2

		static def <E> csize(Node<E> a) {
			if(a === null) {0} else {a.size}
		}
		static def <E> boolean isBalancedPredicate(Node<E> a, Node<E> b) {
			val x = a.csize
			val y = b.csize
			x + y <= 1 || delta * x >= y
		}

		def boolean isBalanced() {
			isBalancedPredicate(lower, upper) && isBalancedPredicate(upper, lower) &&
			if(lower !== null) {lower.isBalanced} else {true} && if(upper !== null) {upper.isBalanced} else {true}
		}

		static def <E> isSingle(Node<E> a, Node<E> b) {
			a.csize < gamma * b.csize
		}

		def  balanceL() {
			if(!isBalancedPredicate(lower, upper)) {
				if(balance) rotateL
			}
		}

		def rotateL() {
			if(isSingle(upper.lower, upper.upper)) {
				singleL
			} else {
				doubleL
			}
		}

		def E get(int i) {
			if(i === lowerSize) {
				value
			} else if(i < lowerSize) {
				lower.get(i)
			} else {
				upper.get(i - lowerSize - 1)
			}
		}

		def Node<E> getNode(int i) {
			if(i === lowerSize) {
				this
			} else if(i < lowerSize) {
				lower.getNode(i)
			} else {
				upper.getNode(i - lowerSize - 1)
			}
		}

		def singleL() {
			val tmp = value
			val x = lower
			val y = upper.lower
			val z = upper.upper

			value = upper.value
			lower = upper
			upper = z
			if(z !== null) {
				z.parent = this
			}

			lower.value = tmp
			lower.lower = x
			if(x !== null) {
				x.parent = lower
			}
			lower.upper = y
			if(y !== null) {
				y.parent = lower
			}

			lower.size = lower.lower.csize + lower.upper.csize + 1
			size = lower.csize + upper.csize + 1
		}

		def doubleL() {
			val tmp = value
			val x = lower
			val y0 = upper.lower.lower
			val y1 = upper.lower.upper

			value = upper.lower.value
			lower = upper.lower
			lower.parent = this
			upper.lower = y1
			if(y1 !== null) {
				y1.parent = upper
			}
			lower.lower = x
			if(x !== null) {
				x.parent = lower
			}
			lower.upper = y0
			if(y0 !== null) {
				y0.parent = lower
			}

			lower.value = tmp

			lower.size = lower.lower.csize + lower.upper.csize + 1
			upper.size = upper.lower.csize + upper.upper.csize + 1
			size = lower.csize + upper.csize + 1
		}

		def  balanceR() {
			if(!isBalancedPredicate(upper, lower)) {
				if(balance) rotateR
			}
		}

		def rotateR() {
			if(isSingle(lower.upper, lower.lower)) {
				singleR
			} else {
				doubleR
			}
		}

		def singleR() {
			val tmp = value
			val x = lower.lower
			val y = lower.upper
			val z = upper

			value = lower.value
			upper = lower
			lower = x
			if(x !== null) {
				x.parent = this
			}

			upper.value = tmp
			upper.lower = y
			if(y !== null) {
				y.parent = upper
			}
			upper.upper = z
			if(z !== null) {
				z.parent = upper
			}

			upper.size = upper.lower.csize + upper.upper.csize + 1
			size = lower.csize + upper.csize + 1
		}

		def doubleR() {
			val tmp = value
			val y0 = lower.upper.lower
			val y1 = lower.upper.upper
			val z = upper

			value = lower.upper.value
			upper = lower.upper
			upper.parent = this
			upper.lower = y1
			if(y1 !== null) {
				y1.parent = upper
			}
			upper.upper = z
			if(z !== null) {
				z.parent = upper
			}
			lower.upper = y0
			if(y0 !== null) {
				y0.parent = lower
			}

			upper.value = tmp

			lower.size = lower.lower.csize + lower.upper.csize + 1
			upper.size = upper.lower.csize + upper.upper.csize + 1
			size = lower.csize + upper.csize + 1
		}

		def eq(E a, E b, Function<E, ? extends Comparable<?>>...bodies) {
			bodies.map[apply(a)] == bodies.map[apply(b)]
		}

		def int depth() {
			if(lower === null) {
				if(upper === null) {
					1
				} else {
					upper.depth + 1
				}
			} else {
				if(upper === null) {
					lower.depth + 1
				} else {
					Math.max(lower.depth, upper.depth) + 1
				}
			}
		}

		def Node<E> min() {
			if(lower === null) {
				this
			} else {
				lower.min
			}
		}

		def Node<E> max() {
			if(upper === null) {
				this
			} else {
				upper.max
			}
		}

		def replaceInParent(Node<E> newNode) {
			if(parent.lower == this) {
				parent.lower = newNode
			} else {
				parent.upper = newNode
			}
			if(newNode !== null) {
				newNode.parent = parent
			}
			parent.decrementSize
		}

		def void decrementSize() {
			size--
			if(parent !== null) {
				parent.decrementSize
			}
		}

		def int remove(E e, Function<E, ? extends Comparable<?>>...bodies) {
			if(value == e) {
				if(lower === null) {
					if(upper === null) {
						replaceInParent(null)
					} else {
						replaceInParent(upper)
					}
					return 0
				} else {
					val pos = lowerSize
					if(upper === null) {
						replaceInParent(lower)
					} else {
						if(lower.size < upper.size) {
							val m = upper.min
							value = m.value
							m.replaceInParent(m.upper)
						} else {
							val m = lower.max
							value = m.value
							m.replaceInParent(m.lower)
						}
					}
					return pos
				}
			} else if(value.lt(e, bodies)) {
				var r = if(lower !== null) {lower.remove(e, bodies)} else {-1}
				if(r < 0) {
					// element not found in lower branch
					// DONE: look in all branches when there is an equality +
					// detect when element not found to throw exception
					r = upper.remove(e, bodies)
					if(r < 0) {
						throw new IllegalStateException('''attempting removal of a non existing element''')
					}
				}
				checkConsistency(bodies)
				balanceL
				r
			} else if(upper !== null) {	// otherwise element not in this branch
				val r = upper.remove(e, bodies) + lowerSize + 1
				balanceR
				r
			} else {
				return -1
			}
		}

		def boolean lt(E a, E b, Function<E, ? extends Comparable<?>>...bodies) {
			!actualLt(a, b, bodies)	// reversing to make it normal
		}

		def boolean actualLt(E a, E b, Function<E, ? extends Comparable<?>>...bodies) {
			for(body : bodies) {
				val ba = body.apply(a) as Comparable<Object>
				val bb = body.apply(b) as Comparable<Object>
				if(ba < bb) {
					return true
				} else if(ba == bb) {
					// let following bodies (if any) be used in subsequent iterations
				} else {
					return false
				}
			}
			return false
//			if(bodies.hasNext) {
//				val body = bodies.next
//				val ba = body.apply(a) as Comparable<Object>
//				val bb = body.apply(b) as Comparable<Object>
//				if(ba < bb) {
//					true
//				} else if(ba == bb) {
//					a.lt(b, bodies)
//				} else {
//					false
//				}
//			} else {
//				false
//			}
		}

		def lowerSize() {
			if(lower === null) {
				0
			} else {
				lower.size
			}
		}

		def upperSize() {
			if(upper === null) {
				0
			} else {
				upper.size
			}
		}

		def int add(E e, Function<E, ? extends Comparable<?>>...bodies) {
			size++
			val ret =
//				if(e.lt(value, bodies.iterator)) {
				if(value.lt(e, bodies)) {	// reversing sort
					if(lower === null) {
						lower = new Node(e, this)
						0
					} else {
						val r = lower.add(e, bodies)
						balanceR
						r
					}
				} else {
					if(upper === null) {
						upper = new Node(e, this)
						size - 1
					} else {
						val r = 1 + upper.add(e, bodies) + lowerSize
						balanceL
						r
					}
				}
			ret
		}

//		def iterator() {
//			TODO: use guava?
//		}
		def void infix(Consumer<E> consumer) {
			if(lower !== null) {
				lower.infix(consumer)
			}
			consumer.accept(value)
			if(upper !== null) {
				upper.infix(consumer)
			}
		}

		override toString() {
			val ret = new StringBuilder
			infix[
				if(ret.length !== 0) {
					ret.append(", ")
				}
				if(it == value) {
					ret.append("*")
				}
				ret.append(it)
			]
			'''[«ret.toString»]'''
		}
	}

	def static <E> testOne(Pair<Integer, ISequence<E>> it, (E)=>Integer body1, (E)=>Integer body2) {
		value.inspect('''unsorted[«key»]: ''')
		new SortedBy(value, [
			AOFFactory.INSTANCE.createOne(body1.apply(it))
		], [
			AOFFactory.INSTANCE.createOne(body2.apply(it))
		]).result
		.collect[it]	// this is here to make sure that we are also testing propagation
		.inspect('''sorted[«key»]  : ''')
	}

	def static <E> assertEquals(Iterable<E> expected, Iterable<E> actual) {
		assertEquals("", expected, actual)
	}

	def static <E> assertEquals(String msg, Iterable<E> expected, Iterable<E> actual) {
		val ite = expected.iterator
		val ita = actual.iterator
		var i = 0
		while(ite.hasNext && ita.hasNext) {
			val e = ite.next
			val a = ita.next
			assertTrue('''«msg»[«i»]: expected «expected.join("{", ", ", "}")[toString]», but got «actual»''', e == a)
			i++
		}
		assertEquals('''«msg».size''', ite.hasNext, ita.hasNext)
	}

	def static <E> assertEquals(String msg, E expected, E actual) {
		assertTrue('''«msg»: expected «expected», but got «actual»''', expected == actual)
	}
	def static assertTrue(String msg, boolean b) {
		if(!b) {
			throw new AssertionError(msg)
		}
	}

	def static void main(String[] args) {
		val bss = #[
			AOFFactory.INSTANCE.createSequence(1, 2, 3, 4, 5, 6),
			AOFFactory.INSTANCE.createSequence(6, 5, 4, 3, 2, 1),
			AOFFactory.INSTANCE.createSequence(6, 4, 5, 1, 2, 3)
		]
		for(it : bss.indexed) {
			val cs = testOne([it], [0])
			assertEquals(value.sort.reverse, cs)
			value.add(3, 8)
			assertEquals(value.sort.reverse, cs)
			value.add(6, -1)
			assertEquals(value.sort.reverse, cs)
			value.removeAt(5)
			assertEquals(value.sort.reverse, cs)
			new BoxFuzzer(value, [BoxFuzzer.rand.nextInt], [
				assertEquals(value.sort.reverse, cs)
			])
		}
		val ps = AOFFactory.INSTANCE.createSequence(
			1 -> 0, 2 -> 0, 3 -> 0, 4 -> 0, 5 -> 0, 6 -> 0
		)
		val cs = (bss.size -> ps).testOne([key], [value])
		assertEquals(ps.sortBy[key * 1000 + value].reverse, cs)
		ps.add(3, 8 -> 0)
		assertEquals(ps.sortBy[key * 1000 + value].reverse, cs)
		ps.add(6, -1 -> 0)
		assertEquals(ps.sortBy[key * 1000 + value].reverse, cs)
		ps.add(3, 1 -> 0)
		assertEquals(ps.sortBy[key * 1000 + value].reverse, cs)
		ps.add(3, 1 -> 1)
		assertEquals(ps.sortBy[key * 1000 + value].reverse, cs)
		ps.add(3, 1 -> -1)
		assertEquals(ps.sortBy[key * 1000 + value].reverse, cs)
	}
}