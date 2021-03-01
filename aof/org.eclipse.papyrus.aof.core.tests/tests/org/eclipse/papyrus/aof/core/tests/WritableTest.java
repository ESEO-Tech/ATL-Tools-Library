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

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class WritableTest extends BaseTest {

	private List<Integer> createJavaList(Integer... elements) {
		// note that Arrays.asList returns an immutable list
		return new ArrayList<Integer>(Arrays.asList(elements));
	}

	// Add

	@Test
	public void testWritableForAddOnSeq() {
		testWritableForAdd(IConstraints.SEQUENCE, 123, 3, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForAddOnBag() {
		testWritableForAdd(IConstraints.BAG, 123, 3, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForAddOnSet() {
		testWritableForAdd(IConstraints.SET, 123, 3, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForAddOnOSet() {
		testWritableForAdd(IConstraints.ORDERED_SET, 123, 3, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForAddOnOpt() {
		testWritableForAdd(IConstraints.OPTION, 123, 0, 1);
	}

	@Test
	public void testWritableForAddOnOne() {
		testWritableForAdd(IConstraints.ONE, 123, 0, 1);
	}

	@Test
	public void testWritableForAddDuplicateOnSeq() {
		testWritableForAdd(IConstraints.SEQUENCE, 3, 3, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForAddDuplicateOnBag() {
		testWritableForAdd(IConstraints.BAG, 3, 3, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForAddDuplicateOnSet() {
		thrown.expect(AssertionError.class);
		testWritableForAdd(IConstraints.SET, 3, 3, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForAddOnDuplicateOSet() {
		thrown.expect(AssertionError.class);
		testWritableForAdd(IConstraints.ORDERED_SET, 3, 3, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForAddDuplicateOnOpt() {
		testWritableForAdd(IConstraints.OPTION, 1, 0, 1);
	}

	@Test
	public void testWritableForAddDuplicateOnOne() {
		testWritableForAdd(IConstraints.ONE, 1, 0, 1);
	}

	public void testWritableForAdd(IConstraints inputType, Integer elementToAdd, int index, Integer... elements) {
		IBox<Integer> box = factory.createBox(inputType, elements);
		box.add(index, elementToAdd);
		List<Integer> expected = createJavaList(elements);
		if (inputType.isSingleton()) {
			expected.clear();
		}
		expected.add(index, elementToAdd);
		assertEquals(expected, box);
	}

	// Add out of bounds

	@Test
	public void testWritableForAddOutOfUpperOnSeq() {
		testWritableForTryAdd(IConstraints.SEQUENCE, 1, 8, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForAddOutOfUpperOnBag() {
		testWritableForTryAdd(IConstraints.BAG, 1, 10, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForAddOutOfUpperOnSet() {
		testWritableForTryAdd(IConstraints.SET, 123, 5, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForAddOutOfUpperOnOSet() {
		testWritableForTryAdd(IConstraints.ORDERED_SET, 123, 6, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForAddOutOfUpperOnOpt() {
		testWritableForTryAdd(IConstraints.OPTION, 123, 1, 1);
	}

	@Test
	public void testWritableForAddOutOfUpperOnOne() {
		testWritableForTryAdd(IConstraints.ONE, 123, 1, 1);
	}

	@Test
	public void testWritableForAddOutOfLowerOnSeq() {
		testWritableForTryAdd(IConstraints.SEQUENCE, 1, -1, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForAddOutOfLowerOnBag() {
		testWritableForTryAdd(IConstraints.BAG, 1, -1, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForAddOutOfLowerOnSet() {
		testWritableForTryAdd(IConstraints.SET, 123, -1, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForAddOutOfLowerOnOSet() {
		testWritableForTryAdd(IConstraints.ORDERED_SET, 123, -1, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForAddOutOfLowerOnOpt() {
		testWritableForTryAdd(IConstraints.OPTION, 123, -1, 1);
	}

	@Test
	public void testWritableForAddOutOfLowerOnOne() {
		testWritableForTryAdd(IConstraints.ONE, 123, -1, 1);
	}

	public void testWritableForTryAdd(IConstraints inputType, Integer elementToAdd, int index, Integer... elements) {
		thrown.expect(AssertionError.class);
		IBox<Integer> box = factory.createBox(inputType, elements);
		box.add(index, elementToAdd);
	}

	// Add null values

	@Test
	public void testWritableForAddNullsOnSeq() {
		testWritableForAdd(IConstraints.SEQUENCE, null, 3, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForAddNullsOnBag() {
		testWritableForAdd(IConstraints.BAG, null, 3, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForAddNullsOnSet() {
		testWritableForAdd(IConstraints.SET, null, 3, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForAddNullsOnOSet() {
		testWritableForAdd(IConstraints.ORDERED_SET, null, 3, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForAddNullsOnOpt() {
		testWritableForAdd(IConstraints.OPTION, null, 0, 1);
	}

	@Test
	public void testWritableForAddNullsOnOne() {
		testWritableForAdd(IConstraints.ONE, null, 0, 1);
	}

	@Test
	public void testWritableForAddNullDuplicateOnSeq() {
		testWritableForAdd(IConstraints.SEQUENCE, null, 3, 1, 2, null, 3, null, null, 4);
	}

	@Test
	public void testWritableForAddNullDuplicateOnBag() {
		testWritableForAdd(IConstraints.BAG, null, 3, 1, 2, null, 3, null, null, 4);
	}

	@Test
	public void testWritableForAddNullDuplicateOnSet() {
		thrown.expect(AssertionError.class);
		testWritableForAdd(IConstraints.SET, null, 3, 1, 2, null, 3, 4);
	}

	@Test
	public void testWritableForAddNullsOnDuplicateOSet() {
		thrown.expect(AssertionError.class);
		testWritableForAdd(IConstraints.ORDERED_SET, null, 3, 1, 2, null, 3, 4);
	}

	@Test
	public void testWritableForAddNullDuplicateOnOpt() {
		testWritableForAdd(IConstraints.OPTION, null, 0, (Integer) null);
	}

	@Test
	public void testWritableForAddNullDuplicateOnOne() {
		testWritableForAdd(IConstraints.ONE, null, 0, (Integer) null);
	}

	// Append

	@Test
	public void testWritableForAppendOnSeq() {
		testWritableForAppend(IConstraints.SEQUENCE, 123, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForAppendOnBag() {
		testWritableForAppend(IConstraints.BAG, 123, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForAppendOnSet() {
		testWritableForAppend(IConstraints.SET, 123, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForAppendOnOSet() {
		testWritableForAppend(IConstraints.ORDERED_SET, 123, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForAppendOnOpt() {
		testWritableForAppend(IConstraints.OPTION, 123, 1);
	}

	@Test
	public void testWritableForAppendOnOne() {
		testWritableForAppend(IConstraints.ONE, 123, 1);
	}

	public void testWritableForAppend(IConstraints inputType, Integer elementToAppend, Integer... elements) {
		IBox<Integer> box = factory.createBox(inputType, elements);
		box.add(elementToAppend);
		List<Integer> expected = createJavaList(elements);
		if (inputType.isSingleton()) {
			expected.clear();
		}
		expected.add(elementToAppend);
		assertEquals(expected, box);
	}

	// Remove at

	@Test
	public void testWritableForRemoveAtOnSeq() {
		testWritableForRemoveAt(IConstraints.SEQUENCE, 3, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForRemoveAtOnBag() {
		testWritableForRemoveAt(IConstraints.BAG, 3, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForRemoveAtOnSet() {
		testWritableForRemoveAt(IConstraints.SET, 3, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForRemoveAtOnOSet() {
		testWritableForRemoveAt(IConstraints.ORDERED_SET, 3, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForRemoveAtOnOpt() {
		testWritableForRemoveAt(IConstraints.OPTION, 0, 1);
	}

	@Test
	public void testWritableForRemoveAtOnOne() {
		IBox<Integer> box = factory.createOne(0, 1);
		box.removeAt(0);
		assert (box.get(0).equals(0));
	}

	public void testWritableForRemoveAt(IConstraints inputType, int index, Integer... elements) {
		IBox<Integer> box = factory.createBox(inputType, elements);
		box.removeAt(index);
		List<Integer> expected = createJavaList(elements);
		expected.remove(index);
		assertEquals(expected, box);
	}

	// Remove at out of bounds

	@Test
	public void testWritableForRemoveAtOutOfUpperOnSeq() {
		testWritableForTryForRemoveAt(IConstraints.SEQUENCE, 8, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForRemoveAtOutOfUpperOnBag() {
		testWritableForTryForRemoveAt(IConstraints.BAG, 10, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForRemoveAtOutOfUpperOnSet() {
		testWritableForTryForRemoveAt(IConstraints.SET, 5, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForRemoveAtOutOfUpperOnOSet() {
		testWritableForTryForRemoveAt(IConstraints.ORDERED_SET, 6, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForRemoveAtOutOfUpperOnOpt() {
		testWritableForTryForRemoveAt(IConstraints.OPTION, 1, 1);
	}

	@Test
	public void testWritableForRemoveAtOutOfUpperOnOne() {
		testWritableForTryForRemoveAt(IConstraints.ONE, 1, 1);
	}

	@Test
	public void testWritableForRemoveAtOutOfLowerOnSeq() {
		testWritableForTryForRemoveAt(IConstraints.SEQUENCE, -1, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForRemoveAtOutOfLowerOnBag() {
		testWritableForTryForRemoveAt(IConstraints.BAG, -1, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForRemoveAtOutOfLowerOnSet() {
		testWritableForTryForRemoveAt(IConstraints.SET, -1, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForRemoveAtOutOfLowerOnOSet() {
		testWritableForTryForRemoveAt(IConstraints.ORDERED_SET, -1, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForRemoveAtOutOfLowerOnOpt() {
		testWritableForTryForRemoveAt(IConstraints.OPTION, -1, 1);
	}

	@Test
	public void testWritableForRemoveAtOutOfLowerOnOne() {
		testWritableForTryForRemoveAt(IConstraints.ONE, -1, 1);
	}

	public void testWritableForTryForRemoveAt(IConstraints inputType, int index, Integer... elements) {
		thrown.expect(AssertionError.class);
		IBox<Integer> box = factory.createBox(inputType, elements);
		box.removeAt(index);
	}

	// Remove

	@Test
	public void testWritableForRemoveOnSeq() {
		testWritableForRemove(IConstraints.SEQUENCE, 3, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForRemoveOnBag() {
		testWritableForRemove(IConstraints.BAG, 3, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForRemoveOnSet() {
		testWritableForRemove(IConstraints.SET, 3, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForRemoveOnOSet() {
		testWritableForRemove(IConstraints.ORDERED_SET, 3, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForRemoveOnOpt() {
		testWritableForRemove(IConstraints.OPTION, 1, 1);
	}

	@Test
	public void testWritableForRemoveOnOne() {
		IBox<Integer> box = factory.createOne(0, 1);
		box.remove(1);
		assert (box.get(0).equals(0));
	}

	public void testWritableForRemove(IConstraints inputType, Integer elementToRemove, Integer... elements) {
		IBox<Integer> box = factory.createBox(inputType, elements);
		box.remove(elementToRemove);
		List<Integer> expected = createJavaList(elements);
		expected.remove(elementToRemove);
		assertEquals(expected, box);
	}

	// Remove null values

	@Test
	public void testWritableForRemoveNullOnSeq() {
		testWritableForRemove(IConstraints.SEQUENCE, null, 1, 2, null, 3, null, 3, 4);
	}

	@Test
	public void testWritableForRemoveNullOnBag() {
		testWritableForRemove(IConstraints.BAG, null, 1, 2, null, 3, null, 3, 4);
	}

	@Test
	public void testWritableForRemoveNullOnSet() {
		testWritableForRemove(IConstraints.SET, null, 1, 2, null, 4);
	}

	@Test
	public void testWritableForRemoveNullOnOSet() {
		testWritableForRemove(IConstraints.ORDERED_SET, null, 1, 2, null, 4);
	}

	@Test
	public void testWritableForRemoveNullOnOpt() {
		testWritableForRemove(IConstraints.OPTION, null, (Integer) null);
	}

	@Test
	public void testWritableForRemoveNullOnOne() {
		IBox<Integer> box = factory.createOne(0, null);
		box.remove(null);
		assert (box.get(0).equals(0));
	}

	// Remove non existing

	@Test
	public void testWritableForRemoveNonExistingOnSeq() {
		testWritableForTryForRemove(IConstraints.SEQUENCE, 8, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForRemoveNonExistingOnBag() {
		testWritableForTryForRemove(IConstraints.BAG, 10, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForRemoveNonExistingOnSet() {
		testWritableForTryForRemove(IConstraints.SET, 5, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForRemoveNonExistingOnOSet() {
		testWritableForTryForRemove(IConstraints.ORDERED_SET, 6, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForRemoveNonExistingOnOpt() {
		testWritableForTryForRemove(IConstraints.OPTION, 123, 1);
	}

	@Test
	public void testWritableForRemoveNonExistingOnOne() {
		testWritableForTryForRemove(IConstraints.ONE, 123, 1);
	}

	public void testWritableForTryForRemove(IConstraints inputType, int elementToRemove, Integer... elements) {
		thrown.expect(AssertionError.class);
		IBox<Integer> box = factory.createBox(inputType, elements);
		box.remove(elementToRemove);
	}

	// Replace

	@Test
	public void testWritableForReplaceOnSeq() {
		testWritableForReplace(IConstraints.SEQUENCE, 123, 3, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForReplaceOnBag() {
		testWritableForReplace(IConstraints.BAG, 123, 3, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForReplaceOnSet() {
		testWritableForReplace(IConstraints.SET, 123, 3, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForReplaceOnOSet() {
		testWritableForReplace(IConstraints.ORDERED_SET, 123, 3, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForReplaceOnOpt() {
		testWritableForReplace(IConstraints.OPTION, 123, 0, 1);
	}

	@Test
	public void testWritableForReplaceOnOne() {
		testWritableForReplace(IConstraints.ONE, 123, 0, 1);
	}

	@Test
	public void testWritableForReplaceDuplicateOnSeq() {
		testWritableForReplace(IConstraints.SEQUENCE, 3, 3, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForReplaceDuplicateOnBag() {
		testWritableForReplace(IConstraints.BAG, 3, 3, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForReplaceDuplicateOnSet() {
		thrown.expect(AssertionError.class);
		testWritableForReplace(IConstraints.SET, 3, 3, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForReplaceOnDuplicateOSet() {
		thrown.expect(AssertionError.class);
		testWritableForReplace(IConstraints.ORDERED_SET, 3, 3, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForReplaceDuplicateOnOpt() {
		testWritableForReplace(IConstraints.OPTION, 1, 0, 1);
	}

	@Test
	public void testWritableForReplaceDuplicateOnOne() {
		testWritableForReplace(IConstraints.ONE, 1, 0, 1);
	}

	public void testWritableForReplace(IConstraints inputType, Integer element, int index, Integer... elements) {
		IBox<Integer> box = factory.createBox(inputType, elements);
		box.set(index, element);
		List<Integer> expected = createJavaList(elements);
		expected.set(index, element);
		assertEquals(expected, box);
	}

	@Test
	public void testReplacingNullValue() {
		IBox<Object> box = factory.createSequence(null, new Object());
		box.set(0, new Object());
	}

	// Replace out of bounds

	@Test
	public void testWritableForReplaceOutOfUpperOnSeq() {
		testWritableForTryReplace(IConstraints.SEQUENCE, 8, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForReplaceOutOfUpperOnBag() {
		testWritableForTryReplace(IConstraints.BAG, 10, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForReplaceOutOfUpperOnSet() {
		testWritableForTryReplace(IConstraints.SET, 5, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForReplaceOutOfUpperOnOSet() {
		testWritableForTryReplace(IConstraints.ORDERED_SET, 6, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForReplaceOutOfUpperOnOpt() {
		testWritableForTryReplace(IConstraints.OPTION, 1, 1);
	}

	@Test
	public void testWritableForReplaceOutOfUpperOnOne() {
		testWritableForTryReplace(IConstraints.ONE, 1, 1);
	}

	@Test
	public void testWritableForReplaceOutOfLowerOnSeq() {
		testWritableForTryReplace(IConstraints.SEQUENCE, -1, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForReplaceOutOfLowerOnBag() {
		testWritableForTryReplace(IConstraints.BAG, -1, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForReplaceOutOfLowerOnSet() {
		testWritableForTryReplace(IConstraints.SET, -1, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForReplaceOutOfLowerOnOSet() {
		testWritableForTryReplace(IConstraints.ORDERED_SET, -1, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForReplaceOutOfLowerOnOpt() {
		testWritableForTryReplace(IConstraints.OPTION, -1, 1);
	}

	@Test
	public void testWritableForReplaceOutOfLowerOnOne() {
		testWritableForTryReplace(IConstraints.ONE, -1, 1);
	}

	public void testWritableForTryReplace(IConstraints inputType, int index, Integer... elements) {
		thrown.expect(AssertionError.class);
		IBox<Integer> box = factory.createBox(inputType, elements);
		box.set(index, null);
	}

	// Move

	@Test
	public void testWritableForMoveOnSeq() {
		testWritableForMove(IConstraints.SEQUENCE, 2, 5, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForMoveOnBag() {
		testWritableForMove(IConstraints.BAG, 5, 1, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForMoveOnSet() {
		testWritableForMove(IConstraints.SET, 0, 3, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForMoveOnOSet() {
		testWritableForMove(IConstraints.ORDERED_SET, 3, 0, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForMoveOnOpt() {
		testWritableForMove(IConstraints.OPTION, 0, 0, 1);
	}

	@Test
	public void testWritableForMoveOnOne() {
		testWritableForMove(IConstraints.ONE, 0, 0, 1);
	}

	public void testWritableForMove(IConstraints inputType, int newIndex, int oldIndex, Integer... elements) {
		IBox<Integer> box = factory.createBox(inputType, elements);
		box.move(newIndex, oldIndex);
		List<Integer> expected = createJavaList(elements);
		Integer element = expected.remove(oldIndex);
		expected.add(newIndex, element);
		assertEquals(expected, box);
	}

	// Replace out of bounds

	@Test
	public void testWritableForMoveOutOfUpperOnSeq() {
		testWritableForTryMove(IConstraints.SEQUENCE, 0, 8, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForMoveOutOfUpperOnBag() {
		testWritableForTryMove(IConstraints.BAG, 10, 8, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForMoveOutOfUpperOnSet() {
		testWritableForTryMove(IConstraints.SET, 5, 3, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForMoveOutOfUpperOnOSet() {
		testWritableForTryMove(IConstraints.ORDERED_SET, 6, 5, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForMoveOutOfUpperOnOpt() {
		testWritableForTryMove(IConstraints.OPTION, 1, 1);
	}

	@Test
	public void testWritableForMoveOutOfUpperOnOne() {
		testWritableForTryMove(IConstraints.ONE, 1, 1);
	}

	@Test
	public void testWritableForMoveOutOfLowerOnSeq() {
		testWritableForTryMove(IConstraints.SEQUENCE, -1, 3, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForMoveOutOfLowerOnBag() {
		testWritableForTryMove(IConstraints.BAG, -1, 5, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForMoveOutOfLowerOnSet() {
		testWritableForTryMove(IConstraints.SET, 2, -1, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForMoveOutOfLowerOnOSet() {
		testWritableForTryMove(IConstraints.ORDERED_SET, 3, -1, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForMoveOutOfLowerOnOpt() {
		testWritableForTryMove(IConstraints.OPTION, 0, -1, 1);
	}

	@Test
	public void testWritableForMoveOutOfLowerOnOne() {
		testWritableForTryMove(IConstraints.ONE, -1, 0, 1);
	}

	public void testWritableForTryMove(IConstraints inputType, int newIndex, int oldIndex, Integer... elements) {
		thrown.expect(AssertionError.class);
		IBox<Integer> box = factory.createBox(inputType, elements);
		box.move(newIndex, oldIndex);
	}


	// Clear

	@Test
	public void testWritableForClearOnSeq() {
		testWritableForClear(IConstraints.SEQUENCE, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForClearOnBag() {
		testWritableForClear(IConstraints.BAG, 1, 1, 2, 2, 3, 3, 3, 4);
	}

	@Test
	public void testWritableForClearOnSet() {
		testWritableForClear(IConstraints.SET, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForClearOnOSet() {
		testWritableForClear(IConstraints.ORDERED_SET, 1, 2, 3, 4);
	}

	@Test
	public void testWritableForClearOnOpt() {
		testWritableForClear(IConstraints.OPTION, 1);
	}

	@Test
	public void testWritableForClearOnOne() {
		testWritableForClear(IConstraints.ONE, 0, 1);
	}

	public void testWritableForClear(IConstraints inputType, Integer... elements) {
		IBox<Integer> box = factory.createBox(inputType, elements);
		box.clear();
		assertEquals(box.isOptional() ? 0 : 1, box.length());
	}

}
