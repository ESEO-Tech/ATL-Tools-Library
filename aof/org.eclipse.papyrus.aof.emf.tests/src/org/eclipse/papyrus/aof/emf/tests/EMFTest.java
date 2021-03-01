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

import org.eclipse.papyrus.aof.emf.tests.population.PopulationFactory;
import org.eclipse.papyrus.aof.emf.tests.population.PopulationPackage;

public interface EMFTest {

	static PopulationFactory efactory = PopulationFactory.eINSTANCE;
	static PopulationPackage epackage = PopulationPackage.eINSTANCE;

}
