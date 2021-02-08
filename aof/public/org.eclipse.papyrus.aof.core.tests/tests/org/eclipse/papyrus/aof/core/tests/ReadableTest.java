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

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class ReadableTest extends BaseTest {

	// Size

	@Test
	public void testReadableForSizeOnSeq() {
		testReadableForSize(IConstraints.SEQUENCE, 7, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testReadableForSizeOnBag() {
		testReadableForSize(IConstraints.BAG, 7, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testReadableForSizeOnSet() {
		testReadableForSize(IConstraints.SET, 4, 1, 2, 3, 4, 4, 4);
	}

	@Test
	public void testReadableForSizeOnOSet() {
		testReadableForSize(IConstraints.ORDERED_SET, 4, 1, 2, 3, 4, 4, 4);
	}

	@Test
	public void testReadableForSizeOnOneDefaultDefault() {
		testReadableForSize(IConstraints.ONE, 1);
	}

	@Test
	public void testReadableForSizeOnOneOtherDefault() {
		testReadableForSize(IConstraints.ONE, 1, 1);
	}

	@Test
	public void testReadableForSizeOnOneValue() {
		testReadableForSize(IConstraints.ONE, 1, 1, 2, 3);
	}

	@Test
	public void testReadableForSizeOnOpt() {
		testReadableForSize(IConstraints.OPTION, 1, 1, 2, 3);
	}

	@Test
	public void testReadableForSizeOnEmptySeq() {
		testReadableForSize(IConstraints.SEQUENCE, 0);
	}

	@Test
	public void testReadableForSizeOnEmptyBag() {
		testReadableForSize(IConstraints.BAG, 0);
	}

	@Test
	public void testReadableForSizeOnEmptySet() {
		testReadableForSize(IConstraints.SET, 0);
	}

	@Test
	public void testReadableForSizeOnEmptyOSet() {
		testReadableForSize(IConstraints.ORDERED_SET, 0);
	}

	@Test
	public void testReadableForSizeOnEmptyOne() {
		testReadableForSize(IConstraints.ONE, 1);
	}

	@Test
	public void testReadableForSizeOnEmptyOpt() {
		testReadableForSize(IConstraints.OPTION, 0);
	}

	@Test
	public void testReadableForSizeOnSeqWithNulls() {
		testReadableForSize(IConstraints.SEQUENCE, 7, null, 1, null, null, 2, null, 3);
	}

	@Test
	public void testReadableForSizeOnBagWithNulls() {
		testReadableForSize(IConstraints.BAG, 7, null, 1, null, null, 2, null, 3);
	}

	@Test
	public void testReadableForSizeOnSetWithNull() {
		testReadableForSize(IConstraints.SET, 4, null, 1, null, null, 2, null, 3);
	}

	@Test
	public void testReadableForSizeOnWithNull() {
		testReadableForSize(IConstraints.ORDERED_SET, 4, null, 1, null, null, 2, null, 3);
	}

	@Test
	public void testReadableForSizeOnOneWithNull() {
		testReadableForSize(IConstraints.ONE, 1, (Integer) null);
	}

	@Test
	public void testReadableForSizeOnOptWithNull() {
		testReadableForSize(IConstraints.OPTION, 1, (Integer) null);
	}

	public void testReadableForSize(IConstraints inputType, int expectedSize, Integer... elements) {
		IBox<Integer> box = factory.createBox(inputType, elements);
		assertEquals(expectedSize, box.length());
	}

	// Get

	@Test
	public void testReadableForGetOnSeq() {
		testReadableForGet(IConstraints.SEQUENCE, 1, 2, 2, 3, 3, 3);
	}

	@Test
	public void testReadableForGetOnBag() {
		testReadableForGet(IConstraints.BAG, 1, 2, 2, 3, 3, 3);
	}

	@Test
	public void testReadableForGetOnSet() {
		testReadableForGet(IConstraints.SET, 1, 2, 3);
	}

	@Test
	public void testReadableForGetOnOSet() {
		testReadableForGet(IConstraints.ORDERED_SET, 1, 2, 3);
	}

	@Test
	public void testReadableForGetOnOne() {
		testReadableForGet(IConstraints.ONE, 1);
	}

	@Test
	public void testReadableForGetOnOpt() {
		testReadableForGet(IConstraints.OPTION, 1);
	}

	@Test
	public void testReadableForGetOnSeqWithNulls() {
		testReadableForGet(IConstraints.SEQUENCE, null, 1, null, null, 2, null, 3);
	}

	@Test
	public void testReadableForGetOnBagWithNulls() {
		testReadableForGet(IConstraints.BAG, null, 1, null, null, 2, null, 3);
	}

	@Test
	public void testReadableForGetOnSetWithNull() {
		testReadableForGet(IConstraints.SET, 1, null, 2, 3);
	}

	@Test
	public void testReadableForGetOnOSetWithNull() {
		testReadableForGet(IConstraints.ORDERED_SET, 1, null, 2, 3);
	}

	@Test
	public void testReadableForGetOnOneWithNull() {
		testReadableForGet(IConstraints.ONE, (Integer) null);
	}

	@Test
	public void testReadableForGetOnOptWithNull() {
		testReadableForGet(IConstraints.OPTION, (Integer) null);
	}

	public void testReadableForGet(IConstraints inputType, Integer... elements) {
		IBox<Integer> box = factory.createBox(inputType, elements);
		for (int i = 0; i < elements.length; i++) {
			assertEquals(elements[i], box.get(i));
		}
	}

	@Test
	public void testReadableForGetOnEmptySeq() {
		thrown.expect(AssertionError.class);
		testReadableForGetOnEmpty(IConstraints.SEQUENCE);
	}

	@Test
	public void testReadableForGetOnEmptyBag() {
		thrown.expect(AssertionError.class);
		testReadableForGetOnEmpty(IConstraints.BAG);
	}

	@Test
	public void testReadableForGetOnEmptySet() {
		thrown.expect(AssertionError.class);
		testReadableForGetOnEmpty(IConstraints.SET);
	}

	@Test
	public void testReadableForGetOnEmptyOSet() {
		thrown.expect(AssertionError.class);
		testReadableForGetOnEmpty(IConstraints.ORDERED_SET);
	}

	@Test
	public void testReadableForGetOnEmptyOne() {
		testReadableForGetOnEmpty(IConstraints.ONE);
	}

	@Test
	public void testReadableForGetOnEmptyOpt() {
		thrown.expect(AssertionError.class);
		testReadableForGetOnEmpty(IConstraints.OPTION);
	}

	public void testReadableForGetOnEmpty(IConstraints inputType) {
		IBox<Integer> box = factory.createBox(inputType);
		// only possible for a one box
		assertEquals(null, box.get(0));
	}

	// Search = indexOf + contains

	@Test
	public void testReadableForSearchExistingOnSeq() {
		testReadableForSearch(IConstraints.SEQUENCE, 3, 4, 0, 1, 2, 2, 3, 3, 3);
	}

	@Test
	public void testReadableForSearchExistingOnBag() {
		testReadableForSearch(IConstraints.BAG, 3, 4, 0, 1, 2, 2, 3, 3, 3);
	}

	@Test
	public void testReadableForSearchExistingOnSet() {
		testReadableForSearch(IConstraints.SET, 2, 1, 1, 2, 3);
	}

	@Test
	public void testReadableForSearchExistingOnOSet() {
		testReadableForSearch(IConstraints.ORDERED_SET, 2, 1, 1, 2, 3);
	}

	@Test
	public void testReadableForSearchExistingOnOneWithDefault() {
		testReadableForSearch(IConstraints.ONE, null, 0);
	}

	@Test
	public void testReadableForSearchExistingOnOneWithNewDefault() {
		testReadableForSearch(IConstraints.ONE, 1, 0, 1);
	}

	@Test
	public void testReadableForSearchExistingOnOneWithValue() {
		testReadableForSearch(IConstraints.ONE, 123, 0, 1, 123);
	}

	@Test
	public void testReadableForSearchExistingOnOpt() {
		testReadableForSearch(IConstraints.OPTION, 123, 0, 123);
	}

	@Test
	public void testReadableForSearchNonExistingOnSeq() {
		testReadableForSearch(IConstraints.SEQUENCE, 4, -1, 0, 1, 2, 2, 3, 3, 3);
	}

	@Test
	public void testReadableForSearchNonExistingOnBag() {
		testReadableForSearch(IConstraints.BAG, 4, -1, 0, 1, 2, 2, 3, 3, 3);
	}

	@Test
	public void testReadableForSearchNonExistingOnSet() {
		testReadableForSearch(IConstraints.SET, 4, -1, 1, 2, 3);
	}

	@Test
	public void testReadableForSearchNonExistingOnOSet() {
		testReadableForSearch(IConstraints.ORDERED_SET, 4, -1, 1, 2, 3);
	}

	@Test
	public void testReadableForSearchNonExistingOnOneWithDefault() {
		testReadableForSearch(IConstraints.ONE, 1, -1);
	}

	@Test
	public void testReadableForSearchNonExistingOnOneWithNewDefault() {
		testReadableForSearch(IConstraints.ONE, 4, -1, 1);
	}

	@Test
	public void testReadableForSearchNonExistingOnOneWithValue() {
		testReadableForSearch(IConstraints.ONE, 1, -1, 1, 123);
	}

	@Test
	public void testReadableForSearchNonExistingOnOpt() {
		testReadableForSearch(IConstraints.OPTION, 4, -1, 123);
	}

	@Test
	public void testReadableForSearchExistingOnSeqWithNulls() {
		testReadableForSearch(IConstraints.SEQUENCE, null, 1, 1, null, null, 2, null, 3);
	}

	@Test
	public void testReadableForSearchExistingOnBagWithNulls() {
		testReadableForSearch(IConstraints.BAG, null, 1, 1, null, null, 2, null, 3);
	}

	@Test
	public void testReadableForSearchExistingOnSetWithNull() {
		testReadableForSearch(IConstraints.SET, null, 1, 1, null, 2, 3);
	}

	@Test
	public void testReadableForSearchExistingOnOSetWithNull() {
		testReadableForSearch(IConstraints.ORDERED_SET, null, 1, 1, null, 2, 3);
	}

	@Test
	public void testReadableForSearchExistingOnOneWithWithNull() {
		testReadableForSearch(IConstraints.ONE, null, 0, (Integer) null);
	}

	@Test
	public void testReadableForSearchExistingOnOptWithNull() {
		testReadableForSearch(IConstraints.OPTION, null, 0, (Integer) null);
	}

	public void testReadableForSearch(IConstraints inputType, Integer elementToSearchFor, int index, Integer... elements) {
		IBox<Integer> box = factory.createBox(inputType, elements);
		assertEquals(index, box.indexOf(elementToSearchFor));
		assertEquals(index != -1, box.contains(elementToSearchFor));
	}

	public void testReadableForContains(IConstraints inputType, Integer elementToSearchFor, boolean found, Integer... elements) {
		IBox<Integer> box = factory.createBox(inputType, elements);
		assertEquals(found, box.contains(elementToSearchFor));
	}

}
