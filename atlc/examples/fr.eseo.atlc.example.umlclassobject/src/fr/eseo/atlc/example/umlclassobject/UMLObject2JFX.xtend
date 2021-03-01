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

package fr.eseo.atlc.example.umlclassobject

import fr.eseo.aof.extensions.LinkedBox
import fr.eseo.atol.gen.ATOLGen
import fr.eseo.atol.gen.ATOLGen.Metamodel
import fr.eseo.atol.gen.AbstractRule
import fr.eseo.atol.gen.plugin.constraints.common.Constraints
import fr.eseo.atol.javafx.JFX
import java.util.HashMap
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.uml2.uml.InstanceSpecification
import org.eclipse.uml2.uml.Slot

@ATOLGen(transformation = "src/fr/eseo/atlc/example/umlclassobject/UMLObject2JFX.atl", metamodels = #[
	@Metamodel(name = "UML", impl = UML),
	@Metamodel(name = "JFX", impl = JFX),
	@Metamodel(name = "Constraints", impl = Constraints)
], libraries = #[
	"src/fr/eseo/atlc/example/umlclassobject/CommonDiagramHelpers.atl"
], extensions = #[Constraints])
class UMLObject2JFX {
	def IBox<Slot> _prev(Slot it) {
//		LinkedBox.toLinkedBox(UMLMM.slot(UMLMM._owningInstance(it)).asOrderedSet).previous(it)
		UMLMM._owningInstance(it).linkedBox.previous(it)
	}

	val linkedBoxCache = new HashMap<InstanceSpecification, LinkedBox<Slot>>
	def LinkedBox<Slot> _linkedBox(InstanceSpecification it) {
		linkedBoxCache.computeIfAbsent(it)[
			LinkedBox.toLinkedBox(UMLMM._slot(it).asOrderedSet)
		]
	}

	def IBox<LinkedBox<Slot>> linkedBox(IBox<InstanceSpecification> it) {
		collect[it?._linkedBox]
	}

	def IBox<Slot> previous(IBox<LinkedBox<Slot>> it, Slot p) {
		collectMutable[it?.previous(p) ?: AbstractRule.emptyOption]
	}

	def IBox<String> asString(IBox<Integer> it) {
		collect([it?.toString])[Integer.parseInt(it)]
	}
}