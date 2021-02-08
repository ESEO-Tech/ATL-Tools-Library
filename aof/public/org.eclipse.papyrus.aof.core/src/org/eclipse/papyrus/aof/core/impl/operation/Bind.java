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

import org.eclipse.papyrus.aof.core.IBinding;
import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IObserver;
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver;

public class Bind<E> {

	private IBox<E> leftBox;

	private IBox<E> rightBox;

	private IObserver<E> leftObserver;

	private IObserver<E> rightObserver;

	private IBinding<E> binding;

	public Bind(IBox<E> leftBox, IBox<E> rightBox) {
		this.leftBox = leftBox;
		this.rightBox = rightBox;
		if (!leftBox.getConstraints().equals(rightBox)) {
			throw new IllegalArgumentException("Left box " + leftBox + " and right box " + rightBox + " must have the same type");
		}
		leftObserver = new LeftObserver();
		rightObserver = new RightObserver();
		binding = new Binding();
		binding.enable();
		leftBox.addObserver(leftObserver);
		rightBox.addObserver(rightObserver);
	}


	public IBinding<E> getBinding() {
		return binding;
	}

	private class Binding implements IBinding<E> {

		@Override
		public IBox<E> getLeft() {
			return leftBox;
		}

		@Override
		public IBox<E> getRight() {
			return rightBox;
		}

		@Override
		public void enable() {
			if(!leftBox.sameAs(rightBox)) {
				// init required so that the left box be updated since changes may have occurred while disabled
				leftBox.assignNoCheck(rightBox);
			}
			leftObserver.setDisabled(false);
			rightObserver.setDisabled(false);
		}

		@Override
		public void disable() {
			leftObserver.setDisabled(true);
			rightObserver.setDisabled(true);
		}

	}

	private abstract class LeftRightObserver extends DefaultObserver<E> {

		protected abstract IBox<E> getOtherBox();

		protected abstract IObserver<E> getOtherObserver();

		@Override
		public void added(int index, E element) {
			getOtherObserver().setDisabled(true);
			getOtherBox().add(index, element);
			getOtherObserver().setDisabled(false);
		}

		@Override
		public void removed(int index, E element) {
			getOtherObserver().setDisabled(true);
			getOtherBox().removeAt(index);
			getOtherObserver().setDisabled(false);
		}

		@Override
		public void replaced(int index, E newElement, E oldElement) {
			getOtherObserver().setDisabled(true);
			getOtherBox().set(index, newElement);
			getOtherObserver().setDisabled(false);
		}

		@Override
		public void moved(int newIndex, int oldIndex, E element) {
			getOtherObserver().setDisabled(true);
			getOtherBox().move(newIndex, oldIndex);
			getOtherObserver().setDisabled(false);
		}

	}

	private class LeftObserver extends LeftRightObserver {

		@Override
		protected IBox<E> getOtherBox() {
			return rightBox;
		}

		@Override
		protected IObserver<E> getOtherObserver() {
			return rightObserver;
		}

	}

	private class RightObserver extends LeftRightObserver {

		@Override
		protected IBox<E> getOtherBox() {
			return leftBox;
		}

		@Override
		protected IObserver<E> getOtherObserver() {
			return leftObserver;
		}

	}

}
