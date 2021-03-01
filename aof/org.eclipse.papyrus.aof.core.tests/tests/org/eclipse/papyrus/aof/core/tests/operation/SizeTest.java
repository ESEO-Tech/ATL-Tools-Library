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

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.eclipse.papyrus.aof.core.tests.BaseTest;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

/**
 * Tests for IBox.count(), isEmpty() and notEmpty()
 */
@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class SizeTest extends BaseTest {

	// Create not empty

	@Test
	public void testCreateForSizeOnSequence() {
		testCreateForSize(IConstraints.SEQUENCE, 7, false, true);
	}

	@Test
	public void testCreateForSizeOnBag() {
		testCreateForSize(IConstraints.BAG, 7, false, true);
	}

	@Test
	public void testCreateForSizeOnOrderedSet() {
		testCreateForSize(IConstraints.ORDERED_SET, 4, false, true);
	}

	@Test
	public void testCreateForSizeOnSet() {
		testCreateForSize(IConstraints.SET, 4, false, true);
	}

	@Test
	public void testCreateForSizeOnOption() {
		testCreateForSize(IConstraints.OPTION, 1, false, true);
	}

	@Test
	public void testCreateForSizeOnOne() {
		testCreateForSize(IConstraints.ONE, 1, false, true);
	}

	public void testCreateForSize(IConstraints inputType, int expectedSize, boolean expectedIsEmpty, boolean expectedNotEmpty) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		assertEquals(factory.createOne(expectedSize), a.size());
		assertEquals(factory.createOne(expectedIsEmpty), a.isEmpty());
		assertEquals(factory.createOne(expectedNotEmpty), a.notEmpty());
	}

	// Create empty

	@Test
	public void testCreateForSizeOnEmptySequence() {
		testCreateEmptyForSize(IConstraints.SEQUENCE, 0, true, false);
	}

	@Test
	public void testCreateForSizeOnEmptyBag() {
		testCreateEmptyForSize(IConstraints.BAG, 0, true, false);
	}

	@Test
	public void testCreateForSizeOnEmptyOrderedSet() {
		testCreateEmptyForSize(IConstraints.ORDERED_SET, 0, true, false);
	}

	@Test
	public void testCreateForSizeOnEmptySet() {
		testCreateEmptyForSize(IConstraints.SET, 0, true, false);
	}

	@Test
	public void testCreateForSizeOnEmptyOption() {
		testCreateEmptyForSize(IConstraints.OPTION, 0, true, false);
	}

	@Test
	public void testCreateForSizeOnEmptyOne() {
		testCreateEmptyForSize(IConstraints.ONE, 1, false, true);
	}

	public void testCreateEmptyForSize(IConstraints inputType, int expectedSize, boolean expectedIsEmpty, boolean expectedNotEmpty) {
		IBox<Integer> a = factory.createBox(inputType);
		if (inputType == IConstraints.ONE)
			a.add(0);
		assertEquals(factory.createOne(expectedSize), a.size());
		assertEquals(factory.createOne(expectedIsEmpty), a.isEmpty());
		assertEquals(factory.createOne(expectedNotEmpty), a.notEmpty());
	}

	// Add

	@Test
	public void testAddForSizeOnSequence() {
		testAddForSize(IConstraints.SEQUENCE);
	}

	@Test
	public void testAddForSizeOnBag() {
		testAddForSize(IConstraints.BAG);
	}

	@Test
	public void testAddForSizeOnOrderedSet() {
		testAddForSize(IConstraints.ORDERED_SET);
	}

	@Test
	public void testAddForSizeOnSet() {
		testAddForSize(IConstraints.SET);
	}

	@Test
	public void testAddForSizeOnOption() {
		testAddForSize(IConstraints.OPTION);
	}

	@Test
	public void testAddForSizeOnOne() {
		testAddForSize(IConstraints.ONE);
	}

	public void testAddForSize(IConstraints inputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 3);
		IBox<Integer> b = a.size();
		IBox<Boolean> c = a.isEmpty();
		IBox<Boolean> d = a.notEmpty();
		if (a.isSingleton()) {
			a.add(0, 4);
		}
		else {
			a.add(4);
			a.add(0, 5);
			if (!a.isUnique()) {
				a.add(1, 2);
				a.add(3, 3);
				a.add(3, 3);
			}
		}
		assertEquals(a.size(), b);
		assertEquals(a.isEmpty(), c);
		assertEquals(a.notEmpty(), d);
	}

	// Remove

	@Test
	public void testRemoveForSizeOnSequence() {
		testRemoveForSize(IConstraints.SEQUENCE);
	}

	@Test
	public void testRemoveForSizeOnBag() {
		testRemoveForSize(IConstraints.BAG);
	}

	@Test
	public void testRemoveForSizeOnOrderedSet() {
		testRemoveForSize(IConstraints.ORDERED_SET);
	}

	@Test
	public void testRemoveForSizeOnSet() {
		testRemoveForSize(IConstraints.SET);
	}

	@Test
	public void testRemoveForSizeOnOption() {
		testRemoveForSize(IConstraints.OPTION);
	}

	@Test
	public void testRemoveForSizeOnOne() {
		testRemoveForSize(IConstraints.ONE);
	}

	public void testRemoveForSize(IConstraints inputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.size();
		IBox<Boolean> c = a.isEmpty();
		IBox<Boolean> d = a.notEmpty();
		if (!a.isSingleton()) {
			a.removeAt(2);
		}
		a.removeAt(0);
		assertEquals(a.size(), b);
		assertEquals(a.isEmpty(), c);
		assertEquals(a.notEmpty(), d);
	}

	// Replace

	@Test
	public void testReplaceForSizeOnSequence() {
		testReplaceForSize(IConstraints.SEQUENCE);
	}

	@Test
	public void testReplaceForSizeOnBag() {
		testReplaceForSize(IConstraints.BAG);
	}

	@Test
	public void testReplaceForSizeOnOrderedSet() {
		testReplaceForSize(IConstraints.ORDERED_SET);
	}

	@Test
	public void testReplaceForSizeOnSet() {
		testReplaceForSize(IConstraints.SET);
	}

	@Test
	public void testReplaceForSizeOnOption() {
		testReplaceForSize(IConstraints.OPTION);
	}

	@Test
	public void testReplaceForSizeOnOne() {
		testReplaceForSize(IConstraints.ONE);
	}

	public void testReplaceForSize(IConstraints inputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.size();
		IBox<Boolean> c = a.isEmpty();
		IBox<Boolean> d = a.notEmpty();
		a.set(0, 5);
		if (!a.isSingleton()) {
			a.set(1, 1);
			a.set(3, 2);
		}
		assertEquals(a.size(), b);
		assertEquals(a.isEmpty(), c);
		assertEquals(a.notEmpty(), d);
	}

	// Move

	@Test
	public void testMoveForSizeOnSequence() {
		testMoveForSize(IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForSizeOnBag() {
		testMoveForSize(IConstraints.BAG);
	}

	@Test
	public void testMoveForSizeOnOrderedSet() {
		testMoveForSize(IConstraints.ORDERED_SET);
	}

	@Test
	public void testMoveForSizeOnSet() {
		testMoveForSize(IConstraints.SET);
	}

	@Test
	public void testMoveForSizeOnOption() {
		testMoveForSize(IConstraints.OPTION);
	}

	@Test
	public void testMoveForSizeOnOne() {
		testMoveForSize(IConstraints.ONE);
	}

	public void testMoveForSize(IConstraints inputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.size();
		IBox<Boolean> c = a.isEmpty();
		IBox<Boolean> d = a.notEmpty();
		if (a.isSingleton()) {
			a.move(0, 0);
		}
		else {
			a.move(0, 1);
			a.move(2, 1);
		}
		assertEquals(a.size(), b);
		assertEquals(a.isEmpty(), c);
		assertEquals(a.notEmpty(), d);
	}

	// Clear

	@Test
	public void testClearForSizeOnSequence() {
		testClearForSize(IConstraints.SEQUENCE);
	}

	@Test
	public void testClearForSizeOnBag() {
		testClearForSize(IConstraints.BAG);
	}

	@Test
	public void testClearForSizeOnOrderedSet() {
		testClearForSize(IConstraints.ORDERED_SET);
	}

	@Test
	public void testClearForSizeOnSet() {
		testClearForSize(IConstraints.SET);
	}

	@Test
	public void testClearForSizeOnOption() {
		testClearForSize(IConstraints.OPTION);
	}

	@Test
	public void testClearForSizeOnOne() {
		testClearForSize(IConstraints.ONE);
	}

	public void testClearForSize(IConstraints inputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.size();
		IBox<Boolean> c = a.isEmpty();
		IBox<Boolean> d = a.notEmpty();
		a.clear();
		assertEquals(a.size(), b);
		assertEquals(a.isEmpty(), c);
		assertEquals(a.notEmpty(), d);
	}

}
