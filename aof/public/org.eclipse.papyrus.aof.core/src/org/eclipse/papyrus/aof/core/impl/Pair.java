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

import org.eclipse.papyrus.aof.core.IPair;
import org.eclipse.papyrus.aof.core.impl.operation.Inspect;
import org.eclipse.papyrus.aof.core.impl.utils.Equality;

public class Pair<L, R> implements IPair<L, R> {

	private L first;

	private R second;

	public Pair(L first, R second) {
		super();
		this.first = first;
		this.second = second;
	}

	@Override
	public L getLeft() {
		return first;
	}

	@Override
	public R getRight() {
		return second;
	}

	// Object

	@Override
	public String toString() {
		return "(" + Inspect.toString(first, null) + ", " + Inspect.toString(second, null) + ")";
	}

	@Override
	public boolean equals(Object other) {
		if (other instanceof Pair<?, ?>) {
			Pair<L, R> that = (Pair<L, R>) other;
			return Equality.optionalEquals(this.first, that.first) && Equality.optionalEquals(this.second, that.second);
		} else {
			return false;
		}
	}

	@Override
	public int hashCode() {
		int firstHashCode = this.first == null ? 0 : this.first.hashCode();
		int secondHashCode = this.second == null ? 0 : this.second.hashCode();
		return firstHashCode + secondHashCode * 67;
	}

}
