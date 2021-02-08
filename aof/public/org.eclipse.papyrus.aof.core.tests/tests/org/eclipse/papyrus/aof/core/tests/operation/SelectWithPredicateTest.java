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
package org.eclipse.papyrus.aof.core.tests.operation;

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class SelectWithPredicateTest extends AbstractSelectTest {

	@Override
	protected IBox<Integer> select(IBox<Integer> a, IUnaryFunction<Integer, Boolean> f) {
		return a.select(f);
	}

	// Select instances of a given class: initial creation

	@Test
	public void testCreateForSelectInstancesOfObjectFromSeq() {
		testCreateForSelectInstancesOfClass(IConstraints.SEQUENCE, IConstraints.SEQUENCE, Object.class, 1, 2, "two", 2, "three", "three", 3, "four");
	}

	@Test
	public void testCreateForSelectInstancesOfIntegerFromSeq() {
		testCreateForSelectInstancesOfClass(IConstraints.SEQUENCE, IConstraints.SEQUENCE, Integer.class, 1, 2, 2, 3);
	}

	@Test
	public void testCreateForSelectInstancesOfBooleanFromSeq() {
		testCreateForSelectInstancesOfClass(IConstraints.SEQUENCE, IConstraints.SEQUENCE, Boolean.class);
	}

	@Test
	public void testCreateForSelectInstancesOfStringFromBag() {
		testCreateForSelectInstancesOfClass(IConstraints.BAG, IConstraints.BAG, String.class, "two", "three", "three", "four");
	}

	@Test
	public void testCreateForSelectInstancesOfIntegerFromSet() {
		testCreateForSelectInstancesOfClass(IConstraints.SET, IConstraints.SET, Integer.class, 1, 2, 3);
	}

	@Test
	public void testCreateForSelectInstancesOfStringFromOSet() {
		testCreateForSelectInstancesOfClass(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET, String.class, "two", "three", "four");
	}

	@Test
	public void testCreateForSelectInstancesOfIntegerFromOpt() {
		testCreateForSelectInstancesOfClass(IConstraints.OPTION, IConstraints.OPTION, Integer.class);
	}

	@Test
	public void testCreateForSelectInstancesOfIntegerFromOne() {
		testCreateForSelectInstancesOfClass(IConstraints.ONE, IConstraints.OPTION, Integer.class);
	}

	@Test
	public void testCreateForSelectInstancesOfStringFromOne() {
		testCreateForSelectInstancesOfClass(IConstraints.ONE, IConstraints.OPTION, String.class, "four");
	}

	public <C> void testCreateForSelectInstancesOfClass(IConstraints inputType, IConstraints expectedType, Class<C> clazz, Object... expectedElements) {
		IBox<Object> a = factory.createBox(inputType, (Object) 1, 2, "two", 2, "three", "three", 3, "four");
		IBox<C> b = a.select(clazz);
		IBox<Object> expectedBox = factory.createBox(expectedType, expectedElements);
		assertEquals(expectedBox, b);
	}

	// Select instances of a given class: mutations

	@Test
	public void testMutationForSelectInstancesOfObjectFromSeq() {
		testMutationForSelectInstancesOfClass(IConstraints.SEQUENCE, Object.class);
	}

	@Test
	public void testMutationForSelectInstancesOfIntegerFromSeq() {
		testMutationForSelectInstancesOfClass(IConstraints.SEQUENCE, Integer.class);
	}

	@Test
	public void testMutationForSelectInstancesOfBooleanFromSeq() {
		testMutationForSelectInstancesOfClass(IConstraints.SEQUENCE, Integer.class);
	}

	@Test
	public void testMutationForSelectInstancesOfStringFromBag() {
		testMutationForSelectInstancesOfClass(IConstraints.BAG, String.class);
	}

	@Test
	public void testMutationForSelectInstancesOfIntegerFromSet() {
		testMutationForSelectInstancesOfClass(IConstraints.SET, Integer.class);
	}

	@Test
	public void testMutationForSelectInstancesOfStringFromOSet() {
		testMutationForSelectInstancesOfClass(IConstraints.ORDERED_SET, String.class);
	}

	@Test
	public void testMutationForSelectInstancesOfIntegerFromOpt() {
		testMutationForSelectInstancesOfClass(IConstraints.OPTION, Integer.class);
	}

	@Test
	public void testMutationForSelectInstancesOfIntegerFromOne() {
		testMutationForSelectInstancesOfClass(IConstraints.ONE, Integer.class);
	}

	@Test
	public void testMutationForSelectInstancesOfStringFromOne() {
		testMutationForSelectInstancesOfClass(IConstraints.ONE, String.class);
	}

	public <C> void testMutationForSelectInstancesOfClass(IConstraints inputType, Class<C> selectorClass) {
		IBox<Object> a = factory.createBox(inputType, (Object) 1, 2, "2", 2, "3", "3", 3, "4", 4, 5, 6, 7);
		IBox<C> b = a.select(selectorClass);
		if (!a.isUnique()) {
			a.add("4");
		}
		a.removeAt(0);
		a.add(0, "zero");
		if (!a.isSingleton()) {
			a.add(8);
			a.removeAt(2);
			a.move(1, 5);
			a.move(4, 0);
			a.set(3, "?");
		}
		assertEquals(a.select(selectorClass), b);
	}


}
