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
package org.eclipse.papyrus.aof.emf.tests;

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.eclipse.papyrus.aof.core.IFactory;
import org.eclipse.papyrus.aof.core.tests.FactoryTest;
import org.eclipse.papyrus.aof.emf.EMFFactory;
import org.eclipse.papyrus.aof.emf.tests.population.Person;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class EMFFactoryTest extends FactoryTest implements EMFTest {

	@Override
	protected IFactory createFactory() {
		return new EMFFactory();
	}

	// Meta-class access

	@Test
	public void testFactoryForGetMetaClassOnJavaPerson() {
		testFactoryForGetMetaClass(Person.class);
	}

	@Test
	public void testFactoryForGetMetaClassOnEcorePerson() {
		testFactoryForGetMetaClass(epackage.getPerson());
	}

	// Property box

	@Test
	public void testCreatePropertyBoxOnPersonNameProperty() {
		Person person = efactory.createPerson();
		IBox<Integer> box = factory.createPropertyBox(person, "name");
		person.setName("John");
		assertEquals(IConstraints.ONE, box.getConstraints());
		assertEquals(person.getName(), box.get(0));
	}

	// Note that boxes representing EMF singleton properties are always one boxes.
	// They contain value null which is equivalent, in the EMF sense, to an AOF empty option box.
	@Test
	public void testCreatePropertyBoxOnPersonParentProperty() {
		Person parent = efactory.createPerson();
		Person person = efactory.createPerson();
		IBox<Integer> box = factory.createPropertyBox(person, "parent");
		person.setName("John");
		person.setParent(parent);
		parent.setName("Jack");
		assertEquals(IConstraints.ONE, box.getConstraints());
		assertEquals(person.getParent(), box.get(0));
	}

	@Test
	public void testCreatePropertyBoxOnPersonChildrenProperty() {
		Person parent = efactory.createPerson();
		Person person = efactory.createPerson();
		IBox<Integer> box = factory.createPropertyBox(person, "children");
		parent.getChildren().add(person);
		person.setName("John");
		parent.setName("Jack");
		assertEquals(IConstraints.ORDERED_SET, box.getConstraints());
		assertEquals(person.getChildren(), box);
	}

}
