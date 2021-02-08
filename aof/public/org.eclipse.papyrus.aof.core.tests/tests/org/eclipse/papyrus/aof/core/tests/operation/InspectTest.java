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

import static org.junit.Assert.assertSame;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.util.Arrays;

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.eclipse.papyrus.aof.core.impl.operation.Inspect;
import org.eclipse.papyrus.aof.core.tests.BaseTest;
import org.junit.After;
import org.junit.Before;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class InspectTest extends BaseTest {

	private ByteArrayOutputStream outputStream;
	private PrintStream standardStream;

	private String label;

	private static String newLine = System.getProperty("line.separator");

	@Before
	public void setUp() {
		super.setUp();
		outputStream = new ByteArrayOutputStream();
		standardStream = System.out;
		System.setOut(new PrintStream(outputStream));
		label = "a=";
	}

	@After
	public void tearDown() throws Exception {
		System.setOut(standardStream);
	}

	@Override
	public void assertEquals(Object expected, Object actual) {
		if ((expected instanceof String) && (actual instanceof String)) {
			super.assertEquals(newLine + expected, newLine + actual);
		}
		else {
			super.assertEquals(expected, actual);
		}
	}

	// Utilities

	private String boxTypeToString(IConstraints boxType) {
		if (boxType == IConstraints.SEQUENCE) {
			return "seq";
		}
		else if (boxType == IConstraints.BAG) {
			return "bag";
		}
		else if (boxType == IConstraints.ORDERED_SET) {
			return "oset";
		}
		else if (boxType == IConstraints.SET) {
			return "set";
		}
		else if (boxType == IConstraints.OPTION) {
			return "opt";
		}
		else /* if (boxType==IConstraints.ONE) */{
			return "one";
		}
	}

	private String expectedString(IConstraints boxType, String contents) {
		return label + boxTypeToString(boxType) + "(" + contents + ")" + newLine;
	}

	private String createTab(IConstraints boxType, int offset) {
		int length = offset + labelToSpaces().length() + boxTypeToString(boxType).length();
		char[] tab = new char[length];
		Arrays.fill(tab, ' ');
		return new String(tab);
	}

	private String labelToSpaces() {
		String spaces = "";
		for (int i = 0; i < label.length(); i++) {
			char c = label.charAt(i);
			if (Character.isWhitespace(c)) {
				spaces += c;
			} else {
				spaces += " ";
			}
		}
		return spaces;
	}

	// Inspect result

	@Test
	public void testResultForInspectOnSeq() {
		testResultForInspect(IConstraints.SEQUENCE);
	}

	@Test
	public void testResultForInspectOnBag() {
		testResultForInspect(IConstraints.BAG);
	}

	@Test
	public void testResultForInspectOnOSet() {
		testResultForInspect(IConstraints.ORDERED_SET);
	}

	@Test
	public void testResultForInspectOnSet() {
		testResultForInspect(IConstraints.SET);
	}

	@Test
	public void testResultForInspectOnOpt() {
		testResultForInspect(IConstraints.OPTION);
	}

	@Test
	public void testResultForInspectOnOne() {
		testResultForInspect(IConstraints.ONE);
	}

	public void testResultForInspect(IConstraints boxType) {
		IBox<Integer> a = factory.createBox(boxType, 1, 2, 3, 4);
		IBox<Integer> b = a.inspect(label);
		assertSame(a, b);
	}

	// Create

	@Test
	public void testCreateForInspectOnSeq() {
		testCreateForInspect(IConstraints.SEQUENCE);
	}

	@Test
	public void testCreateForInspectOnBag() {
		testCreateForInspect(IConstraints.BAG);
	}

	@Test
	public void testCreateForInspectOnOSet() {
		testCreateForInspect(IConstraints.ORDERED_SET);
	}

	@Test
	public void testCreateForInspectOnSet() {
		testCreateForInspect(IConstraints.SET);
	}

	@Test
	public void testCreateForInspectOnOpt() {
		testCreateForInspect(IConstraints.OPTION);
	}

	@Test
	public void testCreateForInspectOnOne() {
		testCreateForInspect(IConstraints.ONE);
	}

	public void testCreateForInspect(IConstraints boxType) {
		IBox<Integer> a = factory.createBox(boxType, 1, 2, 3, 4);
		a.inspect(label);
		String contents = a.isSingleton() ? "4" : "1, 2, 3, 4";
		String expected = expectedString(boxType, contents);
		assertEquals(expected, outputStream.toString());
	}

	// Add

	@Test
	public void testAddForInspectOnSeq() {
		testAddForInspect(IConstraints.SEQUENCE);
	}

	@Test
	public void testAddForInspectOnBag() {
		testAddForInspect(IConstraints.BAG);
	}

	@Test
	public void testAddForInspectOnOSet() {
		testAddForInspect(IConstraints.ORDERED_SET);
	}

	@Test
	public void testAddForInspectOnSet() {
		testAddForInspect(IConstraints.SET);
	}

	@Test
	public void testAddForInspectOnOpt() {
		testAddForInspect(IConstraints.OPTION);
	}

	@Test
	public void testAddForInspectOnOne() {
		testAddForInspect(IConstraints.ONE);
	}

	public void testAddForInspect(IConstraints boxType) {
		IBox<Integer> a = factory.createBox(boxType, 1, 2, 3, 4);
		a.inspect(label);
		String expected;
		if (a.isSingleton()) {
			a.add(0, 5);
			expected = expectedString(boxType, "4");
			expected += expectedString(boxType, "5");
			expected += createTab(boxType, 1) + "^ replaced(0, 5)" + newLine;
		}
		else {
			a.add(2, 5);
			expected = expectedString(boxType, "1, 2, 3, 4");
			expected += expectedString(boxType, "1, 2, 5, 3, 4");
			expected += createTab(boxType, 7) + "^ added(2, 5)" + newLine;
		}
		assertEquals(expected, outputStream.toString());
	}

	// Remove

	@Test
	public void testRemoveForInspectOnSeq() {
		testRemoveForInspect(IConstraints.SEQUENCE);
	}

	@Test
	public void testRemoveForInspectOnBag() {
		testRemoveForInspect(IConstraints.BAG);
	}

	@Test
	public void testRemoveForInspectOnOSet() {
		testRemoveForInspect(IConstraints.ORDERED_SET);
	}

	@Test
	public void testRemoveForInspectOnSet() {
		testRemoveForInspect(IConstraints.SET);
	}

	@Test
	public void testRemoveForInspectOnOpt() {
		testRemoveForInspect(IConstraints.OPTION);
	}

	@Test
	public void testRemoveForInspectOnOne() {
		testRemoveForInspect(IConstraints.ONE);
	}

	public void testRemoveForInspect(IConstraints boxType) {
		IBox<Integer> a = factory.createBox(boxType, 1, 2, 3, 4);
		a.inspect(label);
		String expected;
		if (a.isSingleton()) {
			a.removeAt(0);
			expected = expectedString(boxType, "4");
			if (a.isOptional()) {
				expected += expectedString(boxType, "");
				expected += createTab(boxType, 1) + "^ removed(0, 4)" + newLine;
			}
			else {
				expected += expectedString(boxType, "1");
				expected += createTab(boxType, 1) + "^ replaced(0, 1)" + newLine;
			}
		}
		else {
			a.removeAt(2);
			expected = expectedString(boxType, "1, 2, 3, 4");
			expected += expectedString(boxType, "1, 2, 4");
			expected += createTab(boxType, 7) + "^ removed(2, 3)" + newLine;
		}
		assertEquals(expected, outputStream.toString());
	}

	// Replace

	@Test
	public void testReplaceForInspectOnSeq() {
		testReplaceForInspect(IConstraints.SEQUENCE);
	}

	@Test
	public void testReplaceForInspectOnBag() {
		testReplaceForInspect(IConstraints.BAG);
	}

	@Test
	public void testReplaceForInspectOnOSet() {
		testReplaceForInspect(IConstraints.ORDERED_SET);
	}

	@Test
	public void testReplaceForInspectOnSet() {
		testReplaceForInspect(IConstraints.SET);
	}

	@Test
	public void testReplaceForInspectOnOpt() {
		testReplaceForInspect(IConstraints.OPTION);
	}

	@Test
	public void testReplaceForInspectOnOne() {
		testReplaceForInspect(IConstraints.ONE);
	}

	public void testReplaceForInspect(IConstraints boxType) {
		IBox<Integer> a = factory.createBox(boxType, 1, 2, 3, 4);
		a.inspect(label);
		String expected;
		if (a.isSingleton()) {
			a.set(0, 5);
			expected = expectedString(boxType, "4");
			expected += expectedString(boxType, "5");
			expected += createTab(boxType, 1) + "^ replaced(0, 5)" + newLine;
		}
		else {
			a.set(2, 5);
			expected = expectedString(boxType, "1, 2, 3, 4");
			expected += expectedString(boxType, "1, 2, 5, 4");
			expected += createTab(boxType, 7) + "^ replaced(2, 5)" + newLine;
		}
		assertEquals(expected, outputStream.toString());
	}

	// Move

	@Test
	public void testMoveForInspectOnSeq() {
		testMoveForInspect(IConstraints.SEQUENCE);
	}

	@Test
	public void testMoveForInspectOnBag() {
		testMoveForInspect(IConstraints.BAG);
	}

	@Test
	public void testMoveForInspectOnOSet() {
		testMoveForInspect(IConstraints.ORDERED_SET);
	}

	@Test
	public void testMoveForInspectOnSet() {
		testMoveForInspect(IConstraints.SET);
	}

	@Test
	public void testMoveForInspectOnOpt() {
		testMoveForInspect(IConstraints.OPTION);
	}

	@Test
	public void testMoveForInspectOnOne() {
		testMoveForInspect(IConstraints.ONE);
	}

	public void testMoveForInspect(IConstraints boxType) {
		IBox<Integer> a = factory.createBox(boxType, 1, 2, 3, 4);
		a.inspect(label);
		String expected;
		if (a.isSingleton()) {
			a.move(0, 0);
			expected = expectedString(boxType, "4");
			expected += expectedString(boxType, "4");
			expected += createTab(boxType, 1) + "^ moved(0, 4)" + newLine;
		}
		else {
			a.move(1, 3);
			expected = expectedString(boxType, "1, 2, 3, 4");
			expected += expectedString(boxType, "1, 4, 2, 3");
			expected += createTab(boxType, 4) + "^ moved(1, 4)" + newLine;
		}
		assertEquals(expected, outputStream.toString());
	}

	// Test the null value display

	@Test
	public void testAddForInspectWithNullOnSeq() {
		testAddForInspectWithNull(IConstraints.SEQUENCE);
	}

	public void testAddForInspectWithNull(IConstraints boxType) {
		IBox<Integer> a = factory.createBox(boxType, 1, null, 3, 4);
		a.inspect(label);
		a.add(null);
		String expected = expectedString(boxType, "1, null, 3, 4");
		expected += expectedString(boxType, "1, null, 3, 4, null");
		expected += createTab(boxType, 16) + "^ added(4, null)" + newLine;
		assertEquals(expected, outputStream.toString());
	}

	// Test inspection with whitespace in the label

	// @Test
	// public void testAddWithWhiteSpaceInLabelOnSeq() {
	// testAddWithWhiteSpaceInLabel(IConstraints.SEQUENCE);
	// }
	//
	// public void testAddWithWhiteSpaceInLabel(IConstraints boxType) {
	// IBox<Integer> a = factory.createBox(boxType, 1, 2, 3);
	// // label = "\ta=" + newLine + "\t\t";
	// label = "\ta=\t";
	// a.inspect(label);
	// a.append(4);
	// String expected = expectedString(boxType, "1, 2, 3");
	// expected += expectedString(boxType, "1, 2, 3, 4");
	// expected += createTab(boxType, 10) + "^ added(3, 4)" + newLine;
	// assertEquals(expected, outputStream.toString());
	// }


	// Test inspection with toString

	private IUnaryFunction<Integer, String> integerToString = new IUnaryFunction<Integer, String>() {
		public String apply(Integer i) {
			String prefix = (i > 0) ? "+" : "";
			return prefix + i;
		}
	};

	@Test
	public void testCreateUsingSpecificToStringOnSeq() {
		testCreateUsingSpecificToString(IConstraints.SEQUENCE);
	}

	public void testCreateUsingSpecificToString(IConstraints boxType) {
		IBox<Integer> a = factory.createBox(boxType, 1, 2, 3);
		a.inspect(label, integerToString);
		assertEquals(expectedString(boxType, "+1, +2, +3"), outputStream.toString());
	}

	@Test
	public void testCreateUsingRegisteredToStringOnSeq() {
		testCreateUsingRegisteredToString(IConstraints.SEQUENCE);
	}

	public void testCreateUsingRegisteredToString(IConstraints boxType) {
		IBox<Integer> a = factory.createBox(boxType, 1, 2, 3);
		Inspect.registerToString(Integer.class, integerToString);
		a.inspect(label);
		assertEquals(expectedString(boxType, "+1, +2, +3"), outputStream.toString());
		Inspect.registerToString(Integer.class, null);
	}

}
