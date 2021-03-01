/*******************************************************************************
 *  Copyright (c) 2015 ESEO.
 *  All rights reserved. This program and the accompanying materials
 *  are made available under the terms of the Eclipse Public License v1.0
 *  which accompanies this distribution, and is available at
 *  http://www.eclipse.org/legal/epl-v10.html
 *
 *  Contributors:
 *     Olivier Beaudoux - JUnit testing of Zip operation on all box types
 *******************************************************************************/
package org.eclipse.papyrus.aof.core.tests.operation;

import org.eclipse.papyrus.aof.core.IBinaryFunction;
import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.eclipse.papyrus.aof.core.IPair;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.eclipse.papyrus.aof.core.tests.BaseTest;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
// zipWith tested by testing zip directly
public class ZipWithTest extends BaseTest {

	// Create

	@Test
	public void testCreateForZipOnSeqSeq() {
		testCreateForZip(IConstraints.SEQUENCE, IConstraints.SEQUENCE,
				IConstraints.SEQUENCE);
	}

	@Test
	public void testCreateForZipOnSeqBag() {
		testCreateForZip(IConstraints.SEQUENCE, IConstraints.BAG,
				IConstraints.BAG);
	}

	@Test
	public void testCreateForZipOnBagSeq() {
		testCreateForZip(IConstraints.BAG, IConstraints.SEQUENCE,
				IConstraints.BAG);
	}

