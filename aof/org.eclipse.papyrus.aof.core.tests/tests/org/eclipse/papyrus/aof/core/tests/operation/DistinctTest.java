/*******************************************************************************
 *  Copyright (c) 2015 ESEO.
 *  All rights reserved. This program and the accompanying materials
 *  are made available under the terms of the Eclipse Public License v1.0
 *  which accompanies this distribution, and is available at
 *  http://www.eclipse.org/legal/epl-v10.html
 *
 *  Contributors:
 *     Olivier Beaudoux - JUnit testing of apply operation on all box types
 *******************************************************************************/
package org.eclipse.papyrus.aof.core.tests.operation;

import static org.junit.Assert.assertTrue;

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.eclipse.papyrus.aof.core.tests.BaseTest;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class DistinctTest extends BaseTest {

	// Create

	@Test
	public void testCreateForDistinctOnSequence() {
		testCreateForDistinct(IConstraints.SEQUENCE, IConstraints.ORDERED_SET, 1, 2, 3, 4);
	}

	@Test
	public void testCreateForDistinctOnBag() {
		testCreateForDistinct(IConstraints.BAG, IConstraints.SET, 1, 2, 3, 4);
	}

	@Test
	public void testCreateForDistinctOnOrderedSet() {
		testCreateForDistinct(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET, 1, 2, 3, 4);
	}

	@Test
	public void testCreateForDistinctOnSet() {
		testCreateForDistinct(IConstraints.SET, IConstraints.SET, 1, 2, 3, 4);
	}

	@Test
	public void testCreateForDistinctOnOption() {
		testCreateForDistinct(IConstraints.OPTION, IConstraints.OPTION, 4);
	}

	@Test
	public void testCreateForDistinctOnOne() {
		testCreateForDistinct(IConstraints.ONE, IConstraints.ONE, 4);
	}

	public void testCreateForDistinct(IConstraints inputType, IConstraints expectedType, Integer... expectedElements) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.distinct();
		if (a.isUnique()) {
			assertTrue(a == b);
		}
		else {
			// compute the result from a Java class (implementing Set)?
			IBox<Integer> expected = factory.createBox(expectedType, expectedElements);
			assertEquals(expected, b);
			// check for ref equality in case of set/oset/one/opt
		}
	}

	// Add

	@Test
	public void testAddForDistinctOnSequence() {
		testAddForDistinct(IConstraints.SEQUENCE, IConstraints.ORDERED_SET);
	}

	@Test
	public void testAddForDistinctOnBag() {
		testAddForDistinct(IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testAddForDistinctOnOrderedSet() {
		testAddForDistinct(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testAddForDistinctOnSet() {
		testAddForDistinct(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testAddForDistinctOnOption() {
		testAddForDistinct(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testAddForDistinctOnOne() {
		testAddForDistinct(IConstraints.ONE, IConstraints.ONE);
	}

	public void testAddForDistinct(IConstraints inputType, IConstraints expectedTypes) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.distinct();
		if (a.isSingleton()) {
			a.add(0, 5);
		}
		else {
			a.add(5);
			if (!a.isUnique()) {
				a.add(1, 2);
				a.add(3, 3);
				a.add(3, 3);
			}
		}
		assertEquals(a.distinct(), b);
	}

	// Remove

	@Test
	public void testRemoveForDistinctOnSequence() {
		testRemoveForDistinct(IConstraints.SEQUENCE, IConstraints.ORDERED_SET);
	}

	@Test
	public void testRemoveForDistinctOnBag() {
		testRemoveForDistinct(IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testRemoveForDistinctOnOrderedSet() {
		testRemoveForDistinct(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testRemoveForDistinctOnSet() {
		testRemoveForDistinct(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testRemoveForDistinctOnOption() {
		testRemoveForDistinct(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testRemoveForDistinctOnOne() {
		testRemoveForDistinct(IConstraints.ONE, IConstraints.ONE);
	}

	public void testRemoveForDistinct(IConstraints inputType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.distinct();
		if (!a.isSingleton()) {
			a.removeAt(2);
			a.removeAt(2);
		}
		a.removeAt(0);
		assertEquals(a.distinct(), b);
	}

	// Replace

	@Test
	public void testReplaceForDistinctOnSequence() {
		testReplaceForDistinct(IConstraints.SEQUENCE, IConstraints.ORDERED_SET);
	}

	@Test
	public void testReplaceForDistinctOnBag() {
		testReplaceForDistinct(IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testReplaceForDistinctOnOrderedSet() {
		testReplaceForDistinct(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testReplaceForDistinctOnSet() {
		testReplaceForDistinct(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testReplaceForDistinctOnOption() {
		testReplaceForDistinct(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testReplaceForDistinctOnOne() {
		testReplaceForDistinct(IConstraints.ONE, IConstraints.ONE);
	}

	public void testReplaceForDistinct(IConstraints inputType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.distinct();
		a.set(0, 5);
		if (!a.isSingleton()) {
			a.set(1, 1);
			a.set(3, 2);
		}
		assertEquals(a.distinct(), b);
	}

	// Move

	@Test
	public void testMoveForDistinctOnSequence() {
		testMoveForDistinct(IConstraints.SEQUENCE, IConstraints.ORDERED_SET);
	}

	@Test
	public void testMoveForDistinctOnBag() {
		testMoveForDistinct(IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testMoveForDistinctOnOrderedSet() {
		testMoveForDistinct(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testMoveForDistinctOnSet() {
		testMoveForDistinct(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testMoveForDistinctOnOption() {
		testMoveForDistinct(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testMoveForDistinctOnOne() {
		testMoveForDistinct(IConstraints.ONE, IConstraints.ONE);
	}

	public void testMoveForDistinct(IConstraints inputType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 2, 3, 2, 3, 4, 5, 6);
		IBox<Integer> b = a.distinct();
		if (a.isSingleton()) {
			a.move(0, 0);
		}
		else {
			a.move(1, 3);
			a.move(0, 4);
		}
		assertEquals(a.distinct(), b);
	}

	// Clear

	@Test
	public void testClearForDistinctOnSequence() {
		testClearForDistinct(IConstraints.SEQUENCE, IConstraints.ORDERED_SET);
	}

	@Test
	public void testClearForDistinctOnBag() {
		testClearForDistinct(IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testClearForDistinctOnOrderedSet() {
		testClearForDistinct(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testClearForDistinctOnSet() {
		testClearForDistinct(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testClearForDistinctOnOption() {
		testClearForDistinct(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testClearForDistinctOnOne() {
		testClearForDistinct(IConstraints.ONE, IConstraints.ONE);
	}

	public void testClearForDistinct(IConstraints inputType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.distinct();
		a.clear();
		assertEquals(a.distinct(), b);
	}

	// Add bidir

	@Test
	public void testAddForBidirDistinctOnSequence() {
		testAddForBidirDistinct(IConstraints.SEQUENCE, IConstraints.ORDERED_SET);
	}

	@Test
	public void testAddForBidirDistinctOnBag() {
		testAddForBidirDistinct(IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testAddForBidirDistinctOnOrderedSet() {
		testAddForBidirDistinct(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testAddForBidirDistinctOnSet() {
		testAddForBidirDistinct(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testAddForBidirDistinctOnOption() {
		testAddForBidirDistinct(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testAddForBidirDistinctOnOne() {
		testAddForBidirDistinct(IConstraints.ONE, IConstraints.ONE);
	}

	public void testAddForBidirDistinct(IConstraints inputType, IConstraints expectedTypes) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.distinct();
		if (b.isSingleton()) {
			b.add(0, 5);
		}
		else {
			b.add(5);
			b.add(1, 6);
			b.add(3, 7);
			b.add(3, 8);
		}
		assertEquals(b, a.distinct());
	}

	// Remove bidir

	@Test
	public void testRemoveForBidirDistinctOnSequence() {
		testRemoveForBidirDistinct(IConstraints.SEQUENCE, IConstraints.ORDERED_SET);
	}

	@Test
	public void testRemoveForBidirDistinctOnBag() {
		testRemoveForBidirDistinct(IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testRemoveForBidirDistinctOnOrderedSet() {
		testRemoveForBidirDistinct(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testRemoveForBidirDistinctOnSet() {
		testRemoveForBidirDistinct(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testRemoveForBidirDistinctOnOption() {
		testRemoveForBidirDistinct(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testRemoveForBidirDistinctOnOne() {
		testRemoveForBidirDistinct(IConstraints.ONE, IConstraints.ONE);
	}

	public void testRemoveForBidirDistinct(IConstraints inputType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 2, 3, 5, 3, 4, 6);
		IBox<Integer> b = a.distinct();
		if (!b.isSingleton()) {
			b.remove(2);
			b.remove(1);
			b.remove(6);
		}
		b.removeAt(0);
		assertEquals(b, a.distinct());
	}

	// Replace bidir

	@Test
	public void testReplaceForBidirDistinctOnSequence() {
		testReplaceForBidirDistinct(IConstraints.SEQUENCE, IConstraints.ORDERED_SET);
	}

	@Test
	public void testReplaceForBidirDistinctOnBag() {
		testReplaceForBidirDistinct(IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testReplaceForBidirDistinctOnOrderedSet() {
		testReplaceForBidirDistinct(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testReplaceForBidirDistinctOnSet() {
		testReplaceForBidirDistinct(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testReplaceForBidirDistinctOnOption() {
		testReplaceForBidirDistinct(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testReplaceForBidirDistinctOnOne() {
		testReplaceForBidirDistinct(IConstraints.ONE, IConstraints.ONE);
	}

	public void testReplaceForBidirDistinct(IConstraints inputType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.distinct();
		b.set(0, 5);
		if (!b.isSingleton()) {
			b.set(1, 6);
			b.set(3, 7);
		}
		assertEquals(b, a.distinct());
	}

	// Move bidir

	@Test
	public void testMoveForBidirDistinctOnSequence() {
		testMoveForBidirDistinct(IConstraints.SEQUENCE, IConstraints.ORDERED_SET);
	}

	@Test
	public void testMoveForBidirDistinctOnBag() {
		testMoveForBidirDistinct(IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testMoveForBidirDistinctOnOrderedSet() {
		testMoveForBidirDistinct(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testMoveForBidirDistinctOnSet() {
		testMoveForBidirDistinct(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testMoveForBidirDistinctOnOption() {
		testMoveForBidirDistinct(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testMoveForBidirDistinctOnOne() {
		testMoveForBidirDistinct(IConstraints.ONE, IConstraints.ONE);
	}

	public void testMoveForBidirDistinct(IConstraints inputType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 2, 3, 3, 3, 4, 5, 5, 6);
		IBox<Integer> b = a.distinct();
		if (b.isSingleton()) {
			b.move(0, 0);
		}
		else {
			// b.move(2, 5);
			b.move(4, 0);
		}
		assertEquals(b, a.distinct());
	}

	// Clear bidir

	@Test
	public void testClearForBidirDistinctOnSequence() {
		testClearForBidirDistinct(IConstraints.SEQUENCE, IConstraints.ORDERED_SET);
	}

	@Test
	public void testClearForBidirDistinctOnBag() {
		testClearForBidirDistinct(IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testClearForBidirDistinctOnOrderedSet() {
		testClearForBidirDistinct(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testClearForBidirDistinctOnSet() {
		testClearForBidirDistinct(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testClearForBidirDistinctOnOption() {
		testClearForBidirDistinct(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testClearForBidirDistinctOnOne() {
		testClearForBidirDistinct(IConstraints.ONE, IConstraints.ONE);
	}

	public void testClearForBidirDistinct(IConstraints inputType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.distinct();
		b.clear();
		assertEquals(b, a.distinct());
	}


}
