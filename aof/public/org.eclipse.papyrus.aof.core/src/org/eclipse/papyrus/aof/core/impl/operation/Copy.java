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
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver;

public class Copy<E> extends Operation<E> {

	private IBox<E> sourceBox;

	// throw new IllegalArguementException if the sourceBox and the resultBox have incompatible type regarding
	// the copy => the should have the same cardinality at all times => isUnique and isSingleton and isOptional
	public Copy(IBox<E> sourceBox, IBox<E> resultBox) {
//		if (sourceBox.isUnique() != resultBox.isUnique()) {
//			throw new IllegalArgumentException("Source box " + sourceBox + " should have the same uniqueness constraint that the result box " + resultBox);
//		}
//		if (sourceBox.isSingleton() != resultBox.isSingleton()) {
//			throw new IllegalArgumentException("Source box " + sourceBox + " should have the same singleton constraint that the result box " + resultBox);
//		}
//		if (sourceBox.isOptional() != resultBox.isOptional()) {
//			throw new IllegalArgumentException("Source box " + sourceBox + " should have the same optional constraint that the result box " + resultBox);
//		}
		this.sourceBox = sourceBox;
		setResult(resultBox);
		for (E element : sourceBox) {
			getResult().add(element);
		}
		registerObservation(sourceBox, new SourceObserver());
		registerObservation(getResult(), new ResultObserver());
	}

	@Override
	public E getResultDefautElement() {
		IOne<E> sourceOne = (IOne<E>) sourceBox;
		return sourceOne.getDefaultElement();
	}

	private class SourceObserver extends DefaultObserver<E> {

		@Override
		public void added(int index, E element) {
			getResult().add(index, element);
		}

		@Override
		public void removed(int index, E element) {
			getResult().removeAt(index);
		}

		@Override
		public void replaced(int index, E newElement, E oldElement) {
			getResult().set(index, newElement);
		}

		@Override
		public void moved(int newIndex, int oldIndex, E element) {
			getResult().move(newIndex, oldIndex);
		}

	}

	private class ResultObserver extends DefaultObserver<E> {

		@Override
		public void added(int index, E element) {
			sourceBox.add(index, element);
		}

		@Override
		public void removed(int index, E element) {
			sourceBox.removeAt(index);
		}

		@Override
		public void replaced(int index, E newElement, E oldElement) {
			sourceBox.set(index, newElement);
		}

		@Override
		public void moved(int newIndex, int oldIndex, E element) {
			sourceBox.move(newIndex, oldIndex);
		}

	}
}
