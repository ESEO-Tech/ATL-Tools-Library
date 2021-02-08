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
import org.eclipse.papyrus.aof.core.IOne;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver;

public class SelectWithPredicate<E> extends Operation<E> {

	private IBox<E> sourceBox;

	private IUnaryFunction<? super E, Boolean> selector;

	public SelectWithPredicate(IBox<E> sourceBox, IUnaryFunction<? super E, Boolean> selector) {
		this.sourceBox = sourceBox;
		this.selector = selector;
		for (E element : sourceBox) {
			if (selector.apply(element)) {
				getResult().add(element);
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
		IOne<E> sourceOne = (IOne<E>) sourceBox;
		return sourceOne.getDefaultElement();
	}

	private class SourceObserver extends DefaultObserver<E> {

		@Override
		public void added(int index, E element) {
			if (selector.apply(element)) {
				getResult().add(countTrue(index), element);
			}
		}

		@Override
		public void removed(int index, E element) {
			if (selector.apply(element)) {
				getResult().removeAt(countTrue(index));
			}
		}

		@Override
		public void replaced(int index, E newElement, E oldElement) {
			if (selector.apply(newElement)) {
				if (selector.apply(oldElement)) {
					getResult().set(countTrue(index), newElement);
				}
				else {
					getResult().add(countTrue(index), newElement);
				}
			}
			else if (selector.apply(oldElement)) {
				getResult().removeAt(countTrue(index));
			}
		}

		@Override
		public void moved(int newIndex, int oldIndex, E element) {
			if (selector.apply(element)) {
				getResult().move(countTrue(newIndex), countTrue(oldIndex, newIndex));
			}
		}

		private int countTrue(int untilIndex) {
			return countTrue(untilIndex, untilIndex);
		}

		private int countTrue(int untilIndex, int changeIndex) {
			int count = 0;
			for (int n = 0; n < untilIndex; n++) {
				int index = (n < changeIndex) ? n : n + 1;
				if (selector.apply(sourceBox.get(index))) {
					count++;
				}
			}
			return count;
		}
	}

	protected class ResultObserver extends DefaultObserver<E> {

		@Override
		public void added(int index, E element) {
			if (selector.apply(element)) {
				sourceBox.add(indexOfTrue(index), element);
			}
			else {
				throw new IllegalStateException("Trying to add element " + element + " that does not satisify predicate");
			}
		}

		@Override
		public void removed(int index, E element) {
			if (sourceBox instanceof IOne<?>) {
				if(selector.apply(((IOne<E>)sourceBox).getDefaultElement())) {
					throw new IllegalStateException("Emptying the result " + getResult() + " of a select while the source box " + sourceBox + " is a one box which a default value that satisfies the selector is forbidden");
				}
			}
			sourceBox.removeAt(indexOfTrue(index + 1) - 1);
		}

		@Override
		public void replaced(int index, E newElement, E oldElement) {
			if (selector.apply(newElement)) {
				sourceBox.set(indexOfTrue(index + 1) - 1, newElement);
			}
			else {
				throw new IllegalStateException("Trying to replace element " + oldElement + " by element " + newElement + " that does not satisify predicate");
			}
		}

		@Override
		public void moved(int newIndex, int oldIndex, E element) {
			sourceBox.move(indexOfTrue(newIndex + 1) - 1, indexOfTrue(oldIndex + 1) - 1);
		}

		// it is in fact the reversed version of countTrue...?
		private int indexOfTrue(int untilCount) {
			int index = 0;
			int count = 0;
			while (count < untilCount) {
				if (selector.apply(sourceBox.get(index))) {
					count++;
				}
				index++;
			}
			return index;
		}

	}

}