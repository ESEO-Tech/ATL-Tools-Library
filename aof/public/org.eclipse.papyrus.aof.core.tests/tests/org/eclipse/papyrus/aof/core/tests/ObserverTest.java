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
import org.eclipse.papyrus.aof.core.IObserver;
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class ObserverTest extends BaseTest {

	// Add/remove observers

	private static class TraceObserver extends DefaultObserver<Integer> {

		private List<Object> trace = new ArrayList<Object>();

		public List<Object> getTrace() {
			return trace;
		}

		public void added(int index, Integer element) {
			trace.add("add");
			trace.add(index);
			trace.add(element);
		}

		public void removed(int index, Integer element) {
			trace.add("rem");
			trace.add(index);
			trace.add(element);
		}

		public void replaced(int index, Integer newElement, Integer oldElement) {
			trace.add("rep");
			trace.add(index);
			trace.add(oldElement);
			trace.add(newElement);
		}

		public void moved(int newIndex, int oldIndex, Integer element) {
			trace.add("mov");
			trace.add(newIndex);
			trace.add(oldIndex);
			trace.add(element);
		}
	}

	@Test
	public void testObserverAddRemoveOnSeq() {
		testObserverAddRemove(IConstraints.SEQUENCE);
	}

	@Test
	public void testObserverAddRemoveOnBag() {
		testObserverAddRemove(IConstraints.BAG);
	}

	@Test
	public void testObserverAddRemoveOnSet() {
		testObserverAddRemove(IConstraints.SET);
	}

	@Test
	public void testObserverAddRemoveOnOSet() {
		testObserverAddRemove(IConstraints.ORDERED_SET);
	}

	@Test
	public void testObserverAddRemoveOnOpt() {
		testObserverAddRemove(IConstraints.OPTION);
	}

	@Test
	public void testObserverAddRemoveOnOneDefaultDefault() {
		testObserverAddRemove(IConstraints.ONE);
	}

	public void testObserverAddRemove(IConstraints inputType) {
		IBox<Integer> box = factory.createBox(inputType);
		IObserver<Integer> observer = new TraceObserver();
		// addition test
		box.addObserver(observer);
		int count = 0;
		for (IObserver<Integer> o : box.getObservers()) {
			count++;
			assertEquals(observer, o);
		}
		assertEquals(1, count);
		// removal test
		box.removeObserver(observer);
		count = 0;
		for (IObserver<Integer> o : box.getObservers()) {
			count++;
		}
		assertEquals(0, count);
	}

	@Test
	public void testObserverRemoveNotAddedObserver() {
		thrown.expect(AssertionError.class);
		IBox<Integer> box = factory.createSet();
		IObserver<Integer> observer = new TraceObserver();
		box.removeObserver(observer);
	}

	@Test
	public void testObserverAddAddedObserver() {
		thrown.expect(AssertionError.class);
		IBox<Integer> box = factory.createSet();
		IObserver<Integer> observer = new TraceObserver();
		box.addObserver(observer);
		box.addObserver(observer);
	}


	// Addition observation

	@Test
	public void testObserverForAddedMutationOnSeq() {
		testObserverForAddedMutation(IConstraints.SEQUENCE, "add", 0, 1, "add", 0, 2, "add", 2, 3, "add", 1, 4);
	}

	@Test
	public void testObserverForAddedMutationOnBag() {
		testObserverForAddedMutation(IConstraints.BAG, "add", 0, 1, "add", 0, 2, "add", 2, 3, "add", 1, 4);
	}

	@Test
	public void testObserverForAddedMutationOnSet() {
		testObserverForAddedMutation(IConstraints.SET, "add", 0, 1, "add", 0, 2, "add", 2, 3, "add", 1, 4);
	}

	@Test
	public void testObserverForAddedMutationOnOSet() {
		testObserverForAddedMutation(IConstraints.ORDERED_SET, "add", 0, 1, "add", 0, 2, "add", 2, 3, "add", 1, 4);
	}

	@Test
	public void testObserverForAddedMutationOnOpt() {
		testObserverForAddedMutation(IConstraints.OPTION, "add", 0, 1, "rep", 0, 1, 2);
	}

	@Test
	public void testObserverForAddedMutationOnOne() {
		testObserverForAddedMutation(IConstraints.ONE, "rep", 0, null, 1, "rep", 0, 1, 2);
	}

	public void testObserverForAddedMutation(IConstraints inputType, Object... expectedTrace) {
		IBox<Integer> box = factory.createBox(inputType);
		TraceObserver observer = new TraceObserver();
		box.addObserver(observer);
		box.add(1); // "add", 0, 1
		box.add(0, 2); // "add", 0, 2
		if (!box.isSingleton()) {
			box.add(3); // "add", 2, 3
			box.add(1, 4); // "add", 1, 4
		}
		assertEquals(Arrays.asList(expectedTrace), observer.getTrace());
	}

	// Removal observation

	@Test
	public void testObserverForRemovedMutationOnSeq() {
		testObserverForRemovedMutation(IConstraints.SEQUENCE, "rem", 0, 1, "rem", 3, 5, "rem", 1, 3);
	}

	@Test
	public void testObserverForRemovedMutationOnBag() {
		testObserverForRemovedMutation(IConstraints.BAG, "rem", 0, 1, "rem", 3, 5, "rem", 1, 3);
	}

	@Test
	public void testObserverForRemovedMutationOnSet() {
		testObserverForRemovedMutation(IConstraints.SET, "rem", 0, 1, "rem", 3, 5, "rem", 1, 3);
	}

	@Test
	public void testObserverForRemovedMutationOnOSet() {
		testObserverForRemovedMutation(IConstraints.ORDERED_SET, "rem", 0, 1, "rem", 3, 5, "rem", 1, 3);
	}

	@Test
	public void testObserverForRemovedMutationOnOpt() {
		testObserverForRemovedMutation(IConstraints.OPTION, "rem", 0, 5);
	}

	@Test
	public void testObserverForRemovedMutationOnOne() {
		testObserverForRemovedMutation(IConstraints.ONE, "rep", 0, 5, 1);
	}

	public void testObserverForRemovedMutation(IConstraints inputType, Object... expectedTrace) {
		IBox<Integer> box = factory.createBox(inputType, 1, 2, 3, 4, 5);
		TraceObserver observer = new TraceObserver();
		box.addObserver(observer);
		box.removeAt(0); // "rem", 0, 1
		if (!box.isSingleton()) {
			box.removeAt(3); // "rem", 3, 5
			box.remove(3); // "rem", 1, 3
		}
		assertEquals(Arrays.asList(expectedTrace), observer.getTrace());
	}

	// Replacement observation

	@Test
	public void testObserverForReplacedMutationOnSeq() {
		testObserverForReplacedMutation(IConstraints.SEQUENCE, "rep", 0, 1, 6, "rep", 0, 6, 6, "rep", 4, 5, 7, "rep", 2, 3, 3);
	}

	@Test
	public void testObserverForReplacedMutationOnBag() {
		testObserverForReplacedMutation(IConstraints.BAG, "rep", 0, 1, 6, "rep", 0, 6, 6, "rep", 4, 5, 7, "rep", 2, 3, 3);
	}

	@Test
	public void testObserverForReplacedMutationOnSet() {
		testObserverForReplacedMutation(IConstraints.SET, "rep", 0, 1, 6, "rep", 0, 6, 6, "rep", 4, 5, 7, "rep", 2, 3, 3);
	}

	@Test
	public void testObserverForReplacedMutationOnOSet() {
		testObserverForReplacedMutation(IConstraints.ORDERED_SET, "rep", 0, 1, 6, "rep", 0, 6, 6, "rep", 4, 5, 7, "rep", 2, 3, 3);
	}

	@Test
	public void testObserverForReplacedMutationOnOpt() {
		testObserverForReplacedMutation(IConstraints.OPTION, "rep", 0, 5, 6, "rep", 0, 6, 6);
	}

	@Test
	public void testObserverForReplacedMutationOnOne() {
		testObserverForReplacedMutation(IConstraints.ONE, "rep", 0, 5, 6, "rep", 0, 6, 6);
	}

	public void testObserverForReplacedMutation(IConstraints inputType, Object... expectedTrace) {
		IBox<Integer> box = factory.createBox(inputType, 1, 2, 3, 4, 5);
		TraceObserver observer = new TraceObserver();
		box.addObserver(observer);
		box.set(0, 6); // "rep", 0, 1/5, 6
		box.set(0, 6); // "rep", 0, 1/5, 6
		if (!box.isSingleton()) {
			box.set(4, 7); // "rep", 4, 5, 7
			box.set(2, 3); // "rep", 2, 3,3
		}
		assertEquals(Arrays.asList(expectedTrace), observer.getTrace());
	}

	// Move observation

	@Test
	public void testObserverForMovedMutationOnSeq() {
		testObserverForMovedMutation(IConstraints.SEQUENCE, "mov", 0, 0, 1, "mov", 0, 0, 1, "mov", 0, 5, 6, "mov", 3, 3, 3, "mov", 6, 2, 2);
	}

	@Test
	public void testObserverForMovedMutationOnBag() {
		testObserverForMovedMutation(IConstraints.BAG, "mov", 0, 0, 1, "mov", 0, 0, 1, "mov", 0, 5, 6, "mov", 3, 3, 3, "mov", 6, 2, 2);
	}

	@Test
	public void testObserverForMovedMutationOnSet() {
		testObserverForMovedMutation(IConstraints.SET, "mov", 0, 0, 1, "mov", 0, 0, 1, "mov", 0, 5, 6, "mov", 3, 3, 3, "mov", 6, 2, 2);
	}

	@Test
	public void testObserverForMovedMutationOnOSet() {
		testObserverForMovedMutation(IConstraints.ORDERED_SET, "mov", 0, 0, 1, "mov", 0, 0, 1, "mov", 0, 5, 6, "mov", 3, 3, 3, "mov", 6, 2, 2);
	}

	@Test
	public void testObserverForMovedMutationOnOpt() {
		testObserverForMovedMutation(IConstraints.OPTION, "mov", 0, 0, 7, "mov", 0, 0, 7);
	}

	@Test
	public void testObserverForMovedMutationOnOne() {
		testObserverForMovedMutation(IConstraints.ONE, "mov", 0, 0, 7, "mov", 0, 0, 7);
	}

	public void testObserverForMovedMutation(IConstraints inputType, Object... expectedTrace) {
		IBox<Integer> box = factory.createBox(inputType, 1, 2, 3, 4, 5, 6, 7);
		TraceObserver observer = new TraceObserver();
		box.addObserver(observer);
		box.move(0, 0); // "mov", 0, 0, 1/7
		box.move(0, 0); // "mov", 0, 0, 1/7
		if (!box.isSingleton()) {
			box.move(0, 5); // "mov", 0, 5, 6
			box.move(3, 3); // "mov", 3, 3, 3
			box.move(6, 2); // "mov", 6, 2, 2
		}
		assertEquals(Arrays.asList(expectedTrace), observer.getTrace());
	}

}
