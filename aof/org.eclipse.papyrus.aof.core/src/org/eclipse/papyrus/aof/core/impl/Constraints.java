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

import org.eclipse.papyrus.aof.core.IConstraints;

public class Constraints implements IConstraints {

	private boolean optional;
	private boolean singleton;
	private boolean ordered;
	private boolean unique;

	public Constraints(IConstraints that) {
		this(that.isOptional(), that.isSingleton(), that.isOrdered(), that.isUnique());
	}

	public Constraints(boolean optional, boolean singleton, boolean ordered, boolean unique) {
		this.optional = optional;
		this.singleton = singleton;
		this.ordered = ordered;
		this.unique = unique;
	}

	@Override
	public boolean isOptional() {
		return optional;
	}

	@Override
	public boolean isSingleton() {
		return singleton;
	}

	@Override
	public boolean isOrdered() {
		return ordered;
	}

	@Override
	public boolean isUnique() {
		return unique;
	}

	@Override
	public boolean isLegal() {
		return this.equals(IConstraints.OPTION) || this.equals(IConstraints.ONE) ||
				this.equals(IConstraints.SET) || this.equals(IConstraints.ORDERED_SET) ||
				this.equals(IConstraints.SEQUENCE) || this.equals(IConstraints.BAG);
	}

	@Override
	public boolean matches(IConstraints that) {
		return (this.isOptional() == that.isOptional()) &&
				(this.isSingleton() == that.isSingleton()) &&
				(this.isOrdered() == that.isOrdered()) &&
				(this.isUnique() == that.isUnique());
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + (optional ? 1231 : 1237);
		result = prime * result + (ordered ? 1231 : 1237);
		result = prime * result + (singleton ? 1231 : 1237);
		result = prime * result + (unique ? 1231 : 1237);
		return result;
	}

	@Override
	public boolean equals(Object other) {
		if (other == null) {
			return false;
		} else if (this == other) {
			return true;
		} else if (other instanceof IConstraints) {
			IConstraints that = (IConstraints) other;
			return this.matches(that);
		} else {
			return super.equals(other);
		}
	}

	@Override
	public String toString() {
		if (this.equals(IConstraints.OPTION)) {
			return "opt";
		} else if (this.equals(IConstraints.ONE)) {
			return "one";
		} else if (this.equals(IConstraints.SET)) {
			return "set";
		} else if (this.equals(IConstraints.ORDERED_SET)) {
			return "oset";
		} else if (this.equals(IConstraints.SEQUENCE)) {
			return "seq";
		} else if (this.equals(IConstraints.BAG)) {
			return "bag";
		} else {
			return "optional: " + optional + ", singleton: " + singleton +
					", ordered: " + ordered + ", unique: " + unique;
		}
	}

}
