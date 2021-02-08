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
import org.eclipse.papyrus.aof.core.IBox

@ATOLGen(transformation="testcases/Ecore2UML.atl", patternKind=List, metamodels = #[
	@Metamodel(name="Ecore", impl=Ecore),
	@Metamodel(name="UML", impl=UML)
])
class Ecore2UMLListPatterns {

	def firstToLower(IBox<String> it) {
		it.collect[toFirstLower]
	}
}