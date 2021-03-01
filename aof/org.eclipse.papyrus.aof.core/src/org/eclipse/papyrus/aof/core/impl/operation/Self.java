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

public abstract class Self<E> extends Operation<E> {

	private IBox<E> selfBox;

	protected Self(IBox<E> selfBox) {
		this.selfBox = selfBox;
	}

	@Override
	public boolean isOptional() {
		return selfBox.isOptional();
	}

	@Override
	public boolean isSingleton() {
		return selfBox.isSingleton();
	}

	@Override
	public boolean isOrdered() {
		return selfBox.isOrdered();
	}

	@Override
	public boolean isUnique() {
		return selfBox.isUnique();
	}

	@Override
	public IBox<E> getResult() {
		return selfBox;
	}

	@Override
	public E getResultDefautElement() {
		IOne<E> selfOne = (IOne<E>) selfBox;
		return selfOne.getDefaultElement();
	}

}
