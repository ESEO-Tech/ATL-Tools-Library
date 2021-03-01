/*******************************************************************************
 *  Copyright (c) 2015 ESEO.
 *  All rights reserved. This program and the accompanying materials
 *  are made available under the terms of the Eclipse Public License v1.0
 *  which accompanies this distribution, and is available at
 *  http://www.eclipse.org/legal/epl-v10.html
 *
 *  Contributors:
 *     Olivier Beaudoux - JUnit testing of Collect operation on all box types
 *******************************************************************************/
package org.eclipse.papyrus.aof.core.tests.operation;

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.eclipse.papyrus.aof.core.IPair;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.eclipse.papyrus.aof.core.impl.Pair;
import org.eclipse.papyrus.aof.core.tests.BaseTest;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class CollectWithStateTest extends BaseTest {

	private static int denominator = 2;

	public static IUnaryFunction<Integer, IPair<Integer, Integer>> intDiv = new IUnaryFunction<Integer, IPair<Integer, Integer>>() {
		@Override
		public IPair<Integer, Integer> apply(Integer i) {
			return new Pair<Integer, Integer>(i / denominator, i % denominator);
		}
	};

	public static IUnaryFunction<IPair<Integer, Integer>, Integer> reverseIntDiv = new IUnaryFunction<IPair<Integer, Integer>, Integer>() {
		@Override
		public Integer apply(IPair<Integer, Integer> p) {
			return p.getLeft() * denominator + p.getRight();
		}
	};

	// Add bidir

	@Test
	public void testAddForBidirCollectOnSequence() {
		testAddForBidirCollect(IConstraints.SEQUENCE);
	}

	@Test
	public void testAddForBidirCollectOnBag() {
		testAddForBidirCollect(IConstraints.BAG);
	}

	@Test
	public void testAddForBidirCollectOnOrderedSet() {
		testAddForBidirCollect(IConstraints.ORDERED_SET);
	}

	@Test
	public void testAddForBidirCollectOnSet() {
		testAddForBidirCollect(IConstraints.SET);
	}

	@Test
	public void testAddForBidirCollectOnOption() {
		testAddForBidirCollect(IConstraints.OPTION);
	}

	@Test
	public void testAddForBidirCollectOnOne() {
		testAddForBidirCollect(IConstraints.ONE);
	}

	public void testAddForBidirCollect(IConstraints inputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 3);
		IBox<Integer> b = a.collectWithState(0, intDiv, reverseIntDiv);
		if (b.isSingleton()) {
			b.add(0, 4);
		}
		else {
			if (!a.isUnique()) {
				b.add(4);
			}
			if (!b.isUnique()) {
				b.add(1, 5);
				b.add(3, 6);
				b.add(2, 7);
			}
		}
		assertEquals(b, a.collectWithState(0, intDiv, reverseIntDiv));
	}

	// Remove bidir

	@Test
	public void testRemoveForBidirCollectOnSequence() {
		testRemoveForBidirCollect(IConstraints.SEQUENCE, IConstraints.SEQUENCE, 3, 4, 4, 4, 5);
	}

	@Test
	public void testRemoveForBidirCollectOnBag() {
		testRemoveForBidirCollect(IConstraints.BAG, IConstraints.BAG, 3, 4, 4, 4, 5);
	}

	@Test
	public void testRemoveForBidirCollectOnOrderedSet() {
		testRemoveForBidirCollect(IConstraints.ORDERED_SET, IConstraints.SEQUENCE, 3, 5);
	}

	@Test
	public void testRemoveForBidirCollectOnSet() {
		testRemoveForBidirCollect(IConstraints.SET, IConstraints.BAG, 3, 5);
	}

	@Test
	public void testRemoveForBidirCollectOnOption() {
		testRemoveForBidirCollect(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testRemoveForBidirCollectOnOne() {
		testRemoveForBidirCollect(IConstraints.ONE, IConstraints.ONE, 2);
	}

	public void testRemoveForBidirCollect(IConstraints inputType, IConstraints expectedType, Integer... expectedElements) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.collectWithState(0, intDiv, reverseIntDiv);
		if (!b.isSingleton()) {
			b.removeAt(2);
		}
		b.removeAt(0);
		assertEquals(b, a.collectWithState(0, intDiv, reverseIntDiv));
	}

	// Replace bidir

	@Test
	public void testReplaceForBidirCollectOnSequence() {
		testReplaceForBidirCollect(IConstraints.SEQUENCE);
	}

	@Test
	public void testReplaceForBidirCollectOnBag() {
		testReplaceForBidirCollect(IConstraints.BAG);
	}

	@Test
	public void testReplaceForBidirCollectOnOrderedSet() {
		testReplaceForBidirCollect(IConstraints.ORDERED_SET);
	}

	@Test
	public void testReplaceForBidirCollectOnSet() {
		testReplaceForBidirCollect(IConstraints.SET);
	}

	@Test
	public void testReplaceForBidirCollectOnOption() {
		testReplaceForBidirCollect(IConstraints.OPTION);
	}

	@Test
	public void testReplaceForBidirCollectOnOne() {
		testReplaceForBidirCollect(IConstraints.ONE);
	}

	public void testReplaceForBidirCollect(IConstraints inputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.collectWithState(0, intDiv, reverseIntDiv);
		b.set(0, 6);
		if (!b.isSingleton()) {
			b.set(1, 1);
			b.set(3, 2);
		}
		assertEquals(b, a.collectWithState(0, intDiv, reverseIntDiv));
	}

	// Move bidir

	@Test
	public void testMoveForBidirCollectOnSequence() {
		testMoveForBidirCollect(IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForBidirCollectOnBag() {
		testMoveForBidirCollect(IConstraints.BAG);
	}

	@Test
	public void testMoveForBidirCollectOnOrderedSet() {
		testMoveForBidirCollect(IConstraints.ORDERED_SET);
	}

	@Test
	public void testMoveForBidirCollectOnSet() {
		testMoveForBidirCollect(IConstraints.SET);
	}

	@Test
	public void testMoveForBidirCollectOnOption() {
		testMoveForBidirCollect(IConstraints.OPTION);
	}

	@Test
	public void testMoveForBidirCollectOnOne() {
		testMoveForBidirCollect(IConstraints.ONE);
	}

	public void testMoveForBidirCollect(IConstraints inputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.collectWithState(0, intDiv, reverseIntDiv);
		if (b.isSingleton()) {
			b.move(0, 0);
		}
		else {
			b.move(0, 1);
			b.move(2, 1);
		}
		assertEquals(b, a.collectWithState(0, intDiv, reverseIntDiv));
	}

	// Clear bidir

	@Test
	public void testClearForBidirCollectOnSequence() {
		testClearForBidirCollect(IConstraints.SEQUENCE);
	}

	@Test
	public void testClearForBidirCollectOnBag() {
		testClearForBidirCollect(IConstraints.BAG);
	}

	@Test
	public void testClearForBidirCollectOnOrderedSet() {
		testClearForBidirCollect(IConstraints.ORDERED_SET);
	}

	@Test
	public void testClearForBidirCollectOnSet() {
		testClearForBidirCollect(IConstraints.SET);
	}

	@Test
	public void testClearForBidirCollectOnOption() {
		testClearForBidirCollect(IConstraints.OPTION);
	}

	@Test
	public void testClearForBidirCollectOnOne() {
		testClearForBidirCollect(IConstraints.ONE);
	}

	public void testClearForBidirCollect(IConstraints inputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.collectWithState(0, intDiv, reverseIntDiv);
		b.clear();
		assertEquals(b, a.collectWithState(0, intDiv, reverseIntDiv));
	}

}
