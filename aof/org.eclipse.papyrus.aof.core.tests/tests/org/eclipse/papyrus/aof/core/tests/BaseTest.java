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

import static org.eclipse.papyrus.aof.core.impl.utils.Equality.optionalEquals;

import java.util.Iterator;

import org.eclipse.papyrus.aof.core.AOFFactory;
import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IFactory;
import org.junit.Before;
import org.junit.Rule;
import org.junit.rules.ExpectedException;


public abstract class BaseTest {

	protected static IFactory factory;

	protected IFactory createFactory() {
		return new AOFFactory();
	}

	@Before
	public void setUp() {
		// reset the factory for each test so that the caches are reseted
		// (e.g. meta-class/platform-class map reseted)
		factory = createFactory();
	}


	@Rule
	public ExpectedException thrown = ExpectedException.none();

	private <E> boolean iterableEquals(Iterable<E> firstIterable, Iterable<E> secondIterable) {
		Iterator<E> firstIterator = firstIterable.iterator();
		Iterator<E> secondIterator = secondIterable.iterator();
		while (firstIterator.hasNext() && secondIterator.hasNext()) {
			if (!optionalEquals(firstIterator.next(), secondIterator.next())) {
				return false;
			}
		}
		return !(firstIterator.hasNext() ^ secondIterator.hasNext());
	}

	private void assertEqualsOrNot(Object expected, Object actual, boolean notEquals) {
		boolean result;
		if ((expected instanceof IBox<?>) && (actual instanceof IBox<?>)) {
			IBox expectedBox = (IBox<?>) expected;
			IBox actualBox = (IBox<?>) actual;
			result = expectedBox.sameAs(actualBox);
		}
		else if ((expected instanceof Iterable<?>) && (actual instanceof Iterable<?>)) {
			Iterable expectedIterable = (Iterable<?>) expected;
			Iterable actualIterable = (Iterable<?>) actual;
			result = iterableEquals(expectedIterable, actualIterable);
		}
		else {
			result = optionalEquals(expected, actual);
		}
		String failureMessage = "Expected: " + expected + ", but was: " + actual + ".";
		if (notEquals) {
			org.junit.Assert.assertFalse(failureMessage, result);
		}
		else {
			org.junit.Assert.assertTrue(failureMessage, result);
		}
	}

	public void assertEquals(Object expected, Object actual) {
		assertEqualsOrNot(expected, actual, false);
	}

	public void assertNotEquals(Object expected, Object actual) {
		assertEqualsOrNot(expected, actual, true);
	}

}
