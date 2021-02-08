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

import java.util.ArrayList;
import java.util.List;

import org.eclipse.papyrus.aof.core.tests.BaseTest;

public abstract class CollectBoxTest extends BaseTest {

	// ==================================
	// = Tests on population meta-model =
	// ==================================

	// Utilities

	protected List<String> createNames(int number, String namePrefix) {
		List<String> names = new ArrayList<String>();
		for (int i = 1; i <= number; i++) {
			names.add(namePrefix + i);
		}
		return names;
	}

}
