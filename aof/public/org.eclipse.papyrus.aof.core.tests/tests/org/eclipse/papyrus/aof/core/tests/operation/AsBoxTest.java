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
import org.eclipse.papyrus.aof.core.IOne;
import org.eclipse.papyrus.aof.core.tests.BaseTest;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

/**
 * Tests for IBox.asBox/asOption/asOne/asSet/asOrderedSet/asBag/asSequence,
 * based on Copy, Distinct and First active operation classes.
 *
 */
@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class AsBoxTest extends BaseTest {

	// Create

	@Test
	public void testCreateForAsBoxOnSeqToSeq() {
		testCreateForAsBox(IConstraints.SEQUENCE, IConstraints.SEQUENCE, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testCreateForAsBoxOnSeqToBag() {
		testCreateForAsBox(IConstraints.SEQUENCE, IConstraints.BAG, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testCreateForAsBoxOnSeqToOSet() {
		testCreateForAsBox(IConstraints.SEQUENCE, IConstraints.ORDERED_SET, 1, 2, 3, 4);
	}

	@Test
	public void testCreateForAsBoxOnSeqToSet() {
		testCreateForAsBox(IConstraints.SEQUENCE, IConstraints.SET, 1, 2, 3, 4);
	}

	@Test
	public void testCreateForAsBoxOnSeqToOpt() {
		testCreateForAsBox(IConstraints.SEQUENCE, IConstraints.OPTION, 1);
	}

	@Test
	public void testCreateForAsBoxOnSeqToOne() {
		testCreateForAsBox(IConstraints.SEQUENCE, IConstraints.ONE, 1);
	}

	@Test
	public void testCreateForAsBoxOnSetToSeq() {
		testCreateForAsBox(IConstraints.SET, IConstraints.SEQUENCE, 1, 2, 3, 4);
	}

	@Test
	public void testCreateForAsBoxOnSetToBag() {
		testCreateForAsBox(IConstraints.SET, IConstraints.BAG, 1, 2, 3, 4);
	}

	@Test
	public void testCreateForAsBoxOnSetToOSet() {
		testCreateForAsBox(IConstraints.SET, IConstraints.ORDERED_SET, 1, 2, 3, 4);
	}

	@Test
	public void testCreateForAsBoxOnSetToSet() {
		testCreateForAsBox(IConstraints.SET, IConstraints.SET, 1, 2, 3, 4);
	}

	@Test
	public void testCreateForAsBoxOnSetToOpt() {
		testCreateForAsBox(IConstraints.SET, IConstraints.OPTION, 1);
	}

	@Test
	public void testCreateForAsBoxOnSetToOne() {
		testCreateForAsBox(IConstraints.SET, IConstraints.ONE, 1);
	}

	@Test
	public void testCreateForAsBoxOnOneToSeq() {
		testCreateForAsBox(IConstraints.ONE, IConstraints.SEQUENCE, 4);
	}

	@Test
	public void testCreateForAsBoxOnOneToBag() {
		testCreateForAsBox(IConstraints.ONE, IConstraints.BAG, 4);
	}

	@Test
	public void testCreateForAsBoxOnOneToOSet() {
		testCreateForAsBox(IConstraints.ONE, IConstraints.ORDERED_SET, 4);
	}

	@Test
	public void testCreateForAsBoxOnOneToSet() {
		testCreateForAsBox(IConstraints.ONE, IConstraints.SET, 4);
	}

	@Test
	public void testCreateForAsBoxOnOneToOpt() {
		testCreateForAsBox(IConstraints.ONE, IConstraints.OPTION, 4);
	}

	@Test
	public void testCreateForAsBoxOnOneToOne() {
		testCreateForAsBox(IConstraints.ONE, IConstraints.ONE, 4);
	}

	public void testCreateForAsBox(IConstraints inputType, IConstraints outputType, Integer... expectedElements) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.asBox(outputType);
		IBox<Integer> expected = factory.createBox(outputType, expectedElements);
		assertEquals(expected, b);
	}

	@Test
	public void testOrderedSetasOne() {
		IBox<Integer> a = factory.createOrderedSet();
		IOne<Integer> b = a.asOne(null);
		b.set(0, 1);
	}
	
	// Create same ref box

	@Test
	public void testCreateForAsBoxOnSeqToSame() {
		testCreateForAsBoxToSame(IConstraints.SEQUENCE);
	}

	@Test
	public void testCreateForAsBoxOnBagToSame() {
		testCreateForAsBoxToSame(IConstraints.BAG);
	}

	@Test
	public void testCreateForAsBoxOnOSetToSame() {
		testCreateForAsBoxToSame(IConstraints.ORDERED_SET);
	}

	@Test
	public void testCreateForAsBoxOnSetToSame() {
		testCreateForAsBoxToSame(IConstraints.SET);
	}

	@Test
	public void testCreateForAsBoxOnOptToSame() {
		testCreateForAsBoxToSame(IConstraints.OPTION);
	}

	public void testCreateForAsBoxToSame(IConstraints inputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.asBox(inputType);
		assertTrue(a == b);
	}

	// Add

	@Test
	public void testAddForAsBoxOnSeqToSet() {
		testAddForAsBox(IConstraints.SEQUENCE, IConstraints.SET);
	}

	@Test
	public void testAddForAsBoxOnSeqToOne() {
		testAddForAsBox(IConstraints.SEQUENCE, IConstraints.ONE);
	}

	@Test
	public void testAddForAsBoxOnSeqToOpt() {
		testAddForAsBox(IConstraints.SEQUENCE, IConstraints.OPTION);
	}

	@Test
	public void testAddForAsBoxOnToBag() {
		testAddForAsBox(IConstraints.BAG, IConstraints.ORDERED_SET);
	}

	@Test
	public void testAddForAsBoxOnOSetToSeq() {
		testAddForAsBox(IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testAddForAsBoxOnSetToBag() {
		testAddForAsBox(IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testAddForAsBoxOnOptToSeq() {
		testAddForAsBox(IConstraints.OPTION, IConstraints.SEQUENCE);
	}

	@Test
	public void testAddForAsBoxOnOneToOSet() {
		testAddForAsBox(IConstraints.ONE, IConstraints.ORDERED_SET);
	}

	public void testAddForAsBox(IConstraints inputType, IConstraints outputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 3);
		IBox<Integer> b = a.asBox(outputType);
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
		assertEquals(a.asBox(outputType), b);
	}

	// Remove

	@Test
	public void testRemoveForAsBoxOnSeqToSet() {
		testRemoveForAsBox(IConstraints.SEQUENCE, IConstraints.ONE);
	}

	@Test
	public void testRemoveForAsBoxOnSeqToOpt() {
		testRemoveForAsBox(IConstraints.SEQUENCE, IConstraints.OPTION);
	}

	@Test
	public void testRemoveForAsBoxOnSeqToOne() {
		testRemoveForAsBox(IConstraints.SEQUENCE, IConstraints.ONE);
	}

	@Test
	public void testRemoveForAsBoxOnBagToSet() {
		testRemoveForAsBox(IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testRemoveForAsBoxOnOSetToSeq() {
		testRemoveForAsBox(IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testRemoveForAsBoxOnSetToBag() {
		testRemoveForAsBox(IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testRemoveForAsBoxOnOptToOne() {
		testRemoveForAsBox(IConstraints.OPTION, IConstraints.ONE);
	}

	@Test
	public void testRemoveForAsBoxOnOptToSeq() {
		testRemoveForAsBox(IConstraints.OPTION, IConstraints.SEQUENCE);
	}

	@Test
	public void testRemoveForAsBoxOnOneToOpt() {
		testRemoveForAsBox(IConstraints.ONE, IConstraints.OPTION);
	}

	@Test
	public void testRemoveForAsBoxOnOneToOSet() {
		testRemoveForAsBox(IConstraints.ONE, IConstraints.ORDERED_SET);
	}

	public void testRemoveForAsBox(IConstraints inputType, IConstraints outputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.asBox(outputType);
		if (!a.isSingleton()) {
			a.removeAt(2);
		}
		a.removeAt(0);
		assertEquals(a.asBox(outputType), b);
	}

	// Replace

	@Test
	public void testReplaceForAsBoxOnSeqToSet() {
		testReplaceForAsBox(IConstraints.SEQUENCE, IConstraints.SET);
	}

	@Test
	public void testReplaceForAsBoxOnBagToOSet() {
		testReplaceForAsBox(IConstraints.BAG, IConstraints.ORDERED_SET);
	}

	@Test
	public void testReplaceForAsBoxOnOSetToSeq() {
		testReplaceForAsBox(IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testReplaceForAsBoxOnOSetToOne() {
		testReplaceForAsBox(IConstraints.ORDERED_SET, IConstraints.ONE);
	}

	@Test
	public void testReplaceForAsBoxOnSetToBag() {
		testReplaceForAsBox(IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testReplaceForAsBoxOnOptToOne() {
		testReplaceForAsBox(IConstraints.OPTION, IConstraints.ONE);
	}

	@Test
	public void testReplaceForAsBoxOnOneToOpt() {
		testReplaceForAsBox(IConstraints.ONE, IConstraints.OPTION);
	}

	@Test
	public void testReplaceForAsBoxOnOneToSeq() {
		testReplaceForAsBox(IConstraints.ONE, IConstraints.SEQUENCE);
	}

	public void testReplaceForAsBox(IConstraints inputType, IConstraints outputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.asBox(outputType);
		a.set(0, 5);
		if (!a.isSingleton()) {
			a.set(1, 1);
			a.set(3, 2);
		}
		assertEquals(a.asBox(outputType), b);
	}

	// Move

	@Test
	public void testMoveForAsBoxOnSeqToSet() {
		testMoveForAsBox(IConstraints.SEQUENCE, IConstraints.SET);
	}

	@Test
	public void testMoveForAsBoxOnBagToSeq() {
		testMoveForAsBox(IConstraints.BAG, IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForAsBoxOnBagToOpt() {
		testMoveForAsBox(IConstraints.BAG, IConstraints.OPTION);
	}

	@Test
	public void testMoveForAsBoxOnBagToOne() {
		testMoveForAsBox(IConstraints.BAG, IConstraints.ONE);
	}

	@Test
	public void testMoveForAsBoxOnOSetToSeq() {
		testMoveForAsBox(IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForAsBoxOnSetToBag() {
		testMoveForAsBox(IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testMoveForAsBoxOnOptToSeq() {
		testMoveForAsBox(IConstraints.OPTION, IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForAsBoxOnOneToBag() {
		testMoveForAsBox(IConstraints.ONE, IConstraints.BAG);
	}

	public void testMoveForAsBox(IConstraints inputType, IConstraints outputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.asBox(outputType);
		if (a.isSingleton()) {
			a.move(0, 0);
		}
		else {
			a.move(0, 1);
			a.move(2, 1);
		}
		assertEquals(a.asBox(outputType), b);
	}

	// Clear

	@Test
	public void testClearForAsBoxOnSeqToOne() {
		testClearForAsBox(IConstraints.SEQUENCE, IConstraints.ONE);
	}

	@Test
	public void testClearForAsBoxOnSeqToBag() {
		testClearForAsBox(IConstraints.SEQUENCE, IConstraints.BAG);
	}

	@Test
	public void testClearForAsBoxOnBagToOSet() {
		testClearForAsBox(IConstraints.BAG, IConstraints.ORDERED_SET);
	}

	@Test
	public void testClearForAsBoxOnBagToOne() {
		testClearForAsBox(IConstraints.BAG, IConstraints.ONE);
	}

	@Test
	public void testClearForAsBoxOnOSetToSeq() {
		testClearForAsBox(IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testClearForAsBoxOnSetToBag() {
		testClearForAsBox(IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testClearForAsBoxOnOptToOne() {
		testClearForAsBox(IConstraints.OPTION, IConstraints.ONE);
	}

	@Test
	public void testClearForAsBoxOnOneToOpt() {
		testClearForAsBox(IConstraints.ONE, IConstraints.OPTION);
	}

	public void testClearForAsBox(IConstraints inputType, IConstraints outputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.asBox(outputType);
		a.clear();
		assertEquals(a.asBox(outputType), b);
	}


	// Add bidir

	@Test
	public void testAddForBidirAsBoxOnSeqToSet() {
		testAddForBidirAsBox(IConstraints.SEQUENCE, IConstraints.SET);
	}

	@Test
	public void testAddForBidirAsBoxOnSeqToOne() {
		testAddForBidirAsBox(IConstraints.SEQUENCE, IConstraints.ONE);
	}

	@Test
	public void testAddForBidirAsBoxOnSeqToOpt() {
		testAddForBidirAsBox(IConstraints.SEQUENCE, IConstraints.OPTION);
	}

	@Test
	public void testAddForBidirAsBoxOnBagToOSet() {
		testAddForBidirAsBox(IConstraints.BAG, IConstraints.ORDERED_SET);
	}

	@Test
	public void testAddForBidirAsBoxOnOSetToSeq() {
		testAddForBidirAsBox(IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testAddForBidirAsBoxOnSetToBag() {
		testAddForBidirAsBox(IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testAddForBidirAsBoxOnOptToSeq() {
		thrown.expect(IllegalStateException.class);
		testAddForBidirAsBox(IConstraints.OPTION, IConstraints.SEQUENCE);
	}

	@Test
	public void testAddForBidirAsBoxOnOneToOSet() {
		thrown.expect(IllegalStateException.class);
		testAddForBidirAsBox(IConstraints.ONE, IConstraints.ORDERED_SET);
	}

	public void testAddForBidirAsBox(IConstraints inputType, IConstraints outputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 3);
		IBox<Integer> b = a.asBox(outputType);
		if (b.isSingleton()) {
			b.add(0, 4);
		}
		else {
			b.add(4);
			if (!a.isUnique() && !b.isUnique()) {
				b.add(1, 2);
				b.add(3, 3);
				b.add(3, 3);
			}
		}
		assertEquals(b, a.asBox(outputType));
	}

	// Remove bidir

	@Test
	public void testRemoveForBidirAsBoxOnSeqToSet() {
		testRemoveForBidirAsBox(IConstraints.SEQUENCE, IConstraints.SET);
	}

	@Test
	public void testRemoveForBidirAsBoxOnSeqToOpt() {
		testRemoveForBidirAsBox(IConstraints.SEQUENCE, IConstraints.OPTION);
	}

	@Test
	public void testRemoveForBidirAsBoxOnSeqToOne() {
		testRemoveForBidirAsBox(IConstraints.SEQUENCE, IConstraints.ONE);
	}

	@Test
	public void testRemoveForBidirAsBoxOnBagToSet() {
		testRemoveForBidirAsBox(IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testRemoveForBidirAsBoxOnOSetToSeq() {
		testRemoveForBidirAsBox(IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testRemoveForBidirAsBoxOnSetToBag() {
		testRemoveForBidirAsBox(IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testRemoveForBidirAsBoxOnOptToOne() {
		testRemoveForBidirAsBox(IConstraints.OPTION, IConstraints.ONE);
	}

	@Test
	public void testRemoveForBidirAsBoxOnOptToSeq() {
		testRemoveForBidirAsBox(IConstraints.OPTION, IConstraints.SEQUENCE);
	}

	@Test
	public void testRemoveForBidirAsBoxOnOneToOpt() {
		thrown.expect(IllegalStateException.class);
		testRemoveForBidirAsBox(IConstraints.ONE, IConstraints.OPTION);
	}

	@Test
	public void testRemoveForBidirAsBoxOnOneToOSet() {
		thrown.expect(IllegalStateException.class);
		testRemoveForBidirAsBox(IConstraints.ONE, IConstraints.ORDERED_SET);
	}

	public void testRemoveForBidirAsBox(IConstraints inputType, IConstraints outputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.asBox(outputType);
		if (b.length() > 2) {
			b.removeAt(2);
		}
		b.removeAt(0);
		assertEquals(b, a.asBox(outputType));
	}

	// Replace bidir

	@Test
	public void testReplaceForBidirAsBoxOnSeqToSet() {
		testReplaceForBidirAsBox(IConstraints.SEQUENCE, IConstraints.SET);
	}

	@Test
	public void testReplaceForBidirAsBoxOnBagToOSet() {
		testReplaceForBidirAsBox(IConstraints.BAG, IConstraints.ORDERED_SET);
	}

	@Test
	public void testReplaceForBidirAsBoxOnOSetToSeq() {
		testReplaceForBidirAsBox(IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testReplaceForBidirAsBoxOnOSetToOne() {
		testReplaceForBidirAsBox(IConstraints.ORDERED_SET, IConstraints.ONE);
	}

	@Test
	public void testReplaceForBidirAsBoxOnSetToBag() {
		testReplaceForBidirAsBox(IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testReplaceForBidirAsBoxOnOptToOne() {
		testReplaceForBidirAsBox(IConstraints.OPTION, IConstraints.ONE);
	}

	@Test
	public void testReplaceForBidirAsBoxOnOneToOpt() {
		testReplaceForBidirAsBox(IConstraints.ONE, IConstraints.OPTION);
	}

	@Test
	public void testReplaceForBidirAsBoxOnOneToSeq() {
		testReplaceForBidirAsBox(IConstraints.ONE, IConstraints.SEQUENCE);
	}

	public void testReplaceForBidirAsBox(IConstraints inputType, IConstraints outputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.asBox(outputType);
		b.set(0, 5);
		if (!a.isSingleton() && !b.isSingleton()) {
			b.set(1, 1);
			b.set(3, 2);
		}
		assertEquals(b, a.asBox(outputType));
	}

	// Move bidir

	@Test
	public void testMoveForBidirAsBoxOnSeqToSet() {
		testMoveForBidirAsBox(IConstraints.SEQUENCE, IConstraints.SET);
	}

	@Test
	public void testMoveForBidirAsBoxOnBagToSeq() {
		testMoveForBidirAsBox(IConstraints.BAG, IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForBidirAsBoxOnBagToOpt() {
		testMoveForBidirAsBox(IConstraints.BAG, IConstraints.OPTION);
	}

	@Test
	public void testMoveForBidirAsBoxOnBagToOne() {
		testMoveForBidirAsBox(IConstraints.BAG, IConstraints.ONE);
	}

	@Test
	public void testMoveForBidirAsBoxOnOSetToSeq() {
		testMoveForBidirAsBox(IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForBidirAsBoxOnSetToBag() {
		testMoveForBidirAsBox(IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testMoveForBidirAsBoxOnOptToSeq() {
		testMoveForBidirAsBox(IConstraints.OPTION, IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForBidirAsBoxOnOneToBag() {
		testMoveForBidirAsBox(IConstraints.ONE, IConstraints.BAG);
	}

	public void testMoveForBidirAsBox(IConstraints inputType, IConstraints outputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.asBox(outputType);
		if (b.isSingleton()) {
			b.move(0, 0);
		}
		else {
			if (b.length() > 1) {
				b.move(0, 1);
				if (b.length() > 2) {
					b.move(2, 1);
				}
			}
		}
		assertEquals(b, a.asBox(outputType));
	}

	// Clear bidir

	@Test
	public void testClearForBidirAsBoxOnSeqToOne() {
		testClearForBidirAsBox(IConstraints.SEQUENCE, IConstraints.ONE);
	}

	@Test
	public void testClearForBidirAsBoxOnSeqToBag() {
		testClearForBidirAsBox(IConstraints.SEQUENCE, IConstraints.BAG);
	}

	@Test
	public void testClearForBidirAsBoxOnBagToOSet() {
		testClearForBidirAsBox(IConstraints.BAG, IConstraints.ORDERED_SET);
	}

	@Test
	public void testClearForBidirAsBoxOnBagToOne() {
		testClearForBidirAsBox(IConstraints.BAG, IConstraints.ONE);
	}

	@Test
	public void testClearForBidirAsBoxOnOSetToSeq() {
		testClearForBidirAsBox(IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testClearForBidirAsBoxOnSetToBag() {
		testClearForBidirAsBox(IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testClearForBidirAsBoxOnOptToOne() {
		testClearForBidirAsBox(IConstraints.OPTION, IConstraints.ONE);
	}

	@Test
	public void testClearForBidirAsBoxOnOneToOpt() {
		thrown.expect(IllegalStateException.class);
		testClearForBidirAsBox(IConstraints.ONE, IConstraints.OPTION);
	}

	public void testClearForBidirAsBox(IConstraints inputType, IConstraints outputType) {
		IBox<Integer> a = factory.createBox(inputType, 1, 2, 2, 3, 3, 3, 4);
		IBox<Integer> b = a.asBox(outputType);
		b.clear();
		assertEquals(b, a.asBox(outputType));
	}

}
