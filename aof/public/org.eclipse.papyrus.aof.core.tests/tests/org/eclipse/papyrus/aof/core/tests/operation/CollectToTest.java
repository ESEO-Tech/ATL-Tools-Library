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

import static org.junit.Assert.assertSame;

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.eclipse.papyrus.aof.core.tests.BaseTest;
import org.junit.Before;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
// this test depends on the success of CollectTest (uses IBox.collect)
public class CollectToTest extends BaseTest {

	private static class Named {

		private String name;

		public Named(String name) {
			this.name = name;
		}

		public String getName() {
			return name;
		}

		@Override
		public String toString() {
			return getClass().getSimpleName() + " " + name;
		}

	}

	private static class Source extends Named {
		public Source(String name) {
			super(name);
		}

	}

	private static class Target extends Named {
		public Target(String name) {
			super(name);
		}

	}

	private Source[] createSources(String... sourceNames) {
		Source[] sources = new Source[sourceNames.length];
		for (int i = 0; i < sources.length; i++) {
			sources[i] = new Source(sourceNames[i]);
		}
		return sources;
	}

	private Target[] createTargets(String... targetNames) {
		Target[] targets = new Target[targetNames.length];
		for (int i = 0; i < targets.length; i++) {
			targets[i] = new Target(targetNames[i]);
		}
		return targets;
	}

	private IUnaryFunction<Source, Target> sourceToTarget = new IUnaryFunction<Source, Target>() {
		@Override
		public Target apply(Source s) {
			return new Target(s.getName());
		}
	};

	private IUnaryFunction<Target, Source> targetToSource = new IUnaryFunction<Target, Source>() {
		@Override
		public Source apply(Target t) {
			return new Source(t.getName());
		}
	};

	private IUnaryFunction<Named, String> name = new IUnaryFunction<Named, String>() {
		@Override
		public String apply(Named n) {
			return n.getName();
		}
	};

	private Source[] s;
	private Target[] t;

	@Before
	@Override
	public void setUp() {
		super.setUp();
		s = createSources("A", "B", "C", "D", "E", "F", "G", "H");
		t = createTargets("X", "Y", "Z");
	}

	// Create

	@Test
	public void testCreateForCollectToOnSequence() {
		testCreateForCollectTo(IConstraints.SEQUENCE, IConstraints.SEQUENCE, 1, 3, 2, 4);
	}

	@Test
	public void testCreateForCollectToOnBag() {
		testCreateForCollectTo(IConstraints.BAG, IConstraints.BAG, 1, 3, 2, 4);
	}

