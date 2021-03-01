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
 
 package fr.eseo.jatl.atltypeinference

import fr.eseo.jatl.ATL2Java
import fr.eseo.jatl.ATL2Java.Metamodel
import java.util.Collection
import java.util.Map
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.m2m.atl.common.ATL.ATLPackage
import org.eclipse.m2m.atl.common.OCL.Attribute
import org.eclipse.m2m.atl.common.OCL.OCLPackage
import org.eclipse.m2m.atl.common.OCL.OclFeature
import org.eclipse.m2m.atl.common.OCL.Operation
import org.eclipse.m2m.atl.common.OCL.OperationCallExp
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Delegate
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

/*
 * TODO:
 *	- make sure the ATL transformation still works in ATL
 *	- dispatching between attribute helpers and model element properties
 *	- target pattern element in XML syntax
 */
@ATL2Java(libraries = #[
	"src/fr/eseo/jatl/atltypeinference/ATLTypeInference.atl",
	"src/fr/eseo/jatl/atltypeinference/ATLTypeInferenceToEcore.atl",
	"src/fr/eseo/jatl/atltypeinference/ATLTypingHelpers.atl"
], metamodels = #[
	@Metamodel(name = "ATL", ePackages =#[ATLPackage, OCLPackage]),
	@Metamodel(name = "Ecore", ePackages = #[EcorePackage])
])
@FinalFieldsConstructor
class ATLTypeInference extends ATLTypeInferenceMetamodels implements FloatingVariableResolver {

	@Delegate
	@Accessors
	extension var FloatingVariableResolver floatingVariableResolver = new FloatingVariableResolver {}

	@Accessors
	val excludedMessagePrefixes = #{
		""
		,"var"
		,"nav"
		,"propType"
		,"call"
		,"op"
		,"opu"
		,"superOf"
		,"contextType"
		,"binding"
		,"unify"
		,"apply"
		,"ifExp"
		,"varExp"
		,"mmop"
		,"SHOWTYPE"
	}

	def convType(Object it) {
		switch it {
			EClassifier: instanceClass
			Map<String, ?>: {
				val ttype = get("ttype")
				switch ttype {
					case "Collection": Collection
					Class<?>: ttype
					default: null	// TODO: "Tuple"
				}
			}
			default: it as Class<?>
		}
	}

	// model-specific tuples
	def elementType(Object it) {
		switch it {
			Map<?, ?>: get("elementType")
			default: throw new UnsupportedOperationException("elementType")
		}
	}

	// misc

	def keyType(Object it) {
		switch it {
			Map<?, ?>: get("keyType")
			default: throw new UnsupportedOperationException("keyType")
		}
	}

	def valueType(Object it) {
		switch it {
			Map<?, ?>: get("valueType")
			default: throw new UnsupportedOperationException("valueType")
		}
	}

	def boolean isAssignableFrom(Object sup, Object sub) {
//		if(sup instanceof Map<?, ?>) {
//			if(sub instanceof Map<?, ?>) {
//				if(sup.get("ttype") == "Tuple" && sub.get("ttype") == "Tuple") {
//					println("Tuples");
//				}
//			}
//		}
		if(sup instanceof EClass) {
			if(sub instanceof EClass) {
				if(sup.instanceClass === null || sub.instanceClass === null) {
					// EClasses may fail convType when they have no instanceClass (because their metamodel code has not been generated)
					return sub == sup || sub.EAllSuperTypes.contains(sup)
				}
			}
		}
		val supc = sup.convType
		if(supc === Object) {
			return true
		}
		val subc = sub.convType
		if(supc === null || subc === null) {
			return false
		} 
		val ret = supc.isAssignableFrom(subc)
		ret
	}

	def name(Object it) {
		switch it {
			Map<?, ?>: get("name") as String
			EStructuralFeature: name
			EClassifier: name
			Class<?>: simpleName
			default: throw new UnsupportedOperationException("name")
		}
	}

	def int upper(Object it) {
		switch it {
			Map<?, ?>: get("upper") as Integer
			EStructuralFeature: upper
			default: throw new UnsupportedOperationException("upper")
		}
	}

	def name(Class<?> it) {
		simpleName
	}

	def name(OclFeature it) {
		switch it {
			Operation: name
			Attribute: name
		}
	}

	def Collection<String> literals(Object it) {
		switch it {
			Map<?, ?>: get("literals") as Collection<String>
			default: throw new UnsupportedOperationException("upper")
		}
	}

//	def Object operation(Object it) {
//		switch it {
//			Map<?, ?>: get("operation")
//			default: throw new UnsupportedOperationException("operation")
//		}
//	}

	def OperationCallExp call(Map<Object, Object> it) {
		get("call") as OperationCallExp
	}

	def boolean notFound(Map<Object, Object> it) {
		get("notFound") as Boolean
	}

	def eResource(EObject it) {
		eResource
	}

	def getURI(Resource it) {
		URI
	}
}