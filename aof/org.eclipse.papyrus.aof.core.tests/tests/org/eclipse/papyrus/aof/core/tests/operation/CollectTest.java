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
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.eclipse.papyrus.aof.core.tests.BaseTest;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class CollectTest extends BaseTest {

	public static IUnaryFunction<Integer, Integer> increment = new IUnaryFunction<Integer, Integer>() {
		@Override
		public Integer apply(Integer i) {
			return i + 1;
		}
	};

	public static IUnaryFunction<Integer, Integer> decrement = new IUnaryFunction<Integer, Integer>() {
		@Override
		public Integer apply(Integer i) {
			return i - 1;
		}
	};

	public static IUnaryFunction<Integer, Integer> mult2 = new IUnaryFunction<Integer, Integer>() {
		@Override
		public Integer apply(Integer i) {
			return i * 2;
		}
	};

	public static IUnaryFunction<Integer, Integer> div2 = new IUnaryFunction<Integer, Integer>() {
		@Override
		public Integer apply(Integer i) {
			return i / 2;
		}
	};

	// Create

	@Test
	public void testCreateForCollectOnSequence() {
		testCreateForCollect(IConstraints.SEQUENCE, IConstraints.SEQUENCE, 2, 3, 3, 4, 4, 4, 5);
	}

	@Test
	public void testCreateForCollectOnBag() {
		testCreateForCollect(IConstraints.BAG, IConstraints.BAG, 2, 3, 3, 4, 4, 4, 5);
	}

	@Test
	public void testCreateForCollectOnOrderedSet() {
		testCreateForCollect(IConstraints.ORDERED_SET, IConstraints.SEQUENCE, 2, 3, 4, 5);
	}

	@Test
	public void testCreateForCollectOnSet() {
		testCreateForCollect(IConstraints.SET, IConstraints.BAG, 2, 3, 4, 5);
	}

	@Test
	public void testCreateForCollectOnOption() {
		testCreateForCollect(IConstraints.OPTION, IConstraints.OPTION, 5);
	}

	@Test
	public void testCreateForCollectOnOne() {
		testCreateForCollect(IConstraints.ONE, IConstraints.ONE, 5);
	}

	public void testCreateForCollect(IConstraints inputType, IConstraints expectedType, Integer... expectedElements) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.collect(increment);
		IBox<Integer> expected = factory.createBox(expectedType, expectedElements);
		assertEquals(expected, b);
	}

	// Add

	@Test
	public void testAddForCollectOnSequence() {
		testAddForCollect(IConstraints.SEQUENCE);
	}

	@Test
	public void testAddForCollectOnBag() {
		testAddForCollect(IConstraints.BAG);
	}

	@Test
	public void testAddForCollectOnOrderedSet() {
		testAddForCollect(IConstraints.ORDERED_SET);
	}

	@Test
	public void testAddForCollectOnSet() {
		testAddForCollect(IConstraints.SET);
	}

	@Test
	public void testAddForCollectOnOption() {
		testAddForCollect(IConstraints.OPTION);
	}

	@Test
	public void testAddForCollectOnOne() {
		testAddForCollect(IConstraints.ONE);
	}

	public void testAddForCollect(IConstraints inputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 3);
		IBox<Integer> b = a.collect(increment);
		if (a.isSingleton()) {
			a.add(0, 4);
		}
		else {
			a.add(4);
			if (!a.isUnique()) {
				a.add(1, 2);
				a.add(3, 3);
				a.add(3, 3);
			}
		}
		assertEquals(a.collect(increment), b);
	}

	// Remove

	@Test
	public void testRemoveForCollectOnSequence() {
		testRemoveForCollect(IConstraints.SEQUENCE, IConstraints.SEQUENCE, 3, 4, 4, 4, 5);
	}

	@Test
	public void testRemoveForCollectOnBag() {
		testRemoveForCollect(IConstraints.BAG, IConstraints.BAG, 3, 4, 4, 4, 5);
	}

	@Test
	public void testRemoveForCollectOnOrderedSet() {
		testRemoveForCollect(IConstraints.ORDERED_SET, IConstraints.SEQUENCE, 3, 5);
	}

	@Test
	public void testRemoveForCollectOnSet() {
		testRemoveForCollect(IConstraints.SET, IConstraints.BAG, 3, 5);
	}

	@Test
	public void testRemoveForCollectOnOption() {
		testRemoveForCollect(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testRemoveForCollectOnOne() {
		testRemoveForCollect(IConstraints.ONE, IConstraints.ONE, 2);
	}

	public void testRemoveForCollect(IConstraints inputType, IConstraints expectedType, Integer... expectedElements) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.collect(increment);
		if (!a.isSingleton()) {
			a.removeAt(2);
		}
		a.removeAt(0);
		assertEquals(a.collect(increment), b);
	}

	// Replace

	@Test
	public void testReplaceForCollectOnSequence() {
		testReplaceForCollect(IConstraints.SEQUENCE);
	}

	@Test
	public void testReplaceForCollectOnBag() {
		testReplaceForCollect(IConstraints.BAG);
	}

	@Test
	public void testReplaceForCollectOnOrderedSet() {
		testReplaceForCollect(IConstraints.ORDERED_SET);
	}

	@Test
	public void testReplaceForCollectOnSet() {
		testReplaceForCollect(IConstraints.SET);
	}

	@Test
	public void testReplaceForCollectOnOption() {
		testReplaceForCollect(IConstraints.OPTION);
	}

	@Test
	public void testReplaceForCollectOnOne() {
		testReplaceForCollect(IConstraints.ONE);
	}

	public void testReplaceForCollect(IConstraints inputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.collect(increment);
		a.set(0, 5);
		if (!a.isSingleton()) {
			a.set(1, 1);
			a.set(3, 2);
		}
		assertEquals(a.collect(increment), b);
	}

	// Move

	@Test
	public void testMoveForCollectOnSequence() {
		testMoveForCollect(IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForCollectOnBag() {
		testMoveForCollect(IConstraints.BAG);
	}

	@Test
	public void testMoveForCollectOnOrderedSet() {
		testMoveForCollect(IConstraints.ORDERED_SET);
	}

	@Test
	public void testMoveForCollectOnSet() {
		testMoveForCollect(IConstraints.SET);
	}

	@Test
	public void testMoveForCollectOnOption() {
		testMoveForCollect(IConstraints.OPTION);
	}

	@Test
	public void testMoveForCollectOnOne() {
		testMoveForCollect(IConstraints.ONE);
	}

	public void testMoveForCollect(IConstraints inputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.collect(increment);
		if (a.isSingleton()) {
			a.move(0, 0);
		}
		else {
			a.move(0, 1);
			a.move(2, 1);
		}
		assertEquals(a.collect(increment), b);
	}

	// Clear

	@Test
	public void testClearForCollectOnSequence() {
		testClearForCollect(IConstraints.SEQUENCE);
	}

	@Test
	public void testClearForCollectOnBag() {
		testClearForCollect(IConstraints.BAG);
	}

	@Test
	public void testClearForCollectOnOrderedSet() {
		testClearForCollect(IConstraints.ORDERED_SET);
	}

	@Test
	public void testClearForCollectOnSet() {
		testClearForCollect(IConstraints.SET);
	}

	@Test
	public void testClearForCollectOnOption() {
		testClearForCollect(IConstraints.OPTION);
	}

	@Test
	public void testClearForCollectOnOne() {
		testClearForCollect(IConstraints.ONE);
	}

	public void testClearForCollect(IConstraints inputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.collect(increment);
		a.clear();
		assertEquals(a.collect(increment), b);
	}

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
		IBox<Integer> b = a.collect(increment, decrement);
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
		assertEquals(b, a.collect(increment, decrement));
	}

	@Test
	public void testAddForInconsistentBidirCollect() {
		IBox<Integer> a = factory.createSequence(1, 2);
		IBox<Integer> b = a.collect(mult2, div2);
		a.add(3);
		b.add(2); // consistent
		assertEquals(b, a.collect(mult2));
		thrown.expect(IllegalStateException.class);
		b.add(3);// inconsistent
		assertEquals(b, a.collect(mult2));
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
		IBox<Integer> b = a.collect(increment, decrement);
		if (!b.isSingleton()) {
			b.removeAt(2);
		}
		b.removeAt(0);
		assertEquals(b, a.collect(increment, decrement));
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
		IBox<Integer> b = a.collect(increment, decrement);
		b.set(0, 6);
		if (!b.isSingleton()) {
			b.set(1, 1);
			b.set(3, 2);
		}
		assertEquals(b, a.collect(increment, decrement));
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
		IBox<Integer> b = a.collect(increment, decrement);
		if (b.isSingleton()) {
			b.move(0, 0);
		}
		else {
			b.move(0, 1);
			b.move(2, 1);
		}
		assertEquals(b, a.collect(increment, decrement));
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
		IBox<Integer> b = a.collect(increment, decrement);
		b.clear();
		assertEquals(b, a.collect(increment, decrement));
	}

}
