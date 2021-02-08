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
import org.eclipse.papyrus.aof.core.IUnaryFunction;

// An extended version of Collect that assumes that the given collector is bijective
// it only differs from Collect regarding the isUnique constraints which is the same than the source box, thanks to the bijectivity
public class CollectBijective<E, R> extends Collect<E, R> {

	public CollectBijective(IBox<E> sourceBox, IUnaryFunction<? super E, ? extends R> collector) {
		super(sourceBox, collector);
	}

	public CollectBijective(IBox<E> sourceBox, IUnaryFunction<E, R> collector, IUnaryFunction<R, E> inverseCollector) {
		super(sourceBox, collector, inverseCollector);
	}

	@Override
	public boolean isUnique() {
		return getSourceBox().isUnique();
	}

}
