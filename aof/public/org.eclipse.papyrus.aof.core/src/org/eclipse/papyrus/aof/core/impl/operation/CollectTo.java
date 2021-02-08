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
import org.eclipse.papyrus.aof.core.impl.utils.Cache;
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver;

// note that the cache works only if collector functions are defines once, i.e. they must have the same reference.
public class CollectTo<E, R> extends Operation<R> {

	private static Cache cache = new Cache();

	public static Cache getCache() {
		return cache;
	}

	private IBox<E> sourceBox;

	private IUnaryFunction<E, R> collector;

	private IUnaryFunction<R, E> inverseCollector;

	public CollectTo(IBox<E> sourceBox, IUnaryFunction<? super E, ? extends R> collector) {
		this(sourceBox, (IUnaryFunction<E, R>) collector, null);
	}

	public CollectTo(IBox<E> sourceBox, IUnaryFunction<E, R> collector, IUnaryFunction<R, E> inverseCollector) {
		this.sourceBox = sourceBox;
		this.collector = collector;
		this.inverseCollector = inverseCollector;
		for (E element : sourceBox) {
			getResult().add(getTarget(element));
		}
		registerObservation(sourceBox, new SourceObserver());
		if (inverseCollector != null) {
			registerObservation(getResult(), new ResultObserver());
		}
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
	public boolean isUnique() {
		return sourceBox.isUnique();
	}

	@Override
	public R getResultDefautElement() {
		IOne<E> sourceOne = (IOne<E>) sourceBox;
		return getTarget(sourceOne.getDefaultElement());
	}

	private void addLinkInCache(E source, R target) {
		cache.addLink(source, collector, target);
		if (inverseCollector != null) {
			cache.addLink(target, inverseCollector, source);
		}
	}

	private R getTarget(E source) {
		R target = (R) cache.getTarget(source, collector);
		if (target == null) {
			target = collector.apply(source);
			addLinkInCache(source, target);
		}
		return target;
	}

	private class SourceObserver extends DefaultObserver<E> {

		@Override
		public void added(int index, E element) {
			getResult().add(index, getTarget(element));
		}

		@Override
		public void removed(int index, E element) {
			getResult().removeAt(index);
		}

		@Override
		public void replaced(int index, E newElement, E oldElement) {
			getResult().set(index, getTarget(newElement));
		}

		@Override
		public void moved(int newIndex, int oldIndex, E element) {
			getResult().move(newIndex, oldIndex);
		}

	}

	private class ResultObserver extends DefaultObserver<R> {

		private E getSource(R target) {
			E source = (E) cache.getTarget(target, inverseCollector);
			if (source == null) {
				source = inverseCollector.apply(target);
				addLinkInCache(source, target);
			}
			return source;
		}

		@Override
		public void added(int index, R element) {
			sourceBox.add(index, getSource(element));
		}

		@Override
		public void removed(int index, R element) {
			sourceBox.removeAt(index);
		}

		@Override
		public void replaced(int index, R newElement, R oldElement) {
			sourceBox.set(index, getSource(newElement));
		}

		@Override
		public void moved(int newIndex, int oldIndex, R element) {
			sourceBox.move(newIndex, oldIndex);
		}

	}
}
