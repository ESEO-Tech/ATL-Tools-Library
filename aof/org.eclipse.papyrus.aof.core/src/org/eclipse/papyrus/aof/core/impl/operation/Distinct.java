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

import static org.eclipse.papyrus.aof.core.impl.utils.Equality.optionalEquals;

import java.util.HashSet;
import java.util.Set;

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IOne;
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver;

public class Distinct<E> extends Operation<E> {

	private IBox<E> nonUniqueBox;

	public Distinct(IBox<E> nonUniqueBox) {
		this(nonUniqueBox, null, false);
	}

	public Distinct(IBox<E> nonUniqueBox, IBox<E> uniqueBox, boolean reversed) {
		this.nonUniqueBox = nonUniqueBox;
		setResult(uniqueBox);
		if (nonUniqueBox.isUnique()) {
			throw new IllegalArgumentException("The box " + nonUniqueBox + " must not be a unique box");
		}
		if (!getResult().isUnique()) {
			throw new IllegalArgumentException("The box " + getResult() + " must be a unique box");
		}
		if (reversed) {
			nonUniqueBox.assign(getResult());
		} else {
			getResult().assign(nonUniqueBox);
		}
		registerObservation(nonUniqueBox, new NonUniqueBoxObserver());
		registerObservation(getResult(), new UniqueBoxObserver());
	}

	@Override
	public boolean isOptional() {
		return nonUniqueBox.isOptional();
	}

	@Override
	public boolean isSingleton() {
		return nonUniqueBox.isSingleton();
	}

	@Override
	public boolean isOrdered() {
		return nonUniqueBox.isOrdered();
	}

	@Override
	public boolean isUnique() {
		return true;
	}

	@Override
	public E getResultDefautElement() {
		IOne<E> sourceOne = (IOne<E>) nonUniqueBox;
		return sourceOne.getDefaultElement();
	}

	private class NonUniqueBoxObserver extends DefaultObserver<E> {

		private int countUniques(int untilIndex) {
			Set<E> s = new HashSet<E>();
			for(int i = 0 ; i < untilIndex ; i++) {
				s.add(nonUniqueBox.get(i));
			}
			return s.size();
		}

		private int countUniques(int untilIndex, int changeIndex) {
			int count = 0;
			for (int i = 0; i < untilIndex; i++) {
				int index = (i < changeIndex) ? i : i + 1;
				E element = nonUniqueBox.get(index);
				int j = index - 1;
				boolean found = false;
				while ((j >= 0) && !found) {
					if (optionalEquals(nonUniqueBox.get(j), element)) {
						found = true;
					} else {
						j--;
					}
				}
				if (!found) {
					count++;
				}
			}
			return count;
		}

		@Override
		public void added(int index, E element) {
			if (!getResult().contains(element)) {
				getResult().add(countUniques(index), element);
			}
		}

		@Override
		public void removed(int index, E element) {
			// do the removal only if there is no other occurrence of e in the source box
			if (!nonUniqueBox.contains(element)) {
				getResult().remove(element);
			}
		}

		@Override
		public void replaced(int index, E newElement, E oldElement) {
			if (!nonUniqueBox.contains(oldElement)) {
				if (!getResult().contains(newElement)) {
					getResult().set(getResult().indexOf(oldElement), newElement);
				} else {
					getResult().remove(oldElement);
				}
			} else if (!getResult().contains(newElement)) {
				getResult().add(countUniques(index), newElement);
			}
		}

		@Override
		public void moved(int newIndex, int oldIndex, E element) {
			if (getResult().contains(element)) {
				getResult().move(countUniques(newIndex), countUniques(oldIndex, newIndex));
			}
		}

	}

	private class UniqueBoxObserver extends DefaultObserver<E> {

		private int indexInSource(int indexInResult) {
			if (indexInResult > 0) {
				E elementAtLeft = getResult().get(indexInResult - 1);
				return nonUniqueBox.indexOf(elementAtLeft) + 1;
			} else {
				return 0;
			}
		}

		private int lastIndexOfInSource(E element) {
			int index = nonUniqueBox.length() - 1;
			while (index >= 0) {
				if (optionalEquals(nonUniqueBox.get(index), element)) {
					return index;
				} else {
					index--;
				}
			}
			return -1;
		}

		@Override
		public void added(int index, E element) {
			if (nonUniqueBox.contains(element)) {
				throw new IllegalStateException("Adding element " + element + " in box " + nonUniqueBox + " violates the uniqueness constraints");
			}
			nonUniqueBox.add(indexInSource(index), element);
		}

		@Override
		public void removed(int index, E element) {
			while (nonUniqueBox.contains(element)) {
				nonUniqueBox.remove(element);
			}
		}

		@Override
		public void replaced(int index, E newElement, E oldElement) {
			// replace all occurrences of p by e within the source box
			int i = nonUniqueBox.indexOf(oldElement);
			while (i != -1) {
				nonUniqueBox.set(i, newElement);
				i = nonUniqueBox.indexOf(oldElement);
			}
		}

		@Override
		public void moved(int newIndex, int oldIndex, E element) {
			if (newIndex == oldIndex) {
				// do nothing... should we propagate?
			} else if (newIndex < oldIndex) {
				E elementAtLeftInSource = getResult().get(oldIndex);
				int index = lastIndexOfInSource(elementAtLeftInSource) + 1; // +1 : go from left to the element
				nonUniqueBox.move(indexInSource(newIndex), index);
			} else {
				E elementAtRightInSource = getResult().get(newIndex - 1);
				int index = nonUniqueBox.indexOf(elementAtRightInSource);
				nonUniqueBox.move(index, indexInSource(oldIndex));
			}
		}

	}
}
