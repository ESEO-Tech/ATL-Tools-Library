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

import JavaFX.JavaFXPackage
import JavaFX.Node
import fr.eseo.aof.xtend.utils.AOFAccessors
import fr.eseo.atol.gen.Metaclass
import org.eclipse.papyrus.aof.core.AOFFactory
import fr.eseo.atlc.constraints.ExpressionGroup

@AOFAccessors(JavaFXPackage)
public class JFXModel {

	public static val Metaclass<Figure> Figure = [new Figure()]

	static class Figure {
		val nodes = AOFFactory.INSTANCE.<Node>createSequence
		val constraints = AOFFactory.INSTANCE.<ExpressionGroup>createSequence
		val children = AOFFactory.INSTANCE.<Figure>createSequence
	}
	
	def _id(Node e) {
		e._iD
	}
	
	def _nodes(Figure it) {
		nodes
	}

	def _constraints(Figure it) {
		constraints
	}

	def _children(Figure it) {
		children
	}
}
