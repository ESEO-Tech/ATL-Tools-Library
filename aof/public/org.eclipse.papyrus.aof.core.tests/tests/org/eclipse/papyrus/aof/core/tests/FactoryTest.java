/*******************************************************************************
 *  Copyright (c) 2015 ESEO.
 *  All rights reserved. This program and the accompanying materials
 *  are made available under the terms of the Eclipse Public License v1.0
 *  which accompanies this distribution, and is available at
 *  http://www.eclipse.org/legal/epl-v10.html
 *
 *  Contributors:
 *     Olivier Beaudoux - initial API and implementation
 *******************************************************************************/
package org.eclipse.papyrus.aof.core.tests;

import static org.junit.Assert.assertTrue;

import java.util.Date;

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.eclipse.papyrus.aof.core.IMetaClass;
import org.eclipse.papyrus.aof.core.IPair;
import org.junit.Test;

public abstract class FactoryTest extends BaseTest {

	// Box creation

	@Test
	public void testFactoryForCreateOption() {
		testFactoryForCreateBox(IConstraints.OPTION, 123);
		testFactoryForCreateBox(factory.createOption(123), 123);
	}

	@Test
	public void testFactoryForCreateOneWithDefaultDefault() {
		IBox<Integer> box = factory.createBox(IConstraints.ONE);
		for (Integer integer : box) {
			assertEquals(null, integer);
		}
	}

	@Test
	public void testFactoryForCreateOneWithNewDefault() {
		testFactoryForCreateBox(IConstraints.ONE, 123);
		testFactoryForCreateBox(factory.createOne(123), 123);
	}

	@Test
	public void testFactoryForCreateOneWithValue() {
		testFactoryForCreateBox(factory.createOne(0, 123), 123);
	}

	@Test
	public void testFactoryForCreateSequence() {
		testFactoryForCreateBox(IConstraints.SEQUENCE, 1, 2, 2, 3, 3, 3);
		testFactoryForCreateBox(factory.createSequence(1, 2, 2, 3, 3, 3), 1, 2, 2, 3, 3, 3);
	}

	@Test
	public void testFactoryForCreateBag() {
		testFactoryForCreateBox(IConstraints.BAG, 1, 2, 2, 3, 3, 3);
		testFactoryForCreateBox(factory.createBag(1, 2, 2, 3, 3, 3), 1, 2, 2, 3, 3, 3);
	}

	@Test
	public void testFactoryForCreateSet() {
		testFactoryForCreateBox(IConstraints.SET, 1, 2, 3, 4, 5);
		testFactoryForCreateBox(factory.createSet(1, 2, 2, 3, 3, 3), 1, 2, 3);
	}

	@Test
	public void testFactoryForCreateOrderedSet() {
		testFactoryForCreateBox(IConstraints.ORDERED_SET, 1, 2, 3, 4, 5);
		testFactoryForCreateBox(factory.createOrderedSet(1, 2, 2, 3, 3, 3), 1, 2, 3);
	}

	public void testFactoryForCreateBox(IConstraints constraints, Integer... elements) {
		IBox<Integer> box = factory.createBox(constraints, elements);
		testFactoryForCreateBox(box, elements);
	}

	public void testFactoryForCreateBox(IBox<Integer> box, Integer... exceptedElements) {
		int i = 0;
		for (Integer integer : box) {
			assertEquals(exceptedElements[i], integer);
			i++;
		}
	}

	// Tuple creation

	@Test
	public void testFactoryForCreatePair() {
		IPair<Integer, Integer> pair = factory.createPair(123, 456);
		assertEquals(new Integer(123), pair.getLeft());
		assertEquals(new Integer(456), pair.getRight());
	}

	// Meta-class access

	@Test
	public void testFactoryForGetMetaClassOnString() {
		testFactoryForGetMetaClass(String.class);
	}

	@Test
	public void testFactoryForGetMetaClassOnBoolean() {
		testFactoryForGetMetaClass(Boolean.class);
	}

	@Test
	public void testFactoryForGetMetaClassOnInteger() {
		testFactoryForGetMetaClass(Integer.class);
	}

	@Test
	public void testFactoryForGetMetaClassOnLong() {
		testFactoryForGetMetaClass(Long.class);
	}

	@Test
	public void testFactoryForGetMetaClassOnShort() {
		testFactoryForGetMetaClass(Short.class);
	}

	@Test
	public void testFactoryForGetMetaClassOnByte() {
		testFactoryForGetMetaClass(Byte.class);
	}

	@Test
	public void testFactoryForGetMetaClassOnCharacter() {
		testFactoryForGetMetaClass(Character.class);
	}

	@Test
	public void testFactoryForGetMetaClassOnDouble() {
		testFactoryForGetMetaClass(Double.class);
	}

	@Test
	public void testFactoryForGetMetaClassOnFloat() {
		testFactoryForGetMetaClass(Float.class);
	}

	@Test
	public void testFactoryForGetMetaClassOnDate() {
		testFactoryForGetMetaClass(Date.class);
	}

	public void testFactoryForGetMetaClass(Object platformClass) {
		IMetaClass<Object> metaClass = factory.getMetaClass(platformClass);
		assertTrue(metaClass != null);
	}

}