	@Test
	public void testCreateForZipOnBagBag() {
		testCreateForZip(IConstraints.BAG, IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testCreateForZipOnOSetOSet() {
		testCreateForZip(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET,
				IConstraints.ORDERED_SET);
	}

	@Test
	public void testCreateForZipOnOSetSet() {
		testCreateForZip(IConstraints.ORDERED_SET, IConstraints.SET,
				IConstraints.SET);
	}

	@Test
	public void testCreateForZipOnSetOSet() {
		testCreateForZip(IConstraints.SET, IConstraints.ORDERED_SET,
				IConstraints.SET);
	}

	@Test
	public void testCreateForZipOnSetSet() {
		testCreateForZip(IConstraints.SET, IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testCreateForZipOnSetSeq() {
		testCreateForZip(IConstraints.SET, IConstraints.SEQUENCE,
				IConstraints.SET);
	}

	@Test
	public void testCreateForZipOnOptOpt() {
		testCreateForZip(IConstraints.OPTION, IConstraints.OPTION,
				IConstraints.OPTION);
	}

	@Test
	public void testCreateForZipOnOneOne() {
		testCreateForZip(IConstraints.ONE, IConstraints.ONE, IConstraints.ONE);
	}

	@Test
	public void testCreateForZipOnOneOpt() {
		testCreateForZip(IConstraints.ONE, IConstraints.OPTION,
				IConstraints.OPTION);
	}

	@Test
	public void testCreateForZipOneOptOne() {
		testCreateForZip(IConstraints.OPTION, IConstraints.ONE,
				IConstraints.OPTION);
	}

	@Test
	public void testCreateForZipOnOneOSet() {
		testCreateForZip(IConstraints.ONE, IConstraints.ORDERED_SET,
				IConstraints.OPTION);
	}

	@Test
	public void testCreateForZipOnOSetOne() {
		testCreateForZip(IConstraints.ORDERED_SET, IConstraints.ONE,
				IConstraints.OPTION);
	}

	public void testCreateForZip(IConstraints leftType, IConstraints rightType,
			IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(leftType, 0, 1, 2, 2, 3);
		IBox<Integer> b = factory.createBox(rightType, 1, 2, 2, 3, 3, 4);
		IBox<IPair<Integer, Integer>> c = a.zip(b, false);
		assertEquals(expectedType, c);
		assertEquals(a.zip(b, false), c);
	}

	// Add

	@Test
	public void testAddForZipOnSeqSeq() {
		testAddForZip(IConstraints.SEQUENCE, IConstraints.SEQUENCE,
				IConstraints.SEQUENCE);
	}

	@Test
	public void testAddForZipOnBagSet() {
		testAddForZip(IConstraints.BAG, IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testAddForZipOnOSetSeq() {
		testAddForZip(IConstraints.ORDERED_SET, IConstraints.SEQUENCE,
				IConstraints.ORDERED_SET);
	}

	@Test
	public void testAddForZipOSetBag() {
		testAddForZip(IConstraints.SET, IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testAddForZipOnOptSeq() {
		testAddForZip(IConstraints.OPTION, IConstraints.SEQUENCE,
				IConstraints.OPTION);
	}

	@Test
	public void testAddForZipOnOneOne() {
		testAddForZip(IConstraints.ONE, IConstraints.ONE, IConstraints.ONE);
	}

	@Test
	public void testAddForZipOnOneSeq() {
		testAddForZip(IConstraints.ONE, IConstraints.SEQUENCE,
				IConstraints.OPTION);
	}

	@Test
	public void testAddForZipOnSetOne() {
		testAddForZip(IConstraints.SET, IConstraints.ONE, IConstraints.OPTION);
	}

	public void testAddForZip(IConstraints leftType, IConstraints rightType,
			IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(leftType, 0, 1, 2);
		IBox<Integer> b = factory.createBox(rightType, 1, 2, 2, 3);
		IBox<IPair<Integer, Integer>> c = a.zip(b, false);
		a.add(0, 4);
		b.add(0, 5);
		if (!a.isSingleton() && !b.isSingleton()) {
			if (!a.isUnique()) {
				a.add(1, 2);
			}
			if (!b.isUnique()) {
				b.add(3, 3);
			}
			a.add(3, 3);
		}
		assertEquals(expectedType, c);
		assertEquals(a.zip(b, false), c);
	}

	// Remove

	@Test
	public void testRemoveForZipOnSeqBag() {
		testRemoveForZip(IConstraints.SEQUENCE, IConstraints.BAG,
				IConstraints.BAG);
	}

	@Test
	public void testRemoveForZipOnSeqSet() {
		testRemoveForZip(IConstraints.SEQUENCE, IConstraints.ORDERED_SET,
				IConstraints.ORDERED_SET);
	}

	@Test
	public void testRemoveForZipOnBagOSet() {
		testRemoveForZip(IConstraints.BAG, IConstraints.ORDERED_SET,
				IConstraints.SET);
	}

	@Test
	public void testRemoveForZipOnOSetBag() {
		testRemoveForZip(IConstraints.ORDERED_SET, IConstraints.BAG,
				IConstraints.SET);
	}

	@Test
	public void testRemoveForZipOnSetSet() {
		testRemoveForZip(IConstraints.SET, IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testRemoveForZipOnOptSet() {
		testRemoveForZip(IConstraints.OPTION, IConstraints.SET,
				IConstraints.OPTION);
	}

	@Test
	public void testRemoveForZipOnOptOne() {
		testRemoveForZip(IConstraints.OPTION, IConstraints.ONE,
				IConstraints.OPTION);
	}

	@Test
	public void testRemoveForZipOnOneSeq() {
		testRemoveForZip(IConstraints.ONE, IConstraints.SEQUENCE,
				IConstraints.OPTION);
	}

	@Test
	public void testRemoveForZipOnOneOne() {
		testRemoveForZip(IConstraints.ONE, IConstraints.ONE, IConstraints.ONE);
	}

	public void testRemoveForZip(IConstraints leftType, IConstraints rightType,
			IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(leftType, 0, 1, 2, 2, 3, 4);
		IBox<Integer> b = factory.createBox(rightType, 1, 2, 3, 3, 4, 5, 6);
		IBox<IPair<Integer, Integer>> c = a.zip(b, false);
		a.removeAt(0);
		b.removeAt(0);
		if (!a.isSingleton()) {
			a.removeAt(1);
		}
		if (!b.isSingleton()) {
			b.removeAt(2);
			b.removeAt(1);
			b.removeAt(1);
		}
		assertEquals(expectedType, c);
		assertEquals(a.zip(b, false), c);
	}

	// Replace

	@Test
	public void testReplaceForZipOnSeqSeq() {
		testReplaceForZip(IConstraints.SEQUENCE, IConstraints.SEQUENCE,
				IConstraints.SEQUENCE);
	}

	@Test
	public void testReplaceForZipOnBagOSet() {
		testReplaceForZip(IConstraints.BAG, IConstraints.ORDERED_SET,
				IConstraints.SET);
	}

	@Test
	public void testReplaceForZipOnOSetBag() {
		testReplaceForZip(IConstraints.ORDERED_SET, IConstraints.BAG,
				IConstraints.SET);
	}

	@Test
	public void testReplaceForZipOnSetOSet() {
		testReplaceForZip(IConstraints.SET, IConstraints.ORDERED_SET,
				IConstraints.SET);
	}

	@Test
	public void testReplaceForZipOnSetOpt() {
		testReplaceForZip(IConstraints.SET, IConstraints.OPTION,
				IConstraints.OPTION);
	}

	@Test
	public void testReplaceForZipOnOneOne() {
		testReplaceForZip(IConstraints.ONE, IConstraints.ONE, IConstraints.ONE);
	}

	@Test
	public void testReplaceForZipOnOSetOne() {
		testReplaceForZip(IConstraints.ORDERED_SET, IConstraints.ONE,
				IConstraints.OPTION);
	}

	@Test
	public void testReplaceForZipOnOneBag() {
		testReplaceForZip(IConstraints.ONE, IConstraints.BAG,
				IConstraints.OPTION);
	}

	public void testReplaceForZip(IConstraints leftType,
			IConstraints rightType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(leftType, 0, 1, 2, 2, 3, 4);
		IBox<Integer> b = factory.createBox(rightType, 1, 2, 2, 3, 3);
		IBox<IPair<Integer, Integer>> c = a.zip(b, false);
		a.set(0, 5);
		b.set(0, 4);
		if (!a.isSingleton()) {
			a.set(1, 0);
			a.set(3, 1);
		}
		if (!b.isSingleton()) {
			b.set(1, 0);
		}
		assertEquals(expectedType, c);
		assertEquals(a.zip(b, false), c);
	}

	// Move

	@Test
	public void testMoveForZipOnSeqSeq() {
		testMoveForZip(IConstraints.SEQUENCE, IConstraints.SEQUENCE,
				IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForZipOnBagSet() {
		testMoveForZip(IConstraints.BAG, IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testMoveForZipOnOSetSeq() {
		testMoveForZip(IConstraints.ORDERED_SET, IConstraints.SEQUENCE,
				IConstraints.ORDERED_SET);
	}

	@Test
	public void testMoveForZipOnSetOSet() {
		testMoveForZip(IConstraints.SET, IConstraints.ORDERED_SET,
				IConstraints.SET);
	}

	@Test
	public void testMoveForZipOnOptSeq() {
		testMoveForZip(IConstraints.OPTION, IConstraints.SEQUENCE,
				IConstraints.OPTION);
	}

	@Test
	public void testMoveForZipOnOSetOpt() {
		testMoveForZip(IConstraints.ORDERED_SET, IConstraints.OPTION,
				IConstraints.OPTION);
	}

	@Test
	public void testMoveForZipOnOneOne() {
		testMoveForZip(IConstraints.ONE, IConstraints.ONE, IConstraints.ONE);
	}

	@Test
	public void testMoveForZipOnOneOpt() {
		testMoveForZip(IConstraints.ONE, IConstraints.OPTION,
				IConstraints.OPTION);
	}

	@Test
	public void testMoveForZipOnOneSeq() {
		testMoveForZip(IConstraints.ONE, IConstraints.SEQUENCE,
				IConstraints.OPTION);
	}

	public void testMoveForZip(IConstraints leftType, IConstraints rightType,
			IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(leftType, 0, 1, 2, 2, 3);
		IBox<Integer> b = factory.createBox(rightType, 1, 2, 2, 3);
		IBox<IPair<Integer, Integer>> c = a.zip(b, false);
		if (!a.isSingleton()) {
			a.move(1, 0);
			a.move(0, 2);
		}
		if (!b.isSingleton()) {
			b.move(0, 2);
		}
		assertEquals(expectedType, c);
		assertEquals(a.zip(b, false), c);
	}

	// Clear

	@Test
	public void testClearLeftForZipOnSeqSeq() {
		testClearForZip(IConstraints.SEQUENCE, IConstraints.SEQUENCE, true,
				false, IConstraints.SEQUENCE);
	}

	@Test
	public void testClearLeftForZipOnOptOpt() {
		testClearForZip(IConstraints.OPTION, IConstraints.OPTION, true, false,
				IConstraints.OPTION);
	}

	@Test
	public void testClearLeftForZipOnOneBag() {
		testClearForZip(IConstraints.ONE, IConstraints.BAG, true, false,
				IConstraints.OPTION);
	}

	@Test
	public void testClearRightForZipOnOneBag() {
		testClearForZip(IConstraints.ONE, IConstraints.BAG, false, true,
				IConstraints.OPTION);
	}

	@Test
	public void testClearLeftRightForZipOnOneBag() {
		testClearForZip(IConstraints.ONE, IConstraints.BAG, true, true,
				IConstraints.OPTION);
	}

	@Test
	public void testClearLeftForZipOnOneOSet() {
		testClearForZip(IConstraints.ONE, IConstraints.ORDERED_SET, true,
				false, IConstraints.OPTION);
	}

	@Test
	public void testClearRightForZipOnOneOSet() {
		testClearForZip(IConstraints.ONE, IConstraints.ORDERED_SET, false,
				true, IConstraints.OPTION);
	}

	@Test
	public void testClearLeftRightForZipOnOneOSet() {
		testClearForZip(IConstraints.ONE, IConstraints.ORDERED_SET, true, true,
				IConstraints.OPTION);
	}

	@Test
	public void testClearLeftForZipOnOneOpt() {
		testClearForZip(IConstraints.ONE, IConstraints.OPTION, true, false,
				IConstraints.OPTION);
	}

	@Test
	public void testClearRightForZipOnOneOpt() {
		testClearForZip(IConstraints.ONE, IConstraints.OPTION, false, true,
				IConstraints.OPTION);
	}

	@Test
	public void testClearLeftRightForZipOnOneOpt() {
		testClearForZip(IConstraints.ONE, IConstraints.OPTION, true, true,
				IConstraints.OPTION);
	}

	@Test
	public void testClearLeftForZipOnOneOne() {
		testClearForZip(IConstraints.ONE, IConstraints.ONE, true, false,
				IConstraints.ONE);
	}

	@Test
	public void testClearRightForZipOnOneOne() {
		testClearForZip(IConstraints.ONE, IConstraints.ONE, false, true,
				IConstraints.ONE);
	}

	@Test
	public void testClearLeftRightForZipOnOneOne() {
		testClearForZip(IConstraints.ONE, IConstraints.ONE, true, true,
				IConstraints.ONE);
	}

	public void testClearForZip(IConstraints leftType, IConstraints rightType,
			boolean clearLeft, boolean clearRight, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(leftType, 0, 1, 2, 2, 3);
		IBox<Integer> b = factory.createBox(rightType, 1, 2, 2, 3);
		IBox<IPair<Integer, Integer>> c = a.zip(b, false);
		if (clearLeft)
			a.clear();
		if (clearRight)
			b.clear();
		assertEquals(expectedType, c);
		assertEquals(a.zip(b, false), c);
	}

	// Create with self

	@Test
	public void testCreateForZipOnSeqSelf() {
		testCreateForZipSelf(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testCreateForZipOnBagSelf() {
		testCreateForZipSelf(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testCreateForZipOnOSetSelf() {
		testCreateForZipSelf(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testCreateForZipOnSetSelf() {
		testCreateForZipSelf(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testCreateForZipOnOptSelf() {
		testCreateForZipSelf(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testCreateForZipOnOneSelf() {
		testCreateForZipSelf(IConstraints.ONE, IConstraints.ONE);
	}

	public void testCreateForZipSelf(IConstraints boxType,
			IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(boxType, 1, 2, 2, 3);
		IBox<IPair<Integer, Integer>> b = a.zip(a, true);
		assertEquals(expectedType, b);
		assertEquals(a.zip(a, true), b);
	}

	// Add with self

	@Test
	public void testAddForZipOnSeqSelf() {
		testAddForZipSelf(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testAddForZipOnBagSelf() {
		testAddForZipSelf(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testAddForZipOnOSetSelf() {
		testAddForZipSelf(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testAddForZipOnSetSelf() {
		testAddForZipSelf(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testAddForZipOnOptSelf() {
		testAddForZipSelf(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testAddForZipOnOneSelf() {
		testAddForZipSelf(IConstraints.ONE, IConstraints.ONE);
	}

	public void testAddForZipSelf(IConstraints boxType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(boxType, 1, 2);
		IBox<IPair<Integer, Integer>> b = a.zip(a, true);
		a.add(0, 3);
		if (!a.isSingleton()) {
			if (!a.isUnique()) {
				a.add(1, 2);
			}
			a.add(3, 4);
		}
		assertEquals(expectedType, b);
		assertEquals(a.zip(a, true), b);
	}

	// Remove

	@Test
	public void testRemoveForZipOnSeqSelf() {
		testRemoveForZipSelf(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testRemoveForZipOnBagSelf() {
		testRemoveForZipSelf(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testRemoveForZipOnOSetSelf() {
		testRemoveForZipSelf(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testRemoveForZipOnSetSelf() {
		testRemoveForZipSelf(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testRemoveForZipOnOptSelf() {
		testRemoveForZipSelf(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testRemoveForZipOnOneSelf() {
		testRemoveForZipSelf(IConstraints.ONE, IConstraints.ONE);
	}

	public void testRemoveForZipSelf(IConstraints boxType,
			IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(boxType, 0, 1, 2, 2, 3, 4);
		IBox<IPair<Integer, Integer>> b = a.zip(a, true);
		a.removeAt(0);
		if (!a.isSingleton()) {
			a.removeAt(1);
			a.removeAt(2);
		}
		assertEquals(expectedType, b);
		assertEquals(a.zip(a, true), b);
	}

	// Replace

	@Test
	public void testReplaceForZipOnSeqSelf() {
		testReplaceForZipSelf(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testReplaceForZipOnBagSelf() {
		testReplaceForZipSelf(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testReplaceForZipOnOSetSelf() {
		testReplaceForZipSelf(IConstraints.ORDERED_SET,
				IConstraints.ORDERED_SET);
	}

	@Test
	public void testReplaceForZipOnSetSelf() {
		testReplaceForZipSelf(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testReplaceForZipOnOptSelf() {
		testReplaceForZipSelf(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testReplaceForZipOnOneSelf() {
		testReplaceForZipSelf(IConstraints.ONE, IConstraints.ONE);
	}

	public void testReplaceForZipSelf(IConstraints boxType,
			IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(boxType, 0, 1, 2, 2, 3, 4);
		IBox<IPair<Integer, Integer>> b = a.zip(a, true);
		a.set(0, 5);
		if (!a.isSingleton()) {
			a.set(1, 0);
			a.set(3, 1);
		}
		assertEquals(expectedType, b);
		assertEquals(a.zip(a, true), b);
	}

	// Move with self

	@Test
	public void testMoveForZipOnSeqSelf() {
		testMoveForZipSelf(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForZipOnBagSelf() {
		testMoveForZipSelf(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testMoveForZipOnOSetSelf() {
		testMoveForZipSelf(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testMoveForZipOnSetSelf() {
		testMoveForZipSelf(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testMoveForZipOnOptSelf() {
		testMoveForZipSelf(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testMoveForZipOnOneSelf() {
		testMoveForZipSelf(IConstraints.ONE, IConstraints.ONE);
	}

	public void testMoveForZipSelf(IConstraints boxType,
			IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(boxType, 0, 1, 2, 2, 3);
		IBox<IPair<Integer, Integer>> b = a.zip(a, true);
		if (!a.isSingleton()) {
			a.move(1, 0);
			a.move(0, 2);
		}
		assertEquals(expectedType, b);
		assertEquals(a.zip(a, true), b);
	}

	// Clear with self

	@Test
	public void testClearForZipOnSeqSelf() {
		testClearForZipSelf(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testClearForZipOnOSetSelf() {
		testClearForZipSelf(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testClearForZipOnOptSelf() {
		testClearForZipSelf(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testClearForZipOnOneSelf() {
		testClearForZipSelf(IConstraints.ONE, IConstraints.ONE);
	}

	public void testClearForZipSelf(IConstraints boxType,
			IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(boxType, 0, 1, 2, 2, 3);
		IBox<IPair<Integer, Integer>> b = a.zip(a, true);
		a.clear();
		assertEquals(expectedType, b);
		assertEquals(a.zip(a, true), b);
	}

	// Add bidir

	@Test
	public void testAddForBidirZipOnSeqSeq() {
		testAddForBidirZip(IConstraints.SEQUENCE, IConstraints.SEQUENCE,
				IConstraints.SEQUENCE);
	}

	@Test
	public void testAddForBidirZipOnBagSet() {
		testAddForBidirZip(IConstraints.BAG, IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testAddForBidirZipOnOSetSeq() {
		testAddForBidirZip(IConstraints.ORDERED_SET, IConstraints.SEQUENCE,
				IConstraints.ORDERED_SET);
	}

	@Test
	public void testAddForBidirZipOSetBag() {
		testAddForBidirZip(IConstraints.SET, IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testAddForBidirZipOnOptSeq() {
		testAddForBidirZip(IConstraints.OPTION, IConstraints.SEQUENCE,
				IConstraints.OPTION);
	}

	@Test
	public void testAddForBidirZipOnOneOne() {
		testAddForBidirZip(IConstraints.ONE, IConstraints.ONE, IConstraints.ONE);
	}

	@Test
	public void testAddForBidirZipOnOneSeq() {
		testAddForBidirZip(IConstraints.ONE, IConstraints.SEQUENCE,
				IConstraints.OPTION);
	}

	@Test
	public void testAddForBidirZipOnSetOne() {
		testAddForBidirZip(IConstraints.SET, IConstraints.ONE,
				IConstraints.OPTION);
	}

	public void testAddForBidirZip(IConstraints leftType,
			IConstraints rightType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(leftType, 0, 1, 2);
		IBox<Integer> b = factory.createBox(rightType, 1, 2, 2, 3);
		IBox<IPair<Integer, Integer>> c = a.zip(b, false);
		c.add(0, factory.createPair(4, 4));
		if (!c.isSingleton()) {
			c.add(3, factory.createPair(5, 5));
			if (!c.isUnique()) {
				c.add(1, factory.createPair(5, 5));
			}
		}
		assertEquals(expectedType, c);
		assertEquals(a.zip(b, false), c);
	}

	// Remove bidir

	@Test
	public void testRemoveForBidirZipOnSeqBag() {
		testRemoveForBidirZip(IConstraints.SEQUENCE, IConstraints.BAG,
				IConstraints.BAG);
	}

	@Test
	public void testRemoveForBidirZipOnSeqSet() {
		testRemoveForBidirZip(IConstraints.SEQUENCE, IConstraints.ORDERED_SET,
				IConstraints.ORDERED_SET);
	}

	@Test
	public void testRemoveForBidirZipOnBagOSet() {
		testRemoveForBidirZip(IConstraints.BAG, IConstraints.ORDERED_SET,
				IConstraints.SET);
	}

	@Test
	public void testRemoveForBidirZipOnOSetBag() {
		testRemoveForBidirZip(IConstraints.ORDERED_SET, IConstraints.BAG,
				IConstraints.SET);
	}

	@Test
	public void testRemoveForBidirZipOnSetSet() {
		testRemoveForBidirZip(IConstraints.SET, IConstraints.SET,
				IConstraints.SET);
	}

	@Test
	public void testRemoveForBidirZipOnOptSet() {
		testRemoveForBidirZip(IConstraints.OPTION, IConstraints.SET,
				IConstraints.OPTION);
	}

	@Test
	public void testRemoveForBidirZipOnOptOne() {
		testRemoveForBidirZip(IConstraints.OPTION, IConstraints.ONE,
				IConstraints.OPTION);
	}

	@Test
	public void testRemoveForBidirZipOnOneSeq() {
		thrown.expect(IllegalStateException.class);
		testRemoveForBidirZip(IConstraints.ONE, IConstraints.SEQUENCE,
				IConstraints.OPTION);
	}

	@Test
	public void testRemoveForBidirZipOnOneOne() {
		testRemoveForBidirZip(IConstraints.ONE, IConstraints.ONE,
				IConstraints.ONE);
	}

	public void testRemoveForBidirZip(IConstraints leftType,
			IConstraints rightType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(leftType, 0, 1, 2, 2, 3, 4);
		IBox<Integer> b = factory.createBox(rightType, 1, 2, 3, 3, 4, 5, 6);
		IBox<IPair<Integer, Integer>> c = a.zip(b, false);
		c.removeAt(0);
		if (!c.isSingleton()) {
			c.removeAt(1);
			c.removeAt(2);
			c.removeAt(0);
		}
		assertEquals(expectedType, c);
		assertEquals(a.zip(b, false), c);
	}

	// Replace bidir

	@Test
	public void testReplaceForBidirZipOnSeqSeq() {
		testReplaceForBidirZip(IConstraints.SEQUENCE, IConstraints.SEQUENCE,
				IConstraints.SEQUENCE);
	}

	@Test
	public void testReplaceForBidirZipOnBagOSet() {
		testReplaceForBidirZip(IConstraints.BAG, IConstraints.ORDERED_SET,
				IConstraints.SET);
	}

	@Test
	public void testReplaceForBidirZipOnOSetBag() {
		testReplaceForBidirZip(IConstraints.ORDERED_SET, IConstraints.BAG,
				IConstraints.SET);
	}

	@Test
	public void testReplaceForBidirZipOnSetOSet() {
		testReplaceForBidirZip(IConstraints.SET, IConstraints.ORDERED_SET,
				IConstraints.SET);
	}

	@Test
	public void testReplaceForBidirZipOnSetOpt() {
		testReplaceForBidirZip(IConstraints.SET, IConstraints.OPTION,
				IConstraints.OPTION);
	}

	@Test
	public void testReplaceForBidirZipOnOneOne() {
		testReplaceForBidirZip(IConstraints.ONE, IConstraints.ONE,
				IConstraints.ONE);
	}

	@Test
	public void testReplaceForBidirZipOnOSetOne() {
		testReplaceForBidirZip(IConstraints.ORDERED_SET, IConstraints.ONE,
				IConstraints.OPTION);
	}

	@Test
	public void testReplaceForBidirZipOnOneBag() {
		testReplaceForBidirZip(IConstraints.ONE, IConstraints.BAG,
				IConstraints.OPTION);
	}

	public void testReplaceForBidirZip(IConstraints leftType,
			IConstraints rightType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(leftType, 0, 1, 2, 2, 3, 4);
		IBox<Integer> b = factory.createBox(rightType, 1, 2, 2, 3, 3);
		IBox<IPair<Integer, Integer>> c = a.zip(b, false);
		c.set(0, factory.createPair(5, 5));
		if (!c.isSingleton()) {
			if (!c.isUnique()) {
				c.set(0, factory.createPair(4, 4));
			}
			c.set(2, factory.createPair(6, 6));
			c.set(1, factory.createPair(0, 0));
		}
		assertEquals(expectedType, c);
		assertEquals(a.zip(b, false), c);
	}

	// Move bidir

	@Test
	public void testMoveForBidirZipOnSeqSeq() {
		testMoveForBidirZip(IConstraints.SEQUENCE, IConstraints.SEQUENCE,
				IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForBidirZipOnBagSet() {
		testMoveForBidirZip(IConstraints.BAG, IConstraints.SET,
				IConstraints.SET);
	}

	@Test
	public void testMoveForBidirZipOnOSetSeq() {
		testMoveForBidirZip(IConstraints.ORDERED_SET, IConstraints.SEQUENCE,
				IConstraints.ORDERED_SET);
	}

	@Test
	public void testMoveForBidirZipOnSetOSet() {
		testMoveForBidirZip(IConstraints.SET, IConstraints.ORDERED_SET,
				IConstraints.SET);
	}

	@Test
	public void testMoveForBidirZipOnOptSeq() {
		testMoveForBidirZip(IConstraints.OPTION, IConstraints.SEQUENCE,
				IConstraints.OPTION);
	}

	@Test
	public void testMoveForBidirZipOnOSetOpt() {
		testMoveForBidirZip(IConstraints.ORDERED_SET, IConstraints.OPTION,
				IConstraints.OPTION);
	}

	@Test
	public void testMoveForBidirZipOnOneOne() {
		testMoveForBidirZip(IConstraints.ONE, IConstraints.ONE,
				IConstraints.ONE);
	}

	@Test
	public void testMoveForBidirZipOnOneOpt() {
		testMoveForBidirZip(IConstraints.ONE, IConstraints.OPTION,
				IConstraints.OPTION);
	}

	@Test
	public void testMoveForBidirZipOnOneSeq() {
		testMoveForBidirZip(IConstraints.ONE, IConstraints.SEQUENCE,
				IConstraints.OPTION);
	}

	public void testMoveForBidirZip(IConstraints leftType,
			IConstraints rightType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(leftType, 0, 1, 2, 2, 3);
		IBox<Integer> b = factory.createBox(rightType, 1, 2, 2, 3);
		IBox<IPair<Integer, Integer>> c = a.zip(b, false);
		if (!c.isSingleton()) {
			c.move(1, 0);
			c.move(0, 2);
		}
		if (!c.isSingleton()) {
			c.move(0, 2);
		}
		assertEquals(expectedType, c);
		assertEquals(a.zip(b, false), c);
	}

	// Clear bidir

	@Test
	public void testClearForBidirZipOnSeqSeq() {
		testClearForBidirZip(IConstraints.SEQUENCE, IConstraints.SEQUENCE,
				IConstraints.SEQUENCE);
	}

	@Test
	public void testClearForBidirZipOnOptOpt() {
		testClearForBidirZip(IConstraints.OPTION, IConstraints.OPTION,
				IConstraints.OPTION);
	}

	@Test
	public void testClearForBidirZipOnOneBag() {
		thrown.expect(IllegalStateException.class);
		testClearForBidirZip(IConstraints.ONE, IConstraints.BAG,
				IConstraints.OPTION);
	}

	@Test
	public void testClearForBidirZipOnOSetOne() {
		thrown.expect(IllegalStateException.class);
		testClearForBidirZip(IConstraints.ORDERED_SET, IConstraints.ONE,
				IConstraints.OPTION);
	}

	@Test
	public void testClearForBidirZipOnOneOpt() {
		testClearForBidirZip(IConstraints.ONE, IConstraints.OPTION,
				IConstraints.OPTION);
	}

	@Test
	public void testClearForBidirZipOnOneOne() {
		testClearForBidirZip(IConstraints.ONE, IConstraints.ONE,
				IConstraints.ONE);
	}

	public void testClearForBidirZip(IConstraints leftType,
			IConstraints rightType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(leftType, 0, 1, 2, 2, 3);
		IBox<Integer> b = factory.createBox(rightType, 1, 2, 2, 3);
		IBox<IPair<Integer, Integer>> c = a.zip(b, false);
		c.clear();
		assertEquals(expectedType, c);
		assertEquals(a.zip(b, false), c);
	}

	// Bidir

	@Test
	public void testBidirSelf() {
		IBox<Integer> a = factory.createSequence(1, 2, 3, 4, 5);
		a.zip(a, true).removeAt(3);
		assertEquals(factory.createSequence(1, 2, 3, 5), a);
	}

	@Test
	public void testZipZip() {
		IBox<Integer> a = factory.createOrderedSet(1, 2, 3);//.inspect("a=");
		// b = a.collect(e->0)
		IBox<Integer> b = a.collect(new IUnaryFunction<Integer, Integer>() {
			public Integer apply(Integer a) {
				return 0;
			}
		});//.inspect("b=");
		// c = b.zipWith(b, (l,r)->l)
		IBox<Integer> c = b.zipWith(b,
				new IBinaryFunction<Integer, Integer, Integer>() {
					@Override
					public Integer apply(Integer a, Integer b) {
						return a;
					}
				});//.inspect("c=");
		// d = a.zip(c)
		IBox<IPair<Integer, Integer>> d = c.zip(a, true);//.inspect("d=");
		// this throws an Exception if replacing an element with itself does not propagate the replaced event
		a.add(2, 4);
	}
}
