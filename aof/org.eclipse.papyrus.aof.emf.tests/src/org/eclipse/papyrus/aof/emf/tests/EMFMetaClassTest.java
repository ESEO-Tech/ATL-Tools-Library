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

import org.eclipse.papyrus.aof.core.IFactory;
import org.eclipse.papyrus.aof.core.tests.MetaClassTest;
import org.eclipse.papyrus.aof.emf.EMFFactory;
import org.eclipse.papyrus.aof.emf.tests.population.Person;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class EMFMetaClassTest extends MetaClassTest implements EMFTest {

	@Override
	protected IFactory createFactory() {
		return new EMFFactory();
	}

	// Is instance of

	@Test
	public void testBaseIsInstanceOfJavaPerson() {
		testIsInstanceOfMetaClass(efactory.createPerson(), Person.class, true);
	}

	@Test
	public void testBaseIsInstanceOfEcorePerson() {
		testIsInstanceOfMetaClass(efactory.createPerson(), epackage.getPerson(), true);
	}

	// Get default instance

	@Test
	public void testGetDefaultInstanceOfInvalidClass() {
		thrown.expect(IllegalStateException.class);
		testGetDefaultInstanceOfMetaClass(Person.class);
	}

	@Test
	public void testGetDefaultInstanceOfPerson() {
		testGetDefaultInstanceOfMetaClass(epackage.getPerson());
	}

	// Set default instance

	@Test
	public void testSetDefaultInstanceOfPerson() {
		testSetDefaultInstanceOfMetaClass(epackage.getPerson(), efactory.createPerson());
	}

	// Property accessor

	@Test
	public void testGetPropertyAccessorForInvalidPropertyType() {
		thrown.expect(IllegalArgumentException.class);
		testGetPropertyAccessorOfMetaClass(Person.class, new Object(), null);
	}

	@Test
	public void testGetPropertyAccessorForPersonNameProperty() {
		testGetPropertyAccessorOfMetaClass(epackage.getPerson(), "name", efactory.createPerson(), "Name");
	}

	@Test
	public void testGetPropertyAccessorForPersonAgeProperty() {
		testGetPropertyAccessorOfMetaClass(epackage.getPerson(), "age", efactory.createPerson(), 0);
	}

	@Test
	public void testGetPropertyAccessorForPersonParentProperty() {
		testGetPropertyAccessorOfMetaClass(epackage.getPerson(), "parent", efactory.createPerson(), (Person) null);
	}

	@Test
	public void testGetPropertyAccessorForPersonChildrenProperty() {
		testGetPropertyAccessorOfMetaClass(epackage.getPerson(), "children", efactory.createPerson());
	}

}
