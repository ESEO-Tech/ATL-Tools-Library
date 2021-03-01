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

import com.google.common.collect.HashBasedTable
import com.google.common.collect.Table
import java.util.HashMap
import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.emf.EMFFactory
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.emf.common.util.EList

@Data
class RelationBoxable extends Boxable {
	// Table<Row, Col, Val>
	Table<EClass, EObject, Integer> objectIds = HashBasedTable.create
	Table<EClass, Integer, EObject> inverseObjectId = HashBasedTable.create
	Table<EObject, String, EMFProperty> propertyCache = HashBasedTable.create
	val Map<EObject, String> nameCache = new HashMap

	@Data
	static class EMFProperty extends Property {
		String propertyName
	}

	def register(EObject o) {
		if (!objectIds.contains(o.eClass, o)) {
			val id = getMaxId(o.eClass)
			inverseObjectId.put(o.eClass, id, o)
			objectIds.put(o.eClass, o, id)
		}
		return objectIds.get(o.eClass, o)
	}

	def debug() {
		'''
		«FOR r : objectIds.rowKeySet»
			«r.name»
				«FOR v : objectIds.row(r).entrySet»
					«v.key.name» -> «v.value»
				«ENDFOR»
		«ENDFOR»
		'''
	}

	def getIdOf(EObject it) {
		if (!objectIds.contains(eClass, it)) {
			throw new UnsupportedOperationException('''Object «it» not found.''')
		}
		objectIds.get(eClass, it)
	}

	def getMaxId(EClass c) {
		objectIds.row(c).size
	}

	def EClass getReferencedEClass(Object it, String name) {
		val eIt = it as EObject
		if (name === null) { // the property is the object itself
			eIt.eClass
		}
		else {
			eIt.eClass.EAllReferences.findFirst[it.name == name].EReferenceType
		}
	}

	//FIXME : this crashes if the property is not initialized
	def EObject getReference(Object it, String name) {
		val eIt = it as EObject
		if (name === null) { // the property is the object itself
			eIt
		}
		else {
			val eRef = eIt.eClass.EAllReferences.filter[it.name == name]
			if (eRef.size == 0) {
				throw new UnsupportedOperationException('''Cannot find relation «name» on «it»''')
			}
			else {
				return eIt.eGet(eRef.get(0)) as EObject
			}
		}
	}

	override <T> String getName(Object it) {
		'''«nameCache.get(it)»'''
	}

	val toReadOnlyBoxCache = new HashMap<Pair<Object, String>, IBox<Number>>
	override toReadOnlyBox(Object o, String name) {
		if (toReadOnlyBoxCache.containsKey(o -> name)) {
			toReadOnlyBoxCache.get(o -> name)
		}
		else {
			val ref = getProperty(o, name).property as EObject
			val id = objectIds.get(ref.eClass, ref)
			var IBox<Number> res

			if (name === null) { // dealing with self reference, it will never change
				res = AOFFactory.INSTANCE.createOne(id)
			}
			else {
				res = EMFFactory.INSTANCE.createPropertyBox(o, name).select(EObject).collect[
					//TODO: check if correct
					objectIds.get(eClass, it)
				]
			}
			toReadOnlyBoxCache.put(o -> name, res)
			res
		}
	}

	override getProperty(Object it, String name) {
		val eIt = it as EObject
		val foreignEClass = if (name === null) eIt.eClass else eIt.getReferencedEClass(name)

		if (eIt.eResource !== null) {
			// register all contents of the resource
			eIt.eResource.allContents.forEach[
				register
			]
		}
		else {
			// only register the element
			//TODO : should also register properties of the element
			register(eIt)
		}

		if (!nameCache.containsKey(it)) {
			var String n
			if (eIt.eResource !== null) {
				n = eIt.eResource.getURIFragment(eIt)
			}
			else {
				n = eIt.class.simpleName
			}
			nameCache.put(eIt, '''«n»«IF name !== null».«name»«ENDIF»''')
		}
		if (!propertyCache.contains(it, name)) {
			val prop = new EMFProperty(eIt, [0], [getMaxId(foreignEClass)-1], false, this, name)
			propertyCache.put(eIt, name?:'self', prop)
		}

		propertyCache.get(eIt, name?:'self')
	}

	def hasPath(EObject it, String name) {
		eClass.hasPath(name)
	}

	def hasPath(EClass it, String name) {
		if(name === null || name.empty) {
			return true
		}
		var t = it
		var reachedDataType = false
		for(p : name.split('''\.''')) {
			if(reachedDataType) {
				return false
			}
			val nt = t.getEStructuralFeature(p).EType
			switch nt {
				EClass: t = nt
				default: reachedDataType = true
			}
		}
		return true
	}

	override hasProperty(Object it, String name) {
		switch it {
			EObject: hasPath(name)
			default: false
		}
	}

	override setPropertyValue(Property it, Number value) {
		val eProp = it as EMFProperty
		val eIt = eProp.property as EObject
		val eRefs = eIt.eClass.EAllReferences.filter[
			it.name == eProp.propertyName
		]
		val eRef = eRefs.get(0)
		val targetType = eIt.eClass.EAllReferences.filter[it.name == eProp.propertyName].get(0).EType
		if (!inverseObjectId.contains(targetType, value)) {
			throw new UnsupportedOperationException('''Cannot set value «value» to «eIt».''')
		}
		val newRef = inverseObjectId.get(targetType, value)
		eIt.eSet(eRef, newRef)
	}

	override getPropertyValue(Property it) {
		val eProp = it as EMFProperty
		val eIt = eProp.property as EObject
		val ref = getReference(eIt, eProp.propertyName)
		if (ref === null) {
			null
		}
		else {
			objectIds.get(ref.eClass, ref)
		}
	}

	def List<Pair<Integer, Integer>> getCandidates(EObject it, String relationName, String propertyPath) {
		if (it === null) {
			return #[]
		}
		val reference = eClass.EAllReferences.filter[name==relationName].last.EReferenceType
		val candidates = objectIds.row(reference)

		candidates.entrySet.map[
			value -> key.navigate(propertyPath).intValue
		].clone
	}

	def Number navigate(EObject it, String path) {
		var obj = it
		val navigations = path.split('''\.''')

		if (path.empty) {
			return obj.idOf
		}

		for (n : navigations.take(navigations.size - 1)) {
			val ref = obj.eClass.getEStructuralFeature(n)
			obj = obj.eGet(ref) as EObject
		}
		val attribute = obj.eClass.getEStructuralFeature(navigations.last)
		return obj.eGet(attribute) as Number
	}
}
