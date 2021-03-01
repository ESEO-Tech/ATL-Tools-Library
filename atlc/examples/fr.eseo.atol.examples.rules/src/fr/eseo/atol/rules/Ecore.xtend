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

package fr.eseo.atol.rules

import fr.eseo.aof.xtend.utils.AOFAccessors
import org.eclipse.emf.ecore.EEnumLiteral
import org.eclipse.emf.ecore.EcorePackage

import static fr.eseo.atol.gen.MetamodelUtils.*

@AOFAccessors(EcorePackage)
class Ecore {

	public val __abstract = boolOneDefault[_abstract]

	public val __ordered = boolOneDefault[_ordered]

	public val __changeable = boolOneDefault[_changeable]

	public val __derived = boolOneDefault[_derived]

	public val __unique = boolOneDefault[_unique]

	public val __containment = boolOneDefault[_containment]

	public val __volatile = boolOneDefault[_volatile]

	public val __transient = boolOneDefault[_transient]

	public val __lowerBound = oneDefault(0)[_lowerBound]

	public val __upperBound = oneDefault(0)[_upperBound]

	public val __value = oneDefault(0)[
		switch it {
			EEnumLiteral: _value
			default: throw new UnsupportedOperationException
		}
	]
}