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

import java.util.HashMap
import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.xtend.lib.annotations.Data

@Data
class EMFBoxable extends Boxable {
	val Object emfMM
	val Map<Object, String> nameCache = new HashMap
	
	override toReadOnlyBox(Object o, String propertyName) {
		val b = getProperty(o, propertyName).property as IBox<Number>
		b
	}

	override <T> String getName(Object it) {
		'''«nameCache.get(it)»'''
	}

	def getMethod(EObject it, String name) {
		val validTypes = #{int, float, double, long, Integer, Double, Float}
		val attribute = eClass.EAllAttributes.filter[it.name == name].last

		if (attribute === null) {
			return #[]
		}

		if (validTypes.exists[
			attribute.EType.instanceClass == it
		]) {
			return emfMM.class.declaredMethods.filter[
						it.name == "_" + name
					]
		}
		else {
			return #[]
		}
	}

	override hasProperty(Object it, String name) {
		if (it instanceof EObject) {
			return getMethod(name).size > 0
		}
		else {
			return false
		}
	}

	override getProperty(Object it, String name) {
		val eIt = it as EObject
		val m = getMethod(eIt, name).get(0)
		val r = m.invoke(emfMM, it)
		val src = it as EObject
		if (src.eResource !== null && !nameCache.containsKey(r)) { //TODO: when removing an element its resource is null
			val propName = src.eResource.getURIFragment(src) + "." + name
			nameCache.put(r, propName)
		}
		new Property(r, null, null, true, this)
	}

	override setPropertyValue(Property it, Number value) {
		val p = property
		switch (p) {
			IBox<Number>: {
				p.set(0, value)
			}
			default: {
				throw new UnsupportedOperationException('''Cannot set value '«value»' to «it».''')
			}
		}
	}

	override getPropertyValue(Property it) {
		val p = property
		switch (p) {
			IBox<Number>: {
				p.get(0)
			}
			default: {
				throw new UnsupportedOperationException('''Cannot get value of «it».''')
			}
		}
	}
}
