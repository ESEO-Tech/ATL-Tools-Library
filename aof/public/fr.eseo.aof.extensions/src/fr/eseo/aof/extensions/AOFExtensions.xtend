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

import java.util.WeakHashMap
import java.util.function.BiConsumer
import org.eclipse.emf.common.notify.Notifier
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.IMetaClass
import org.eclipse.papyrus.aof.core.IOne
import org.eclipse.papyrus.aof.core.IUnaryFunction
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver

interface AOFExtensions {
	def sum(IBox<Integer> b) {
		new Sum(b, 0, [$0+$1], [$0-$1]).result as IOne<Integer>
	}
	// for naming consistency
	def sumIntegers(IBox<Integer> it) {
		sum
	}
	def sumFloats(IBox<Float> b) {
		new Sum(b, 0.0f, [$0+$1], [$0-$1]).result as IOne<Float>
	}
	def sumDoubles(IBox<Double> b) {
		new Sum(b, 0.0d, [$0+$1], [$0-$1]).result as IOne<Double>
	}
	def <C> allContents(Notifier n, IMetaClass<C> c) {
		AllContents._allContents(n, c)
	}
	def <E> take(IBox<E> b, int n) {
		new Take(b, n).result
	}
	def <E> drop(IBox<E> b, int n) {
		new Drop(b, n).result
	}
	def <E> subSequence(IBox<E> b, int l, int u) {
		if(l > 1) {
			b.drop(l - 1)
		}
		b.take(u - l + 1)
	}
	def <E> sortedBy(IBox<E> b, IUnaryFunction<E, IBox<? extends Comparable<?>>>...bodies) {
		new SortedBy(b, bodies as IUnaryFunction<?, ?>[] as IUnaryFunction<E, IOne<? extends Comparable<?>>>[]).result
	}
	def <E, F> onceForEach(IBox<E> source, (E)=>F added, BiConsumer<E, F> removed, BiConsumer<E, F> readded) {
		val cache = new WeakHashMap
		source.forEach[
			// TODO: should we check for duplicates? or prevent duplicates from being in source box
			cache.put(it, added.apply(it))
		]
		source.addObserver(new DefaultObserver<E> {
			override added(int index, E element) {
				val f = cache.get(element)
				if(f === null) {
					cache.put(element, added.apply(element))
				} else {
					readded.accept(element, f)
				}
			}
			override moved(int newIndex, int oldIndex, E element) {
			}
			override removed(int index, E element) {
				val f = cache.get(element)
				removed.accept(element, f)
			}
			override replaced(int index, E newElement, E oldElement) {
			}
		})
	}
	def <E, K> selectBy(IBox<E> source, IBox<K> key, IUnaryFunction<E, IBox<K>> collector) {
		new SelectBy(source, key.asOne(null))[collector.apply(it).asOne(null)].result
	}
	def <E> reverse(IBox<E> it) {
		new Reverse(it).result
	}

	def <E> emptyBAG() {
		IBox.BAG as IBox<E>
	}

	def <E> emptyOrderedSet() {
		IBox.ORDERED_SET as IBox<E>
	}

	def <E> emptySequence() {
		IBox.SEQUENCE as IBox<E>
	}

	def <E> emptySet() {
		IBox.SET as IBox<E>
	}

	def <E> emptyOption() {
		IBox.OPTION as IBox<E>
	}

	def <E> emptyOne() {
		IBox.ONE as IBox<E>
	}

	// does not preserve order, and sends incorrect indices
	// does not cache the result of the collector, which must do it itself
	def <T, E> IBox<E> unorderedCollectMutable(IBox<T> it, IUnaryFunction<T, IBox<E>> collector) {
		val ret = AOFFactory.INSTANCE.createBag
		val innerObserver = new DefaultObserver<E> {
			override added(int index, E element) {
				ret.add(element)
			}
			override moved(int newIndex, int oldIndex, Object element) {
				// nothing to do
			}
			override removed(int index, E element) {
				// this may be costly
				ret.remove(element)
			}
			override replaced(int index, E newElement, E oldElement) {
				removed(-1, oldElement)
				added(-1, newElement)
			}
		}
		val outerObserver = new DefaultObserver<T> {
			override added(int index, T element) {
				val b = collector.apply(element)
				b.forEach[e |
					ret.add(e)
				]
				b.addObserver(innerObserver)
			}
			override moved(int newIndex, int oldIndex, Object element) {
				// nothing to do
			}
			
			override removed(int index, T element) {
				val b = collector.apply(element)
				b.removeObserver(innerObserver)
				b.forEach[
					ret.remove(it)
				]
			}
			
			override replaced(int index, T newElement, T oldElement) {
				removed(-1, oldElement)
				added(-1, newElement)
			}
			
		}
		addObserver(outerObserver)
		forEach[t |
			val b = collector.apply(t)
			b.forEach[e |
				ret.add(e)
			]
			b.addObserver(innerObserver)
		]
		return ret
	}
}