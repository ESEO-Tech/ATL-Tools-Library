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

import java.util.HashMap
import java.util.Map
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.IOption
import org.eclipse.papyrus.aof.core.IOrderedSet
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver
import org.eclipse.xtend.lib.annotations.Data

/*
 * Because IOrderedSet.delegate is an ArrayList, which has O(1) random access, we already have O(1) propagation.
 * We would not gain anything by doing "next" in addition to "previous" at the same time, and we would lose some
 * memory when only one is required.
 * If IOrderedSet.delegate was for instance a LinkedHashSet, which has O(n) random access, it would be more efficient
 * to do "next" & "previous" at the same time to have O(1) propagation.
 *
 * Remark: can only really work on OrderedSet, because: 1) requires ordering for the existence of a "previous" element
 * , and 2) unicity for the possibility to get a unique previous element from an element.
 *
 * In the following OCL examples, "oset" (unquoted) denotes a globally accessible OrderedSet(E).
 * 1- A solution that traverses the whole oset for each element:
 * context E def: previous : E =
 *	oset->iterate(e; acc : Tuple(prev:E,ret:E) = Tuple {prev = OclUndefined, ret = OclUndefined} |
 *		Tuple {
 *			ret =
 *				if e = self then
 *					acc.prev
 *				else
 *					acc.ret
 *				endif,
 *			prev = e
 *		}
 *	).ret
 * 2- A solution that computes a Map (to be used as in this class):
 * oset->iterate(e; acc : Tuple(prev:E,ret:Map(E,E)) = Tuple {prev = OclUndefined, ret = Map {} |
 *	Tuple {
 *		prev = e,
 *		ret = acc.ret.including(e, acc.prev)
 *	}
 * ).ret
 * 3- A solution that computes a Set of pairs (which should then be transformed into a Map, and used as in this class):
 * oset->iterate(e; acc : Tuple(prev:E,ret:Set(Tuple(fst:E,snd:E))) = Tuple {prev = OclUndefined, ret = Set {} |
 *	Tuple {
 *		prev = e,
 *		ret = acc.ret->including(Tuple {fst = e, snd = acc.prev})
 *	}
 * ).ret
 * 4- A solution that also computes a Set of pairs (with same remark):
 * oset->zip(oset->prepend(OclUndefined))
 * 5- A solution that computes a Map using a new operation:
 * oset->mapTo(oset->prepend(OclUndefined))
 *	=> could have interesting properties if changes were applied on both sources simultaneously.
 *
 *
 * Open questions: how to make one (or several) of these examples active? With which algorithmic complexity compared
 * to this class?
 *
 * Could we define a fold/iterate-like operation for which incrementality would be simpler?
 * fold		:: (a -> b -> a) -> a -> [b] -> a
 * afold	:: (a -> b -> a) -> a -> (a -> b -> c) -> [b] -> [c]
 * afold stateUpdater init collector col   = snd $ foldl (\acc e -> (stateUpdater (fst acc) e, (snd acc) ++ [collector (fst acc) e])) (init, []) col
 *	oset->afold
 *		(e; acc : E = OclUndefined |	
 *			e
 *		)
 *		(e, acc |
 *			acc
 *		)
 */
@Data
class LinkedBox<E> {
	val Map<E, IOption<E>> previousOptions
	val IBox<E> OPT = AOFFactory.INSTANCE.createOption

	def previous(E e) {
		previousOptions.computeIfAbsent(e)[
			AOFFactory.INSTANCE.createOption
		]
	}

	def previous(IBox<E> b) {
		b.collectMutable[
			it.previous ?: OPT
		]
	}

	static val unmodifiableObserver = new DefaultObserver<Object> {
		override added(int index, Object element) {
			error
		}

		override moved(int newIndex, int oldIndex, Object element) {
			error
		}

		override removed(int index, Object element) {
			error
		}

		override replaced(int index, Object newElement, Object oldElement) {
			error
		}

		def private void error() {
			throw new UnsupportedOperationException("LinkedBox is not bidirectional")
		}
	}

	static val Map<IBox<?>, LinkedBox<?>> cache = new HashMap

