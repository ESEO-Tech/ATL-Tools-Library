/*******************************************************************************
 *  Copyright (c) 2015 ESEO.
 *  All rights reserved. This program and the accompanying materials
 *  are made available under the terms of the Eclipse Public License v1.0
 *  which accompanies this distribution, and is available at
 *  http://www.eclipse.org/legal/epl-v10.html
 *
 *  Contributors:
 *     Olivier Beaudoux - JUnit testing of CollectBox operation on all box types
 *******************************************************************************/
package org.eclipse.papyrus.aof.core.tests.operation;

import java.util.Arrays;
import java.util.List;

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.eclipse.papyrus.aof.core.IOne;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.eclipse.papyrus.aof.core.tests.population.Person;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class AOFCollectBoxTest extends CollectBoxTest {

	// ==================================
	// = Tests on population meta-model =
	// ==================================

	// Utilities

	private Person createPerson(String name) {
		Person person = new Person();
		person.getName().set(name);
		person.getEmails().add(name.toLowerCase() + "@hip.com");
		person.getEmails().add(name.toLowerCase() + "@hop.fr");
		return person;
	}

	private Person createPerson(String parentName, List<String> childNames) {
		Person person = createPerson(parentName);
		for (String childName : childNames) {
			Person child = createPerson(childName);
			child.getParent().set(person);
			person.getChildren().add(child);
		}
		return person;
	}

	// Create

	@Test
	public void testCreateForCollectChildNames() {
		List<String> childNames = createNames(3, "Child");
		Person parent = createPerson("Parent", childNames);
		IBox<String> parentChildNames = parent.getChildren().collectMutable(factory, Person.class, "name");
		assertEquals(IConstraints.BAG, parentChildNames.getConstraints());
		assertEquals(childNames, parentChildNames);
	}

	@Test
	public void testCreateForCollectChildEmails() {
		List<String> childNames = createNames(2, "Child");
		Person parent = createPerson("Parent", childNames);
		IBox<String> childEmails = parent.getChildren().collectMutable(factory, Person.class, "emails");
		assertEquals(IConstraints.BAG, childEmails.getConstraints());
		assertEquals(Arrays.asList("child1@hip.com", "child1@hop.fr", "child2@hip.com", "child2@hop.fr"), childEmails);
	}

	@Test
	public void testCreateForCollectParentEmails() {
		Person parent = createPerson("Parent", createNames(1, "Child"));
		Person child = parent.getChildren().get(0);
		IBox<String> parentEmails = child.getParent().collectMutable(factory, Person.class, "emails");
		assertEquals(IConstraints.ORDERED_SET, parentEmails.getConstraints());
		assertEquals(Arrays.asList("parent@hip.com", "parent@hop.fr"), parentEmails);
	}


	// Add

	@Test
	public void testAddForCollectChildNames() {
		List<String> childNames = createNames(3, "Child");
		Person parent = createPerson("Parent", childNames);
		IBox<String> parentChildNames = parent.getChildren().collectMutable(factory, Person.class, "name");
		Person child = createPerson("John");
		parent.getChildren().add(1, child);
		childNames.add(1, "John");
		assertEquals(childNames, parentChildNames);
	}

	// Remove

	@Test
	public void testRemoveForCollectChildNames() {
		List<String> childNames = createNames(4, "Child");
		Person parent = createPerson("Parent", childNames);
		IBox<String> parentChildNames = parent.getChildren().collectMutable(factory, Person.class, "name");
		parent.getChildren().removeAt(1);
		childNames.remove(1);
		assertEquals(childNames, parentChildNames);
	}

	// Replace

	@Test
	public void testReplaceForCollectChildNames() {
		List<String> childNames = createNames(3, "Child");
		Person parent = createPerson("Parent", childNames);
		IBox<String> parentChildNames = parent.getChildren().collectMutable(factory, Person.class, "name");
		Person child = createPerson("John");
		parent.getChildren().set(1, child);
		childNames.set(1, "John");
		assertEquals(childNames, parentChildNames);
	}

	// Move

	@Test
	public void testMoveForCollectChildNames() {
		List<String> childNames = createNames(5, "Child");
		Person parent = createPerson("Parent", childNames);
		IBox<String> parentChildNames = parent.getChildren().collectMutable(factory, Person.class, "name");
		parent.getChildren().move(0, 4);
		parent.getChildren().move(3, 1);
		childNames.add(0, childNames.remove(4));
		childNames.add(3, childNames.remove(1));
		assertEquals(childNames, parentChildNames);
	}

	// Clear

	@Test
	public void testClearForCollectChildNames() {
		List<String> childNames = createNames(5, "Child");
		Person parent = createPerson("Parent", childNames);
		IBox<String> parentChildNames = parent.getChildren().collectMutable(factory, Person.class, "name");
		parent.getChildren().clear();
		childNames.clear();
		assertEquals(childNames, parentChildNames);
	}

	// Inner add

	@Test
	public void testInnerAddCollectChildEmails() {
		Person parent = createPerson("Parent", createNames(2, "Child"));
		IBox<String> childEmails = parent.getChildren().collectMutable(factory, Person.class, "emails");
		parent.getChildren().get(0).getEmails().add(1, "child1@new.fr");
		assertEquals(Arrays.asList("child1@hip.com", "child1@new.fr", "child1@hop.fr", "child2@hip.com", "child2@hop.fr"), childEmails);
	}


	// Inner remove

	@Test
	public void testInnerRemoveForCollectChildEmails() {
		Person parent = createPerson("Parent", createNames(2, "Child"));
		IBox<String> childEmails = parent.getChildren().collectMutable(factory, Person.class, "emails");
		parent.getChildren().get(1).getEmails().removeAt(0);
		assertEquals(Arrays.asList("child1@hip.com", "child1@hop.fr", "child2@hop.fr"), childEmails);
	}

	// Inner replace

	@Test
	public void testInnerReplaceForCollectChildEmails() {
		Person parent = createPerson("Parent", createNames(2, "Child"));
		IBox<String> childEmails = parent.getChildren().collectMutable(factory, Person.class, "emails");
		parent.getChildren().get(1).getEmails().set(0, "child2@new.fr");
		assertEquals(Arrays.asList("child1@hip.com", "child1@hop.fr", "child2@new.fr", "child2@hop.fr"), childEmails);
	}

	// Inner move

	@Test
	public void testInnerMoveForCollectChildEmails() {
		Person parent = createPerson("Parent", createNames(2, "Child"));
		IBox<String> childEmails = parent.getChildren().collectMutable(factory, Person.class, "emails");
		parent.getChildren().get(0).getEmails().move(0, 1);
		assertEquals(Arrays.asList("child1@hop.fr", "child1@hip.com", "child2@hip.com", "child2@hop.fr"), childEmails);
	}

	// Inner clear

	@Test
	public void testInnerClearForCollectChildNames() {
		Person parent = createPerson("Parent", createNames(3, "Child"));
		IBox<String> childNames = parent.getChildren().collectMutable(factory, Person.class, "name");
		parent.getChildren().get(1).getName().clear();
		assertEquals(Arrays.asList("Child1", "Name", "Child3"), childNames);
	}


	@Test
	public void testInnerClearForCollectChildEmails() {
		Person parent = createPerson("Parent", createNames(2, "Child"));
		IBox<String> childEmails = parent.getChildren().collectMutable(factory, Person.class, "emails");
		parent.getChildren().get(0).getEmails().clear();
		assertEquals(IConstraints.BAG, childEmails.getConstraints());
		assertEquals(Arrays.asList("child2@hip.com", "child2@hop.fr"), childEmails);
	}


	// Add backward

	@Test
	public void testAddBackwardForCollectParentEmails() {
		Person parent = createPerson("Parent", createNames(1, "Child"));
		Person child = parent.getChildren().get(0);
		IBox<String> parentEmails = child.getParent().collectMutable(factory, Person.class, "emails");
		parentEmails.add(0, "parent@new.fr");
		IBox<String> actualParentEmails = child.getParent().collectMutable(factory, Person.class, "emails");
		assertEquals(parentEmails, actualParentEmails);
	}

	// Remove backward

	@Test
	public void testRemoveBackwardForCollectParentEmails() {
		Person parent = createPerson("Parent", createNames(1, "Child"));
		Person child = parent.getChildren().get(0);
		IBox<String> parentEmails = child.getParent().collectMutable(factory, Person.class, "emails");
		parentEmails.removeAt(0);
		IBox<String> actualParentEmails = child.getParent().collectMutable(factory, Person.class, "emails");
		assertEquals(parentEmails, actualParentEmails);
	}

	// Replace backward

	@Test
	public void testReplaceBackwardForCollectParentEmails() {
		Person parent = createPerson("Parent", createNames(1, "Child"));
		Person child = parent.getChildren().get(0);
		IBox<String> parentEmails = child.getParent().collectMutable(factory, Person.class, "emails");
		parentEmails.set(1, "parent@new.fr");
		IBox<String> actualParentEmails = child.getParent().collectMutable(factory, Person.class, "emails");
		assertEquals(parentEmails, actualParentEmails);
	}

	// Move backward

	@Test
	public void testMoveBackwardForCollectParentEmails() {
		Person parent = createPerson("Parent", createNames(1, "Child"));
		Person child = parent.getChildren().get(0);
		IBox<String> parentEmails = child.getParent().collectMutable(factory, Person.class, "emails");
		parentEmails.move(1, 0);
		IBox<String> actualParentEmails = child.getParent().collectMutable(factory, Person.class, "emails");
		assertEquals(parentEmails, actualParentEmails);
	}

	// Clear backward

	@Test
	public void testClearBackwardForCollectParentEmails() {
		Person parent = createPerson("Parent", createNames(1, "Child"));
		Person child = parent.getChildren().get(0);
		IBox<String> parentEmails = child.getParent().collectMutable(factory, Person.class, "emails");
		parentEmails.clear();
		IBox<String> actualParentEmails = child.getParent().collectMutable(factory, Person.class, "emails");
		assertEquals(parentEmails, actualParentEmails);
	}


	// ===================================
	// = Tests on "anonymous" meta-model =
	// ===================================

	public static class Sample {

		private IBox<Integer> box;

		public Sample(IConstraints boxType) {
			box = factory.createBox(boxType);
		}

		public IBox<Integer> getBox() {
			return box;
		}

		@Override
		public String toString() {
			return "box=" + box.toString();
		}

	}

	public static class SeqSample extends Sample {
		public SeqSample() {
			super(IConstraints.SEQUENCE);
		}

	}

	public static class BagSample extends Sample {
		public BagSample() {
			super(IConstraints.BAG);
		}

	}

	public static class OSetSample extends Sample {
		public OSetSample() {
			super(IConstraints.ORDERED_SET);
		}

	}

	public static class SetSample extends Sample {
		public SetSample() {
			super(IConstraints.SET);
		}

	}

	public static class OneSample extends Sample {
		public OneSample() {
			super(IConstraints.ONE);
		}

	}

	public static class OptSample extends Sample {
		public OptSample() {
			super(IConstraints.OPTION);
		}

	}

	public Sample createSample(IConstraints boxType, Integer... elements) {
		Sample sample;
		if (boxType == IConstraints.SEQUENCE) {
			sample = new SeqSample();
		}
		else if (boxType == IConstraints.BAG) {
			sample = new BagSample();
		}
		else if (boxType == IConstraints.ORDERED_SET) {
			sample = new OSetSample();
		}
		else if (boxType == IConstraints.SET) {
			sample = new SetSample();
		}
		else if (boxType == IConstraints.OPTION) {
			sample = new OptSample();
		}
		else if (boxType == IConstraints.ONE) {
			sample = new OneSample();
			IOne<Integer> oneBox = (IOne<Integer>) sample.getBox();
			Integer defaultInteger = (elements.length > 0) ? elements[0] : 0;
			oneBox.clear(defaultInteger);
		}
		else {
			throw new IllegalArgumentException("Invalid box type");
		}
		sample.getBox().assign(Arrays.asList(elements));
		return sample;
	}

	// Create

	@Test
	public void testCreateForCollectBoxOnSeqOSet() {
		testCreateForCollectBox(IConstraints.SEQUENCE, IConstraints.ORDERED_SET, IConstraints.SEQUENCE, 1, 2, 2, 3, 2, 3, 3, 4);
	}

	@Test
	public void testCreateForCollectBoxOnBagOSet() {
		testCreateForCollectBox(IConstraints.BAG, IConstraints.ORDERED_SET, IConstraints.BAG, 1, 2, 2, 3, 2, 3, 3, 4);
	}

	@Test
	public void testCreateForCollectBoxOnOSetOSet() {
		testCreateForCollectBox(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET, IConstraints.SEQUENCE, 1, 2, 2, 3, 3, 4);
	}

	@Test
	public void testCreateForCollectBoxOnSetOSet() {
		testCreateForCollectBox(IConstraints.SET, IConstraints.ORDERED_SET, IConstraints.BAG, 1, 2, 2, 3, 3, 4);
	}

	@Test
	public void testCreateForCollectBoxOnOptOSet() {
		testCreateForCollectBox(IConstraints.OPTION, IConstraints.ORDERED_SET, IConstraints.ORDERED_SET, 3, 4);
	}

	@Test
	public void testCreateForCollectBoxOnOneOSet() {
		testCreateForCollectBox(IConstraints.ONE, IConstraints.ORDERED_SET, IConstraints.ORDERED_SET, 3, 4);
	}

	public void testCreateForCollectBox(IConstraints inputType, IConstraints innerType, IConstraints expectedType, Integer... expectedElements) {
		Sample sample1 = createSample(innerType, 1, 2);
		Sample sample2 = createSample(innerType, 2, 3);
		Sample sample3 = createSample(innerType, 3, 3, 4);
		Sample[] samples = { sample1, sample2, sample2, sample3 };
		IBox<Sample> a = factory.createBox(inputType, samples);
		IBox<Integer> b = a.collectMutable(factory, sample1.getClass(), "box");
		IBox<Integer> expected = factory.createBox(expectedType, expectedElements);
		assertEquals(expected, b);
	}

	// Add

	@Test
	public void testForwardAddForCollectBoxOnSeqSet() {
		testForwardAddForCollectBox(IConstraints.SEQUENCE, IConstraints.SET);
	}

	@Test
	public void testForwardAddForCollectBoxOnBagSet() {
		testForwardAddForCollectBox(IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testForwardAddForCollectBoxOnOSetSet() {
		testForwardAddForCollectBox(IConstraints.ORDERED_SET, IConstraints.SET);
	}

	@Test
	public void testForwardAddForCollectBoxOnSetSet() {
		testForwardAddForCollectBox(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testForwardAddForCollectBoxOnOptSet() {
		testForwardAddForCollectBox(IConstraints.OPTION, IConstraints.SET);
	}

	@Test
	public void testForwardAddForCollectBoxOnOneSet() {
		testForwardAddForCollectBox(IConstraints.ONE, IConstraints.SET);
	}

	public void testForwardAddForCollectBox(IConstraints inputType, IConstraints innerType) {
		Sample sample1 = createSample(innerType, 1, 2);
		Sample sample2 = createSample(innerType, 2, 3);
		Sample sample3 = createSample(innerType, 3, 3, 4);
		Sample[] samples = { sample1, sample2 };
		IBox<Sample> a = factory.createBox(inputType, samples);
		IBox<Integer> b = a.collectMutable(factory, sample1.getClass(), "box");
		if (a.isSingleton()) {
			a.add(0, sample3);
		}
		else {
			a.add(2, sample3);
			if (!a.isUnique()) {
				a.add(2, sample2);
			}
		}
		assertEquals(a.collectMutable(factory, sample1.getClass(), "box"), b);
	}

	// Remove

	@Test
	public void testForwardRemoveForCollectBoxOnSeqSeq() {
		testForwardRemoveForCollectBox(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testForwardRemoveForCollectBoxOnBagSeq() {
		testForwardRemoveForCollectBox(IConstraints.BAG, IConstraints.SEQUENCE);
	}

	@Test
	public void testForwardRemoveForCollectBoxOnOSetSeq() {
		testForwardRemoveForCollectBox(IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testForwardRemoveForCollectBoxOnSetSeq() {
		testForwardRemoveForCollectBox(IConstraints.SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testForwardRemoveForCollectBoxOnOptSeq() {
		testForwardRemoveForCollectBox(IConstraints.OPTION, IConstraints.SEQUENCE);
	}

	@Test
	public void testForwardRemoveForCollectBoxOnOneSeq() {
		testForwardRemoveForCollectBox(IConstraints.ONE, IConstraints.SEQUENCE);
	}

	public void testForwardRemoveForCollectBox(IConstraints inputType, IConstraints innerType) {
		Sample sample1 = createSample(innerType, 1, 2);
		Sample sample2 = createSample(innerType, 2, 3);
		Sample sample3 = createSample(innerType, 3, 3, 4);
		Sample[] samples = { sample1, sample2, sample2, sample3 };
		IBox<Sample> a = factory.createBox(inputType, samples);
		IBox<Integer> b = a.collectMutable(factory, sample1.getClass(), "box");
		if (a.isSingleton()) {
			a.removeAt(0);
		}
		else {
			a.removeAt(1);
			a.removeAt(0);
		}
		assertEquals(a.collectMutable(factory, sample1.getClass(), "box"), b);
	}

	// Replace

	@Test
	public void testForwardReplaceForCollectBoxOnSeqBag() {
		testForwardReplaceForCollectBox(IConstraints.SEQUENCE, IConstraints.BAG);
	}

	@Test
	public void testForwardReplaceForCollectBoxOnBagBag() {
		testForwardReplaceForCollectBox(IConstraints.BAG, IConstraints.BAG);
	}

	@Test
	public void testForwardReplaceForCollectBoxOnOSetBag() {
		testForwardReplaceForCollectBox(IConstraints.ORDERED_SET, IConstraints.BAG);
	}

	@Test
	public void testForwardReplaceForCollectBoxOnSetBag() {
		testForwardReplaceForCollectBox(IConstraints.SET, IConstraints.BAG);
	}

	@Test
	public void testForwardReplaceForCollectBoxOnOptBag() {
		testForwardReplaceForCollectBox(IConstraints.OPTION, IConstraints.BAG);
	}

	@Test
	public void testForwardReplaceForCollectBoxOnOneBag() {
		testForwardReplaceForCollectBox(IConstraints.ONE, IConstraints.BAG);
	}

	public void testForwardReplaceForCollectBox(IConstraints inputType, IConstraints innerType) {
		Sample sample1 = createSample(innerType, 1, 2, 3);
		Sample sample2 = createSample(innerType, 2, 4);
		Sample sample3 = createSample(innerType, 3, 3, 5);
		Sample[] samples = { sample1, sample2, sample2 };
		IBox<Sample> a = factory.createBox(inputType, samples);
		IBox<String> b = a.collectMutable(factory, sample1.getClass(), "box");
		if (a.isSingleton()) {
			a.set(0, sample3);
		}
		else {
			a.set(1, sample3);
			if (!a.isUnique()) {
				a.set(2, sample1);
			}
		}
		assertEquals(a.collectMutable(factory, sample1.getClass(), "box"), b);
	}

	// Move

	@Test
	public void testForwardMoveForCollectBoxOnSeqOSet() {
		testForwardMoveForCollectBox(IConstraints.SEQUENCE, IConstraints.ORDERED_SET);
	}

	@Test
	public void testForwardMoveForCollectBoxOnBagOSet() {
		testForwardMoveForCollectBox(IConstraints.BAG, IConstraints.ORDERED_SET);
	}

	@Test
	public void testForwardMoveForCollectBoxOnOSetOSet() {
		testForwardMoveForCollectBox(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testForwardMoveForCollectBoxOnSetOSet() {
		testForwardMoveForCollectBox(IConstraints.SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testForwardMoveForCollectBoxOnOptOSet() {
		testForwardMoveForCollectBox(IConstraints.OPTION, IConstraints.ORDERED_SET);
	}

	@Test
	public void testForwardMoveForCollectBoxOnOneOSet() {
		testForwardMoveForCollectBox(IConstraints.ONE, IConstraints.ORDERED_SET);
	}

	public void testForwardMoveForCollectBox(IConstraints inputType, IConstraints innerType) {
		Sample sample1 = createSample(innerType, 1, 2);
		Sample sample2 = createSample(innerType, 2, 3);
		Sample sample3 = createSample(innerType, 3, 3, 4);
		Sample[] samples = { sample1, sample2, sample2, sample3 };
		IBox<Sample> a = factory.createBox(inputType, samples);
		IBox<Integer> b = a.collectMutable(factory, sample1.getClass(), "box");
		if (a.isSingleton()) {
			a.move(0, 0);
		}
		else {
			a.move(0, 1);
			a.move(2, 1);
		}
		assertEquals(a.collectMutable(factory, sample1.getClass(), "box"), b);
	}

	// Clear

	@Test
	public void testForwardClearForCollectBoxOnSeqOne() {
		testForwardClearForCollectBox(IConstraints.SEQUENCE, IConstraints.ONE);
	}

	@Test
	public void testForwardClearForCollectBoxOnBagOne() {
		testForwardClearForCollectBox(IConstraints.BAG, IConstraints.ONE);
	}

	@Test
	public void testForwardClearForCollectBoxOnOSetOne() {
		testForwardClearForCollectBox(IConstraints.ORDERED_SET, IConstraints.ONE);
	}

	@Test
	public void testForwardClearForCollectBoxOnSetOne() {
		testForwardClearForCollectBox(IConstraints.SET, IConstraints.ONE);
	}

	@Test
	public void testForwardClearForCollectBoxOnOptOne() {
		testForwardClearForCollectBox(IConstraints.OPTION, IConstraints.ONE);
	}

	@Test
	public void testForwardClearForCollectBoxOnOneOne() {
		testForwardClearForCollectBox(IConstraints.ONE, IConstraints.ONE);
	}

	public void testForwardClearForCollectBox(IConstraints inputType, IConstraints innerType) {
		Sample sample1 = createSample(innerType, 1, 2);
		Sample sample2 = createSample(innerType, 2, 3);
		Sample[] samples = { sample1, sample2 };
		IBox<Sample> a = factory.createBox(inputType, samples);
		IBox<Integer> b = a.collectMutable(factory, sample1.getClass(), "box");
		a.clear();
		assertEquals(a.collectMutable(factory, sample1.getClass(), "box"), b);
	}

	// Inner add

	@Test
	public void testInnerAddForCollectBoxOnSeqSet() {
		testInnerAddForCollectBox(IConstraints.SEQUENCE, IConstraints.SET);
	}

	@Test
	public void testInnerAddForCollectBoxOnBagSet() {
		testInnerAddForCollectBox(IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testInnerAddForCollectBoxOnOSetSet() {
		testInnerAddForCollectBox(IConstraints.ORDERED_SET, IConstraints.SET);
	}

	@Test
	public void testInnerAddForCollectBoxOnSetSet() {
		testInnerAddForCollectBox(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testInnerAddForCollectBoxOnOptSet() {
		testInnerAddForCollectBox(IConstraints.OPTION, IConstraints.SET);
	}

	@Test
	public void testInnerAddForCollectBoxOnOneSet() {
		testInnerAddForCollectBox(IConstraints.ONE, IConstraints.SET);
	}

	public void testInnerAddForCollectBox(IConstraints inputType, IConstraints innerType) {
		Sample sample1 = createSample(innerType, 2);
		Sample sample2 = createSample(innerType, 2, 3);
		Sample sample3 = createSample(innerType, 3, 3, 4);
		Sample[] samples = { sample1, sample2, sample2, sample3 };
		IBox<Sample> a = factory.createBox(inputType, samples);
		IBox<Integer> b = a.collectMutable(factory, sample1.getClass(), "box");
		sample1.getBox().add(0, 1);
		if (!innerType.isUnique()) {
			sample2.getBox().add(3);
			sample3.getBox().add(1, 3);
		}
		assertEquals(a.collectMutable(factory, sample1.getClass(), "box"), b);
	}

	// Inner remove

	@Test
	public void testInnerRemoveForCollectBoxOnSeqSeq() {
		testInnerRemoveForCollectBox(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testInnerRemoveForCollectBoxOnBagSeq() {
		testInnerRemoveForCollectBox(IConstraints.BAG, IConstraints.SEQUENCE);
	}

	@Test
	public void testInnerRemoveForCollectBoxOnOSetSeq() {
		testInnerRemoveForCollectBox(IConstraints.ORDERED_SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testInnerRemoveForCollectBoxOnSetSeq() {
		testInnerRemoveForCollectBox(IConstraints.SET, IConstraints.SEQUENCE);
	}

	@Test
	public void testInnerRemoveForCollectBoxOnOptSeq() {
		testInnerRemoveForCollectBox(IConstraints.OPTION, IConstraints.SEQUENCE);
	}

	@Test
	public void testInnerRemoveForCollectBoxOnOneSeq() {
		testInnerRemoveForCollectBox(IConstraints.ONE, IConstraints.SEQUENCE);
	}

	public void testInnerRemoveForCollectBox(IConstraints inputType, IConstraints innerType) {
		Sample sample1 = createSample(innerType, 1, 2);
		Sample sample2 = createSample(innerType, 2, 3);
		Sample sample3 = createSample(innerType, 3, 3, 4);
		Sample[] samples = { sample1, sample2, sample2, sample3 };
		IBox<Sample> a = factory.createBox(inputType, samples);
		IBox<Integer> b = a.collectMutable(factory, sample1.getClass(), "box");
		sample1.getBox().removeAt(0);
		sample2.getBox().removeAt(1);
		sample3.getBox().removeAt(1);
		assertEquals(a.collectMutable(factory, sample1.getClass(), "box"), b);
	}

	// Inner replace

	@Test
	public void testInnerReplaceForCollectBoxOnSeqOpt() {
		testInnerReplaceForCollectBox(IConstraints.SEQUENCE, IConstraints.OPTION);
	}

	@Test
	public void testInnerReplaceForCollectBoxOnBagOpt() {
		testInnerReplaceForCollectBox(IConstraints.BAG, IConstraints.OPTION);
	}

	@Test
	public void testInnerReplaceForCollectBoxOnOSetOpt() {
		testInnerReplaceForCollectBox(IConstraints.ORDERED_SET, IConstraints.OPTION);
	}

	@Test
	public void testInnerReplaceForCollectBoxOnSetOpt() {
		testInnerReplaceForCollectBox(IConstraints.SET, IConstraints.OPTION);
	}

	@Test
	public void testInnerReplaceForCollectBoxOnOptOpt() {
		testInnerReplaceForCollectBox(IConstraints.OPTION, IConstraints.OPTION);
	}

	@Test
	public void testInnerReplaceForCollectBoxOnOneOpt() {
		testInnerReplaceForCollectBox(IConstraints.ONE, IConstraints.OPTION);
	}

	public void testInnerReplaceForCollectBox(IConstraints inputType, IConstraints innerType) {
		Sample sample1 = createSample(innerType, 1);
		Sample sample2 = createSample(innerType, 2);
		Sample sample3 = createSample(innerType);
		Sample sample4 = createSample(innerType, 3);
		Sample[] samples = { sample1, sample2, sample2, sample3, sample4 };
		IBox<Sample> a = factory.createBox(inputType, samples);
		IBox<Integer> b = a.collectMutable(factory, sample1.getClass(), "box");
		sample1.getBox().set(0, 2);
		sample2.getBox().set(0, 3);
		sample4.getBox().set(0, 4);
		assertEquals(a.collectMutable(factory, sample1.getClass(), "box"), b);
	}

	// Inner move

	@Test
	public void testInnerMoveForCollectBoxOnSeqOSet() {
		testInnerMoveForCollectBox(IConstraints.SEQUENCE, IConstraints.ORDERED_SET);
	}

	@Test
	public void testInnerMoveForCollectBoxOnBagOSet() {
		testInnerMoveForCollectBox(IConstraints.BAG, IConstraints.ORDERED_SET);
	}

	@Test
	public void testInnerMoveForCollectBoxOnOSetOSet() {
		testInnerMoveForCollectBox(IConstraints.ORDERED_SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testInnerMoveForCollectBoxOnSetOSet() {
		testInnerMoveForCollectBox(IConstraints.SET, IConstraints.ORDERED_SET);
	}

	@Test
	public void testInnerMoveForCollectBoxOnOptOSet() {
		testInnerMoveForCollectBox(IConstraints.OPTION, IConstraints.ORDERED_SET);
	}

	@Test
	public void testInnerMoveForCollectBoxOnOneOSet() {
		testInnerMoveForCollectBox(IConstraints.ONE, IConstraints.ORDERED_SET);
	}

	public void testInnerMoveForCollectBox(IConstraints inputType, IConstraints innerType) {
		Sample sample1 = createSample(innerType, 1, 2);
		Sample sample2 = createSample(innerType, 2, 3);
		Sample sample3 = createSample(innerType, 3, 3, 4);
		Sample[] samples = { sample1, sample2, sample2, sample3 };
		IBox<Sample> a = factory.createBox(inputType, samples);
		IBox<Integer> b = a.collectMutable(factory, sample1.getClass(), "box");
		sample1.getBox().move(1, 0);
		sample2.getBox().move(0, 1);
		sample3.getBox().move(0, 1);
		assertEquals(a.collectMutable(factory, sample1.getClass(), "box"), b);
	}

	// Inner clear

	@Test
	public void testInnerClearForCollectBoxOnSeqOne() {
		testInnerClearForCollectBox(IConstraints.SEQUENCE, IConstraints.ONE);
	}

	@Test
	public void testInnerClearForCollectBoxOnBagOne() {
		testInnerClearForCollectBox(IConstraints.BAG, IConstraints.ONE);
	}

	@Test
	public void testInnerClearForCollectBoxOnOSetOne() {
		testInnerClearForCollectBox(IConstraints.ORDERED_SET, IConstraints.ONE);
	}

	@Test
	public void testInnerClearForCollectBoxOnSetOne() {
		testInnerClearForCollectBox(IConstraints.SET, IConstraints.ONE);
	}

	@Test
	public void testInnerClearForCollectBoxOnOptOne() {
		testInnerClearForCollectBox(IConstraints.OPTION, IConstraints.ONE);
	}

	@Test
	public void testInnerClearForCollectBoxOnOneOne() {
		testInnerClearForCollectBox(IConstraints.ONE, IConstraints.ONE);
	}

	public void testInnerClearForCollectBox(IConstraints inputType, IConstraints innerType) {
		Sample sample1 = createSample(innerType, 1, 2);
		Sample sample2 = createSample(innerType, 2, 3);
		Sample[] samples = { sample1, sample2 };
		IBox<Sample> a = factory.createBox(inputType, samples);
		IBox<Integer> b = a.collectMutable(factory, sample1.getClass(), "box");
		sample1.getBox().clear();
		sample2.getBox().clear();
		assertEquals(a.collectMutable(factory, sample1.getClass(), "box"), b);
	}

	// Add backward

	@Test
	public void testBackwardAddForCollectBoxOnSeqSet() {
		thrown.expect(IllegalStateException.class);
		testBackwardAddForCollectBox(IConstraints.SEQUENCE, IConstraints.SET);
	}

	@Test
	public void testBackwardAddForCollectBoxOnBagSet() {
		thrown.expect(IllegalStateException.class);
		testBackwardAddForCollectBox(IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testBackwardAddForCollectBoxOnOSetSet() {
		thrown.expect(IllegalStateException.class);
		testBackwardAddForCollectBox(IConstraints.ORDERED_SET, IConstraints.SET);
	}

	@Test
	public void testBackwardAddForCollectBoxOnSetSet() {
		thrown.expect(IllegalStateException.class);
		testBackwardAddForCollectBox(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testBackwardAddForCollectBoxOnOptSet() {
		testBackwardAddForCollectBox(IConstraints.OPTION, IConstraints.SET);
	}

	@Test
	public void testBackwardAddForCollectBoxOnOneSet() {
		testBackwardAddForCollectBox(IConstraints.ONE, IConstraints.SET);
	}

	public void testBackwardAddForCollectBox(IConstraints inputType, IConstraints innerType) {
		Sample sample1 = createSample(innerType, 1, 2);
		Sample sample2 = createSample(innerType, 2, 3);
		Sample[] samples = { sample1, sample2 };
		IBox<Sample> a = factory.createBox(inputType, samples);
		IBox<Integer> b = a.collectMutable(factory, sample1.getClass(), "box");
		if (b.isSingleton()) {
			b.add(0, 123);
		}
		else {
			b.add(2, 456);
			if (!b.isUnique()) {
				b.add(2, 1);
			}
		}
		assertEquals(b, a.collectMutable(factory, sample1.getClass(), "box"));
	}

	// Remove backward

	@Test
	public void testBackwardRemoveForCollectBoxOnSeqSet() {
		thrown.expect(IllegalStateException.class);
		testBackwardRemoveForCollectBox(IConstraints.SEQUENCE, IConstraints.SET);
	}

	@Test
	public void testBackwardRemoveForCollectBoxOnBagSet() {
		thrown.expect(IllegalStateException.class);
		testBackwardRemoveForCollectBox(IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testBackwardRemoveForCollectBoxOnOSetSet() {
		thrown.expect(IllegalStateException.class);
		testBackwardRemoveForCollectBox(IConstraints.ORDERED_SET, IConstraints.SET);
	}

	@Test
	public void testBackwardRemoveForCollectBoxOnSetSet() {
		thrown.expect(IllegalStateException.class);
		testBackwardRemoveForCollectBox(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testBackwardRemoveForCollectBoxOnOptSet() {
		testBackwardRemoveForCollectBox(IConstraints.OPTION, IConstraints.SET);
	}

	@Test
	public void testBackwardRemoveForCollectBoxOnOneSet() {
		testBackwardRemoveForCollectBox(IConstraints.ONE, IConstraints.SET);
	}

	public void testBackwardRemoveForCollectBox(IConstraints inputType, IConstraints innerType) {
		Sample sample1 = createSample(innerType, 1, 2);
		Sample sample2 = createSample(innerType, 2, 3);
		Sample sample3 = createSample(innerType, 3, 4);
		Sample[] samples = { sample1, sample2, sample3 };
		IBox<Sample> a = factory.createBox(inputType, samples);
		IBox<Integer> b = a.collectMutable(factory, sample1.getClass(), "box");
		b.removeAt(0);
		if (!b.isSingleton()) {
			b.removeAt(0);
		}
		assertEquals(b, a.collectMutable(factory, sample1.getClass(), "box"));
	}

	// Replace backward

	@Test
	public void testBackwardReplaceForCollectBoxOnSeqSet() {
		thrown.expect(IllegalStateException.class);
		testBackwardReplaceForCollectBox(IConstraints.SEQUENCE, IConstraints.SET);
	}

	@Test
	public void testBackwardReplaceForCollectBoxOnBagSet() {
		thrown.expect(IllegalStateException.class);
		testBackwardReplaceForCollectBox(IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testBackwardReplaceForCollectBoxOnOSetSet() {
		thrown.expect(IllegalStateException.class);
		testBackwardReplaceForCollectBox(IConstraints.ORDERED_SET, IConstraints.SET);
	}

	@Test
	public void testBackwardReplaceForCollectBoxOnSetSet() {
		thrown.expect(IllegalStateException.class);
		testBackwardReplaceForCollectBox(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testBackwardReplaceForCollectBoxOnOptSet() {
		testBackwardReplaceForCollectBox(IConstraints.OPTION, IConstraints.SET);
	}

	@Test
	public void testBackwardReplaceForCollectBoxOnOneSet() {
		testBackwardReplaceForCollectBox(IConstraints.ONE, IConstraints.SET);
	}

	public void testBackwardReplaceForCollectBox(IConstraints inputType, IConstraints innerType) {
		Sample sample1 = createSample(innerType, 1, 2);
		Sample sample2 = createSample(innerType, 2, 3);
		Sample sample3 = createSample(innerType, 3, 4);
		Sample[] samples = { sample1, sample2, sample3 };
		IBox<Sample> a = factory.createBox(inputType, samples);
		IBox<Integer> b = a.collectMutable(factory, sample1.getClass(), "box");
		b.set(0, 5);
		if (!b.isSingleton()) {
			b.set(1, 6);
		}
		assertEquals(b, a.collectMutable(factory, sample1.getClass(), "box"));
	}

	// Move backward

	@Test
	public void testBackwardMoveForCollectBoxOnSeqSet() {
		thrown.expect(IllegalStateException.class);
		testBackwardMoveForCollectBox(IConstraints.SEQUENCE, IConstraints.SET);
	}

	@Test
	public void testBackwardMoveForCollectBoxOnBagSet() {
		thrown.expect(IllegalStateException.class);
		testBackwardMoveForCollectBox(IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testBackwardMoveForCollectBoxOnOSetSet() {
		thrown.expect(IllegalStateException.class);
		testBackwardMoveForCollectBox(IConstraints.ORDERED_SET, IConstraints.SET);
	}

	@Test
	public void testBackwardMoveForCollectBoxOnSetSet() {
		thrown.expect(IllegalStateException.class);
		testBackwardMoveForCollectBox(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testBackwardMoveForCollectBoxOnOptSet() {
		testBackwardMoveForCollectBox(IConstraints.OPTION, IConstraints.SET);
	}

	@Test
	public void testBackwardMoveForCollectBoxOnOneSet() {
		testBackwardMoveForCollectBox(IConstraints.ONE, IConstraints.SET);
	}

	public void testBackwardMoveForCollectBox(IConstraints inputType, IConstraints innerType) {
		Sample sample1 = createSample(innerType, 1, 2);
		Sample sample2 = createSample(innerType, 2, 3);
		Sample sample3 = createSample(innerType, 3, 4);
		Sample sample4 = createSample(innerType, 4, 5);
		Sample[] samples = { sample1, sample2, sample3, sample4 };
		IBox<Sample> a = factory.createBox(inputType, samples);
		IBox<Integer> b = a.collectMutable(factory, sample1.getClass(), "box");
		b.move(0, 0);
		if (!b.isSingleton()) {
			b.move(0, 1);
			if (!b.isUnique()) {
				b.move(4, 2);
			}
		}
		assertEquals(b, a.collectMutable(factory, sample1.getClass(), "box"));
	}

	// Clear backward

	@Test
	public void testBackwardClearForCollectBoxOnSeqSet() {
		thrown.expect(IllegalStateException.class);
		testBackwardClearForCollectBox(IConstraints.SEQUENCE, IConstraints.SET);
	}

	@Test
	public void testBackwardClearForCollectBoxOnBagSet() {
		thrown.expect(IllegalStateException.class);
		testBackwardClearForCollectBox(IConstraints.BAG, IConstraints.SET);
	}

	@Test
	public void testBackwardClearForCollectBoxOnOSetSet() {
		thrown.expect(IllegalStateException.class);
		testBackwardClearForCollectBox(IConstraints.ORDERED_SET, IConstraints.SET);
	}

	@Test
	public void testBackwardClearForCollectBoxOnSetSet() {
		thrown.expect(IllegalStateException.class);
		testBackwardClearForCollectBox(IConstraints.SET, IConstraints.SET);
	}

	@Test
	public void testBackwardClearForCollectBoxOnOptSet() {
		testBackwardClearForCollectBox(IConstraints.OPTION, IConstraints.SET);
	}

	@Test
	public void testBackwardClearForCollectBoxOnOneSet() {
		testBackwardClearForCollectBox(IConstraints.ONE, IConstraints.SET);
	}

	public void testBackwardClearForCollectBox(IConstraints inputType, IConstraints innerType) {
		Sample sample1 = createSample(innerType, 1, 2);
		Sample sample2 = createSample(innerType, 2, 3);
		Sample sample3 = createSample(innerType, 3, 4);
		Sample sample4 = createSample(innerType, 4, 5);
		Sample[] samples = { sample1, sample2, sample3, sample4 };
		IBox<Sample> a = factory.createBox(inputType, samples);
		IBox<Integer> b = a.collectMutable(factory, sample1.getClass(), "box");
		b.clear();
		assertEquals(b, a.collectMutable(factory, sample1.getClass(), "box"));
	}

	// Integration test: CollectBox + SelectWithPresence

	public static IUnaryFunction<Integer, Boolean> isOdd = new IUnaryFunction<Integer, Boolean>() {
		@Override
		public Boolean apply(Integer i) {
			return i % 2 == 1;
		}
	};


	@Test
	public void testCollectBoxAndSelectOnOne() {
		testCollectBoxAndSelect(IConstraints.SEQUENCE, IConstraints.ONE);
	}

	public void testCollectBoxAndSelect(IConstraints inputType, IConstraints innerType) {
		Sample sample1 = createSample(innerType, 1, 2);
		Sample sample2 = createSample(innerType, 2, 3);
		Sample sample3 = createSample(innerType, 3, 3, 4);
		Sample[] samples = { sample1, sample2, sample2, sample3 };
		IBox<Sample> a = factory.createBox(inputType, samples);
		IBox<Integer> b = a.collectMutable(factory, sample1.getClass(), "box");
		IBox<Boolean> c = b.collect(isOdd);
		IBox<Sample> d = a.selectMutable(c);
		d.collectMutable(factory, sample1.getClass(), "box");
		sample3.getBox().add(0, 5);
		// throws a concurrent modification on observer list if getObservers() does not return a clone of the list
		// test succeeds if there is no thrown exception
	}

	@Test
	public void testCollectBoxAfterSelectOnSeqOne() {
		testCollectBoxAfterSelect(IConstraints.SEQUENCE, IConstraints.ONE);
	}

	@Test
	public void testCollectBoxAfterSelectOnSeqOpt() {
		testCollectBoxAfterSelect(IConstraints.SEQUENCE, IConstraints.OPTION);
	}

	@Test
	public void testCollectBoxAfterSelectOnSeqSeq() {
		testCollectBoxAfterSelect(IConstraints.SEQUENCE, IConstraints.SEQUENCE);
	}

	@Test
	public void testCollectBoxAfterSelectOnSetOne() {
		testCollectBoxAfterSelect(IConstraints.SET, IConstraints.ONE);
	}

	@Test
	public void testCollectBoxAfterSelectOnSetOpt() {
		testCollectBoxAfterSelect(IConstraints.SET, IConstraints.OPTION);
	}

	@Test
	public void testCollectBoxAfterSelectOnSetSeq() {
		testCollectBoxAfterSelect(IConstraints.SET, IConstraints.SEQUENCE);
	}

	public void testCollectBoxAfterSelect(IConstraints inputType, IConstraints innerType) {
		Sample sample1 = createSample(innerType, 2);
		Sample sample2 = createSample(innerType, 3);
		Sample sample3 = createSample(innerType, 4);
		Sample[] samples = { sample1, sample2, sample2, sample3 };
		IBox<Sample> a = factory.createBox(inputType, samples);
		IBox<Integer> b = a.collectMutable(factory, sample1.getClass(), "box");
		IBox<Boolean> c = b.collect(isOdd);
		IBox<Sample> d = a.selectMutable(c);
		IBox<Sample> e = d.collectMutable(factory, sample1.getClass(), "box");
		sample2.getBox().set(0, 6);
		// test succeeds if there is no thrown exception
	}



}
