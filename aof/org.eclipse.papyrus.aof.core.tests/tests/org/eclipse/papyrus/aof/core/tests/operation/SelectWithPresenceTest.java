/*******************************************************************************
 *  Copyright (c) 2015 ESEO.
 *  All rights reserved. This program and the accompanying materials
 *  are made available under the terms of the Eclipse Public License v1.0
 *  which accompanies this distribution, and is available at
 *  http://www.eclipse.org/legal/epl-v10.html
 *
 *  Contributors:
 *     Olivier Beaudoux - JUnit testing of SelectMutables operation on all box types
 *******************************************************************************/
package org.eclipse.papyrus.aof.core.tests.operation;

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class SelectWithPresenceTest extends AbstractSelectTest {

	@Override
	protected IBox<Integer> select(IBox<Integer> a, IUnaryFunction<Integer, Boolean> f) {
		IBox<Boolean> b = a.collect(f);
		return a.selectMutable(b);
	}

	// Remove Bidir

	@Test
	public void testRemoveForBidirSelectOnSequence() {
		testRemoveForBidirSelect(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

}
