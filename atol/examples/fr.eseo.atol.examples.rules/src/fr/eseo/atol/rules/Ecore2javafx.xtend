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

import com.google.common.collect.ImmutableList
import fr.eseo.atol.gen.ListRule
import javafx.scene.shape.Rectangle
import javafx.scene.text.Text
import org.eclipse.emf.ecore.EPackage

import static extension fr.eseo.atol.gen.AbstractRule.*

class Ecore2javafx {
	val extension Ecore = new Ecore
	
	public val package2rectangle = new ListRule(ImmutableList.of(Ecore.EPackage), ImmutableList.of(JFX.Rectangle, JFX.Text))[in, out |
		val model = in.get(0) as EPackage
		val r = out.get(0) as Rectangle
		val t = out.get(1) as Text
		
		r.idProperty <=> model._name
		r.x = 200.0
		r.y = 200.0
		r.width = 200.0
		r.height = 200.0

		t.idProperty <=> model._name
		t.textProperty <=> model._name
		t.x = 200.0
		t.y = 200.0
	]
	
}