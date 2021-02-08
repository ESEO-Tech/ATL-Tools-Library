/****************************************************************
 *  Copyright (C) 2020 ESEO
 *
 *  This program and the accompanying materials are made
 *  available under the terms of the Eclipse Public License 2.0
 *  which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 *  Contributors:
 *    - Frédéric Jouault
 *
 *  version 1.0
 *
 *  SPDX-License-Identifier: EPL-2.0
 ****************************************************************/

package fr.eseo.aof.exploration

import java.util.Collection
import java.util.HashSet
import java.util.LinkedHashSet
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.IOne
import org.eclipse.papyrus.aof.core.IOrderedSet
import org.eclipse.papyrus.aof.core.ISet
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.papyrus.aof.core.impl.operation.Inspect
/*
 * Flatten works, but does not support graphs
 * Closure partially works
 */
class Closure {
	// test closure or flatten
	static val TEST_CLOSURE = !false

	// test breadth-first or depth-first
	static val TEST_BREADTH_FIRST = false

	static val factory = AOFFactory.INSTANCE

	@Data
	static class Node {
		IOne<String> label = factory.createOne(null)
		IOrderedSet<Node> children = factory.createOrderedSet()

		new(String label, Node...children) {
			this.label.set(label)
			children.forEach[child |
				this.children.add(child)
			]
		}
	}

	private def static ex0() {
		val tree =
			new Node("a");

		showActiveClosure(tree)

		tree
	}

	private def static ex1() {
		val tree =
			new Node("a",
				new Node("b"),
				new Node("c")
			);

		showActiveClosure(tree)

		tree
	}

	private def static ex2() {
		val tree =
			new Node("a",
				new Node("b",
					new Node("c")
				),
				new Node("d")
			);

		showActiveClosure(tree)

		tree
	}

	def static showActiveClosure(Node tree) {
//		val c =
			factory.createOrderedSet(tree).closure[
				it.children
//*
			].collectMutable[	// replaceable by Inspect.registerToString(...) in main
				if(it == null) {
					IBox.ONE as IOne<?> as IOne<String>
				} else {
					it.label
				}
/**/
			].inspect("c: ")
	}

	def static void main(String[] args) {
		Inspect.registerToString(Node)[it.label.get]

		val pipesSer = new PipesSerializer
		val tree = ex1
		pipesSer.serialize("test.plantuml")

		showPassiveClosure(tree)

		tree.children.add(0, new Node("e"))
		showPassiveClosure(tree)

		tree.children.get(0).children.add(0, new Node("f"))
		showPassiveClosure(tree)

		if(TEST_CLOSURE) {
			// Turn it into a graph
			tree.children.get(0).children.add(tree)
			showPassiveClosure(tree)
		}
	}

	def static <E> IBox<E> closure(IBox<E> a, (E)=>IBox<E> f) {
		if(TEST_CLOSURE) {
			a.closure_(a.asSet, f, TEST_BREADTH_FIRST)
		} else {
			a.flatten_(f, TEST_BREADTH_FIRST)
		}
	}

	// TODO: fix problem with alreadySeen, which is not the same during the whole traversal... but it may already deal with cycles... adding an asOrderedSet at the end may be enough
	def static <E> IBox<E> closure_(IBox<E> a, ISet<E> alreadySeen, (E)=>IBox<E> f, boolean breadthFirst) {
		if(breadthFirst) {
			a.concat(
				a.collectMutable[
					if(it == null) {
						IBox.SEQUENCE as IBox<E>
					} else {
						val targets = f.apply(it).asOrderedSet
						targets.minus(
							alreadySeen
						).closure_(alreadySeen.union(targets).asSet, f, breadthFirst)
					}
				]
			)
		} else {// depth-first
			a.collectMutable[
				if(it == null) {
					IBox.SEQUENCE as IBox<E>
				} else {
					val targets = f.apply(it).asOrderedSet.minus(
						alreadySeen
					)
					factory.createOne(it).concat(
						targets.closure_(alreadySeen.union(targets).asSet, f, breadthFirst)
					)
				}
			]
		}
	}

	def static <E> IOrderedSet<E> minus(IOrderedSet<E> left, ISet<E> right) {
//*		// by composition
		left.minus1(right)
/*/		// ad-hoc
		left.minus2(right)
/**/
	}

	def static <E> IOrderedSet<E> minus1(IOrderedSet<E> left, ISet<E> right) {
		left.selectMutable[
			right.excludes(it)
		].asOrderedSet
	}

	def static <E> IOne<Boolean> excludes(ISet<E> box, E element) {
/*
		// fails with exception on ex2... bug in AOF? TODO: debug
		box.union(factory.createOne(element)).size.zipWith(box.size)[$0 != $1].asOne(false)
/*/
		box.select[it == element].isEmpty
/**/
	}

	// TODO:
	//	- test
	//	- keep order
	//	- bidir?
	def static <E> IOrderedSet<E> minus2(IOrderedSet<E> left, ISet<E> right) {
		val ret = factory.createOrderedSet()
		val inLeft = new HashSet<E>(left.toSet)
		val inRight = new HashSet<E>(right.toSet)
		left.filter[
			!inRight.contains(it)
		].forEach[
			ret.add(it)
		]
		left.addObserver(new DefaultObserver<E> {
			override added(int index, E element) {
				if(!inRight.contains(element) && !inLeft.contains(element)) {
					if(index == 0) {	// hack to keep first element first... but we really need to actually keep order
						ret.add(0, element)
					} else {
						ret.add(element)
					}
				}
				inLeft.add(element)
			}
			override moved(int newIndex, int oldIndex, E element) {
				// no impact
			}
			override removed(int index, E element) {
				inLeft.remove(element)
				ret.remove(element)
			}
			override replaced(int index, E newElement, E oldElement) {
				removed(index, oldElement)
				added(index, newElement)
			}
		})
		right.addObserver(new DefaultObserver<E> {
			override added(int index, E element) {
				if(!inRight.contains(element) && inLeft.contains(element)) {
					inRight.add(element)
					ret.remove(element)
				}
			}
			override moved(int newIndex, int oldIndex, E element) {
				// no impact
			}
			override removed(int index, E element) {
				inRight.remove(element)
				if(inLeft.contains(element)) {
					ret.add(element)
				}
			}
			override replaced(int index, E newElement, E oldElement) {
				removed(index, oldElement)
				added(index, newElement)
			}
		})
		ret
	}

	def static <E> IBox<E> flatten_(IBox<E> a, (E)=>IBox<E> f, boolean breadthFirst) {
		if(breadthFirst) {
			a.concat(
				a.collectMutable[
					if(it == null) {
						IBox.SEQUENCE as IBox<E>
					} else {
						f.apply(it).flatten_(f, breadthFirst)
					}
				]
			)
		} else {// depth-first
			a.collectMutable[
				if(it == null) {
					IBox.SEQUENCE as IBox<E>
				} else {
					factory.createOne(it).concat(
						f.apply(it).flatten_(f, breadthFirst)
					)
				}
			]
		}
	}

	def static showPassiveClosure(Node tree) {
		println('''pasv: «closure(tree).map[it.label.get]»''')
	}

	def static closure(Node tree) {
		// TODO: add alreadyTraversed Set
		closure_(tree, new LinkedHashSet<Node>)
	}

	def static Collection<Node> closure_(Node tree, Collection<Node> ret) {
		if(ret.contains(tree)) {
			ret
		} else {
			ret.add(tree)
			tree.children.forEach[child |
				closure_(child, ret)
			]
			ret
		}
	}
}