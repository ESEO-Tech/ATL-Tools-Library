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

import org.eclipse.papyrus.aof.core.IBinding;
import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.eclipse.papyrus.aof.core.tests.BaseTest;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class BindTest extends BaseTest {

	// Create

	@Test
	public void testCreateForBindOnBagSeq() {
		thrown.expect(IllegalArgumentException.class);
		testCreateForBind(IConstraints.BAG, IConstraints.SEQUENCE);
	}

	@Test
	public void testCreateForBindOnSetOne() {
		thrown.expect(IllegalArgumentException.class);
		testCreateForBind(IConstraints.SET, IConstraints.ONE);
	}

	@Test
	public void testCreateForBindOnSeqSeq() {
		testCreateForBind(IConstraints.SEQUENCE, IConstraints.SEQUENCE, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testCreateForBindOnBagBag() {
		testCreateForBind(IConstraints.BAG, IConstraints.BAG, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testCreateForBindOnOSetOSet() {
		testCreateForBind(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testCreateForBindOnSetSet() {
		testCreateForBind(IConstraints.SET, IConstraints.SET, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testCreateForBindOnOptOpt() {
		testCreateForBind(IConstraints.OPTION, IConstraints.OPTION, 4);
	}

	@Test
	public void testCreateForBindOnOneOne() {
		testCreateForBind(IConstraints.ONE, IConstraints.ONE, 4);
	}

	public void testCreateForBind(IConstraints leftType, IConstraints rightType, Integer... expectedElements) {
		IBox<Integer> leftBox = factory.createBox(leftType);
		IBox<Integer> rightBox = factory.createBox(rightType, 1, 2, 2, 3, 3, 3, 4);
		leftBox.bind(rightBox);
		IBox<Integer> expected = factory.createBox(leftType, expectedElements);
		assertEquals(expected, leftBox);
	}

	// Add

	@Test
	public void testAddForBindOnSequence() {
		testAddForBind(IConstraints.SEQUENCE, IConstraints.SEQUENCE, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testAddForBindOnBag() {
		testAddForBind(IConstraints.BAG, IConstraints.BAG, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testAddForBindOnOrderedSet() {
		testAddForBind(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET, 1, 2, 3, 4);
	}

	@Test
	public void testAddForBindOnSet() {
		testAddForBind(IConstraints.SET, IConstraints.SET, 1, 2, 3, 4);
	}

	@Test
	public void testAddForBindOnOption() {
		testAddForBind(IConstraints.OPTION, IConstraints.OPTION, 4);
	}

	@Test
	public void testAddForBindOnOne() {
		testAddForBind(IConstraints.ONE, IConstraints.ONE, 4);
	}

	public void testAddForBind(IConstraints leftType, IConstraints rightType, Integer... expectedElements) {
		IBox<Integer> leftBox = factory.createBox(leftType);
		IBox<Integer> rightBox = factory.createBox(rightType, 1, 2, 3);
		leftBox.bind(rightBox);
		if (rightBox.isSingleton()) {
			rightBox.add(0, 4);
		}
		else {
			rightBox.add(4);
			if (!rightBox.isUnique()) {
				rightBox.add(1, 2);
				rightBox.add(3, 3);
				rightBox.add(3, 3);
			}
		}
		IBox<Integer> expected = factory.createBox(leftBox, expectedElements);
		assertEquals(expected, rightBox);
	}

	// Remove

	@Test
	public void testRemoveForBindOnSequence() {
		testRemoveForBind(IConstraints.SEQUENCE, IConstraints.SEQUENCE, 2, 3, 3, 3, 4);
	}

	@Test
	public void testRemoveForBindOnBag() {
		testRemoveForBind(IConstraints.BAG, IConstraints.BAG, 2, 3, 3, 3, 4);
	}

	@Test
	public void testRemoveForBindOnOrderedSet() {
		testRemoveForBind(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET, 2, 4);
	}

	@Test
	public void testRemoveForBindOnSet() {
		testRemoveForBind(IConstraints.SET, IConstraints.SET, 2, 4);
	}

	@Test
	public void testRemoveForBindOnOption() {
		testRemoveForBind(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testRemoveForBindOnOne() {
		testRemoveForBind(IConstraints.ONE, IConstraints.ONE, 1);
	}

	public void testRemoveForBind(IConstraints leftType, IConstraints rightType, Integer... expectedElements) {
		IBox<Integer> leftBox = factory.createBox(leftType);
		IBox<Integer> rightBox = factory.createBox(rightType, 1, 2, 2, 3, 3, 3, 4);
		leftBox.bind(rightBox);
		if (!rightBox.isSingleton()) {
			rightBox.removeAt(2);
		}
		rightBox.removeAt(0);
		IBox<Integer> expected = factory.createBox(leftType, expectedElements);
		assertEquals(expected, leftBox);
	}

	// Replace

	@Test
	public void testReplaceForBindOnSeqSeq() {
		testReplaceForBind(IConstraints.SEQUENCE, IConstraints.SEQUENCE, 5, 1, 2, 2, 3, 3, 4);
	}

	@Test
	public void testReplaceForBindOnBagBag() {
		testReplaceForBind(IConstraints.BAG, IConstraints.BAG, 5, 1, 2, 2, 3, 3, 4);
	}

	@Test
	public void testReplaceForBindOnOSetOSet() {
		testReplaceForBind(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET, 5, 1, 3, 2);
	}

	@Test
	public void testReplaceForBindOnSetSet() {
		testReplaceForBind(IConstraints.SET, IConstraints.SET, 5, 1, 3, 2);
	}

	@Test
	public void testReplaceForBindOnOptOpt() {
		testReplaceForBind(IConstraints.OPTION, IConstraints.OPTION, 5);
	}

	@Test
	public void testReplaceForBindOnOne() {
		testReplaceForBind(IConstraints.ONE, IConstraints.ONE, 5);
	}

	public void testReplaceForBind(IConstraints leftType, IConstraints rightType, Integer... expectedElements) {
		IBox<Integer> leftBox = factory.createBox(leftType);
		IBox<Integer> rightBox = factory.createBox(rightType, 1, 2, 2, 3, 3, 3, 4);
		leftBox.bind(rightBox);
		rightBox.set(0, 5);
		if (!rightBox.isSingleton()) {
			rightBox.set(1, 1);
			rightBox.set(3, 2);
		}
		IBox<Integer> expected = factory.createBox(leftType, expectedElements);
		assertEquals(expected, leftBox);
	}

	// Move

	@Test
	public void testMoveForBindOnSeqSeq() {
		testMoveForBind(IConstraints.SEQUENCE, IConstraints.SEQUENCE, 2, 2, 1, 3, 3, 3, 4);
	}

	@Test
	public void testMoveForBindOnBagBag() {
		testMoveForBind(IConstraints.BAG, IConstraints.BAG, 2, 2, 1, 3, 3, 3, 4);
	}

	@Test
	public void testMoveForBindOnOSetOSet() {
		testMoveForBind(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET, 2, 3, 1, 4);
	}

	@Test
	public void testMoveForBindOnSetSet() {
		testMoveForBind(IConstraints.SET, IConstraints.SET, 2, 3, 1, 4);
	}

	@Test
	public void testMoveForBindOnOptOpt() {
		testMoveForBind(IConstraints.OPTION, IConstraints.OPTION, 4);
	}

	@Test
	public void testMoveForBindOnOneOne() {
		testMoveForBind(IConstraints.ONE, IConstraints.ONE, 4);
	}

	public void testMoveForBind(IConstraints leftType, IConstraints rightType, Integer... expectedElements) {
		IBox<Integer> leftBox = factory.createBox(leftType);
		IBox<Integer> rightBox = factory.createBox(rightType, 1, 2, 2, 3, 3, 3, 4);
		leftBox.bind(rightBox);
		if (rightBox.isSingleton()) {
			rightBox.move(0, 0);
		}
		else {
			rightBox.move(0, 1);
			rightBox.move(2, 1);
		}
		IBox<Integer> expected = factory.createBox(leftType, expectedElements);
		assertEquals(expected, leftBox);
	}

	// Clear

	@Test
	public void testClearForBindOnSeqSeq() {
		testClearForBind(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testClearForBindOnBagBag() {
		testClearForBind(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testClearForBindOnOSetOSet() {
		testClearForBind(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testClearForBindOnSet() {
		testClearForBind(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testClearForBindOnOptOpt() {
		testClearForBind(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testClearForBindOnOneOne() {
		testClearForBind(IConstraints.ONE, IConstraints.ONE, 1);
	}

	public void testClearForBind(IConstraints leftType, IConstraints rightType, Integer... expectedElements) {
		IBox<Integer> leftBox = factory.createBox(leftType);
		IBox<Integer> rightBox = factory.createBox(rightType, 1, 2, 2, 3, 3, 3, 4);
		leftBox.bind(rightBox);
		rightBox.clear();
		IBox<Integer> expected = factory.createBox(leftType, expectedElements);
		assertEquals(expected, leftBox);
	}

	// Create bidir

	@Test
	public void testCreateForBidirBindOnBagSeq() {
		thrown.expect(IllegalArgumentException.class);
		testCreateForBidirBind(IConstraints.BAG, IConstraints.SEQUENCE);
	}

	@Test
	public void testCreateForBidirBindOnSetOne() {
		thrown.expect(IllegalArgumentException.class);
		testCreateForBidirBind(IConstraints.SET, IConstraints.ONE);
	}

	@Test
	public void testCreateForBidirBindOnSeqSeq() {
		testCreateForBidirBind(IConstraints.SEQUENCE, IConstraints.SEQUENCE, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testCreateForBidirBindOnBagBag() {
		testCreateForBidirBind(IConstraints.BAG, IConstraints.BAG, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testCreateForBidirBindOnOSetOSet() {
		testCreateForBidirBind(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testCreateForBidirBindOnSetSet() {
		testCreateForBidirBind(IConstraints.SET, IConstraints.SET, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testCreateForBidirBindOnOptOpt() {
		testCreateForBidirBind(IConstraints.OPTION, IConstraints.OPTION, 4);
	}

	@Test
	public void testCreateForBidirBindOneOne() {
		testCreateForBind(IConstraints.ONE, IConstraints.ONE, 4);
	}

	public void testCreateForBidirBind(IConstraints leftType, IConstraints rightType, Integer... expectedElements) {
		IBox<Integer> leftBox = factory.createBox(leftType);
		IBox<Integer> rightBox = factory.createBox(rightType, 1, 2, 2, 3, 3, 3, 4);
		leftBox.bind(rightBox);
		IBox<Integer> expected = factory.createBox(rightType, expectedElements);
		assertEquals(expected, rightBox);
	}

	// Add bidir

	@Test
	public void testAddForBidirBindOnSeqSeq() {
		testAddForBidirBind(IConstraints.SEQUENCE, IConstraints.SEQUENCE, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testAddForBidirBindOnBagBag() {
		testAddForBidirBind(IConstraints.BAG, IConstraints.BAG, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testAddForBidirBindOnOSetOSet() {
		testAddForBidirBind(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET, 1, 2, 3, 4);
	}

	@Test
	public void testAddForBidirBindOnSetSet() {
		testAddForBidirBind(IConstraints.SET, IConstraints.SET, 1, 2, 3, 4);
	}

	@Test
	public void testAddForBidirBindOnOptOpt() {
		testAddForBidirBind(IConstraints.OPTION, IConstraints.OPTION, 4);
	}

	@Test
	public void testAddForBidirBindOnOneOne() {
		testAddForBidirBind(IConstraints.ONE, IConstraints.ONE, 4);
	}

	public void testAddForBidirBind(IConstraints leftType, IConstraints rightType, Integer... expectedElements) {
		IBox<Integer> leftBox = factory.createBox(leftType, -1, 0);
		IBox<Integer> rightBox = factory.createBox(rightType, 1, 2, 3);
		leftBox.bind(rightBox);
		if (leftBox.isSingleton()) {
			leftBox.add(0, 4);
		}
		else {
			leftBox.add(4);
			if (!leftBox.isUnique()) {
				leftBox.add(1, 2);
				leftBox.add(3, 3);
				leftBox.add(3, 3);
			}
		}
		IBox<Integer> expected = factory.createBox(rightType, expectedElements);
		assertEquals(expected, rightBox);
	}


	// Remove bidir

	@Test
	public void testRemoveForBidirBindOnSequence() {
		testRemoveForBind(IConstraints.SEQUENCE, IConstraints.SEQUENCE, 2, 3, 3, 3, 4);
	}

	@Test
	public void testRemoveForBidirBindOnBag() {
		testRemoveForBind(IConstraints.BAG, IConstraints.BAG, 2, 3, 3, 3, 4);
	}

	@Test
	public void testRemoveForBidirBindOnOrderedSet() {
		testRemoveForBind(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET, 2, 4);
	}

	@Test
	public void testRemoveForBidirBindOnSet() {
		testRemoveForBind(IConstraints.SET, IConstraints.SET, 2, 4);
	}

	@Test
	public void testRemoveForBidirBindOnOption() {
		testRemoveForBind(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testRemoveForBidirBindOnOne() {
		testRemoveForBind(IConstraints.ONE, IConstraints.ONE, 1);
	}

	public void testRemoveForBidirBind(IConstraints leftType, IConstraints rightType, Integer... expectedElements) {
		IBox<Integer> leftBox = factory.createBox(leftType);
		IBox<Integer> rightBox = factory.createBox(rightType, 1, 2, 2, 3, 3, 3, 4);
		leftBox.bind(rightBox);
		if (!leftBox.isSingleton()) {
			leftBox.removeAt(2);
		}
		leftBox.removeAt(0);
		IBox<Integer> expected = factory.createBox(rightBox, expectedElements);
		assertEquals(expected, rightBox);
	}

	// Replace bidir

	@Test
	public void testReplaceForBidirBindOnSeqSeq() {
		testReplaceForBind(IConstraints.SEQUENCE, IConstraints.SEQUENCE, 5, 1, 2, 2, 3, 3, 4);
	}

	@Test
	public void testReplaceForBidirBindOnBagBag() {
		testReplaceForBind(IConstraints.BAG, IConstraints.BAG, 5, 1, 2, 2, 3, 3, 4);
	}

	@Test
	public void testReplaceForBidirBindOnOSetOSet() {
		testReplaceForBind(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET, 5, 1, 3, 2);
	}

	@Test
	public void testReplaceForBidirBindOnSetSet() {
		testReplaceForBind(IConstraints.SET, IConstraints.SET, 5, 1, 3, 2);
	}

	@Test
	public void testReplaceForBidirBindOnOptOpt() {
		testReplaceForBind(IConstraints.OPTION, IConstraints.OPTION, 5);
	}

	@Test
	public void testReplaceForBidirBindOnOne() {
		testReplaceForBind(IConstraints.ONE, IConstraints.ONE, 5);
	}

	public void testReplaceForBidirBind(IConstraints leftType, IConstraints rightType, Integer... expectedElements) {
		IBox<Integer> leftBox = factory.createBox(leftType);
		IBox<Integer> rightBox = factory.createBox(rightType, 1, 2, 2, 3, 3, 3, 4);
		leftBox.bind(rightBox);
		leftBox.set(0, 5);
		if (!leftBox.isSingleton()) {
			leftBox.set(1, 1);
			leftBox.set(3, 2);
		}
		IBox<Integer> expected = factory.createBox(rightType, expectedElements);
		assertEquals(expected, rightBox);
	}

	// Move bidir

	@Test
	public void testMoveForBidirBindOnSeqSeq() {
		testMoveForBind(IConstraints.SEQUENCE, IConstraints.SEQUENCE, 2, 2, 1, 3, 3, 3, 4);
	}

	@Test
	public void testMoveForBidirBindOnBagBag() {
		testMoveForBind(IConstraints.BAG, IConstraints.BAG, 2, 2, 1, 3, 3, 3, 4);
	}

	@Test
	public void testMoveForBidirBindOnOSetOSet() {
		testMoveForBind(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET, 2, 3, 1, 4);
	}

	@Test
	public void testMoveForBidirBindOnSetSet() {
		testMoveForBind(IConstraints.SET, IConstraints.SET, 2, 3, 1, 4);
	}

	@Test
	public void testMoveForBidirBindOnOptOpt() {
		testMoveForBind(IConstraints.OPTION, IConstraints.OPTION, 4);
	}

	@Test
	public void testMoveForBidirBindOnOneOne() {
		testMoveForBind(IConstraints.ONE, IConstraints.ONE, 4);
	}

	public void testMoveForBidirBind(IConstraints leftType, IConstraints rightType, Integer... expectedElements) {
		IBox<Integer> leftBox = factory.createBox(leftType);
		IBox<Integer> rightBox = factory.createBox(rightType, 1, 2, 2, 3, 3, 3, 4);
		leftBox.bind(rightBox);
		if (leftBox.isSingleton()) {
			leftBox.move(0, 0);
		}
		else {
			leftBox.move(0, 1);
			leftBox.move(2, 1);
		}
		IBox<Integer> expected = factory.createBox(rightType, expectedElements);
		assertEquals(expected, rightBox);
	}

	// Clear bidir

	@Test
	public void testClearForBidirBindOnSeqSeq() {
		testClearForBind(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testClearForBidirBindOnBagBag() {
		testClearForBind(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testClearForBidirBindOnOSetOSet() {
		testClearForBind(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testClearForBidirBindOnSet() {
		testClearForBind(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testClearForBidirBindOnOptOpt() {
		testClearForBind(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testClearForBidirBindOnOneOne() {
		testClearForBind(IConstraints.ONE, IConstraints.ONE, 1);
	}

	public void testClearBidirForBind(IConstraints leftType, IConstraints rightType, Integer... expectedElements) {
		IBox<Integer> leftBox = factory.createBox(leftType);
		IBox<Integer> rightBox = factory.createBox(rightType, 1, 2, 2, 3, 3, 3, 4);
		leftBox.bind(rightBox);
		leftBox.clear();
		IBox<Integer> expected = factory.createBox(rightType, expectedElements);
		assertEquals(expected, rightBox);
	}

	// Enabling and disabling a binding

	@Test
	public void testDisableBindingOnSequence() {
		testDisableBinding(IConstraints.SEQUENCE);
	}

	@Test
	public void testDisableBindingOnBag() {
		testDisableBinding(IConstraints.BAG);
	}

	@Test
	public void testDisableBindingOnOrderedSet() {
		testDisableBinding(IConstraints.ORDERED_SET);
	}

	@Test
	public void testDisableBindingOnSet() {
		testDisableBinding(IConstraints.SET);
	}

	@Test
	public void testDisableBindingOnOption() {
		testDisableBinding(IConstraints.OPTION);
	}

	@Test
	public void testDisableBindingOnOne() {
		testDisableBinding(IConstraints.ONE);
	}

	public void testDisableBinding(IConstraints boxType) {
		IBox<Integer> leftBox = factory.createBox(boxType);
		IBox<Integer> rightBox = factory.createBox(boxType, 1, 2, 3);
		IBinding<Integer> binding = leftBox.bind(rightBox);
		rightBox.add(4);
		rightBox.add(5);
		binding.disable();
		rightBox.add(6);
		rightBox.add(7);
		IBox<Integer> expectedBox = factory.createBox(boxType, 1, 2, 3, 4, 5);
		assertEquals(expectedBox, leftBox);
	}

	@Test
	public void testEnableBindingOnSequence() {
		testEnableBinding(IConstraints.SEQUENCE);
	}

	@Test
	public void testEnableBindingOnBag() {
		testEnableBinding(IConstraints.BAG);
	}

	@Test
	public void testEnableBindingOnOrderedSet() {
		testEnableBinding(IConstraints.ORDERED_SET);
	}

	@Test
	public void testEnableBindingOnSet() {
		testEnableBinding(IConstraints.SET);
	}

	@Test
	public void testEnableBindingOnOption() {
		testEnableBinding(IConstraints.OPTION);
	}

	@Test
	public void testEnableBindingOnOne() {
		testEnableBinding(IConstraints.ONE);
	}

	public void testEnableBinding(IConstraints boxType) {
		IBox<Integer> leftBox = factory.createBox(boxType);
		IBox<Integer> rightBox = factory.createBox(boxType, 1, 2, 3);
		IBinding<Integer> binding = leftBox.bind(rightBox);
		rightBox.add(4);
		binding.disable();
		rightBox.add(5);
		rightBox.add(6);
		binding.enable();
		rightBox.add(7);
		rightBox.add(8);
		IBox<Integer> expectedBox = factory.createBox(boxType, 1, 2, 3, 4, 5, 6, 7, 8);
		assertEquals(expectedBox, leftBox);
	}

}
