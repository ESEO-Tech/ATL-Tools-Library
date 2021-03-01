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
package org.eclipse.papyrus.aof.emf.tests;

import java.util.Arrays;
import java.util.List;

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.eclipse.papyrus.aof.core.IFactory;
import org.eclipse.papyrus.aof.core.IMetaClass;
import org.eclipse.papyrus.aof.core.tests.operation.CollectBoxTest;
import org.eclipse.papyrus.aof.emf.EMFFactory;
import org.eclipse.papyrus.aof.emf.tests.population.Person;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class EMFCollectBoxTest extends CollectBoxTest implements EMFTest {


	@Override
	protected IFactory createFactory() {
		IFactory factory = new EMFFactory();
		Person = factory.getMetaClass(epackage.getPerson());
		return factory;
	}

	// ==================================
	// = Tests on population meta-model =
	// ==================================

	// Utilities

	private IMetaClass<Person> Person;

	private Person createPerson(String name) {
		Person person = efactory.createPerson();
		person.setName(name);
		person.getEmails().add(name.toLowerCase() + "@hip.com");
		person.getEmails().add(name.toLowerCase() + "@hop.fr");
		return person;
	}

	private Person createPerson(String parentName, List<String> childNames) {
		Person person = createPerson(parentName);
		for (String childName : childNames) {
			Person child = createPerson(childName);
			person.getChildren().add(child);
		}
		return person;
	}


	// Create

	@Test
	public void testCreateForCollectChildNames() {
		List<String> childNames = createNames(3, "Child");
		Person parent = createPerson("Parent", childNames);
		IBox<Person> children = factory.createPropertyBox(parent, "children");
		IBox<String> parentChildNames = children.collectMutable(Person, "name");
		// IBox<String> parentChildNames = children.collectMutable(factory, epackage.getPerson(), "name");
		assertEquals(IConstraints.SEQUENCE, parentChildNames.getConstraints());
		assertEquals(childNames, parentChildNames);
	}

	@Test
	public void testCreateForCollectChildEmails() {
		List<String> childNames = createNames(2, "Child");
		Person parent = createPerson("Parent", childNames);
		IBox<Person> children = factory.createPropertyBox(parent, "children");
		IBox<String> childEmails = children.collectMutable(Person, "emails");
		// IBox<String> childEmails = children.collectMutable(Person, "emails");
		assertEquals(IConstraints.SEQUENCE, childEmails.getConstraints());
		assertEquals(Arrays.asList("child1@hip.com", "child1@hop.fr", "child2@hip.com", "child2@hop.fr"), childEmails);
	}

	@Test
	public void testCreateForCollectParentEmails() {
		Person parent = createPerson("Parent", createNames(1, "Child"));
		Person child = parent.getChildren().get(0);
		IBox<Person> parentProperty = factory.createPropertyBox(child, "parent");
		IBox<String> parentEmails = parentProperty.collectMutable(Person, "emails");
		assertEquals(IConstraints.ORDERED_SET, parentEmails.getConstraints());
		assertEquals(Arrays.asList("parent@hip.com", "parent@hop.fr"), parentEmails);
	}

	// Add

	@Test
	public void testAddForCollectChildNames() {
		List<String> childNames = createNames(3, "Child");
		Person parent = createPerson("Parent", childNames);
		IBox<Person> children = factory.createPropertyBox(parent, "children");
		IBox<String> parentChildNames = children.collectMutable(Person, "name");
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
		IBox<Person> children = factory.createPropertyBox(parent, "children");
		IBox<String> parentChildNames = children.collectMutable(Person, "name");
		parent.getChildren().remove(1);
		childNames.remove(1);
		assertEquals(childNames, parentChildNames);
	}

	// Replace

	@Test
	public void testReplaceForCollectChildNames() {
		List<String> childNames = createNames(3, "Child");
		Person parent = createPerson("Parent", childNames);
		IBox<Person> children = factory.createPropertyBox(parent, "children");
		IBox<String> parentChildNames = children.collectMutable(Person, "name");
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
		IBox<Person> children = factory.createPropertyBox(parent, "children");
		IBox<String> parentChildNames = children.collectMutable(Person, "name");
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
		IBox<Person> children = factory.createPropertyBox(parent, "children");
		IBox<String> parentChildNames = children.collectMutable(Person, "name");
		parent.getChildren().clear();
		childNames.clear();
		assertEquals(childNames, parentChildNames);
	}

	// Inner add

	@Test
	public void testInnerAddCollectChildEmails() {
		Person parent = createPerson("Parent", createNames(2, "Child"));
		IBox<Person> children = factory.createPropertyBox(parent, "children");
		IBox<String> childEmails = children.collectMutable(Person, "emails");
		parent.getChildren().get(0).getEmails().add(1, "child1@new.fr");
		assertEquals(Arrays.asList("child1@hip.com", "child1@new.fr", "child1@hop.fr", "child2@hip.com", "child2@hop.fr"), childEmails);
	}


	// Inner remove

	@Test
	public void testInnerRemoveForCollectChildEmails() {
		Person parent = createPerson("Parent", createNames(2, "Child"));
		IBox<Person> children = factory.createPropertyBox(parent, "children");
		IBox<String> childEmails = children.collectMutable(Person, "emails");
		parent.getChildren().get(1).getEmails().remove(0);
		assertEquals(Arrays.asList("child1@hip.com", "child1@hop.fr", "child2@hop.fr"), childEmails);
	}

	// Inner replace

	@Test
	public void testInnerReplaceForCollectChildEmails() {
		Person parent = createPerson("Parent", createNames(2, "Child"));
		IBox<Person> children = factory.createPropertyBox(parent, "children");
		IBox<String> childEmails = children.collectMutable(Person, "emails");
		parent.getChildren().get(1).getEmails().set(0, "child2@new.fr");
		assertEquals(Arrays.asList("child1@hip.com", "child1@hop.fr", "child2@new.fr", "child2@hop.fr"), childEmails);
	}

	// Inner move

	@Test
	public void testInnerMoveForCollectChildEmails() {
		Person parent = createPerson("Parent", createNames(2, "Child"));
		IBox<Person> children = factory.createPropertyBox(parent, "children");
		IBox<String> childEmails = children.collectMutable(Person, "emails");
		parent.getChildren().get(0).getEmails().move(0, 1);
		assertEquals(Arrays.asList("child1@hop.fr", "child1@hip.com", "child2@hip.com", "child2@hop.fr"), childEmails);
	}

	// Inner clear

	// @Test
	// public void testInnerClearForCollectChildNames() {
	// Person parent = createPerson("Parent", createNames(3, "Child"));
	// IBox<Person> children = factory.createPropertyBox(parent, "children");
	// IBox<String> childNames = children.collect(factory, epackage.getPerson(), "name");
	// parent.getChildren().get(1)..getName().clear();
	// assertEquals(Arrays.asList("Child1", "Name", "Child3"), childNames);
	// }


	@Test
	public void testInnerClearForCollectChildEmails() {
		Person parent = createPerson("Parent", createNames(2, "Child"));
		IBox<Person> children = factory.createPropertyBox(parent, "children");
		IBox<String> childEmails = children.collectMutable(Person, "emails");
		parent.getChildren().get(0).getEmails().clear();
		assertEquals(IConstraints.SEQUENCE, childEmails.getConstraints());
		assertEquals(Arrays.asList("child2@hip.com", "child2@hop.fr"), childEmails);
	}


	// Add backward

	@Test
	public void testAddBackwardForCollectParentEmails() {
		Person parent = createPerson("Parent", createNames(1, "Child"));
		Person child = parent.getChildren().get(0);
		IBox<Person> parentProperty = factory.createPropertyBox(child, "parent");
		IBox<String> parentEmails = parentProperty.collectMutable(Person, "emails");
		parentEmails.add(0, "parent@new.fr");
		IBox<String> actualParentEmails = parentProperty.collectMutable(Person, "emails");
		assertEquals(parentEmails, actualParentEmails);
	}

	// Remove backward

	@Test
	public void testRemoveBackwardForCollectParentEmails() {
		Person parent = createPerson("Parent", createNames(1, "Child"));
		Person child = parent.getChildren().get(0);
		IBox<Person> parentProperty = factory.createPropertyBox(child, "parent");
		IBox<String> parentEmails = parentProperty.collectMutable(Person, "emails");
		parentEmails.removeAt(0);
		IBox<String> actualParentEmails = parentProperty.collectMutable(Person, "emails");
		assertEquals(parentEmails, actualParentEmails);
	}

	// Replace backward

	@Test
	public void testReplaceBackwardForCollectParentEmails() {
		Person parent = createPerson("Parent", createNames(1, "Child"));
		Person child = parent.getChildren().get(0);
		IBox<Person> parentProperty = factory.createPropertyBox(child, "parent"); // = child.parent
		IBox<String> parentEmails = parentProperty.collectMutable(Person, "emails"); // = child.parent.emails
		parentEmails.set(1, "parent@new.fr");
		IBox<String> actualParentEmails = parentProperty.collectMutable(Person, "emails");
		assertEquals(parentEmails, actualParentEmails);
	}

	// Move backward

	@Test
	public void testMoveBackwardForCollectParentEmails() {
		Person parent = createPerson("Parent", createNames(1, "Child"));
		Person child = parent.getChildren().get(0);
		IBox<Person> parentProperty = factory.createPropertyBox(child, "parent");
		IBox<String> parentEmails = parentProperty.collectMutable(Person, "emails");
		parentEmails.move(1, 0);
		IBox<String> actualParentEmails = parentProperty.collectMutable(Person, "emails");
		assertEquals(parentEmails, actualParentEmails);
	}

	// Clear backward

	@Test
	public void testClearBackwardForCollectParentEmails() {
		Person parent = createPerson("Parent", createNames(1, "Child"));
		Person child = parent.getChildren().get(0);
		IBox<Person> parentProperty = factory.createPropertyBox(child, "parent");
		IBox<String> parentEmails = parentProperty.collectMutable(Person, "emails");
		parentEmails.clear();
		IBox<String> actualParentEmails = parentProperty.collectMutable(Person, "emails");
		assertEquals(parentEmails, actualParentEmails);
	}

}
