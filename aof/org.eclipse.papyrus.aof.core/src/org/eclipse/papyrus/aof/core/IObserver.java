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
 * Defines the way of observing mutations performed on the writable and observable contents of boxes
 * (see {@link org.eclipse.papyrus.aof.core.IWritable} and {@link org.eclipse.papyrus.aof.core.IReadable}).
 * <p>
 * A observer receives notification of mutations as soon as it has been registered to the observable contents. It can
 * then decide to disable the notification.
 * 
 * @param <E>
 *            type of the elements contained in the observable
 *            that this contents observer observes
 */
public interface IObserver<E> {

	/**
	 * Returns whether this observer receives notifications or not
	 * 
	 * @return true this observer does not receive any notification, false otherwise
	 */
	boolean isDisabled();

	/**
	 * Enables or disables the notification of this observer.
	 * 
	 * @param disabled
	 *            true this observer does not receive any notification, false otherwise
	 */
	void setDisabled(boolean disabled);

	/**
	 * Notifies this observer that a specified element has just been inserted into the observable contents at a given
	 * position.
	 * 
	 * @param index
	 *            position of the inserted element
	 * @param element
	 *            element that has just been inserted
	 */
	void added(int index, E element);

	/**
	 * Notifies this observer that a specified element has just been removed from the observable contents at a given
	 * position.
	 * 
	 * @param index
	 *            position of the removed element
	 * @param element
	 *            element that has just been removed
	 */
	void removed(int index, E element);

	/**
	 * Notifies this observer that a specified old element has just been replaced by a new element
	 * in the observable contents at a given position.
	 * 
	 * @param index
	 *            position of the new element
	 * @param newElement
	 *            element located at the given position after the removal
	 * @param oldElement
	 *            element located at the given position before the removal
	 */
	void replaced(int index, E newElement, E oldElement);

	/**
	 * Notifies this observer that a specified element has just been moved from an old position to a new position.
	 * 
	 * @param newIndex
	 *            position of the element after the move
	 * @param oldIndex
	 *            position of the element before the move
	 * @param element
	 *            element that has just been moved
	 */
	void moved(int newIndex, int oldIndex, E element);

}
