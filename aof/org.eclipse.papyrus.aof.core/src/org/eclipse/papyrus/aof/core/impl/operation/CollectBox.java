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
import org.eclipse.papyrus.aof.core.IObserver;
import org.eclipse.papyrus.aof.core.IOne;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver;
import org.eclipse.papyrus.aof.core.impl.utils.cache.IBinaryCache;
import org.eclipse.papyrus.aof.core.impl.utils.cache.WeakKeysWeakValuesBinaryCache;

public class CollectBox<E, R> extends Operation<R> {

	private IBox<E> sourceBox;

	private IUnaryFunction<? super E, ? extends IBox<R>> collector;

	private IBox<R> resultDefault;

	public CollectBox(IBox<E> sourceBox, E sourceDefault, IUnaryFunction<? super E, ? extends IBox<R>> collector) {
		this.sourceBox = sourceBox;
		this.collector = collector;
		// if the cache already contains the result, don't compute it twice
		if (cache.get(sourceBox, collector) == null) {
			// try to get the result default: if the sourceDefault is null and the collector does not handle this null
			// value, it is a large change to throw a null pointer exception
			try {
				this.resultDefault = collector.apply(sourceDefault);
			} catch (NullPointerException exception) {
				if (sourceDefault == null) {
					throw new IllegalStateException("The collector must provide a default box given a null argument value", exception);
				} else {
					throw exception;
				}
			}
			SourceObserver sourceObserver = new SourceObserver();
			// register first so that we can use its added method in the init phase
			registerObservation(sourceBox, sourceObserver);
			// init phase
			for (int i = 0; i < sourceBox.length(); i++) {
				sourceObserver.addedInternal(i, sourceBox.get(i), false);
			}
			// backward observation
			registerObservation(getResult(), new ResultObserver());
		}
	}

	@Override
	public boolean isOptional() {
		return sourceBox.isOptional() || resultDefault.isOptional();
	}

	@Override
	public boolean isSingleton() {
		return sourceBox.isSingleton() && resultDefault.isSingleton();
	}

	@Override
	public boolean isOrdered() {
		return sourceBox.isOrdered() && resultDefault.isOrdered();
	}

	@Override
	public boolean isUnique() {
		return sourceBox.isSingleton() && resultDefault.isUnique();
	}

	@Override
	public R getResultDefautElement() {
		IOne<E> sourceOne = (IOne<E>) sourceBox;
		IOne<R> innerOne = (IOne<R>) collector.apply(sourceOne.getDefaultElement());
		return innerOne.getDefaultElement();
	}


	// cache implementation

	// must be weak if static... would be better if user provided/controlled
	private static IBinaryCache<IBox<?>, IUnaryFunction<?, ?>, IBox<?>> cache = new WeakKeysWeakValuesBinaryCache<IBox<?>, IUnaryFunction<?, ?>, IBox<?>>();

	@Override
	public IBox<R> getResult() {
		IBox<R> result = (IBox<R>) cache.get(sourceBox, collector);
		if (result == null) {
			result = super.getResult();
			cache.put(sourceBox, collector, result);
		}
		return result;
	}

	// active algorithm

	private List<IObserver<R>> innerObservers = new ArrayList<IObserver<R>>();

	private class SourceObserver extends DefaultObserver<E> {

		@Override
		public void added(int index, E element) {
			addedInternal(index, element, true);
		}

		public void addedInternal(int index, E element, boolean silence) {
			InnerBoxObserver innerObserver = new InnerBoxObserver();
			IBox<R> innerBox = collector.apply(element);
			// init phase of the inner box
			IObserver<R> silentObserver = registerObservation(innerBox, innerObserver);
			innerObservers.add(index, silentObserver);
			innerObserver.silentObserver = silentObserver;
			// we must silence other observers manually because of the silentObserver by-passing
			if(silence) {
				silent(true);
			}
			if((!isSingleton()) && index == innerObservers.size() - 1) {
				// we added at the end, no need to compute sumSizes
				innerObserver.addedAll(getResult().length(), innerBox);
			} else {
				innerObserver.addedAll(innerBox);
			}
			if(silence) {
				silent(false);
			}
		}

		@Override
		public void removed(int index, E element) {
			IObserver<R> innerObserver = innerObservers.get(index);
			IBox<R> innerBox = collector.apply(element);
			for (R innerElement : innerBox) {
				innerObserver.removed(0, innerElement);
			}
			innerObservers.remove(index);
			unregisterObservation(innerBox, innerObserver);
			innerObserver.setDisabled(true); // in case it is still in a collection being iterated upon
		}

		@Override
		public void replaced(int index, E newElement, E oldElement) {
			removed(index, oldElement);
			added(index, newElement);
			// should be optimized...
		}

		@Override
		public void moved(int newIndex, int oldIndex, E e) {
			removed(oldIndex, e);
			added(newIndex, e);
			// should be optimized...
		}

	}

	// cannot be implemented as an inner class witin SourceObserver due to closure limitation (index i is constant
	// inside the closure)
	private class InnerBoxObserver extends DefaultObserver<R> {
		public IObserver<R> silentObserver;

		// Position of the element to insert/remove/update
		// Note that index i is retrieved from the index of this inner observer within the registered inner
		// observers. It cannot be given by the observation of 'a' due to function closure.
		private int outerIndex(int j) {
			int i = innerObservers.indexOf(silentObserver);
			return j + sumSizes(i);
		}

		public void addedAll(IBox<R> innerBox) {
			addedAll(outerIndex(0), innerBox);
		}

		public void addedAll(int index, IBox<R> innerBox) {
			for(R element : innerBox) {
				getResult().add(index++, element);
			}
		}

		@Override
		public void added(int index, R element) {
			getResult().add(outerIndex(index), element);
		}

		@Override
		public void removed(int index, R element) {
			getResult().removeAt(outerIndex(index));
		}

		@Override
		public void replaced(int index, R newElement, R oldElement) {
			getResult().set(outerIndex(index), newElement);
		}

		@Override
		public void moved(int newIndex, int oldIndex, R element) {
			getResult().move(outerIndex(newIndex), outerIndex(oldIndex));
		}

	}

	// a.elements.slice(0, i).map(e => f(e).elements.size).sum()
	private int sumSizes(int until) {
		int sum = 0;
		for (int i = 0; i < until; i++) {
			IBox<R> b = collector.apply(sourceBox.get(i));
			sum += b.length();
		}
		return sum;
	}

	private class ResultObserver extends DefaultObserver<R> {

		private IBox<R> getInnerBox() {
			if (!sourceBox.isSingleton()) {
				throw new IllegalStateException("Writing on the collect result " + sourceBox + " is restructed to singleton result");
			}
			E sourceElement = sourceBox.get(0);
			return collector.apply(sourceElement);
		}

		@Override
		public void added(int index, R element) {
			if (sourceBox.length() > 0) {
				getInnerBox().add(index, element);
			}
		}

		@Override
		public void removed(int index, R element) {
			if (sourceBox.length() > 0) {
				getInnerBox().removeAt(index);
			}
		}

		@Override
		public void replaced(int index, R newElement, R oldElement) {
			if (sourceBox.length() > 0) {
				getInnerBox().set(index, newElement);
			}
		}

		@Override
		public void moved(int newIndex, int oldIndex, R element) {
			if (sourceBox.length() > 0) {
				getInnerBox().move(newIndex, oldIndex);
			}
		}

	}
}
