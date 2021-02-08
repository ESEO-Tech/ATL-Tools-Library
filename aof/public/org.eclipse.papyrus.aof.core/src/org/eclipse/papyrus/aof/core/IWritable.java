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
 * Represents the writable contents of a box.
 * Box writings are achieved using an index-based access.
 * <p>
 * Any box is also an instance of {@link org.eclipse.papyrus.aof.core.IConstrained}. Consequently, invoking a writing
 * method may throw exception, such as InvalidStateException (uniqueness constraints violated) or
 * IndexOutOfBoundException.
 * <p>
 * Any box is also an instance of {@link org.eclipse.papyrus.aof.core.IObservable}. Consequently, invoking a writing
 * method on a box notifies registered observers.
 * 
 * @param <E>
 *            type of the elements contained in this writable contents
 */
public interface IWritable<E> {

	/**
	 * Appends the specified element to the end of this writable object.
	 * <p>
	 * All observers are notified of the appending afterwards.
	 * 
	 * @param element
	 *            element to be appended to this writable contents
	 * @throws IllegalStateException
	 *             if this writable contents is constrained with a uniqueness constraint,
	 *             and the element is already contained in this contents
	 */
	void add(E element);

	/**
	 * Inserts the specified element at the specified position in this writable contents.
	 * <p>
	 * If the index equals the contents size, the element is appended to the contents.
	 * <p>
	 * All observers are notified of the insertion afterwards.
	 * 
	 * @param index
	 *            index at which the specified element is to be inserted
	 * @param element
	 *            element to be appended to this writable contents
	 * @throws IllegalStateException
	 *             if this writable contents is constrained with a uniqueness constraint,
	 *             and the element is already contained in this writable contents
	 * @throws IndexOutOfBoundException
	 *             if index is less than 0, or greater than the size of the contents
	 */
	void add(int index, E element);

	/**
	 * Assigns a new contents to this writable contents by first clearing it, then by appending all elements
	 * given by the specified iterable.
	 * 
	 * If this writable contents cannot have duplicates, i.e. <code>!isSingleton() && isUnique()</code>),
	 * duplicates that appear in the elements are discarded.
	 * 
	 * If this writable contents is a singleton, the last element defines the singleton contents.
	 * 
	 * If the iterable is empty, this writable contents is empty, except for one box.
	 * 
	 * In all cases, each removing performed when clearing, as well as each appending, result in a notification
	 * to all registered observers.
	 * 
	 * @param iterable
	 *            iterable defining the elements that are assigned to this writable contents
	 * @throws IllegalArgumentException
	 *             if the specified iterable is null
	 */
	void assign(Iterable<E> iterable);

	void assignNoCheck(Iterable<E> iterable);

	/**
	 * Assigns a new contents to this writable contents by first clearing it, then by appending all specified elements.
	 * 
	 * This method is equivalent to <code>assign(Arrays.asList(elements))</code> (see {@link #assign(Iterable)}).
	 * 
	 * A null value can be assign to this writable contents using <code>assign((E) null)</code>.
	 * 
	 * @param elements
	 *            the elements that are assigned to this writable contents
	 */
	void assign(E... elements);


	/**
	 * Removes the specified element from this writable contents.
	 * <p>
	 * All observers are notified of the removal afterwards.
	 * 
	 * @param element
	 *            element to be removed from this writable contents
	 * @throws IllegalStateException
	 *             if the element is not contained in this contents
	 */
	void remove(E element);

	/**
	 * Removes the element at the specified location of this writable contents.
	 * <p>
	 * All observers are notified of the removal afterwards.
	 * 
	 * @param index
	 *            location of the element to remove from this writable contents
	 * @throws IndexOutOfBoundException
	 *             if index is less than 0, or greater or equal than the size of the contents
	 */
	void removeAt(int index);

	/**
	 * Clear this writable contents by removing all the elements of this writable contents.
	 * <p>
	 * All observers are notified of the removals afterwards.
	 * <p>
	 * If the box is a one box (i.e. a singleton with a not optional constraints), the default value of the one defines
	 * the new contents of the box.
	 */
	void clear();

	/**
	 * Replaces the element at the specified position in this writable contents with the specified element.
	 * <p>
	 * All observers are notified of the replacement afterwards.
	 * 
	 * @param index
	 *            index of the element to replace
	 * @param element
	 *            element to be stored at the specified position
	 * @throws IllegalStateException
	 *             if this writable contents is constrained with a uniqueness constraint,
	 *             and the element is already contained in this writable contents
	 * @throws IndexOutOfBoundException
	 *             if index is less than 0, or greater or equals than the size of this writable contents
	 * @see #set(int, Object)
	 */
	void set(int index, E element);

	/**
	 * Moves the element from an old position to a new position in this writable contents.
	 * <p>
	 * All observers are notified of the move afterwards.
	 * 
	 * @param newIndex
	 *            the new position used to store the element
	 * @param oldIndex
	 *            the old position where the element was stored
	 * @throws IndexOutOfBoundException
	 *             if the new or old index is less than 0, or greater or equals than the size of this writable contents
	 */
	void move(int newIndex, int oldIndex);

}
