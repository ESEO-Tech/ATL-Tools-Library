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
import org.eclipse.papyrus.aof.core.impl.utils.Equality;

public abstract class Collect<E, R> extends Operation<R> {

	private IBox<E> sourceBox;

	private IUnaryFunction<E, R> collector;
	private IUnaryFunction<R, E> inverseCollector;

	public Collect(IBox<E> sourceBox, IUnaryFunction<? super E, ? extends R> collector) {
		this(sourceBox, (IUnaryFunction<E, R>) collector, null);
	}

	// note: necessarily bijective => should be refactored in CollectBijective

	public Collect(IBox<E> sourceBox, IUnaryFunction<E, R> collector, IUnaryFunction<R, E> inverseCollector) {
		this.sourceBox = sourceBox;
		this.collector = collector;
		this.inverseCollector = inverseCollector;
		for (E element : sourceBox) {
			getResult().add(collector.apply(element));
		}
		registerObservation(sourceBox, new SourceObserver());
		if (inverseCollector != null) {
			registerObservation(getResult(), new ResultObserver());
		}
	}

	protected IBox<E> getSourceBox() {
		return sourceBox;
	}

	@Override
	public boolean isOptional() {
		return sourceBox.isOptional();
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
	public R getResultDefautElement() {
		IOne<E> sourceOne = (IOne<E>) sourceBox;
		return collector.apply(sourceOne.getDefaultElement());
	}

	private class SourceObserver extends DefaultObserver<E> {

		@Override
		public void added(int index, E element) {
			getResult().add(index, collector.apply(element));
		}

		@Override
		public void removed(int index, E element) {
			getResult().removeAt(index);
		}

		@Override
		public void replaced(int index, E newElement, E oldElement) {
			getResult().set(index, collector.apply(newElement));
		}

		@Override
		public void moved(int newIndex, int oldIndex, E element) {
			getResult().move(newIndex, oldIndex);
		}

	}

	private class ResultObserver extends DefaultObserver<R> {

		private E getInverseElement(R element) {
			E inverseElement = inverseCollector.apply(element);
			R forwardElement = collector.apply(inverseElement);
			if (!Equality.optionalEquals(element, forwardElement)) {
				throw new IllegalStateException("Element " + element + " is not consistent regarding the inverse collector. The expected element is " + forwardElement);
			}
			return inverseElement;
		}

		@Override
		public void added(int index, R element) {
			sourceBox.add(index, getInverseElement(element));
		}

		@Override
		public void removed(int index, R element) {
			sourceBox.removeAt(index);
		}

		@Override
		public void replaced(int index, R newElement, R oldElement) {
			sourceBox.set(index, getInverseElement(newElement));
		}

		@Override
		public void moved(int newIndex, int oldIndex, R element) {
			sourceBox.move(newIndex, oldIndex);
		}

	}

}
