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
package org.eclipse.papyrus.aof.core.tests.population;

import org.eclipse.papyrus.aof.core.AOFFactory;
import org.eclipse.papyrus.aof.core.IOne;
import org.eclipse.papyrus.aof.core.IOption;
import org.eclipse.papyrus.aof.core.IOrderedSet;
import org.eclipse.papyrus.aof.core.ISet;

public class Person {

	private IOne<String> name = AOFFactory.INSTANCE.createOne("Name");

	private IOption<Integer> age = AOFFactory.INSTANCE.createOption();

	private IOrderedSet<String> emails = AOFFactory.INSTANCE.createOrderedSet();

	private IOption<Person> parent = AOFFactory.INSTANCE.createOption();

	private ISet<Person> children = AOFFactory.INSTANCE.createSet();


	public IOne<String> getName() {
		return name;
	}

	public IOption<Integer> getAge() {
		return age;
	}

	public IOrderedSet<String> getEmails() {
		return emails;
	}

	public IOption<Person> getParent() {
		return parent;
	}

	public ISet<Person> getChildren() {
		return children;
	}

	@Override
	public String toString() {
		return name.get(0);
	}

}
