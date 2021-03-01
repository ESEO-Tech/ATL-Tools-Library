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
import org.eclipse.papyrus.aof.core.ISingleton;
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver;

public class First<E> extends Operation<E> {

	private IBox<E> sourceBox;
	private boolean reversed;

	public First(IBox<E> sourceBox, ISingleton<E> resultBox, boolean reversed) {
		this.sourceBox = sourceBox;
		this.reversed = reversed;
		setResult(resultBox);
		if (reversed) {
			if (getResult().length() > 0) {
				sourceBox.add(getResult().get(0));
			}
		} else {
			if (sourceBox.length() > 0) {
				getResult().add(sourceBox.get(0));
			}
		}
		registerObservation(sourceBox, new SourceObserver());
		registerObservation(getResult(), new ResultObserver());
	}


	@Override
	public E getResultDefautElement() {
		IOne<E> sourceOne = (IOne<E>) sourceBox;
		return sourceOne.getDefaultElement();
	}

	@Override
	public ISingleton<E> getResult() {
		return (ISingleton<E>) super.getResult();
	}

	private class SourceObserver extends DefaultObserver<E> {

		@Override
		public void added(int index, E element) {
			if (index == 0) {
				getResult().add(0, element);
			} else if (reversed && getResult().isSingleton()) {
				throw new IllegalStateException("Adding element " + element + " in source box " + sourceBox + " violate singleton constraints of the result box " + getResult());
			}
		}

		@Override
		public void removed(int index, E element) {
			if (index == 0) {
				if (sourceBox.length() == 0) {
					if (reversed && !getResult().isOptional()) {
						throw new IllegalStateException("Removing element " + element + " in source box " + sourceBox + " violate non-optional constraints of the result box " + getResult());
					} else {
						getResult().clear();
					}
				} else {
					getResult().set(0, sourceBox.get(0));
				}
			}
		}

		@Override
		public void replaced(int index, E newElement, E oldElement) {
			if (index == 0) {
				getResult().set(0, newElement);
			}
		}

		@Override
		public void moved(int newIndex, int oldIndex, E element) {
			if (newIndex == 0) {
				getResult().set(0, element);
			} else if(oldIndex == 0) {
				getResult().set(0, sourceBox.get(0));
			}
		}

	}

	private class ResultObserver extends DefaultObserver<E> {

		@Override
		public void added(int index, E element) {
			sourceBox.add(0, element);
		}

		@Override
		public void removed(int index, E element) {
			if (!sourceBox.isOptional()) {
				throw new IllegalStateException("Clearing the option result box is forbidden when the source box " + sourceBox + " is a one box");
			} else {
				sourceBox.clear();
			}
		}

		@Override
		public void replaced(int index, E newElement, E oldElement) {
			if (sourceBox.length() == 0) {
				sourceBox.add(newElement);
			} else {
				sourceBox.set(index, newElement);
			}

		}

		@Override
		public void moved(int newIndex, int oldIndex, E element) {
		}

	}
}
