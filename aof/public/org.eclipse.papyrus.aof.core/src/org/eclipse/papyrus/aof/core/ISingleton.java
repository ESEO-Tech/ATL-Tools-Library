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
package org.eclipse.papyrus.aof.core;

/**
 * Represents boxes containing no more than one element.
 * <p>
 * Two shortcut methods {@link #get()} and {@link #set(Object)} are introduced for easing singleton reading and writing.
 */
public interface ISingleton<E> extends IBox<E> {

	/**
	 * Returns the element contained in this singleton box.
	 * <p>
	 * This method is a shortcut to <code>get(0)</code>.
	 * <p>
	 * If the box is empty, an exception is thrown.
	 * 
	 * @return the element contained in this singleton box
	 * @throws IndexOutOfBoundsException
	 *             if the singleton is empty
	 * @see #get(int)
	 */
	E get();

	/**
	 * Sets the element in this singleton box.
	 * <p>
	 * This method is a shortcut to <code>set(0, element)</code>.
	 * 
	 * @param element
	 *            the element that defines the contents of this singleton box
	 * @see #set(int, Object)
	 */
	void set(E element);

}
