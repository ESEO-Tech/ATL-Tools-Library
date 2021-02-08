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
 * Represents the readable contents of boxex.
 * <p>
 * Box readings are achieved using an index-based access.
 * 
 * @param <E>
 *            type of the elements contained in this readable contents
 */
public interface IReadable<E> extends Iterable<E> {

	/**
	 * Returns the element at the specified position in this readable contents.
	 * 
	 * @param index
	 *            index of the element to return
	 * @return the element at the specified position in this readable contents
	 * @throws <code>IndexOutOfBoundsException</code> if the index is out of range,
	 *         i.e. <code>(index < 0 || index >= size())</code>
	 */
	E get(int index);

	/**
	 * Returns the number of elements in this readable contents.
	 * 
	 * @return the number of elements in this readable contents
	 */
	int length();

	/**
	 * Returns the index of the first occurrence of the specified element in this readable contents,
	 * or -1 if the contents does not contain the element.
	 * <p>
	 * Comparison is performed using object equality method {@link java.lang.Object#equals(Object)}, supplemented by
	 * <code>null</code> element comparison.
	 * 
	 * @param element
	 *            element to search for
	 * @return the index of the first element occurrence,
	 *         or -1 if this readable contents does not contain the element
	 */
	int indexOf(E element);

	/**
	 * Returns whether this readable contents contains the specified element or not.
	 * <p>
	 * Comparison is performed using object equality method {@link java.lang.Object#equals(Object)}, supplemented by
	 * <code>null</code> element comparison.
	 * 
	 * @param element
	 *            element to search for
	 * @return whether this readable contents contains the element or not
	 */
	boolean contains(E element);

}
