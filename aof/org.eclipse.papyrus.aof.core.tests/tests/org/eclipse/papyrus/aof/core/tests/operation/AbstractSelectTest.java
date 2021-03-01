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
import org.eclipse.papyrus.aof.core.tests.BaseTest;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
// annotation @FixMethodOrder not inherited
public abstract class AbstractSelectTest extends BaseTest {

	protected abstract IBox<Integer> select(IBox<Integer> a, IUnaryFunction<Integer, Boolean> f);

	public static IUnaryFunction<Integer, Boolean> isOdd = new IUnaryFunction<Integer, Boolean>() {
		@Override
		public Boolean apply(Integer i) {
			return i % 2 != 0;
		}
	};

	// Create

	@Test
	public void testCreateForSelectOnSequence() {
		testCreateForSelect(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testCreateForSelectOnBag() {
		testCreateForSelect(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testCreateForSelectOnOrderedSet() {
		testCreateForSelect(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testCreateForSelectOnSet() {
		testCreateForSelect(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testCreateForSelectOnOption() {
		testCreateForSelect(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testCreateForSelectOnOne() {
		testCreateForSelect(IConstraints.ONE, IConstraints.OPTION);
	}

	public void testCreateForSelect(IConstraints inputType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = select(a, isOdd);
		assertEquals(expectedType, b);
		assertEquals(select(a, isOdd), b);
	}

	// Add

	@Test
	public void testAddForSelectOnSequence() {
		testAddForSelect(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testAddForSelectOnBag() {
		testAddForSelect(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testAddForSelectOnOrderedSet() {
		testAddForSelect(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testAddForSelectOnSet() {
		testAddForSelect(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testAddForSelectOnOption() {
		testAddForSelect(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testAddForSelectOnOne() {
		testAddForSelect(IConstraints.ONE, IConstraints.OPTION);
	}

	public void testAddForSelect(IConstraints inputType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 3);
		IBox<Integer> b = select(a, isOdd);
		if (a.isSingleton()) {
			a.add(0, 5);
		} else {
			a.add(4);
			a.add(5);
			if (!a.isUnique()) {
				a.add(1, 2);
				a.add(3, 3);
				a.add(3, 3);
			}
		}
		assertEquals(expectedType, b);
		assertEquals(select(a, isOdd), b);
	}

	// Remove

	@Test
	public void testRemoveForSelectOnSequence() {
		testRemoveForSelect(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testRemoveForSelectOnBag() {
		testRemoveForSelect(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testRemoveForSelectOnOrderedSet() {
		testRemoveForSelect(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testRemoveForSelectOnSet() {
		testRemoveForSelect(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testRemoveForSelectOnOption() {
		testRemoveForSelect(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testRemoveForSelectOnOne() {
		testRemoveForSelect(IConstraints.ONE, IConstraints.OPTION);
	}

	public void testRemoveForSelect(IConstraints inputType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4, 5,
				7);
		IBox<Integer> b = select(a, isOdd);
		if (a.isSingleton()) {
			a.removeAt(0);
		} else {
			a.removeAt(2);
			a.removeAt(0);
		}
		assertEquals(expectedType, b);
		assertEquals(select(a, isOdd), b);
	}

	// Replace

	@Test
	public void testReplaceForSelectOnSequence() {
		testReplaceForSelect(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testReplaceForSelectOnBag() {
		testReplaceForSelect(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testReplaceForSelectOnOrderedSet() {
		testReplaceForSelect(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testReplaceForSelectOnSet() {
		testReplaceForSelect(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testReplaceForSelectOnOption() {
		testReplaceForSelect(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testReplaceForSelectOnOne() {
		testReplaceForSelect(IConstraints.ONE, IConstraints.OPTION);
	}

	public void testReplaceForSelect(IConstraints inputType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4, 5);
		IBox<Integer> b = select(a, isOdd);
		a.set(0, 6);
		if (!a.isSingleton()) {
			a.set(1, 1);
			a.set(3, 2);
		}
		assertEquals(expectedType, b);
		assertEquals(select(a, isOdd), b);
	}

	// Move

	@Test
	public void testMoveForSelectOnSequence() {
		testMoveForSelect(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForSelectOnBag() {
		testMoveForSelect(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testMoveForSelectOnOrderedSet() {
		testMoveForSelect(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testMoveForSelectOnSet() {
		testMoveForSelect(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testMoveForSelectOnOption() {
		testMoveForSelect(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testMoveForSelectOnOne() {
		testMoveForSelect(IConstraints.ONE, IConstraints.OPTION);
	}

	public void testMoveForSelect(IConstraints inputType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4, 5);
		IBox<Integer> b = select(a, isOdd);
		if (a.isSingleton()) {
			a.move(0, 0);
		} else {
			a.move(0, 1);
			a.move(3, 2);
		}
		assertEquals(expectedType, b);
		assertEquals(select(a, isOdd), b);
	}

	@Test
	public void testBigMoveForSelect() {
		IBox<Integer> a = factory.createSequence(1, 2, 2, 3, 3, 4, 5);
		IBox<Integer> b = select(a, isOdd);
		a.move(3, 4);
		a.move(1, 3);
		a.move(0, 1);
		assertEquals(select(a, isOdd), b);
	}

	@Test
	public void testBigMoveForSelect2() {
		IBox<Integer> a = factory.createSequence(1, 2, 2, 3, 3, 4, 5);
		IBox<Integer> b = select(a, isOdd);
		a.move(1, 3);
		a.move(0, 1);
		assertEquals(select(a, isOdd), b);
	}

	@Test
	public void testTwoMovesForSelect() {
		IBox<Integer> a = factory.createSequence(1, 2, 3, 4, 5);
		IBox<Integer> b = select(a, isOdd);
		a.move(1, 2);
		assertEquals(select(a, isOdd), b);
		a.move(0, 1);
		assertEquals(select(a, isOdd), b);
	}

	@Test
	public void testOneMoveForSelect() {
		IBox<Integer> a = factory.createSequence(1, 3, 2, 4, 5);
		IBox<Integer> b = select(a, isOdd);
		a.move(0, 1);
		assertEquals(select(a, isOdd), b);
	}

	// Clear

	@Test
	public void testClearForSelectOnSequence() {
		testClearForSelect(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testClearForSelectOnBag() {
		testClearForSelect(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testClearForSelectOnOrderedSet() {
		testClearForSelect(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testClearForSelectOnSet() {
		testClearForSelect(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testClearForSelectOnOption() {
		testClearForSelect(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testClearForSelectOnOne() {
		testClearForSelect(IConstraints.ONE, IConstraints.OPTION);
	}

	public void testClearForSelect(IConstraints inputType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = select(a, isOdd);
		a.clear();
		assertEquals(expectedType, b);
		assertEquals(select(a, isOdd), b);
	}

	// Add Bidir

	@Test
	public void testAddForBidirSelectOnSequence() {
		testAddForBidirSelect(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testAddForBidirSelectOnBag() {
		testAddForBidirSelect(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testAddForBidirSelectOnOrderedSet() {
		testAddForBidirSelect(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testAddForBidirSelectOnSet() {
		testAddForBidirSelect(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testAddForBidirSelectOnOption() {
		testAddForBidirSelect(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testAddForBidirSelectOnOne() {
		testAddForBidirSelect(IConstraints.ONE, IConstraints.OPTION);
	}

	public void testAddForBidirSelect(IConstraints inputType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 3);
		IBox<Integer> b = select(a, isOdd);
		b.add(0, 5);
		if (!b.isSingleton()) {
			b.add(7);
			if (!a.isUnique()) {
				b.add(2, 5);
				b.add(3, 1);
			}
		}
		assertEquals(expectedType, b);
		assertEquals(select(a, isOdd), b);
	}

	// Remove Bidir

	@Test
	public void testRemoveForBidirSelectOnSequence() {
		testRemoveForBidirSelect(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testRemoveForBidirSelectOnBag() {
		testRemoveForBidirSelect(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testRemoveForBidirSelectOnOrderedSet() {
		testRemoveForBidirSelect(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testRemoveForBidirSelectOnSet() {
		testRemoveForBidirSelect(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testRemoveForBidirSelectOnOption() {
		testRemoveForBidirSelect(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testRemoveForBidirSelectOnOne() {
		thrown.expect(IllegalStateException.class);
		testRemoveForBidirSelect(IConstraints.ONE, IConstraints.OPTION);
	}

	public void testRemoveForBidirSelect(IConstraints inputType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4, 5, 7);
		IBox<Integer> b = select(a, isOdd);
		b.removeAt(0);
		if (!b.isSingleton()) {
			b.removeAt(1);
			b.removeAt(b.length() - 1);
		}
		assertEquals(expectedType, b);
		assertEquals(select(a, isOdd), b);
	}

	// Replace Bidir

	@Test
	public void testReplaceForBidirSelectOnSequence() {
		testReplaceForBidirSelect(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testReplaceForBidirSelectOnBag() {
		testReplaceForBidirSelect(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testReplaceForBidirSelectOnOrderedSet() {
		testReplaceForBidirSelect(IConstraints.ORDERED_SET,
				IConstraints.ORDERED_SET);
	}

	@Test
	public void testReplaceForBidirSelectOnSet() {
		testReplaceForBidirSelect(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testReplaceForBidirSelectOnOption() {
		testReplaceForBidirSelect(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testReplaceForBidirSelectOnOne() {
		testReplaceForBidirSelect(IConstraints.ONE, IConstraints.OPTION);
	}

	public void testReplaceForBidirSelect(IConstraints inputType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4, 5);
		IBox<Integer> b = select(a, isOdd);
		b.set(0, 7);
		if (!a.isSingleton()) {
			b.set(1, 9);
			b.set(b.length() - 1, 11);
			b.set(2, 5);
		}
		assertEquals(expectedType, b);
		assertEquals(select(a, isOdd), b);
	}

	// Move Bidir

	@Test
	public void testMoveForBidirSelectOnSequence() {
		testMoveForBidirSelect(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForBidirSelectOnBag() {
		testMoveForBidirSelect(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testMoveForBidirSelectOnOrderedSet() {
		testMoveForBidirSelect(IConstraints.ORDERED_SET,
				IConstraints.ORDERED_SET);
	}

	@Test
	public void testMoveForBidirSelectOnSet() {
		testMoveForBidirSelect(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testMoveForBidirSelectOnOption() {
		testMoveForBidirSelect(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testMoveForBidirSelectOnOne() {
		testMoveForBidirSelect(IConstraints.ONE, IConstraints.OPTION);
	}

	public void testMoveForBidirSelect(IConstraints inputType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 3, 4, 2, 3, 6, 7, 6, 9, 3, 3, 4, 5);
		IBox<Integer> b = select(a, isOdd);
		if (a.isSingleton()) {
			b.move(0, 0);
		} else {
			b.move(0, 4);
			b.move(3, 1);
		}
		assertEquals(expectedType, b);
		assertEquals(select(a, isOdd), b);
	}

	@Test
	public void testBigMoveForBidirSelect() {
		IBox<Integer> a = factory.createSequence(1, 2, 2, 3, 3, 4, 5);
		IBox<Integer> b = select(a, isOdd); // 3, 1, 3, 3, 5
		a.move(3, 4);
		a.move(1, 3);
		a.move(0, 1); // 5, 1, 2, 2, 3, 3, 3, 4
		IBox<Integer> expected = factory.createSequence(3, 1, 3, 5);
		assertEquals(expected, b);
	}

	@Test
	public void testBigMoveForBidirSelect2() {
		IBox<Integer> a = factory.createSequence(1, 2, 2, 3, 3, 4, 5);
		IBox<Integer> c = select(a, isOdd); // 3, 1, 3, 5
		a.move(1, 3);
		a.move(0, 1);
		IBox<Integer> expected = factory.createSequence(3, 1, 3, 5);
		assertEquals(expected, c);
	}

	@Test
	public void testTwoMovesForBidirSelect() {
		IBox<Integer> a = factory.createSequence(1, 2, 3, 4, 5);
		IBox<Integer> c = select(a, isOdd); // 1, 3, 5
		a.move(1, 2); // 1, 3, 2, 4, 5
		assertEquals(factory.createSequence(1, 3, 5), c);
		a.move(0, 1); // 3, 1, 2, 4, 5
		assertEquals(factory.createSequence(3, 1, 5), c);
	}

	@Test
	public void testOneMoveForBidirSelect() {
		IBox<Integer> a = factory.createSequence(1, 3, 2, 4, 5);
		IBox<Integer> c = select(a, isOdd); // 1, 3, 5
		a.move(0, 1); // 3, 1, 2, 4, 5
		assertEquals(factory.createSequence(3, 1, 5), c); // 3, 1, 5
	}

	// Clear Bidir

	@Test
	public void testClearForBidirSelectOnSequence() {
		testClearForBidirSelect(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testClearForBidirSelectOnBag() {
		testClearForBidirSelect(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testClearForBidirSelectOnOrderedSet() {
		testClearForBidirSelect(IConstraints.ORDERED_SET,
				IConstraints.ORDERED_SET);
	}

	@Test
	public void testClearForBidirSelectOnSet() {
		testClearForBidirSelect(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testClearForBidirSelectOnOption() {
		testClearForBidirSelect(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testClearForBidirSelectOnOne() {
		testClearForBidirSelect(IConstraints.ONE, IConstraints.OPTION);
	}

	public void testClearForBidirSelect(IConstraints inputType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = select(a, isOdd);
		a.clear();
		assertEquals(expectedType, b);
		assertEquals(select(a, isOdd), b);
	}

	// Illegal bidir mutations

	public void testIllegalAddForBidirSelect() {
		thrown.expect(IllegalStateException.class);
		IBox<Integer> a = factory.createSequence(1, 2, 3);
		IBox<Integer> c = select(a, isOdd);
		c.add(4);
	}

	public void testIllegalReplaceForBidirSelect() {
		thrown.expect(IllegalStateException.class);
		IBox<Integer> a = factory.createSequence(1, 2, 3);
		IBox<Integer> c = select(a, isOdd);
		c.set(0, 4);
	}

}
