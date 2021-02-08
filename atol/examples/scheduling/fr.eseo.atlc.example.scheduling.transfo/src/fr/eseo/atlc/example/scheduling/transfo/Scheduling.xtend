/****************************************************************
 *  Copyright (C) 2020 ESEO, Université d'Angers 
 *
 *  This program and the accompanying materials are made
 *  available under the terms of the Eclipse Public License 2.0
 *  which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 *  Contributors:
 *    - Frédéric Jouault
 *    - Théo Le Calvar
 *
 *  version 1.0
 *
 *  SPDX-License-Identifier: EPL-2.0
 ****************************************************************/

package fr.eseo.atlc.example.scheduling.transfo

import fr.eseo.aof.xtend.utils.AOFAccessors
import fr.eseo.atlc.example.scheduling.SchedulingPackage

import static fr.eseo.atol.gen.MetamodelUtils.*
import fr.eseo.atlc.example.scheduling.Period

@AOFAccessors(SchedulingPackage)
class Scheduling {
	public val __load = <Period, Float>oneDefault(0.0f)[
		_load
	]
}