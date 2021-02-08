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
import java.util.HashMap
import java.util.Map
import java.util.function.BiConsumer
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.IMetaClass
import org.eclipse.xtend.lib.annotations.Data

@Data
class ListRule extends AbstractRule {
	val ImmutableList<IMetaClass<?>> inTypes
	val ImmutableList<IMetaClass<?>> outTypes
	val BiConsumer<ImmutableList<Object>, ImmutableList<Object>> lambda

	// TODO: fix this, as it will not work with two rules matching the same list of elements
	val Map<ImmutableList<Object>,ImmutableList<Object>> trace = new HashMap

	static def IBox<ImmutableList<Object>> collectTo(IBox<?> source, ListRule...rules) {
		source.collect[Object it |
			if(it === null) {
				return null
			}
			val in = switch it {
					ImmutableList<Object>: it
					default: ImmutableList.<Object>of(it)
				}
			for(rule : rules) {
				if(rule.inTypes.size === in.size && rule.inTypes.indexed.forall[it.value.isInstance(in.get(it.key))]) {
					return rule.apply(in)
				}
			}
			throw new IllegalStateException('''No matching rule found for «it» among: «rules.toList»''')
		]
	}

	def apply(ImmutableList<Object> in) {
		var out = trace.get(in)
		if(out === null) {
			out = new ImmutableList.Builder<Object>.addAll(outTypes.map[it.newInstance]).build
			trace.put(in, out)
			lambda.accept(in, out)
		}
		out
	}

	def apply1To1(Object in_) {
		ImmutableList.of(in_).apply.get(0)
	}

	// to register "external" trace elements such as EBoolean to Boolean in Ecore2UML
	def register(ImmutableList<Object> in, ImmutableList<Object> out) {
		trace.put(in, out)
	}

	override register(Object...elems) {
		trace.put(
			ImmutableList.copyOf(elems.take(inTypes.size)),
			ImmutableList.copyOf(elems.drop(inTypes.size))
		)
	}

	// 1-to-1 variant
	override register1To1(Object in, Object out) {
		trace.put(ImmutableList.of(in), ImmutableList.of(out))
	}

	static def <=>(IBox<?> left, IBox<?> right) {
		(left as IBox<Object>).bind(right.asBox(left) as IBox<Object>)
	}

}
