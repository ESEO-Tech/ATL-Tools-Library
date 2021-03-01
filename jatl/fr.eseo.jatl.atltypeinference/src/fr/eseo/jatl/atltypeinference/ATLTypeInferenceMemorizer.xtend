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
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.m2m.atl.common.ATL.ATLPackage
import org.eclipse.m2m.atl.common.OCL.OCLPackage
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@ATL2Java(libraries = #[
	"src/fr/eseo/jatl/atltypeinference/ATLTypeInferenceMemorizer.atl"
], metamodels = #[
	@Metamodel(name = "ATL", ePackages = #[ATLPackage, OCLPackage]),
	@Metamodel(name = "Ecore", ePackages = #[EcorePackage])
])
@FinalFieldsConstructor
class ATLTypeInferenceMemorizer extends ATLTypeInference {
//	@Accessors
//	val excludedMessagePrefixes = #{
//		""
//		,"var"
//		,"nav"
//		,"propType"
//		,"call"
//		,"op"
//		,"opu"
//		,"superOf"
//		,"contextType"
//		,"binding"
//		,"unify"
//		,"apply"
//		,"ifExp"
//		,"varExp"
//		,"mmop"
//		,"SHOWTYPE"
//	}

}