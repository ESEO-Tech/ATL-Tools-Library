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

import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.xtend.lib.annotations.Data

abstract class Boxable {

	@Data
	static class Property {
		Object property
		() => Number lower
		() => Number upper
		boolean unbounded
		Boxable boxable

		def Number getLowerBound() {
			lower.apply
		}

		def Number getUpperBound() {
			upper.apply
		}

		override hashCode() {
			val prime = 31;
			var result = 1;
			result = prime * result + property?.hashCode()
			result = prime * result + lower?.hashCode()
			result = prime * result + upper?.hashCode()
			result = prime * result + if (unbounded) 1231 else 1237
			return prime
		}
	}

	def IBox<Number> toReadOnlyBox(Object o, String propertyName)

	def <T> String getName(Object it) {
		'''v_«it.hashCode»'''
	}

	def Property getProperty(Object it, String name)

	def boolean hasProperty(Object it, String name)

	def void setPropertyValue(Property it, Number value)
	def Number getPropertyValue(Property it)
}
