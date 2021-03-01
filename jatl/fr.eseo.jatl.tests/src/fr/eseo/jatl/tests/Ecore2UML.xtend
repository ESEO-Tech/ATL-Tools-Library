package fr.eseo.jatl.tests

import fr.eseo.jatl.ATL2Java
import fr.eseo.jatl.ATL2Java.Metamodel
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.uml2.uml.UMLPackage

@ATL2Java(libraries = #[
	"../atlc/examples/fr.eseo.atol.examples.rules/testcases/Ecore2UML.atl"
], metamodels = #[
	@Metamodel(name = "Ecore", ePackages = #[EcorePackage]),
	@Metamodel(name = "UML", ePackages = #[UMLPackage])
])
class Ecore2UML extends UMLEcore {
	
	override getExcludedMessagePrefixes() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override getModel(String name) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}