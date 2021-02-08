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

package fr.eseo.atol.gen

import org.eclipse.papyrus.aof.core.IMetaClass

interface Metaclass<C> extends IMetaClass<C> {
	override isInstance(Object object) {
		throw new UnsupportedOperationException
	}

	override isSubTypeOf(IMetaClass<?> that) {
		throw new UnsupportedOperationException
	}

	override getDefaultInstance() {
		throw new UnsupportedOperationException
	}

	override setDefaultInstance(C defaultInstance) {
		throw new UnsupportedOperationException
	}

	override <E> getPropertyAccessor(Object property) {
		throw new UnsupportedOperationException
	}
}
