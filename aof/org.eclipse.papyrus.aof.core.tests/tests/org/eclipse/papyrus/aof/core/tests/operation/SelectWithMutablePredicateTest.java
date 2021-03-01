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

import org.eclipse.papyrus.aof.core.AOFFactory;
import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.eclipse.papyrus.aof.core.IOne;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class SelectWithMutablePredicateTest extends AbstractSelectTest {

	protected IBox<Integer> select(IBox<Integer> a, final IUnaryFunction<Integer, Boolean> f) {
		return a.selectMutable(new IUnaryFunction<Integer, IOne<Boolean>>() {
			public IOne<Boolean> apply(Integer a) {
				// not a typical example since Integer is immutable
				// see the javadoc example for IBox.selectMutable
				return AOFFactory.INSTANCE.createOne(f.apply(a));
			}
		});
	}

	// Remove Bidir

	@Test
	public void testRemoveForBidirSelectOnSequence() {
		testRemoveForBidirSelect(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	// collectMutable should be tested in the same way, but can it really fail in a similar way?
	// This test currently fails
	// Some other changes would not explicitly fail unless internal state checks of SelectWithMutablePredicate are enabled in InnerBoxObserver
	// AOF2 should be able to handle it by taking it into account (source < inner) in the topological sort
	@Test
	public void testInnerBeforeSource() {
		final IBox<Integer> a = factory.createSequence(2);
		final IOne<Boolean> b = a.collect(isOdd).asOne(false);
		a.selectMutable(new IUnaryFunction<Integer, IOne<Boolean>>() {
			@Override
			public IOne<Boolean> apply(Integer parameter) {
				return b;
			}
		});
		a.add(0, 1);
	}
}
