/*******************************************************************************
 *  Copyright (c) 2015 ESEO.
 *  All rights reserved. This program and the accompanying materials
 *  are made available under the terms of the Eclipse Public License v1.0
 *  which accompanies this distribution, and is available at
 *  http://www.eclipse.org/legal/epl-v10.html
 *
 *  Contributors:
 *     Olivier Beaudoux - JUnit testing of path operation on all box types
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
public class ConcatTest extends BaseTest {

	protected IUnaryFunction<Integer, Boolean> lessThanFive = new IUnaryFunction<Integer, Boolean>() {
		@Override
		public Boolean apply(Integer i) {
			return i < 5;
		}
	};

	// Create

	@Test
	public void testCreateForConcatOnSeqOSet() {
		testCreateForConcat(IConstraints.SEQUENCE, IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testCreateForConcatOnBagOSet() {
		testCreateForConcat(IConstraints.BAG, IConstraints.ORDERED_SET, IConstraints.BAG);
	}

	@Test
	public void testCreateForConcatOnOSetOSet() {
		testCreateForConcat(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testCreateForConcatOnSetOSet() {
		testCreateForConcat(IConstraints.SET, IConstraints.ORDERED_SET, IConstraints.BAG);
	}

	@Test
	public void testCreateForConcatOnOptSet() {
		testCreateForConcat(IConstraints.OPTION, IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testCreateForConcatOnOneOSet() {
		testCreateForConcat(IConstraints.ONE, IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	public void testCreateForConcat(IConstraints leftType, IConstraints rightType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(leftType, 1, 2, 2, 3);
		IBox<Integer> b = factory.createBox(rightType, 7, 5, 8, 5, 6);
		IBox<Integer> c = a.concat(b);
		assertEquals(expectedType, c);
		assertEquals(a.concat(b), c);
	}

	// Add

	@Test
	public void testAddForConcatOnSeqSeq() {
		testAddForConcat(IConstraints.SEQUENCE, IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testAddForConcatOnSeqSet() {
		testAddForConcat(IConstraints.SEQUENCE, IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testAddForConcatOnBagSet() {
		testAddForConcat(IConstraints.BAG, IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testAddForConcatOnOSetSet() {
		testAddForConcat(IConstraints.ORDERED_SET, IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testAddForConcatOnSetSet() {
		testAddForConcat(IConstraints.SET, IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testAddForConcatOnOptSet() {
		testAddForConcat(IConstraints.OPTION, IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testAddForConcatOnOneSet() {
		testAddForConcat(IConstraints.ONE, IConstraints.SET, IConstraints.BAG);
	}

	public void testAddForConcat(IConstraints leftType, IConstraints rightType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(leftType, 1, 2);
		IBox<Integer> b = factory.createBox(rightType, 5, 6);
		IBox<Integer> c = a.concat(b);
		a.add(0, 3);
		b.add(0, 7);
		a.add(4);
		if (!a.isUnique()) {
			a.add(2, 2);
		}
		if (!b.isUnique()) {
			b.add(5);
		}
		assertEquals(expectedType, c);
		assertEquals(a.concat(b), c);
	}

	// Remove

	@Test
	public void testRemoveForConcatOnSeqSeq() {
		testRemoveForConcat(IConstraints.SEQUENCE, IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testRemoveForConcatOnBagSeq() {
		testRemoveForConcat(IConstraints.BAG, IConstraints.SEQUENCE, IConstraints.BAG);
	}

	@Test
	public void testRemoveForConcatOnOSetSeq() {
		testRemoveForConcat(IConstraints.ORDERED_SET, IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testRemoveForConcatOnSetSet() {
		testRemoveForConcat(IConstraints.SET, IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testRemoveForConcatOnOptSeq() {
		testRemoveForConcat(IConstraints.OPTION, IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testRemoveForConcatOnSeqOne() {
		testRemoveForConcat(IConstraints.SEQUENCE, IConstraints.ONE, IConstraints.SEQUENCE);
	}

	public void testRemoveForConcat(IConstraints leftType, IConstraints rightType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(leftType, 1, 2, 2, 3);
		IBox<Integer> b = factory.createBox(rightType, 5, 5, 7, 5, 6);
		IBox<Integer> c = a.concat(b);
		a.removeAt(0);
		b.removeAt(0);
		if (!a.isSingleton()) {
			a.removeAt(1);
		}
		if (!a.isUnique()) {
			a.removeAt(0);
		}
		assertEquals(expectedType, c);
		assertEquals(a.concat(b), c);
	}

	// Replace

	@Test
	public void testReplaceForConcatOnSeqBag() {
		testReplaceForConcat(IConstraints.SEQUENCE, IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testReplaceForConcatOnBagBag() {
		testReplaceForConcat(IConstraints.BAG, IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testReplaceForConcatOnOSetBag() {
		testReplaceForConcat(IConstraints.ORDERED_SET, IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testReplaceForConcatOnSetBag() {
		testReplaceForConcat(IConstraints.SET, IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testReplaceForConcatOnOptBag() {
		testReplaceForConcat(IConstraints.OPTION, IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testReplaceForConcatOnOneBag() {
		testReplaceForConcat(IConstraints.ONE, IConstraints.BAG, IConstraints.BAG);
	}

	public void testReplaceForConcat(IConstraints leftType, IConstraints rightType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(leftType, 1, 2, 2, 3);
		IBox<Integer> b = factory.createBox(rightType, 5, 5, 7, 5, 6);
		IBox<Integer> c = a.concat(b);
		a.set(0, 4);
		b.set(0, 8);
		a.set(0, 4);
		if (!b.isUnique()) {
			b.set(2, 5);
			b.set(3, 6);
		}
		if (!a.isUnique()) {
			a.set(2, 3);
		}
		assertEquals(expectedType, c);
		assertEquals(a.concat(b), c);
	}

	// Move

	@Test
	public void testMoveForConcatOnSeqOSet() {
		testMoveForConcat(IConstraints.SEQUENCE, IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForConcatOnBagOSet() {
		testMoveForConcat(IConstraints.BAG, IConstraints.ORDERED_SET, IConstraints.BAG);
	}

	@Test
	public void testMoveForConcatOnOSetOSet() {
		testMoveForConcat(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForConcatOnSetOSet() {
		testMoveForConcat(IConstraints.SET, IConstraints.ORDERED_SET, IConstraints.BAG);
	}

	@Test
	public void testMoveForConcatOnOptOSet() {
		testMoveForConcat(IConstraints.OPTION, IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForConcatOnOSetOne() {
		testMoveForConcat(IConstraints.ORDERED_SET, IConstraints.ONE, IConstraints.SEQUENCE);
	}

	public void testMoveForConcat(IConstraints leftType, IConstraints rightType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(leftType, 1, 2, 2, 3);
		IBox<Integer> b = factory.createBox(rightType, 5, 5, 7, 5, 6);
		IBox<Integer> c = a.concat(b);
		if (a.isSingleton()) {
			a.move(0, 0);
		}
		if (b.isSingleton()) {
			b.move(0, 0);
		}
		if (!a.isSingleton()) {
			a.move(0, 2);
			a.move(2, 1);
		}
		if (!b.isSingleton()) {
			b.move(2, 1);
			b.move(0, 2);
		}
		assertEquals(expectedType, c);
		assertEquals(a.concat(b), c);
	}

	// Clear

	@Test
	public void testClearForConcatOnOneSeq() {
		testClearForConcat(IConstraints.ONE, IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testClearForConcatOnOneBag() {
		testClearForConcat(IConstraints.ONE, IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testClearForConcatOnOneOSet() {
		testClearForConcat(IConstraints.ONE, IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testClearForConcatOnOneSet() {
		testClearForConcat(IConstraints.ONE, IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testClearForConcatOnOneOpt() {
		testClearForConcat(IConstraints.ONE, IConstraints.OPTION, IConstraints.SEQUENCE);
	}

	@Test
	public void testClearForConcatOnOptOne() {
		testClearForConcat(IConstraints.OPTION, IConstraints.ONE, IConstraints.SEQUENCE);
	}

	@Test
	public void testClearForConcatOnOneOne() {
		testClearForConcat(IConstraints.ONE, IConstraints.ONE, IConstraints.SEQUENCE);
	}

	public void testClearForConcat(IConstraints leftType, IConstraints rightType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(leftType, 1, 2, 2, 3);
		IBox<Integer> b = factory.createBox(rightType, 5, 5, 7, 5, 6);
		IBox<Integer> c = a.concat(b);
		a.clear();
		assertEquals(expectedType, c);
		assertEquals(a.concat(b), c);
	}


	// Create with self

	@Test
	public void testCreateForConcatOnSeqSelf() {
		testCreateForConcatSelf(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testCreateForConcatOnBagSelf() {
		testCreateForConcatSelf(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testCreateForConcatOnOSetSelf() {
		testCreateForConcatSelf(IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testCreateForConcatOnSetSelf() {
		testCreateForConcatSelf(IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testCreateForConcatOnOptSelf() {
		testCreateForConcatSelf(IConstraints.OPTION, IConstraints.SEQUENCE);
	}

	@Test
	public void testCreateForConcatOnOneSelf() {
		testCreateForConcatSelf(IConstraints.ONE, IConstraints.SEQUENCE);
	}

	public void testCreateForConcatSelf(IConstraints selfType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(selfType, 1, 2, 2, 3);
		IBox<Integer> b = a.concat(a);
		assertEquals(expectedType, b);
		assertEquals(a.concat(a), b);
	}

	// Add with self

	@Test
	public void testAddForConcatOnSeqSelf() {
		testAddForConcatSelf(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testAddForConcatOnBagSelf() {
		testAddForConcatSelf(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testAddForConcatOnOSetSelf() {
		testAddForConcatSelf(IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testAddForConcatOnSetSelf() {
		testAddForConcatSelf(IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testAddForConcatOnOptSelf() {
		testAddForConcatSelf(IConstraints.OPTION, IConstraints.SEQUENCE);
	}

	@Test
	public void testAddForConcatOnOneSelf() {
		testAddForConcatSelf(IConstraints.ONE, IConstraints.SEQUENCE);
	}

	public void testAddForConcatSelf(IConstraints selfType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(selfType, 1, 2);
		IBox<Integer> b = a.concat(a);
		a.add(0, 3);
		a.add(4);
		if (!a.isUnique()) {
			a.add(2, 2);
		}
		assertEquals(expectedType, b);
		assertEquals(a.concat(a), b);
	}

	// Remove with self

	@Test
	public void testRemoveForConcatOnSeqSelf() {
		testRemoveForConcatSelf(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testRemoveForConcatOnBagSelf() {
		testRemoveForConcatSelf(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testRemoveForConcatOnOSetSelf() {
		testRemoveForConcatSelf(IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testRemoveForConcatOnSetSelf() {
		testRemoveForConcatSelf(IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testRemoveForConcatOnOptSelf() {
		testRemoveForConcatSelf(IConstraints.OPTION, IConstraints.SEQUENCE);
	}

	@Test
	public void testRemoveForConcatOnOneSelf() {
		testRemoveForConcatSelf(IConstraints.ONE, IConstraints.SEQUENCE);
	}

	public void testRemoveForConcatSelf(IConstraints selfType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(selfType, 1, 2, 2, 3);
		IBox<Integer> b = a.concat(a);
		a.removeAt(0);
		if (!a.isSingleton()) {
			a.removeAt(1);
		}
		if (!a.isUnique()) {
			a.removeAt(0);
		}
		assertEquals(expectedType, b);
		assertEquals(a.concat(a), b);
	}

	// Replace with self

	@Test
	public void testReplaceForConcatOnSeqSelf() {
		testReplaceForConcatSelf(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testReplaceForConcatOnBagSelf() {
		testReplaceForConcatSelf(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testReplaceForConcatOnOSetSelf() {
		testReplaceForConcatSelf(IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testReplaceForConcatOnSetSelf() {
		testReplaceForConcatSelf(IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testReplaceForConcatOnOptSelf() {
		testReplaceForConcatSelf(IConstraints.OPTION, IConstraints.SEQUENCE);
	}

	@Test
	public void testReplaceForConcatOnOneSelf() {
		testReplaceForConcatSelf(IConstraints.ONE, IConstraints.SEQUENCE);
	}

	public void testReplaceForConcatSelf(IConstraints selfType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(selfType, 1, 2, 2, 3);
		IBox<Integer> b = a.concat(a);
		a.set(0, 4);
		a.set(0, 4);
		if (!a.isUnique()) {
			a.set(2, 3);
		}
		assertEquals(expectedType, b);
		assertEquals(a.concat(a), b);
	}

	// Move with self

	@Test
	public void testMoveForConcatOnSeqSelf() {
		testMoveForConcatSelf(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForConcatOnBagSelf() {
		testMoveForConcatSelf(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testMoveForConcatOnOSetSelf() {
		testMoveForConcatSelf(IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForConcatOnSetSelf() {
		testMoveForConcatSelf(IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testMoveForConcatOnOptSelf() {
		testMoveForConcatSelf(IConstraints.OPTION, IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForConcatOnOneSelf() {
		testMoveForConcatSelf(IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	public void testMoveForConcatSelf(IConstraints selfType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(selfType, 1, 2, 2, 3);
		IBox<Integer> b = a.concat(a);
		if (a.isSingleton()) {
			a.move(0, 0);
		}
		if (!a.isSingleton()) {
			a.move(0, 2);
			a.move(2, 1);
		}
		assertEquals(expectedType, b);
		assertEquals(a.concat(a), b);
	}

	// Clear with self

	@Test
	public void testClearForConcatOnSeqSelf() {
		testClearForConcatSelf(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testClearForConcatOnBagSelf() {
		testClearForConcatSelf(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testClearForConcatOnOSetSelf() {
		testClearForConcatSelf(IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testClearForConcatOnSetSelf() {
		testClearForConcatSelf(IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testClearForConcatOnOptSelf() {
		testClearForConcatSelf(IConstraints.OPTION, IConstraints.SEQUENCE);
	}

	@Test
	public void testClearForConcatOnOneSelf() {
		testClearForConcatSelf(IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	public void testClearForConcatSelf(IConstraints selfType, IConstraints expectedType) {
		IBox<Integer> a = factory.createBox(selfType, 1, 2, 2, 3);
		IBox<Integer> b = a.concat(a);
		a.clear();
		assertEquals(expectedType, b);
		assertEquals(a.concat(a), b);
	}

}
