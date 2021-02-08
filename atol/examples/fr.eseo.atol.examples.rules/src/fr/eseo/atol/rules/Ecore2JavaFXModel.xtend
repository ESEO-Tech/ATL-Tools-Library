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
import fr.eseo.atol.gen.plugin.constraints.common.Constraints

//@ATOLGen("/fr.eseo.atol.examples.ecore2jfx/ecore2jfx.atl")
@ATOLGen(transformation="ecore2jfx.atl", metamodels=#[
	@Metamodel(name="Ecore", impl=Ecore),
	@Metamodel(name="JFX", impl=JFXModel),
	@Metamodel(name="Constraints", impl=Constraints)
], extensions = #[Constraints])
class Ecore2JavaFXModel {

}