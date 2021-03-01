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

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * A delegate that uses a Java list to implements most of the box operations
 * 
 * @author obeaudoux
 * 
 * @param <E>
 */
public class ListDelegate<E> extends BaseDelegate<E> {

	private List<E> list = new ArrayList<E>();

	// Iterable

	@Override
	public Iterator<E> iterator() {
		return list.iterator();
	}

	// Readable

	@Override
	public E get(int index) {
		return list.get(index);
	}

	@Override
	public int length() {
		return list.size();
	}

	// Writable

	@Override
	public void add(int index, E element) {
		list.add(index, element);
		fireAdded(index, element);
	}

	@Override
	public void removeAt(int index) {
		E element = list.remove(index);
		fireRemoved(index, element);
	}

	@Override
	public void set(int index, E element) {
		E oldElement = list.set(index, element);
		fireReplaced(index, element, oldElement);
	}

	@Override
	public void move(int newIndex, int oldIndex) {
		E element = list.get(oldIndex);
		if (newIndex != oldIndex) {
			list.remove(oldIndex);
			list.add(newIndex, element);
		}
		fireMoved(newIndex, oldIndex, element);
	}

	
	
}
