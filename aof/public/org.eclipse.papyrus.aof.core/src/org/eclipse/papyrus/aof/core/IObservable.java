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
 * Represents the observable contents of boxes.
 * <p>
 * Any registered observer instance of {@link org.eclipse.papyrus.aof.core.IObserver} receives notification of mutations
 * that occur on this observable contents whenever a method defined in {@link org.eclipse.papyrus.aof.core.IWritable} is
 * invoked on the writable contents.
 * 
 * @param <E>
 *            type of the elements contained in this observable contents
 */
public interface IObservable<E> {

	/**
	 * Appends an observer to the list of observers for this observable contents.
	 * The order in which notifications will be delivered to multiple observers follows the appending order.
	 * 
	 * @param observer
	 *            observer to be appended to the list of observers
	 * @throws IllegalStateException
	 *             if the observer is already contained in the list of observers
	 * @throws IllegalArgumentException
	 *             if the observer is null
	 * 
	 */
	void addObserver(IObserver<E> observer);

	/**
	 * Removes an observer from the list of observers for this observable contents.
	 * 
	 * @param observer
	 *            observer to be removed from the list of observers
	 * @throws IllegalStateException
	 *             if the observer is already contained in the list of observers
	 */
	void removeObserver(IObserver<E> observer);

	/**
	 * Returns the list of observers that have been registered to this observable contents.
	 * 
	 * The list is returned as an iterable contents which is a <b>clone</b> of the internal list.
	 * Consequently, adding or removing an observer while iterating on the observable contents
	 * has no impact of the iterations, thus avoiding any concurrent access exception.
	 * 
	 * @return the list of observers observing this observable contents
	 */
	Iterable<IObserver<E>> getObservers();

	/**
	 * Returns whether this observable contents has registered observer or not.
	 * 
	 * @return true if this observable contents has at least one registerd observer, false otherwise
	 */
	boolean isObserved();

}
