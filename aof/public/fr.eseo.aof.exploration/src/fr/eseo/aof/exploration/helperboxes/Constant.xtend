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

import java.util.Collections
import org.eclipse.papyrus.aof.core.IObservable
import org.eclipse.papyrus.aof.core.IObserver

interface Constant<E> extends IObservable<E> {	
	override addObserver(IObserver<E> observer) {
	}
	
	override getObservers() {
		Collections.emptyList
	}

	// This interface should not be used in a context where the isObserved method might be called
	override isObserved() {
		throw new UnsupportedOperationException("Cannot meaningfully answer")
	}
	
	override removeObserver(IObserver<E> observer) {
	}
	
}