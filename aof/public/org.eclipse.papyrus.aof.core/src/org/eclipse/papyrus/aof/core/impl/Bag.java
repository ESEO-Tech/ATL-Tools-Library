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

import org.eclipse.papyrus.aof.core.IBag;
import org.eclipse.papyrus.aof.core.IConstraints;

public class Bag<E> extends Collection<E> implements IBag<E> {

	// IConstrained

	@Override
	public IConstraints getConstraints() {
		return IConstraints.BAG;
	}

}
