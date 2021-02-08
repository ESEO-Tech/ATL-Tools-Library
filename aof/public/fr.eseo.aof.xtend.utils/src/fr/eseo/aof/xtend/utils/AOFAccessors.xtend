/****************************************************************
 *  Copyright (C) 2020 ESEO
 *
 *  This program and the accompanying materials are made
 *  available under the terms of the Eclipse Public License 2.0
 *  which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 *  Contributors:
 *    - Frédéric Jouault
 *
 *  version 1.0
 *
 *  SPDX-License-Identifier: EPL-2.0
 ****************************************************************/

package fr.eseo.aof.xtend.utils

import java.util.HashMap
import java.util.Map
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.AbstractFieldProcessor

@Active(AOFAccessorsProcessor)
annotation AOFAccessors {
	Class<? extends EPackage>[] value

	@Active(FieldAOFAccessorsProcessor)
	annotation Field {}

	interface Utils {
		val factory = "org.eclipse.papyrus.aof.emf.EMFFactory.INSTANCE"

		def extend(MutableClassDeclaration cls, String ePackageName, extension TransformationContext context, Map<String, Integer> alreadyProcessed) {
			val iBoxType = "org.eclipse.papyrus.aof.core.IBox".findTypeGlobally
			val ePackage = Class.forName(ePackageName).getField("eINSTANCE").get(null) as EPackage

			ePackage.EClassifiers.filter(EClass)
				.forEach[c |
					val cType = c.instanceClass.findTypeGlobally.newTypeReference
					cls.addField('''«c.name»''')[
						primarySourceElement = cls.primarySourceElement
						static = true
						visibility = Visibility.PUBLIC
						type = "org.eclipse.papyrus.aof.core.IMetaClass".findTypeGlobally.newTypeReference(cType)
						initializer = '''
							«factory».getMetaClass(«ePackageName».eINSTANCE.get«c.name.escape»())
						'''
					]
					c.EStructuralFeatures
						.filter[!derived]
						.forEach[f |
							val n = alreadyProcessed.get(f.name) ?: 0
							alreadyProcessed.put(f.name, n + 1)
							val suffix = if(n == 0) {""} else {n}
	
							val retType = iBoxType.newTypeReference(f.EType.instanceClass.findTypeGlobally.newTypeReference)
							cls.addMethod('''_«f.name»''')[
								primarySourceElement = cls.primarySourceElement
								addParameter("o", cType)
								returnType = retType
								body = '''
									return «factory».createPropertyBox(o, «ePackageName».eINSTANCE.get«c.name»_«f.name.toFirstUpper»());
								'''
							]
							cls.addMethod('''«f.name»«suffix»''')[
								primarySourceElement = cls.primarySourceElement
								addParameter("b", iBoxType.newTypeReference(cType.newWildcardTypeReference))
								returnType = retType
								body = '''
									return b.collectMutable(«factory», «ePackageName».eINSTANCE.get«c.name»(), «ePackageName».eINSTANCE.get«c.name»_«f.name.toFirstUpper»());
								'''
							]
						]
				]
		}

		static val toEscape = #{"Class"}
		def static escape(String s) {
			if(toEscape.contains(s)) {
				'''«s»_'''
			} else {
				s
			}
		}
	}

	static class AOFAccessorsProcessor extends AbstractClassProcessor implements Utils {
		override doTransform(MutableClassDeclaration it, extension TransformationContext context) {
			val cls = it

			findAnnotation(AOFAccessors.findTypeGlobally)
				.getClassArrayValue("value")
				.forEach[ePackage |
					cls.extend(
						ePackage.name,
						context,
						new HashMap
					)
				]
		}
	}

	static class FieldAOFAccessorsProcessor extends AbstractFieldProcessor implements Utils {
		override doTransform(MutableFieldDeclaration it, extension TransformationContext context) {
			val cls = it.declaringType as MutableClassDeclaration
			cls.extend(
				type.name,
				context,
				new HashMap
			)
		}
	}
}