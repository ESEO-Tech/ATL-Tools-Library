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
import org.eclipse.uml2.uml.AggregationKind
import org.eclipse.uml2.uml.Classifier
import org.eclipse.uml2.uml.LiteralInteger
import org.eclipse.uml2.uml.LiteralSpecification
import org.eclipse.uml2.uml.LiteralUnlimitedNatural
import org.eclipse.uml2.uml.MultiplicityElement
import org.eclipse.uml2.uml.NamedElement
import org.eclipse.uml2.uml.ParameterDirectionKind
import org.eclipse.uml2.uml.Property
import org.eclipse.uml2.uml.StructuralFeature
import org.eclipse.uml2.uml.UMLPackage
import org.eclipse.uml2.uml.VisibilityKind

import static fr.eseo.atol.gen.MetamodelUtils.*

@AOFAccessors(UMLPackage)
class UML {

	public val __visibility = <NamedElement, VisibilityKind>enumConverterBuilder(
		[_visibility], VisibilityKind
	)

	public val __direction = enumConverterBuilder(
		[_direction], ParameterDirectionKind
	)

	public val __aggregation = enumConverterBuilder(
		[_aggregation], AggregationKind
	)

	public val __isAbstract = <Classifier>boolOneDefault[_isAbstract]

	public val __isReadOnly = <StructuralFeature>boolOneDefault[_isReadOnly]

	public val __isDerived = <Property>boolOneDefault[_isDerived]

	public val __isOrdered = <MultiplicityElement>boolOneDefault[_isOrdered]

	public val __isUnique = boolOneDefault[_isUnique]

	public val __value = <LiteralSpecification, Integer>oneDefault(0)[
		switch it {
			LiteralInteger: _value
			LiteralUnlimitedNatural: _value
			default: throw new UnsupportedOperationException
		}
	]
}
