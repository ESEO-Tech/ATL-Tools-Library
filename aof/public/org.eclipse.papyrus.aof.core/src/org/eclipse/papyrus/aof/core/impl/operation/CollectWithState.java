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

import java.util.ArrayList;
import java.util.List;

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IOne;
import org.eclipse.papyrus.aof.core.IPair;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.eclipse.papyrus.aof.core.impl.Pair;
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver;
import org.eclipse.papyrus.aof.core.impl.utils.Equality;

// An extended version of Collect that enables intermediate state.
// It does not differ much from Collect, which is actually equivalent to this class when intermediate state is not used.
public class CollectWithState<E, R, S> extends Operation<R> {

	@Override
	public boolean isUnique() {
		return getSourceBox().isSingleton();
	}

	private IBox<E> sourceBox;
	private S defaultState;
	private List<S> intermediateStates;

	private IUnaryFunction<? super E, IPair<R, S>> collector;
	private IUnaryFunction<IPair<R, S>, ? extends E> reverseCollector;

	public CollectWithState(IBox<E> sourceBox, S defaultState, IUnaryFunction<? super E, IPair<R, S>> collector, IUnaryFunction<IPair<R, S>, ? extends E> reverseCollector) {
		this.sourceBox = sourceBox;
		this.defaultState = defaultState;
		this.collector = collector;
		this.reverseCollector = reverseCollector;
		this.intermediateStates = new ArrayList<S>();
		for (E element : sourceBox) {
			IPair<R, S> ras = collector.apply(element);
			intermediateStates.add(ras.getRight());
			getResult().add(ras.getLeft());
		}
		registerObservation(sourceBox, new SourceObserver());
		if (reverseCollector != null) {
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
		return collector.apply(sourceOne.getDefaultElement()).getLeft();
	}

	private class SourceObserver extends DefaultObserver<E> {

		@Override
		public void added(int index, E element) {
			IPair<R ,S> ras = collector.apply(element);
			intermediateStates.set(index, ras.getRight());
			getResult().add(index, ras.getLeft());
		}

		@Override
		public void removed(int index, E element) {
			getResult().removeAt(index);
		}

		@Override
		public void replaced(int index, E newElement, E oldElement) {
			IPair<R ,S> ras = collector.apply(newElement);
			intermediateStates.set(index, ras.getRight());
			getResult().set(index, ras.getLeft());
		}

		@Override
		public void moved(int newIndex, int oldIndex, E element) {
			getResult().move(newIndex, oldIndex);
		}

	}

	private class ResultObserver extends DefaultObserver<R> {

		private E getInverseElement(S intermediateState, R element) {
			E inverseElement = reverseCollector.apply(new Pair<R, S>(element, intermediateState));
			IPair<R, S> forward = collector.apply(inverseElement);
			if (!Equality.optionalEquals(new Pair<R, S>(element, intermediateState), forward)) {
				throw new IllegalStateException("Element " + element + " with state " + intermediateState + " is not consistent regarding the inverse collector. The expected element with state is " + forward);
			}
			return inverseElement;
		}

		@Override
		public void added(int index, R element) {
			sourceBox.add(index, getInverseElement(defaultState, element));
		}

		@Override
		public void removed(int index, R element) {
			sourceBox.removeAt(index);
		}

		@Override
		public void replaced(int index, R newElement, R oldElement) {
			sourceBox.set(index, getInverseElement(intermediateStates.get(index), newElement));
		}

		@Override
		public void moved(int newIndex, int oldIndex, R element) {
			sourceBox.move(newIndex, oldIndex);
		}

	}

}
