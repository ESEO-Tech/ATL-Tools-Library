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

package fr.eseo.atlc.example.graf.transfo

import fr.eseo.atol.gen.ATOLGen
import fr.eseo.atol.gen.ATOLGen.Metamodel
import fr.eseo.atol.gen.plugin.constraints.common.Constraints
import fr.eseo.atol.javafx.JFX

@ATOLGen(transformation="src/fr/eseo/atlc/example/graf/transfo/Graf2JFX.atl", metamodels=#[
	@Metamodel(name="Graf", impl=Graf),
	@Metamodel(name="JFX", impl=JFX),
	@Metamodel(name="Constraints", impl=Constraints)
], extensions = #[Constraints])
class Graf2JFX {

}