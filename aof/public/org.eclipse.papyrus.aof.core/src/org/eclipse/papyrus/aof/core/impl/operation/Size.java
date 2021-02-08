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

// note: bidir version of Size should define the elements to add when the size grows by using a function that give the element for the given position
public class Size<E> extends Operation<Integer> {

	private IBox<E> sourceBox;

	public Size(IBox<E> sourceBox) {
		this.sourceBox = sourceBox;
		setSize();
		registerObservation(sourceBox, new SourceObserver());
	}

	@Override
	public boolean isOptional() {
		return false;
	}

	@Override
	public boolean isSingleton() {
		return true;
	}

	@Override
	public boolean isOrdered() {
		return true;
	}

	@Override
	public boolean isUnique() {
		return true;
	}

	@Override
	public Integer getResultDefautElement() {
		// only called when resultBox instanceof IOne
		return 1;
	}

	@Override
	public IOne<Integer> getResult() {
		return (IOne<Integer>) super.getResult();
	}

	private void setSize() {
		getResult().add(0, sourceBox.length());
	}

	private class SourceObserver extends DefaultObserver<E> {

		@Override
		public void added(int index, E element) {
			setSize();
		}

		@Override
		public void removed(int index, E element) {
			setSize();
		}

		@Override
		public void replaced(int index, E newElement, E oldElement) {
		}

		@Override
		public void moved(int newIndex, int oldIndex, E element) {
		}

	}

}
