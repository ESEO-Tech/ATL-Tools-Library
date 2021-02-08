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

import org.eclipse.papyrus.aof.core.IConstraints;
import org.eclipse.papyrus.aof.core.impl.Constraints;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class ConstraintsTest extends BaseTest {

	// Constraints value

	@Test
	public void testConstraintsValueForSeq() {
		testConstraintsValue(IConstraints.SEQUENCE, true, false, true, false);
	}

	@Test
	public void testConstraintsValueForBag() {
		testConstraintsValue(IConstraints.BAG, true, false, false, false);
	}

	@Test
	public void testConstraintsValueForSet() {
		testConstraintsValue(IConstraints.SET, true, false, false, true);
	}

	@Test
	public void testConstraintsValueForOSet() {
		testConstraintsValue(IConstraints.ORDERED_SET, true, false, true, true);
	}

	@Test
	public void testConstraintsValueForOpt() {
		testConstraintsValue(IConstraints.OPTION, true, true, true, true);
	}

	@Test
	public void testConstraintsValueForOne() {
		testConstraintsValue(IConstraints.ONE, false, true, true, true);
	}

	public void testConstraintsValue(IConstraints constraints, boolean optional, boolean singleton, boolean ordered, boolean unique) {
		assertEquals(constraints.isOptional(), optional);
		assertEquals(constraints.isSingleton(), singleton);
		assertEquals(constraints.isOrdered(), ordered);
		assertEquals(constraints.isUnique(), unique);
	}

	// Legal constraints (6 combinations)

	@Test
	public void testConstraintsLegalityForSeq() {
		testConstraintsLegality(IConstraints.SEQUENCE);
	}

	@Test
	public void testConstraintsLegalityForBag() {
		testConstraintsLegality(IConstraints.BAG);
	}

	@Test
	public void testConstraintsLegalityForSet() {
		testConstraintsLegality(IConstraints.SET);
	}

	@Test
	public void testConstraintsLegalityForOSet() {
		testConstraintsLegality(IConstraints.ORDERED_SET);
	}

	@Test
	public void testConstraintsLegalityForOpt() {
		testConstraintsLegality(IConstraints.OPTION);
	}

	@Test
	public void testConstraintsLegalityForOne() {
		testConstraintsLegality(IConstraints.ONE);
	}

	public void testConstraintsLegality(IConstraints constraints) {
		assertEquals(true, constraints.isLegal());
	}

	// Illegal constraints (10 combinations)
	// Note that the number of all combinations is 2^4=16 (6 legal, 10 illegal)

	@Test
	public void testConstraintsIllegalitiesForSingleton() {
		// a singleton is necessary ordered and unique
		boolean[] falseTrue = { false, true }; // option, one
		for (boolean b : falseTrue) {
			testConstraintsIllegality(b, true, false, false);
			testConstraintsIllegality(b, true, true, false);
			testConstraintsIllegality(b, true, false, true);
		}
	}

	@Test
	public void testConstraintsIllegalitiesForNonOptional() {
		// a non optional is necessary a one
		testConstraintsIllegality(false, false, false, false);
		testConstraintsIllegality(false, false, true, false);
		testConstraintsIllegality(false, false, false, true);
		testConstraintsIllegality(false, false, true, true);
	}

	public void testConstraintsIllegality(boolean optional, boolean singleton, boolean ordered, boolean unique) {
		IConstraints constraints = new Constraints(optional, singleton, ordered, unique);
		assertEquals(false, constraints.isLegal());
	}

	// Equality

	IConstraints[] allConstraints = { IConstraints.SEQUENCE, IConstraints.BAG, IConstraints.SET, IConstraints.ORDERED_SET, IConstraints.OPTION, IConstraints.ONE };

	@Test
	public void testConstraintsEqualityForSeq() {
		for (IConstraints constraints : allConstraints) {
			testConstraintsEquality(IConstraints.SEQUENCE, constraints, constraints == IConstraints.SEQUENCE);
		}
	}

	@Test
	public void testConstraintsEqualityForBag() {
		for (IConstraints constraints : allConstraints) {
			testConstraintsEquality(IConstraints.BAG, constraints, constraints == IConstraints.BAG);
		}
	}

	@Test
	public void testConstraintsEqualityForSet() {
		for (IConstraints constraints : allConstraints) {
			testConstraintsEquality(IConstraints.SET, constraints, constraints == IConstraints.SET);
		}
	}

	@Test
	public void testConstraintsEqualityForOSet() {
		for (IConstraints constraints : allConstraints) {
			testConstraintsEquality(IConstraints.ORDERED_SET, constraints, constraints == IConstraints.ORDERED_SET);
		}
	}

	@Test
	public void testConstraintsEqualityForOpt() {
		for (IConstraints constraints : allConstraints) {
			testConstraintsEquality(IConstraints.OPTION, constraints, constraints == IConstraints.OPTION);
		}
	}

	@Test
	public void testConstraintsEqualityForOne() {
		for (IConstraints constraints : allConstraints) {
			testConstraintsEquality(IConstraints.ONE, constraints, constraints == IConstraints.ONE);
		}
	}

	public void testConstraintsEquality(IConstraints leftConstraints, IConstraints rightConstraints, boolean equals) {
		assertEquals(equals, leftConstraints.matches(rightConstraints));
		assertEquals(equals, rightConstraints.matches(leftConstraints));
	}

}
