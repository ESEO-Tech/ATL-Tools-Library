package fr.eseo.jatl.tests

import fr.eseo.jatl.EcoreHelpers
import fr.eseo.jatl.OCLLibrary
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.uml2.uml.UMLPackage

@EcoreHelpers(packages = #[
	UMLPackage,
	EcorePackage
], atolCompatibility = true)
abstract class UMLEcore implements OCLLibrary {
	
}