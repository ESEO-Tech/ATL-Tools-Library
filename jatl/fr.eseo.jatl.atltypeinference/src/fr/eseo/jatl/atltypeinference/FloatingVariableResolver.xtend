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

import java.util.Collections
import java.util.Map
import org.eclipse.m2m.atl.common.ATL.Rule
import org.eclipse.m2m.atl.common.OCL.VariableExp

/**
 * This interface can be used to provide type inference for variables that cannot be resolved (e.g., because they are implicitly defined).
 * This should never happen in "classical" ATL, but some extensions (e.g., concrete target syntax) can make use of it.
 */
interface FloatingVariableResolver {
	def Object floatingVariableInferredType(VariableExp it) {
		println('''warning: «location»: undefined variable: «referredVariable.varName»''')
//		OclAnyType
		null
	}

	def Map<String, Object> extraRuleVariables(Rule it) {
		Collections.emptyMap
	}
}