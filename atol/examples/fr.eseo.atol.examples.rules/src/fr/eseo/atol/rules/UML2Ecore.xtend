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

import fr.eseo.aof.exploration.OCLByEquivalence

@ATOLGen(transformation="testcases/UML2Ecore.atl", metamodels=#[
	@Metamodel(name="UML", impl=UML),
	@Metamodel(name="Ecore", impl=Ecore)
])
class UML2Ecore {

	def <E> indexOf(IBox<E> b, E e) {
		OCLByEquivalence.indexOf(b, e)
	}
}