	def static <E> LinkedBox<E> toLinkedBox(IOrderedSet<E> list) {
		var ret = cache.get(list) as LinkedBox<E>
		if(ret === null) {
			val previousOptions = new HashMap<E, IOption<E>>
			extension val linkedBox = new LinkedBox(previousOptions)
			ret = linkedBox
			cache.put(list, ret)

			var E previous = null
			for(e : list) {
//				val opt = AOFFactory.INSTANCE.<E>createOption
//				opt.addObserver(unmodifiableObserver as IObserver<E>)	// TODO: only possible if we allow OUR changes
				if(previous !== null) {
//					opt.add(previous)
					linkedBox.previous(e).add(previous)
				}
				previous = e
			}

			list.addObserver(new DefaultObserver<E> {
				override added(int index, E element) {
//					val opt = AOFFactory.INSTANCE.<E>createOption
//					previousOptions.put(element, opt)
					val opt = linkedBox.previous(element)

					if(index < list.length - 1) {
						list.get(index + 1).previous.set(element)
					}
					if(index > 0) {
						opt.add(list.get(index - 1))
					}
				}

				override moved(int newIndex, int oldIndex, E element) {
					val oldNext = oldIndex + if(newIndex > oldIndex) 0 else 1
					if(oldNext < list.length) {
						list.get(oldNext).previous.set(list.get(oldNext - 1))
					}
					list.get(newIndex + 1).previous.set(element)

					if(newIndex > 0) {
						element.previous.set(list.get(newIndex - 1))
					} else {
						element.previous.clear
					}
				}

				override removed(int index, E element) {
					if(index < list.length) {	// list is already one element smaller
						val nextPrevious = list.get(index).previous
						val oldPrevious = element.previous
						nextPrevious.copyContents(oldPrevious)
					}
					previousOptions.remove(element)
					if(index == 0 && list.length !== 0) {
						list.get(0).previous.clear
					}
				}

				private def <E> copyContents(IOption<E> to, IOption<E> from) {
						if(from.length === 0) {
							to.clear
						} else {
							to.set(from.get)
						}
				}

				override replaced(int index, E newElement, E oldElement) {
					val oldPrevious = oldElement.previous
					val opt = AOFFactory.INSTANCE.<E>createOption
					opt.copyContents(oldPrevious)
					previousOptions.put(newElement, opt)
					previousOptions.remove(oldElement)

					if(index < list.length - 1) {
						list.get(index + 1).previous.set(newElement)
					}
				}
			})
		}
		ret
	}

	// test-only
	// TODO: extract into proper test class
	def static void main(String[] args) {
		new TestInts(AOFFactory.INSTANCE.createOrderedSet(0, 1, 2, 3, 4, 5, 6, 7))
	}

	static class Test<E> {
		extension val LinkedBox<E> linkedBox
		new(IOrderedSet<E> a) {
			println("Initialization")
			a.inspect('''	a: ''')
			linkedBox = a.toLinkedBox
			for(e : a) {
				e.inspectPrevious
			}
		}

		private def inspectPrevious(E e) {
			e.previous.inspect('''	«e».previous: ''')
		}

		def rm(IBox<E> box, E e) {
			println('''Removing «e»''')
			box.remove(e)
		}

		def ad(IBox<E> box, E e) {
			println('''Appending «e»''')
			box.add(e)
			e.inspectPrevious
		}

		def pd(IBox<E> box, E e) {
			println('''Prepending «e»''')
			box.add(0, e)
			e.inspectPrevious
		}

		def ad(IBox<E> box, int index, E e) {
			println('''Inserting «e»''')
			box.add(index, e)
			e.inspectPrevious
		}

		def st(IBox<E> box, int index, E e) {
			println('''Setting «index», «e»''')
			box.set(index, e)
			e.inspectPrevious
		}

		def mv(IBox<E> box, int newIndex, int oldIndex) {
			println('''Moving «newIndex», «oldIndex»''')
			box.move(newIndex, oldIndex)
		}
	}

	static class TestInts extends Test<Integer> {
		new(IOrderedSet<Integer> a) {
			super(a)

			a.rm(4)
			a.rm(0)
			a.rm(7)

			a.ad(10)
			a.rm(6)

			a.pd(-1)

			a.mv(2, 4)

			a.st(0, -2)
			a.st(3, 4)
			a.st(5, 11)

			a.rm(3)

			a.mv(0, 1)
			a.mv(1, 4)
			a.mv(0, 4)
		}
	}
}
