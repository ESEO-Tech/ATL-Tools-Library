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

import fr.eseo.aof.extensions.AOFExtensions
import fr.eseo.aof.extensions.LinkedBox
import fr.eseo.atol.gen.ATOLGen
import fr.eseo.atol.gen.ATOLGen.Metamodel
import fr.eseo.atol.gen.AbstractRule
import fr.eseo.atol.gen.plugin.constraints.common.Constraints
import fr.eseo.atol.javafx.JFX
import java.util.HashMap
import javafx.scene.shape.Circle
import javafx.scene.shape.Rectangle
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Property

@ATOLGen(transformation = "src/fr/eseo/atlc/example/umlclassobject/UMLClass2JFX.atl", metamodels = #[
	@Metamodel(name = "UML", impl = UML),
	@Metamodel(name = "JFX", impl = JFX),
	@Metamodel(name = "Constraints", impl = Constraints)
], libraries = #[
	"src/fr/eseo/atlc/example/umlclassobject/CommonDiagramHelpers.atl"
], extensions = #[Constraints])
class UMLClass2JFX implements AOFExtensions {
	def IBox<Property> _prev(Property it) {
//		LinkedBox.toLinkedBox(UMLMM.ownedAttribute4(UMLMM._class(it)).asOrderedSet).previous(it)
		UMLMM._class(it).linkedBox.previous(it)
	}

	val linkedBoxCache = new HashMap<Class, LinkedBox<Property>>
	def LinkedBox<Property> _linkedBox(Class it) {
		linkedBoxCache.computeIfAbsent(it)[
			LinkedBox.toLinkedBox(UMLMM._ownedAttribute(it).asOrderedSet)
		]
	}

	def IBox<LinkedBox<Property>> linkedBox(IBox<Class> it) {
		collect[it?._linkedBox]
	}

	def IBox<Property> previous(IBox<LinkedBox<Property>> it, Property p) {
		collectMutable[it?.previous(p) ?: AbstractRule.emptyOption]
	}

	def _x(Rectangle it) {
		JFXMM._x(it)
	}

	def _y(Rectangle it) {
		JFXMM._y(it)
	}

	def x(IBox<Rectangle> it) {
		JFXMM.x(it)
	}

	def y(IBox<Rectangle> it) {
		JFXMM.y(it)
	}

	def _centerX(Circle it) {
		JFXMM._centerX(it)
	}

	def _centerY(Circle it) {
		JFXMM._centerY(it)
	}

	def centerX(IBox<Circle> it) {
		JFXMM.centerX(it)
	}

	def centerY(IBox<Circle> it) {
		JFXMM.centerY(it)
	}
}