/****************************************************************
 *  Copyright (C) 2020 ESEO
 *
 *  This program and the accompanying materials are made
 *  available under the terms of the Eclipse Public License 2.0
 *  which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 *  Contributors:
 *    - Frédéric Jouault
 *
 *  version 1.0
 *
 *  SPDX-License-Identifier: EPL-2.0
 ****************************************************************/

package fr.eseo.aof.exploration.helperboxes

import org.eclipse.papyrus.aof.core.IWritable

interface ReadOnly<E> extends IWritable<E> {
	override add(E element) {
		error
	}
	
	override add(int index, E element) {
		error
	}
	
	override assign(Iterable<E> iterable) {
		error
	}
	
	override assign(E... elements) {
		error
	}
	
	override assignNoCheck(Iterable<E> iterable) {
		error
	}
	
	override clear() {
		error
	}
	
	override move(int newIndex, int oldIndex) {
		error
	}
	
	override remove(E element) {
		error
	}
	
	override removeAt(int index) {
		error
	}
	
	override set(int index, E element) {
		error
	}

	def static error() {
		throw new UnsupportedOperationException("A read-only box cannot be modified")
	}
}
