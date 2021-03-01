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

import org.eclipse.papyrus.aof.core.AOFFactory;
import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.eclipse.papyrus.aof.core.IObserver;
import org.eclipse.papyrus.aof.core.IOne;
import org.eclipse.papyrus.aof.core.impl.Constraints;
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver;

/**
 * An active operation with optional bidirectional capabilities.
 *
 * @param <R>
 */
public abstract class Operation<R> implements IConstraints {

	private IBox<R> resultBox;

	private List<IObserver<?>> observers = new ArrayList<IObserver<?>>();

	protected void setResult(IBox<R> resultBox) {
		if (resultBox != null) {
			this.resultBox = resultBox;
		}
	}

	// IConstraints

	// provided implementation in case of a result box created outside the operation

	@Override
	public boolean isOptional() {
		return resultBox.isOptional();
	}

	@Override
	public boolean isSingleton() {
		return resultBox.isSingleton();
	}

	@Override
	public boolean isOrdered() {
		return resultBox.isOrdered();
	}

	@Override
	public boolean isUnique() {
		return resultBox.isUnique();
	}


	// Operation


	public IBox<R> getResult() {
		if (resultBox == null) {
			resultBox = AOFFactory.INSTANCE.createBox(this);
			if (resultBox.matches(ONE)) {
				IOne<R> resultOne = (IOne<R>) getResult();
				resultOne.clear(getResultDefautElement());
			}
		}
		return resultBox;
	}

	/**
	 * Computes and returns the default element of the result box if it is one box.
	 * This method is called the first time {@link #getResult()} is invoked if the result is a one box.
	 * Requires to be implemented by derived classes, notably for bidirectional purpose (the one box
	 * result may be emptied, thus requiring the one to have a default value).
	 * 
	 * @return the default element of the one result box
	 */
	public abstract R getResultDefautElement();

	// P for "operation parameter" (including E if the operation is bidirection: result box is observed in that case)
	// required only for bidir ops (the most cases)
	public <P> IObserver<P> registerObservation(IBox<P> observedBox, IObserver<P> observer) {
		SilentObserver<P> silentObserver = new SilentObserver<P>(observer);
		observers.add(silentObserver);
		observedBox.addObserver(silentObserver);
		return silentObserver;
	}

	public <P> void unregisterObservation(IBox<P> observedBox, IObserver<P> silentObserver) {
		observers.remove(silentObserver);
		observedBox.removeObserver(silentObserver);
	}

	protected Operation<R> silent(boolean silent) {
		for (IObserver<?> observer : observers) {
			observer.setDisabled(silent);
		}
		return this;
	}

	private class SilentObserver<P> extends DefaultObserver<P> {

		private IObserver<P> wrappedObserver;

		private SilentObserver(IObserver<P> wrappedObserver) {
			this.wrappedObserver = wrappedObserver;
		}

		@Override
		public void added(int index, P element) {
			silent(true);
			wrappedObserver.added(index, element);
			silent(false);
		}

		@Override
		public void removed(int index, P element) {
			silent(true);
			wrappedObserver.removed(index, element);
			silent(false);
		}

		@Override
		public void replaced(int index, P newElement, P oldElement) {
			silent(true);
			wrappedObserver.replaced(index, newElement, oldElement);
			silent(false);
		}

		@Override
		public void moved(int newIndex, int oldIndex, P element) {
			silent(true);
			wrappedObserver.moved(newIndex, oldIndex, element);
			silent(false);
		}

	}

	// IConstraints

	// the op is legal if its constraints are legal
	// incorrect type rule of the op may result in inconsistent box types
	@Override
	public boolean isLegal() {
		IConstraints delegate = new Constraints(this);
		return delegate.isLegal();
	}

	@Override
	public boolean matches(IConstraints that) {
		IConstraints delegate = new Constraints(this);
		return delegate.matches(that);
	}


	// Object

	@Override
	public String toString() {
		return getClass().getSimpleName() + " " + new Constraints(this).toString();
	}

}
