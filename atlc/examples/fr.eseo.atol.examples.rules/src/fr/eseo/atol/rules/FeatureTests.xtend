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

package fr.eseo.atol.rules

import fr.eseo.atol.gen.ATOLGen
import fr.eseo.atol.gen.ATOLGen.Metamodel
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.uml2.uml.LiteralInteger
import org.eclipse.uml2.uml.UMLPackage
import org.eclipse.uml2.uml.resource.UML402UMLResource

@ATOLGen(transformation="FeatureTests.atl",metamodels=#[
	@Metamodel(name="UML", impl=UML),
	@Metamodel(name="Ecore", impl=Ecore)
])
class FeatureTests {
	def static void main(String[] args) {
		val resourceFactoryRegistry = Resource.Factory.Registry.INSTANCE	// rs.resourceFactoryRegistry
		resourceFactoryRegistry.extensionToFactoryMap.put(
			"uml",
			UML402UMLResource.Factory.INSTANCE
		)
		val rs = new ResourceSetImpl
		rs.packageRegistry.put(UMLPackage.eINSTANCE.nsURI, UMLPackage.eINSTANCE)
		val r = rs.getResource(URI.createFileURI("testcases/uml/uml-out-expected.uml"), true)
		extension val featureTests = new FeatureTests
		r.allContents.filter(LiteralInteger).forEach[
			println(_ifTest)
		]
	}
}