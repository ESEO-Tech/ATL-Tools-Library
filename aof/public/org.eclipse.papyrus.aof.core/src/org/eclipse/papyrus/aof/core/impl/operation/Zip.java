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

import org.eclipse.papyrus.aof.core.AOFFactory;
import org.eclipse.papyrus.aof.core.IBinaryFunction;
import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IPair;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.eclipse.papyrus.aof.core.utils.Functions;

public class Zip<L, R> extends ZipWith<L, R, IPair<L, R>> {

	public Zip(IBox<L> leftBox, IBox<R> rightBox, boolean leftRightDependency) {
		super(leftBox, rightBox, leftRightDependency, (IBinaryFunction) pair(), (IUnaryFunction) Functions.identity());
	}

	private static <L, R> IBinaryFunction<L, R, IPair<L, R>> pair() {
		return new IBinaryFunction<L, R, IPair<L, R>>() {
			@Override
			public IPair<L, R> apply(L left, R right) {
				return AOFFactory.INSTANCE.createPair(left, right);
			}
		};
	}


	@Override
	public boolean isUnique() {
		return leftBox.isUnique() || rightBox.isUnique();
	}

}
