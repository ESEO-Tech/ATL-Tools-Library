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

package fr.eseo.atol.gen

import com.google.common.collect.ImmutableList
import com.google.common.collect.ImmutableMultiset
import com.google.common.collect.ImmutableSet
import java.util.Collection
import java.util.function.Consumer
import java.util.function.Function
import java.util.function.Supplier
import javafx.beans.property.StringProperty
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBag
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.IObserver
import org.eclipse.papyrus.aof.core.IOne
import org.eclipse.papyrus.aof.core.IOption
import org.eclipse.papyrus.aof.core.IOrderedSet
import org.eclipse.papyrus.aof.core.ISequence
import org.eclipse.papyrus.aof.core.ISet
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver

abstract class AbstractRule {

//	new (Metaclass ...outTypes, (ImmutableList<Object>, ImmutableList<Object>) => ImmutableList<Object> lambda) {
//		this.outTypes = outTypes
//		this.lambda = lambda
//	}

	def void register1To1(Object in, Object out)

	def void register(Object...elems)

	static def <=>(StringProperty left, IBox<String> right) {
		left.set(right.get(0))
		right.addObserver(new IObserver<String>() {
			var disabled = false
			
			override added(int index, String element) {
				if (!disabled)
					left.set(element)
			}
			
			override isDisabled() {
				this.disabled
			}
			
			override moved(int newIndex, int oldIndex, String element) {
				if (!disabled)
					left.set(element)
			}
			
			override removed(int index, String element) {
				if (!disabled)
					left.set("")
			}
			
			override replaced(int index, String newElement, String oldElement) {
				if (!disabled)
					left.set(newElement)
			}
			
			override setDisabled(boolean disabled) {
				this.disabled = disabled
			}
			
		})
		left.addListener[
			right.set(0, left.value)
		]
	}

	static def <E> debug(E e, String msg) {
		println('''«msg»: «e»''')
		e
	}

	static def <E> debug(IBox<E> e, String msg) {
		e.inspect('''«msg»: ''')
	}

	// TODO: mutable inspect?
	static def <E> debug(IBox<E> e, IBox<String> msg) {
		e.inspect('''«msg.get(0)»: ''')
	}

	static def <E, R> R let(E e, Function<E, R> f) {
		f.apply(e)
	}

	static def <E> letStat(E e, Consumer<E> f) {
		f.accept(e)
	}

	static def <R> R wrap(Supplier<R> s) {
		s.get
	}

	static def <E> E throwException(Exception e) {
		throw e
	}

	static def <E> E autoCast(Object o) {
		o as E
	}

	static def <E> emptyBAG() {
		IBox.BAG as IBox<E>
	}

	static def <E> emptyOrderedSet() {
		IBox.ORDERED_SET as IBox<E>
	}

	static def <E> emptySequence() {
		IBox.SEQUENCE as IBox<E>
	}

	static def <E> emptySet() {
		IBox.SET as IBox<E>
	}

	static def <E> emptyOption() {
		IBox.OPTION as IBox<E>
	}

	public static val FALSE = AOFFactory.INSTANCE.createOne(false)

	public static val TRUE = AOFFactory.INSTANCE.createOne(true)

	static def <E> IOne<Collection<E>> asImmutable(IBox<E> it) {
		val ret = AOFFactory.INSTANCE.createOne(immutableCollection)
		addObserver(new DefaultObserver<E> {
			override added(int index, Object element) {
				ret.set(immutableCollection)
			}

			override moved(int newIndex, int oldIndex, Object element) {
				ret.set(immutableCollection)
			}

			override removed(int index, Object element) {
				ret.set(immutableCollection)
			}

			override replaced(int index, Object newElement, Object oldElement) {
				ret.set(immutableCollection)
			}
		})
		ret
	}

	private static def <E> Collection<E> immutableCollection(IBox<E> b) {
		switch b {
			IBag<?>: ImmutableMultiset.copyOf(b)
			IOne<?>, IOption<?>,					// singletons can be mapped to list
			ISequence<?>: ImmutableList.copyOf(b)
			ISet<?>,
			IOrderedSet<?>: ImmutableSet.copyOf(b)	// ImmutableSets preserve ordering
			default: throw new UnsupportedOperationException
		}
	}

	// Similar to IBox.asOne(default), but does not change the default value if already a one
	def static <E> IOne<E> asOneD(IBox<E> it, E defaultDefault) {
		if(it instanceof IOne<?>) {
			it as IOne<E>
		} else {
			it.asOne(defaultDefault)
		}
	}
}
