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

import java.util.HashMap
import java.util.Map
import java.util.function.BiConsumer
import org.eclipse.papyrus.aof.core.IBox

class TupleRule<S, T> extends AbstractRule {
	val Class<S> inTypes
	val Class<T> outTypes
	val BiConsumer<S, T> lambda

	new(Class<S> inTypes, Class<T> outTypes, BiConsumer<S, T> lambda) {
		this.inTypes = inTypes
		this.outTypes = outTypes
		this.lambda = lambda
	}

	public var BiConsumer<S, T> registerCustomTrace = null

	val Map<S,T> trace = new HashMap

	static def <S, T> IBox<T> collectTo(IBox<S> source, TupleRule<? extends S, ? extends T>...rules) {
		source.collect[S it |
			if(it === null) {
				return null
			}
			val in = it
			for(rule : rules) {
				if(rule.inTypes.isInstance(in)) {
					return (rule as TupleRule<S, T>).apply(in)
				}
			}
			throw new IllegalStateException('''No matching rule found for «it» among: «rules.toList»''')
		]
	}

	def apply(S in) {
		var out = trace.get(in)
		if(out === null) {
			out = outTypes.newInstance
			trace.put(in, out)
			if(registerCustomTrace !== null) {
				registerCustomTrace.accept(in, out)
			}
			lambda.accept(in, out)
		}
		out
	}

	def apply1To1(Object in_) {
		outTypes.fields.findFirst[true].get(
			in_.wrapIn.apply
		)
	}

	// to register "external" trace elements such as EBoolean to Boolean in Ecore2UML
//	def register(S in, T out) {
//		trace.put(in, out)
//	}

	// each tuple class has two constructor:
	// - one with arguments to wrap existing elements
	//		- for source tuples
	//		- for target tuples when wrapping pre-existing target elements to register trace links
	// - one without arguments to create new elements
	//		- for target tuples
	// This method find the wrapping constructor
	def <E> wrappingConstructor(Class<E> c) {
		c.constructors.findFirst[parameterCount > 0]
	}

	def bind(Object...elems) {
		val wrapped = elems.wrap
		lambda.accept(
			wrapped.key,
			wrapped.value
		)
	}

	def wrap(Object...elems) {
		val inc = inTypes.wrappingConstructor
		inc.newInstance(
			elems.take(inc.parameterCount).toList.toArray
		) as S ->
		outTypes.wrappingConstructor.newInstance(
			elems.drop(inc.parameterCount).toList.toArray
		) as T
	}

	// the first n (= number of args of inTypes constructor) elems correspond to the source elements,
	// and the rest to the target elements
	override register(Object...elems) {
		val wrapped = elems.wrap
		trace.put(
			wrapped.key,
			wrapped.value
		)
	}

	// 1-to-1 variant
	override register1To1(Object in, Object out) {
		trace.put(
			in.wrapIn,
			outTypes.constructors.findFirst[true].newInstance(out) as T
		)
	}

	def wrapIn(Object in) {
		inTypes.constructors.findFirst[true].newInstance(in) as S
	}

	static def <E> <=>(IBox<E> left, IBox<E> right) {
		(left as IBox<Object>).bind(right.asBox(left) as IBox<Object>)
	}

	static def <E> Class<E> gen(Class<? extends E> c) {
		c as Class<E>
	}

}
