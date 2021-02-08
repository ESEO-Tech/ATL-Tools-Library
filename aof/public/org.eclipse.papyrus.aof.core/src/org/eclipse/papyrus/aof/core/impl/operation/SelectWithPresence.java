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

import org.eclipse.papyrus.aof.core.AOFFactory;
import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IOne;
import org.eclipse.papyrus.aof.core.IPair;
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver;


public class SelectWithPresence<E> extends Operation<E> {

	private IBox<IPair<E, Boolean>> sourceBox;

	public SelectWithPresence(IBox<IPair<E, Boolean>> sourceBox) {
		this.sourceBox = sourceBox;
		for (IPair<E, Boolean> pair : sourceBox) {
			if (pair.getRight()) {
				getResult().add(pair.getLeft());
			}
		}
		registerObservation(sourceBox, new SourceObserver());
		registerObservation(getResult(), new ResultObserver());
	}

	@Override
	public boolean isOptional() {
		return true;
	}

	@Override
	public boolean isSingleton() {
		return sourceBox.isSingleton();
	}

	@Override
	public boolean isOrdered() {
		return sourceBox.isOrdered();
	}

	@Override
	public boolean isUnique() {
		return sourceBox.isUnique();
	}

	@Override
	public E getResultDefautElement() {
		IOne<IPair<E, Boolean>> sourceOne = (IOne<IPair<E, Boolean>>) sourceBox;
		return sourceOne.getDefaultElement().getLeft();
	}

	private class SourceObserver extends DefaultObserver<IPair<E, Boolean>> {

		@Override
		public void added(int index, IPair<E, Boolean> pair) {
			if (pair.getRight()) {
				getResult().add(countTrue(index), pair.getLeft());
			}
		}

		@Override
		public void removed(int index, IPair<E, Boolean> pair) {
			if (pair.getRight()) {
				getResult().removeAt(countTrue(index));
			}
		}

		@Override
		public void replaced(int index, IPair<E, Boolean> newPair, IPair<E, Boolean> oldPair) {
			if (oldPair.getRight() && newPair.getRight()) {
				getResult().set(countTrue(index), newPair.getLeft());
			} else if (!oldPair.getRight() && newPair.getRight()) {
				getResult().add(countTrue(index), newPair.getLeft());
			} else if (oldPair.getRight() && !newPair.getRight()) {
				getResult().removeAt(countTrue(index));
			}
		}

		@Override
		public void moved(int newIndex, int oldIndex, IPair<E, Boolean> pair) {
			if (pair.getRight()) {
				getResult().move(countTrue(newIndex), countTrue(oldIndex, newIndex));
			}
		}

		/**
		 * Counts the number of true values in the new version of the predicate for a the given interval.
		 * 
		 * @param untilIndex
		 *            the upper bound of the interval, exclusive : [0..untilIndex[
		 * @return the number of true values
		 */
		private int countTrue(int untilIndex) {
			return countTrue(untilIndex, untilIndex);
		}

		/**
		 * Counts the number of true values in the old version of the predicate for a the given interval.
		 * 
		 * @param untilIndex
		 *            the upper bound of the interval, exclusive : [0..untilIndex[
		 * @param changeIndex
		 *            the index of the change between the old version and
		 * @return the number of true values
		 */
		private int countTrue(int untilIndex, int changeIndex) {
			int count = 0;
			for (int n = 0; n < untilIndex; n++) {
				int index = (n < changeIndex) ? n : n + 1;
				if (sourceBox.get(index).getRight()) {
					count++;
				}
			}
			return count;
		}

	}

	private class ResultObserver extends DefaultObserver<E> {

		private IPair<E, Boolean> createPair(E element, Boolean selected) {
			return AOFFactory.INSTANCE.createPair(element, selected);
		}

		@Override
		public void added(int index, E element) {
			sourceBox.add(indexOfTrue(index), createPair(element, true));
		}

		@Override
		public void removed(int index, E element) {
			if (sourceBox instanceof IOne<?>) {
				throw new IllegalStateException("Emptying the result " + getResult() + " of a select while the source box " + sourceBox + " is a one box is forbidden");
			}
			sourceBox.removeAt(indexOfTrue(index + 1) - 1);
		}

		@Override
		public void replaced(int index, E newElement, E oldElement) {
			sourceBox.set(indexOfTrue(index + 1) - 1, createPair(newElement, true));
		}

		@Override
		public void moved(int newIndex, int oldIndex, E element) {
			sourceBox.move(indexOfTrue(newIndex + 1) - 1, indexOfTrue(oldIndex + 1) - 1);
		}

		// it is in fact the reverse version of countTrue...?
		private int indexOfTrue(int untilCount) {
			int index = 0;
			int count = 0;
			while (count < untilCount) {
				if (sourceBox.get(index).getRight()) {
					count++;
				}
				index++;
			}
			return index;
		}

	}

}