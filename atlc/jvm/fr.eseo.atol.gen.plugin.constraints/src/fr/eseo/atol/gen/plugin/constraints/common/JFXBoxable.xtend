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

import javafx.beans.property.ReadOnlyProperty
import javafx.beans.value.WritableNumberValue
import org.eclipse.xtend.lib.annotations.Data

import static extension fr.eseo.atol.gen.JFXUtils.*

@Data
class JFXBoxable extends Boxable {
	val Object jfxMM

	override toReadOnlyBox(Object it, String propertyName) {
		val prop = getProperty(propertyName).property as ReadOnlyProperty<Number>
		prop.toBox
	}

	override hasProperty(Object it, String name) {
		return 	class.methods.filter[it.name == name + "Property"].size > 0 ||
				jfxMM.class.methods.filter[it.name == name + "Property"].size > 0 ||
				jfxMM.class.methods.filter[it.name == "_" + name].size > 0
	}

	override getProperty(Object it, String name) {
		if (class.methods.filter[it.name == name + "Property"].size > 0) {
			val m =  class.getMethod('''«name»Property''')	
			new Property(m.invoke(it), null, null, true, this)
		}
		else if (jfxMM.class.methods.filter[it.name == name + "Property"].size > 0) {
			val m =  jfxMM.class.getMethod('''«name»Property''', #[it.class])
			new Property(m.invoke(jfxMM, it), null, null, true, this)
		}
		else {
			val m =  jfxMM.class.getMethod('''_«name»''', #[it.class])
			new Property(m.invoke(jfxMM, it), null, null, true, this)
		}
	}

	override <T> String getName(Object it) {
		switch it {
			ReadOnlyProperty<T>: {
				var p = it as ReadOnlyProperty<T>
				'''«p.generateId».«p.name»'''
			}
			default: {
				super.getName(it)
			}
		}
	}

	override setPropertyValue(Property it, Number value) {
		val prop = property
		switch (prop) {
			WritableNumberValue: {
				prop.value = value
			}
			default: {
				throw new UnsupportedOperationException('''Cannot set property «it» with value «value».''')
			}
		}
	}

	override getPropertyValue(Property it) {
		val prop = property
		switch (prop) {
			ReadOnlyProperty<Number>: {
				prop.value
			}
			default: {
				throw new UnsupportedOperationException('''Cannot get property of «it».''')
			}
		}
	}
}
