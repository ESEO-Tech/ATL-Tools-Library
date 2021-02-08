/*******************************************************************************
 *  Copyright (c) 2015 ESEO.
 *  All rights reserved. This program and the accompanying materials
 *  are made available under the terms of the Eclipse Public License v1.0
 *  which accompanies this distribution, and is available at
 *  http://www.eclipse.org/legal/epl-v10.html
 *
 *  Contributors:
 *     Olivier Beaudoux - initial API and implementation
 *******************************************************************************/
package org.eclipse.papyrus.aof.core.impl;

import static org.eclipse.papyrus.aof.core.impl.utils.Equality.optionalEquals;

import org.eclipse.papyrus.aof.core.ISingleton;

public abstract class Singleton<E> extends Box<E> implements ISingleton<E> {

	// IWritable

	@Override
	public void add(int index, E element) {
		assert index == 0;

		add(element);
	}

	@Override
	public void add(E element) {
		// Testing the size of the delegate for the case of an empty option
		if (length() == 0) {
			getDelegate().add(0, element);
		} else if (!optionalEquals(get(0), element)) {
			getDelegate().set(0, element);
		}
	}

	@Override
	public void set(int index, E element) {
		assert index == 0;

		if (length() == 0) {
			getDelegate().add(element);
		} else {
			super.set(index, element);
		}
	}

	@Override
	public void move(int newIndex, int oldIndex) {
		assert newIndex == 0;
		assert oldIndex == 0;

		getDelegate().move(newIndex, oldIndex);
		// nothing to do: moving an element from index 0 to 0 is useless
	}

	// ISingleton

	@Override
	public E get() {
		return get(0);
	}

	@Override
	public void set(E element) {
		set(0, element);
	}

}
