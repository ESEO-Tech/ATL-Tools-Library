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

import org.eclipse.papyrus.aof.core.IBox

import static extension java.lang.Enum.*

class MetamodelUtils {
	// TODO: add an option to AOFAccessors to do this in the generated accessor methods?
	def static <E, T extends Enum<T>> enumConverterBuilder((E)=>IBox<T> accessor, Class<T> enumeration) {
		enumConverterBuilder(accessor, enumeration, "_LITERAL")
	}

	def static <E, T extends Enum<T>> enumConverterBuilder((E)=>IBox<T> accessor, Class<T> enumeration, String suffix) {
		[E e |
			accessor.apply(e).collect([it?.toString], [
				if(it === null) {
					null
				} else {
					enumeration.valueOf('''«it.toUpperCase»«suffix»''')
				}
			])
		]
	}

	// TODO: add an option to AOFAccessors to do this in the generated accessor methods?
	static def <E, R> oneDefault(R defaultValue, (E)=>IBox<R> accessor) {
		[E e |
			accessor.apply(e).asOne(defaultValue)
		]
	}

	static def <E> boolOneDefault((E)=>IBox<Boolean> accessor) {
		oneDefault(false, accessor)
	}

}