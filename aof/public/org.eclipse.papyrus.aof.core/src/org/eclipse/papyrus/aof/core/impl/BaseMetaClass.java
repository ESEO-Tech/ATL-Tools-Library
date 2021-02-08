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
package org.eclipse.papyrus.aof.core.impl;

import org.eclipse.papyrus.aof.core.IMetaClass;

public abstract class BaseMetaClass<C> implements IMetaClass<C> {

	private C defaultInstance;

	// must returns null is the default instance cannot be computed automatically
	protected abstract C computeDefaultInstance();

	// IMetaClass

	@Override
	public C getDefaultInstance() {
		if (defaultInstance == null) {
			defaultInstance = computeDefaultInstance();
		}
		if (defaultInstance == null) {
			throw new IllegalStateException("Class " + this + " has no defined default instance");
		}
		return defaultInstance;
	}

	@Override
	public void setDefaultInstance(C defaultInstance) {
		if (defaultInstance == null) {
			throw new IllegalArgumentException("A default instance can never be null");
		}
		if (this.defaultInstance != null) {
			throw new IllegalStateException("Default instance " + this.defaultInstance + " has been already defined for class " + this);
		}
		if (!isInstance(defaultInstance)) {
			throw new IllegalStateException("Default instance " + defaultInstance + " is not an instance of " + this);
		}
		this.defaultInstance = defaultInstance;
	}

}