	@Test
	public void testCreateForCollectToOnOrderedSet() {
		testCreateForCollectTo(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testCreateForCollectToOnSet() {
		testCreateForCollectTo(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testCreateForCollectToOnOption() {
		testCreateForCollectTo(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testCreateForCollectToOnOne() {
		testCreateForCollectTo(IConstraints.ONE, IConstraints.ONE);
	}

	public void testCreateForCollectTo(IConstraints inputType, IConstraints expectedType, Integer... sameRefsIndices) {
		IBox<Source> a = factory.createBox(inputType, s[0], s[1], s[2], s[1], s[2], s[3]);
		IBox<Target> b = a.collectTo(sourceToTarget);
		assertEquals(expectedType, b.getConstraints());
		assertEquals(a.collect(name), b.collect(name));
		for (int i = 0; i < sameRefsIndices.length; i += 2) {
			Target t1 = b.get(sameRefsIndices[i]);
			Target t2 = b.get(sameRefsIndices[i + 1]);
			assertSame("At index " + i + ", ", t1, t2);
		}
	}

	// Add

	@Test
	public void testAddForCollectToOnSequence() {
		testAddForCollectTo(IConstraints.SEQUENCE, 1, 4, 1, 6, 2, 5, 3, 7);
	}

	@Test
	public void testAddForCollectToOnBag() {
		testAddForCollectTo(IConstraints.BAG, 1, 4, 1, 6, 2, 5, 3, 7);
	}

	@Test
	public void testAddForCollectToOnOrderedSet() {
		testAddForCollectTo(IConstraints.ORDERED_SET);
	}

	@Test
	public void testAddForCollectToOnSet() {
		testAddForCollectTo(IConstraints.SET);
	}

	@Test
	public void testAddForCollectToOnOption() {
		testAddForCollectTo(IConstraints.OPTION);
	}

	@Test
	public void testAddForCollectToOnOne() {
		testAddForCollectTo(IConstraints.ONE);
	}

	public void testAddForCollectTo(IConstraints inputType, Integer... sameRefsIndices) {
		IBox<Source> a = factory.createBox(inputType, s[0], s[1], s[2], s[1], s[2], s[3]);
		IBox<Target> b = a.collectTo(sourceToTarget);
		if (a.isSingleton()) {
			a.add(0, s[4]);
		}
		else {
			a.add(s[4]); // s[0], s[1], s[2], s[1], s[2], s[3], s[4]
			if (!a.isUnique()) {
				a.add(1, s[2]); // s[0], s[2], s[1], s[2], s[1], s[2], s[3], s[4]
				a.add(3, s[3]); // s[0], s[2], s[1], s[3], s[2], s[1], s[2], s[3], s[4]
			}
		}
		assertEquals(a.collectTo(sourceToTarget).collect(name), b.collect(name));
		for (int i = 0; i < sameRefsIndices.length; i += 2) {
			Target t1 = b.get(sameRefsIndices[i]);
			Target t2 = b.get(sameRefsIndices[i + 1]);
			assertSame("At index " + i + ", ", t1, t2);
		}
	}

	// Remove

	@Test
	public void testRemoveForCollectToOnSequence() {
		testRemoveForCollectTo(IConstraints.SEQUENCE, 0, 1);
	}

	@Test
	public void testRemoveForCollectToOnBag() {
		testRemoveForCollectTo(IConstraints.BAG, 0, 1);
	}

	@Test
	public void testRemoveForCollectToOnOrderedSet() {
		testRemoveForCollectTo(IConstraints.ORDERED_SET);
	}

	@Test
	public void testRemoveForCollectToOnSet() {
		testRemoveForCollectTo(IConstraints.SET);
	}

	@Test
	public void testRemoveForCollectToOnOption() {
		testRemoveForCollectTo(IConstraints.OPTION);
	}

	@Test
	public void testRemoveForCollectToOnOne() {
		testRemoveForCollectTo(IConstraints.ONE);
	}

	public void testRemoveForCollectTo(IConstraints inputType, Integer... sameRefsIndices) {
		IBox<Source> a = factory.createBox(inputType, s[0], s[1], s[2], s[1], s[2], s[3]);
		IBox<Target> b = a.collectTo(sourceToTarget);
		if (!a.isSingleton()) {
			a.removeAt(2);
		}
		a.removeAt(0); // s[1], s[1], s[2], s[3]
		assertEquals(a.collectTo(sourceToTarget).collect(name), b.collect(name));
		for (int i = 0; i < sameRefsIndices.length; i += 2) {
			Target t1 = b.get(sameRefsIndices[i]);
			Target t2 = b.get(sameRefsIndices[i + 1]);
			assertSame("At index " + i + ", ", t1, t2);
		}
	}

	// Replace

	@Test
	public void testReplaceForCollectToOnSequence() {
		testReplaceForCollectTo(IConstraints.SEQUENCE, 1, 5, 2, 3, 3, 4);
	}

	@Test
	public void testReplaceForCollectToOnBag() {
		testReplaceForCollectTo(IConstraints.BAG, 1, 5, 2, 3, 3, 4);
	}

	@Test
	public void testReplaceForCollectToOnOrderedSet() {
		testReplaceForCollectTo(IConstraints.ORDERED_SET);
	}

	@Test
	public void testReplaceForCollectToOnSet() {
		testReplaceForCollectTo(IConstraints.SET);
	}

	@Test
	public void testReplaceForCollectToOnOption() {
		testReplaceForCollectTo(IConstraints.OPTION);
	}

	@Test
	public void testReplaceForCollectToOnOne() {
		testReplaceForCollectTo(IConstraints.ONE);
	}

	public void testReplaceForCollectTo(IConstraints inputType, Integer... sameRefsIndices) {
		IBox<Source> a = factory.createBox(inputType, s[0], s[1], s[2], s[1], s[2], s[3], s[4]);
		IBox<Target> b = a.collectTo(sourceToTarget);
		if (a.isSingleton()) {
			a.set(0, s[2]);
		}
		else {
			a.set(1, s[5]); // s[5], s[1], s[2], s[1], s[2], s[3], s[4]
			if (!a.isUnique()) {
				a.set(1, s[3]); // s[5], s[3], s[2], s[1], s[2], s[3], s[4]
				a.set(3, s[2]); // s[5], s[3], s[2], s[2], s[2], s[3], s[4]
			}
		}
		assertEquals(a.collectTo(sourceToTarget).collect(name), b.collect(name));
		for (int i = 0; i < sameRefsIndices.length; i += 2) {
			Target t1 = b.get(sameRefsIndices[i]);
			Target t2 = b.get(sameRefsIndices[i + 1]);
			assertSame("At index " + i + ", ", t1, t2);
		}
	}

	// Move

	@Test
	public void testMoveForCollectToOnSequence() {
		testMoveForCollectTo(IConstraints.SEQUENCE, 0, 3, 2, 4);
	}

	@Test
	public void testMoveForCollectToOnBag() {
		testMoveForCollectTo(IConstraints.BAG, 0, 3, 2, 4);
	}

	@Test
	public void testMoveForCollectToOnOrderedSet() {
		testMoveForCollectTo(IConstraints.ORDERED_SET);
	}

	@Test
	public void testMoveForCollectToOnSet() {
		testMoveForCollectTo(IConstraints.SET);
	}

	@Test
	public void testMoveForCollectToOnOption() {
		testMoveForCollectTo(IConstraints.OPTION);
	}

	@Test
	public void testMoveForCollectToOnOne() {
		testMoveForCollectTo(IConstraints.ONE);
	}

	public void testMoveForCollectTo(IConstraints inputType, Integer... sameRefsIndices) {
		IBox<Source> a = factory.createBox(inputType, s[0], s[1], s[2], s[1], s[2], s[3], s[4], s[5], s[6]);
		IBox<Target> b = a.collectTo(sourceToTarget);
		if (a.isSingleton()) {
			a.move(0, 0);
		}
		else {
			a.move(0, 2); // s[2], s[0], s[1], s[1], s[2], s[3]
			a.move(4, 3); // s[2], s[0], s[1], s[2], s[1], s[3]
		}
		assertEquals(a.collectTo(sourceToTarget).collect(name), b.collect(name));
		for (int i = 0; i < sameRefsIndices.length; i += 2) {
			Target t1 = b.get(sameRefsIndices[i]);
			Target t2 = b.get(sameRefsIndices[i + 1]);
			assertSame("At index " + i + ", ", t1, t2);
		}
	}

	// Clear

	@Test
	public void testClearForCollectToOnSequence() {
		testClearForCollectTo(IConstraints.SEQUENCE);
	}

	@Test
	public void testClearForCollectToOnBag() {
		testClearForCollectTo(IConstraints.BAG);
	}

	@Test
	public void testClearForCollectToOnOrderedSet() {
		testClearForCollectTo(IConstraints.ORDERED_SET);
	}

	@Test
	public void testClearForCollectToOnSet() {
		testClearForCollectTo(IConstraints.SET);
	}

	@Test
	public void testClearForCollectToOnOption() {
		testClearForCollectTo(IConstraints.OPTION);
	}

	@Test
	public void testClearForCollectToOnOne() {
		testClearForCollectTo(IConstraints.ONE);
	}

	public void testClearForCollectTo(IConstraints inputType) {
		IBox<Source> a = factory.createBox(inputType, s[0], s[1], s[2], s[1], s[2], s[3]);
		IBox<Target> b = a.collectTo(sourceToTarget);
		a.clear();
		assertEquals(a.collectTo(sourceToTarget).collect(name), b.collect(name));
	}

	// Add bidir

	@Test
	public void testAddForBidirApplyOnSequence() {
		testAddForBidirApply(IConstraints.SEQUENCE, 0, 2, 1, 9, 9, 10, 4, 6, 5, 7);
	}

	@Test
	public void testAddForBidirApplyOnBag() {
		testAddForBidirApply(IConstraints.BAG, 0, 2, 1, 9, 9, 10, 4, 6, 5, 7);
	}

	@Test
	public void testAddForBidirApplyOnOrderedSet() {
		testAddForBidirApply(IConstraints.ORDERED_SET);
	}

	@Test
	public void testAddForBidirApplyOnSet() {
		testAddForBidirApply(IConstraints.SET);
	}

	@Test
	public void testAddForBidirApplyOnOption() {
		testAddForBidirApply(IConstraints.OPTION);
	}

	@Test
	public void testAddForBidirApplyOnOne() {
		testAddForBidirApply(IConstraints.ONE);
	}

	public void testAddForBidirApply(IConstraints inputType, Integer... sameRefsIndices) {
		IBox<Source> a = factory.createBox(inputType, s[0], s[1], s[2], s[1], s[2], s[3]);
		IBox<Target> b = a.collectTo(sourceToTarget, targetToSource);
		if (b.isSingleton()) {
			b.add(0, t[0]);
		}
		else {
			b.add(t[0]); // s'[0], s'[1], s'[2], s'[1], s'[2], s'[3], t[0]
			b.add(0, t[1]); // t[1], s'[0], s'[1], s'[2], s'[1], s'[2], s'[3], t[0]
			if (!b.isUnique()) {
				b.add(1, t[0]); // t[1], t[0], s'[0], s'[1], s'[2], s'[1], s'[2], s'[3], t[0]
				b.add(2, t[1]); // t[1], t[0], t[1], s'[0], s'[1], s'[2], s'[1], s'[2], s'[3], t[0]
				b.add(t[0]); // t[1], t[0], t[1], s'[0], s'[1], s'[2], s'[1], s'[2], s'[3], t[0], t[0]
			}
		}
		assertEquals(b.collect(name), a.collectTo(sourceToTarget).collect(name));
		for (int i = 0; i < sameRefsIndices.length; i += 2) {
			Source s1 = a.get(sameRefsIndices[i]);
			Source s2 = a.get(sameRefsIndices[i + 1]);
			assertSame("At index " + i + ", ", s1, s2);
		}
	}

	// Remove bidir

	@Test
	public void testRemoveForBidirApplyOnSequence() {
		testRemoveForBidirApply(IConstraints.SEQUENCE, 1, 2);
	}

	@Test
	public void testRemoveForBidirApplyOnBag() {
		testRemoveForBidirApply(IConstraints.BAG, 1, 2);
	}

	@Test
	public void testRemoveForBidirApplyOnOrderedSet() {
		testRemoveForBidirApply(IConstraints.ORDERED_SET);
	}

	@Test
	public void testRemoveForBidirApplyOnSet() {
		testRemoveForBidirApply(IConstraints.SET);
	}

	@Test
	public void testRemoveForBidirApplyOnOption() {
		testRemoveForBidirApply(IConstraints.OPTION);
	}

	@Test
	public void testRemoveForBidirApplyOnOne() {
		testRemoveForBidirApply(IConstraints.ONE);
	}

	public void testRemoveForBidirApply(IConstraints inputType, Integer... sameRefsIndices) {
		IBox<Source> a = factory.createBox(inputType, s[0], s[1], s[2], s[1], s[2], s[3]);
		IBox<Target> b = a.collectTo(sourceToTarget, targetToSource);
		b.removeAt(0); // s'[1], s'[2], s'[1], s'[2], s'[3] // s'[1], s'[2], s'[3]
		if (!b.isSingleton()) {
			b.removeAt(2); // s'[1], s'[2], s'[2], s'[3] // s'[1], s'[2]
		}
		assertEquals(b.collect(name), a.collectTo(sourceToTarget).collect(name));
		for (int i = 0; i < sameRefsIndices.length; i += 2) {
			Source s1 = a.get(sameRefsIndices[i]);
			Source s2 = a.get(sameRefsIndices[i + 1]);
			assertSame("At index " + i + ", ", s1, s2);
		}
	}

	// Replace bidir

	@Test
	public void testReplaceForBidirApplyOnSequence() {
		testReplaceForBidirApply(IConstraints.SEQUENCE, 2, 3);
	}

	@Test
	public void testReplaceForBidirApplyOnBag() {
		testReplaceForBidirApply(IConstraints.BAG, 2, 3);
	}

	@Test
	public void testReplaceForBidirApplyOnOrderedSet() {
		testReplaceForBidirApply(IConstraints.ORDERED_SET);
	}

	@Test
	public void testReplaceForBidirApplyOnSet() {
		testReplaceForBidirApply(IConstraints.SET);
	}

	@Test
	public void testReplaceForBidirApplyOnOption() {
		testReplaceForBidirApply(IConstraints.OPTION);
	}

	@Test
	public void testReplaceForBidirApplyOnOne() {
		testReplaceForBidirApply(IConstraints.ONE);
	}

	public void testReplaceForBidirApply(IConstraints inputType, Integer... sameRefsIndices) {
		IBox<Source> a = factory.createBox(inputType, s[0], s[1], s[2], s[1], s[2], s[3]);
		IBox<Target> b = a.collectTo(sourceToTarget, targetToSource);
		b.set(0, t[0]); // t[0], s'[1], s'[2], s'[1], s'[2], s'[3] // t[0], s'[1], s'[2], s'[3]
		if (!b.isSingleton()) {
			b.set(2, t[1]); // t[0], s'[1], t[1], s'[1], s'[2], s'[3] // t[0], s'[1], t[1], s'[3]
			if (!b.isUnique()) {
				b.set(3, t[1]); // t[0], s'[1], t[1], t[1], s'[2], s'[3]
			}
		}
		assertEquals(b.collect(name), a.collectTo(sourceToTarget).collect(name));
		for (int i = 0; i < sameRefsIndices.length; i += 2) {
			Source s1 = a.get(sameRefsIndices[i]);
			Source s2 = a.get(sameRefsIndices[i + 1]);
			assertSame("At index " + i + ", ", s1, s2);
		}
	}

	// Move bidir

	@Test
	public void testMoveForBidirApplyOnSequence() {
		testMoveForBidirApply(IConstraints.SEQUENCE, 0, 4, 1, 2);
	}

	@Test
	public void testMoveForBidirApplyOnBag() {
		testMoveForBidirApply(IConstraints.BAG, 0, 4, 1, 2);
	}

	@Test
	public void testMoveForBidirApplyOnOrderedSet() {
		testMoveForBidirApply(IConstraints.ORDERED_SET);
	}

	@Test
	public void testMoveForBidirApplyOnSet() {
		testMoveForBidirApply(IConstraints.SET);
	}

	@Test
	public void testMoveForBidirApplyOnOption() {
		testMoveForBidirApply(IConstraints.OPTION);
	}

	@Test
	public void testMoveForBidirApplyOnOne() {
		testMoveForBidirApply(IConstraints.ONE);
	}

	public void testMoveForBidirApply(IConstraints inputType, Integer... sameRefsIndices) {
		IBox<Source> a = factory.createBox(inputType, s[0], s[1], s[2], s[1], s[2], s[3]);
		IBox<Target> b = a.collectTo(sourceToTarget, targetToSource);
		b.move(0, 0); // s'[0], s'[1], s'[2], s'[1], s'[2], s'[3] // s'[0], s'[1], s'[2], s'[3]
		if (!b.isSingleton()) {
			b.move(0, 2); // s'[2], s'[0], s'[1], s'[1], s'[2], s'[3] // s'[2], s'[0], s'[1], s'[3]
			b.move(3, 1); // s'[2], s'[1], s'[1], s'[0], s'[2], s'[3] // s'[2], s'[1], s'[3], s'[0]
		}
		assertEquals(b.collect(name), a.collectTo(sourceToTarget).collect(name));
		for (int i = 0; i < sameRefsIndices.length; i += 2) {
			Source s1 = a.get(sameRefsIndices[i]);
			Source s2 = a.get(sameRefsIndices[i + 1]);
			assertSame("At index " + i + ", ", s1, s2);
		}
	}

	// Clear bidir

	@Test
	public void testClearForBidirApplyOnSequence() {
		testClearForBidirApply(IConstraints.SEQUENCE, 0, 4, 1, 2);
	}

	@Test
	public void testClearForBidirApplyOnBag() {
		testClearForBidirApply(IConstraints.BAG, 0, 4, 1, 2);
	}

	@Test
	public void testClearForBidirApplyOnOrderedSet() {
		testClearForBidirApply(IConstraints.ORDERED_SET);
	}

	@Test
	public void testClearForBidirApplyOnSet() {
		testClearForBidirApply(IConstraints.SET);
	}

	@Test
	public void testClearForBidirApplyOnOption() {
		testClearForBidirApply(IConstraints.OPTION);
	}

	@Test
	public void testClearForBidirApplyOnOne() {
		testClearForBidirApply(IConstraints.ONE);
	}

	public void testClearForBidirApply(IConstraints inputType, Integer... sameRefsIndices) {
		IBox<Source> a = factory.createBox(inputType, s[0], s[1], s[2], s[1], s[2], s[3]);
		IBox<Target> b = a.collectTo(sourceToTarget, targetToSource);
		b.clear();
		assertEquals(b.collect(name), a.collectTo(sourceToTarget).collect(name));
	}

}
