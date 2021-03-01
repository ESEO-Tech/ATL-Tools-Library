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

package fr.eseo.atol.gen.plugin.constraints.common

import fr.eseo.atol.gen.ATOLGen
import fr.eseo.atol.gen.ATOLGen.Metamodel
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.ISequence
import org.eclipse.papyrus.aof.core.IOption

@ATOLGen(transformation = "src/fr/eseo/atol/gen/plugin/constraints/common/SimplifyConstraints.atl", metamodels = #[
	@Metamodel(name = "Constraints", impl = Constraints)
])
class SimplifyConstraints {
	extension ConstraintsHelpers ch

	def toReadOnlyBox(Object source, String propertyName) {
		ch.toReadOnlyBox(source, propertyName) as IBox<?> as IBox<Double>
	}

	// propertyName should not change (i.e., it would change if the transformation itself was modified)
	def toReadOnlyBox(Object source, IBox<String> propertyName) {
		ch.toReadOnlyBox(source, propertyName.get(0)) as IBox<?> as IBox<Double>
	}

	def <E> asSequence(E e) {
		AOFFactory.INSTANCE.createSequence(e)
	}

	def <E> IBox<E> toSequence(ISequence<E> e) {
		e
	}

	def <E> ISequence<E> toISequence(IBox<E> e) {
		e.asSequence()
	}

	def <E> rawConcat(IBox<E> l, IBox<E> r) {
		l.concat(r)
	}

	def <E> unwrap(IBox<E> it) {
		get(0)
	}
}