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
import org.eclipse.papyrus.aof.core.ISequence;

public class Sequence<E> extends Collection<E> implements ISequence<E> {

	// IConstrained

	@Override
	public IConstraints getConstraints() {
		return IConstraints.SEQUENCE;
	}

}
