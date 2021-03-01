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
package org.eclipse.papyrus.aof.core.impl.operation;

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver;

public class Concat<E> extends Operation<E> {

	private IBox<E> leftBox;

	private IBox<E> rightBox;

	private IUnaryFunction<E, Boolean> leftSelector;

	/**
	 * 
	 * Constructor.
	 *
	 * @param leftBox
	 * @param rightBox
	 * @param leftSelector
	 *            Function used for selecting the left or right box when updating the result box
	 *            in case of a bidirectional concatenation.
	 *            It can used for unidirectional concatenation for checking the left selection constraints.
	 *            If null, the concatenation is unidirectional.
	 */
	public Concat(IBox<E> leftBox, IBox<E> rightBox, IUnaryFunction<E, Boolean> leftSelector) {
		this.leftBox = leftBox;
		this.rightBox = rightBox;
		this.leftSelector = leftSelector;
		// initial contents
		for (E element : leftBox) {
			if (satisifiesLeft(element)) {
				getResult().add(element);
			} else {
				throw new IllegalStateException("Element " + element + " at left must statisfy the left selector");
			}
		}
		for (E element : rightBox) {
			if (satisifiesRight(element)) {
				getResult().add(element);
			} else {
				throw new IllegalStateException("Element " + element + " at right must not statisfy the left selector");
			}
		}
		// active contents
		registerObservation(leftBox, new LeftObserver());
		registerObservation(rightBox, new RightObserver());
	}

	@Override
	public boolean isOptional() {
		return true;
	}

	@Override
	public boolean isSingleton() {
		return false;
	}

	@Override
	public boolean isOrdered() {
		return leftBox.isOrdered() && rightBox.isOrdered();
	}

	@Override
	public boolean isUnique() {
		return false;
	}

	@Override
	public E getResultDefautElement() {
		throw new IllegalStateException("Method getResultDefautElement() must never be called for Concat operation since the operation never return a singleton");
	}

	private boolean satisifiesLeft(E element) {
		if (leftSelector == null) {
			return true;
		} else {
			return leftSelector.apply(element);
		}
	}

	private boolean satisifiesRight(E element) {
		if (leftSelector == null) {
			return true;
		} else {
			return !leftSelector.apply(element);
		}
	}

	private class LeftObserver extends DefaultObserver<E> {

		@Override
		public void added(int index, E element) {
			if (satisifiesLeft(element)) {
				getResult().add(index, element);
			} else {
				throw new IllegalStateException("Element " + element + " must statisfy the left selector");
			}
		}

		@Override
		public void removed(int index, E element) {
			getResult().removeAt(index);
		}

		@Override
		public void replaced(int index, E newElement, E oldElement) {
			if (satisifiesLeft(newElement)) {
				getResult().set(index, newElement);
			} else {
				throw new IllegalStateException("Element " + newElement + " must statisfy the left selector");
			}
		}

		@Override
		public void moved(int newIndex, int oldIndex, E element) {
			getResult().move(newIndex, oldIndex);
		}

	}

	private class RightObserver extends DefaultObserver<E> {

		@Override
		public void added(int index, E element) {
			if (satisifiesRight(element)) {
				getResult().add(index + leftBox.length(), element);
			} else {
				throw new IllegalStateException("Element " + element + " does not statisfy the left selector");
			}
		}

		@Override
		public void removed(int index, E element) {
			getResult().removeAt(index + leftBox.length());
		}

		@Override
		public void replaced(int index, E newElement, E oldElement) {
			if (satisifiesRight(newElement)) {
				getResult().set(index + leftBox.length(), newElement);
			} else {
				throw new IllegalStateException("Element " + newElement + " does not statisfy the left selector");
			}
		}

		@Override
		public void moved(int newIndex, int oldIndex, E element) {
			getResult().move(newIndex + leftBox.length(), oldIndex + leftBox.length());
		}

	}

}