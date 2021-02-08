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

package fr.eseo.atol.gen

import org.eclipse.m2m.atl.emftvm.compiler.AtlResourceFactoryImpl
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.common.util.URI

/*
 * This code depends on the EMFTVM ATL component, which is not available from
 * the main Eclipse update site.
 * The ATL-specific update site must therefore be used.
 * As of 20180522, the update site corresponding to the version of ATL available
 * in the main Eclipse update site is:
 * http://download.eclipse.org/mmt/atl/updates/releases/3.8/R201705182014/
 * All update sites can be found from:
 * http://www.eclipse.org/atl/downloads/
 */
class Main {
	def static void main(String[] args) {
		val rs = new ResourceSetImpl
		rs.resourceFactoryRegistry.extensionToFactoryMap.put("atl", new AtlResourceFactoryImpl)

		val r = rs.getResource(URI.createFileURI("../fr.eseo.atol.examples.ecore2jfx/ecore2jfx.atl"), true)
		r.errors.forEach[
			println('''error: «it»''')
		]
		r.warnings.forEach[
			println('''warning: «it»''')
		]
		if(!r.errors.isEmpty) {
			System.exit(1)
		}

		println(
			'''
				r.contents
			'''
		)
	}
}