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

import fr.eseo.jatl.EcoreHelpers
import fr.eseo.jatl.OCLLibrary
import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.m2m.atl.common.ATL.ATLPackage
import org.eclipse.m2m.atl.common.OCL.OCLPackage
import org.eclipse.xtend.lib.annotations.Data

@EcoreHelpers(packages = #[
   	ATLPackage,
   	OCLPackage,
   	EcorePackage
])
@Data
class ATLTypeInferenceMetamodels implements OCLLibrary {
	val Map<String, List<Resource>> models

	override Iterable<Resource> getModel(String name) {
		models.get(name)
	}
	
	override getExcludedMessagePrefixes() {
		#{}
	}
	
}