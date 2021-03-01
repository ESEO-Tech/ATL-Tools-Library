/*******************************************************************************
 *  Copyright (c) 2015 ESEO.
 *  All rights reserved. This program and the accompanying materials
 *  are made available under the terms of the Eclipse Public License v1.0
 *  which accompanies this distribution, and is available at
 *  http://www.eclipse.org/legal/epl-v10.html
 *
 *  Contributors:
 *     Frédéric Jouault - initial API and implementation
 *******************************************************************************/
package org.eclipse.papyrus.aof.core.impl.utils;

public abstract class FactoryObserver<E> extends DefaultObserver<E> {

	@Override
	public void removed(int index, E element) {
	}

	@Override
	public void replaced(int index, E newElement, E oldElement) {
	}

	@Override
	public void moved(int newIndex, int oldIndex, E element) {
	}

}
