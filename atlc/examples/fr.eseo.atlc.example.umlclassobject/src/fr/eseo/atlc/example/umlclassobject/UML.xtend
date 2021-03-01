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

import fr.eseo.aof.xtend.utils.AOFAccessors
import fr.eseo.atol.gen.AbstractRule
import java.util.HashMap
import javafx.scene.shape.Circle
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.uml2.uml.Generalization
import org.eclipse.uml2.uml.UMLPackage

@AOFAccessors(UMLPackage)
class UML {
	val waypointsCache = new HashMap<Generalization, IBox<Circle>>
	def _waypoints(Generalization it) {
		waypointsCache.computeIfAbsent(it)[AOFFactory.INSTANCE.createSequence]
	}

	def waypoints(IBox<Generalization> it) {
		collectMutable[it?._waypoints ?: AbstractRule.emptySequence]
	}
}