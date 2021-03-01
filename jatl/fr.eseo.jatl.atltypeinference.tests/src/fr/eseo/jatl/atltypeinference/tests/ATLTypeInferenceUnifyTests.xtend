/****************************************************************
 *  Copyright (C) 2021 ESEO, Université d'Angers 
 *
 *  This program and the accompanying materials are made
 *  available under the terms of the Eclipse Public License 2.0
 *  which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 *  Contributors:
 *    - Frédéric Jouault
 *
 *  version 1.0
 *
 *  SPDX-License-Identifier: EPL-2.0
 ****************************************************************/
 
 package fr.eseo.jatl.atltypeinference.tests

import fr.eseo.jatl.atltypeinference.ATLTypeInference
import java.util.Collections
import org.eclipse.m2m.atl.common.OCL.OCLFactory
import org.junit.Test
import static org.junit.Assert.assertEquals
import com.google.common.collect.ImmutableMap

class ATLTypeInferenceUnifyTests {
	extension val ATLTypeInference ati = new ATLTypeInference(Collections.emptyMap)
	@Test
	def void test1() {
		val a = OCLFactory.eINSTANCE.createCollectionType => [
			elementType = OCLFactory.eINSTANCE.createOclAnyType
		]
		val b = #{
			"ttype" ->"Collection",
			"elementType" -> Object
		}
		assertEquals(Collections.emptyMap, a.unify(b))
	}

	val OclAnyType = OCLFactory.eINSTANCE.createOclAnyType
	val OclAnyType2 = OCLFactory.eINSTANCE.createOclAnyType	// different instance for tests that need to make sure they are considered equivalent

//	@Test
//	def void test2() {
//		val a = OCLFactory.eINSTANCE.createCollectionType => [
//			elementType = OclAnyType
//		]
//		val b = OCLFactory.eINSTANCE.createCollectionType => [
//			elementType = OclAnyType2
//		]
//		assertEquals(Collections.emptyMap, a.unify(b))
//	}

	val tpModel = OCLFactory.eINSTANCE.createOclModel => [
		name = "TP"
	]
	@Test
	def void test3() {
		val a = OCLFactory.eINSTANCE.createCollectionType => [
			elementType = OCLFactory.eINSTANCE.createOclModelElement => [
				model = tpModel
				name = "A"
			]
		]
		val b = #{
			"ttype" -> "Collection",
			"elementType" -> Object
		}
		assertEquals(ImmutableMap.of("A", Object), a.unify(b))
	}
}