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
 
 package fr.eseo.jatl

import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.EPackage
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.Delegate
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

@Data
class CompilationHelpers implements MutableClassDeclaration, TransformationContext {
	@Delegate
	final extension MutableClassDeclaration cd
	@Delegate
	final extension TransformationContext context

	val Map<String, List<EPackage>> packages
}