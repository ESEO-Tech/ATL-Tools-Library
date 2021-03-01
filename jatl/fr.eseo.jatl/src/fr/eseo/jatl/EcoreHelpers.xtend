/****************************************************************
 *  Copyright (C) 2021 ESEO, Université d'Angers 
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
 
 package fr.eseo.jatl

import com.google.common.collect.ArrayListMultimap
import java.util.ArrayList
import java.util.Collection
import java.util.Map
import java.util.stream.Collectors
import javax.annotation.Generated
import org.eclipse.emf.common.util.EMap
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend2.lib.StringConcatenationClient

@Active(EcoreHelpersProcessor)
annotation EcoreHelpers {
	Class<? extends EPackage>[] packages = #[]
	boolean atolCompatibility = false

	static class EcoreHelpersProcessor extends AbstractClassProcessor {
		override doTransform(MutableClassDeclaration it, extension TransformationContext context) {
			val ann = findAnnotation(EcoreHelpers.findTypeGlobally)
			val packages = ann
						.getClassArrayValue("packages")
			val atolCompatibility = ann.getBooleanValue("atolCompatibility")
			val seenFeatures = ArrayListMultimap.create
			for(package : packages) {
				val ePackage = Class.forName(package.name).getField("eINSTANCE").get(null) as EPackage
				for(eClass : ePackage.EClassifiers.filter(EClass).filter[instanceClass != Map.Entry]) {
					for(esf : eClass.EStructuralFeatures) {
						addMethod(esf, esf.name, context, false)

						if(atolCompatibility) {
							// not necessary for ATL2Java, but here for compatibility with AOFAccessors used in ATOL transformations
							if(seenFeatures.containsKey(esf.name)) {
								//addMethod(esf, esf.name + seenFeatures.get(esf.name).size, context, false)
								if(esf.withImplicitCollect) {
									addMethod(esf, esf.name + seenFeatures.get(esf.name).size, context, true)
								}
							} else if(esf.withImplicitCollect) {
								addMethod(esf, esf.name, context, true)
							}
							seenFeatures.put(esf.name, esf)
						}
					}
				}
			}
		}

		def withImplicitCollect(EStructuralFeature it) {
			!isMap && name != "first"
		}

		def isMap(EStructuralFeature it) {
			EType.instanceClass == Map.Entry
		}

		def addMethod(MutableClassDeclaration it, EStructuralFeature esf, String name, extension TransformationContext context, boolean implicitCollect) {
			addMethod(name)[
				val type = esf.EContainingClass.instanceClass.newTypeReference
				addParameter("it",
					if(implicitCollect) {
						Collection.newTypeReference(type.newWildcardTypeReference)
					} else {
						type
					}
				)
				returnType = esf.EType.instanceClass.newTypeReference
				val retType = if(esf.isMany) {
					if(esf.isMap) {
						EMap.newTypeReference
					} else {
						Collection.newTypeReference(returnType)
					}
				} else {
					returnType
				}
				if(esf.isMany || implicitCollect) {
					if(esf.isMap) {
						returnType = EMap.newTypeReference
					} else {
						returnType = Collection.newTypeReference(returnType)
					}
				}
				addAnnotation(Generated.newAnnotationReference[
					set("value", "EcoreHelpers")
				])
				val bodyExp =
					if(false) {
						[simpleBodyExp(esf)]
					} else {
						[refBodyExp(esf, retType)]
					}
				if(implicitCollect) {
					body = '''return it.stream().«
						if(esf.isMany) {
							"flatMap"
						} else {
							"map"
						}
					»(e -> («bodyExp.apply("e")»)«
						if(esf.isMany) {
							".stream()"
						} else {
							""
						}
					»).collect(«Collectors».toCollection(«ArrayList»::new));'''
				} else {
					body = '''return «bodyExp.apply("it")»;'''
				}
			]
		}

		def StringConcatenationClient simpleBodyExp(String it, EStructuralFeature esf) {
			// this simplified translation of feature names to method names does not work with all metamodels (e.g., UML)
			val verb = if(esf.EType.name == "Boolean" || esf.EType.name == "EBoolean") "is" else "get"
			'''«it».«verb»«esf.name.substring(0, 1).toUpperCase + esf.name.substring(1)»()'''
		}

		def StringConcatenationClient refBodyExp(String it, EStructuralFeature esf, TypeReference retType) {
			val ecn =	esf.EContainingClass.name + if(esf.EContainingClass.name == "Class") {
							"_"
						} else {
							""
						}
			'''(«retType»)«it».eGet(«esf.EContainingClass.EPackage.class».eINSTANCE.get«ecn»().getEStructuralFeature("«esf.name»"))'''
		}
	}
}