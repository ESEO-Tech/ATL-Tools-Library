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

import java.util.regex.Pattern
import org.eclipse.xtend.lib.annotations.AccessorsProcessor
import org.eclipse.xtend.lib.annotations.DataProcessor
import org.eclipse.xtend.lib.annotations.EqualsHashCodeProcessor
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructorProcessor
import org.eclipse.xtend.lib.annotations.ToStringConfiguration
import org.eclipse.xtend.lib.annotations.ToStringProcessor
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Modifier
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableConstructorDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder

// TODO:
//	- support collections
// DONE:
//	- hide boxes in toString?
@Active(AOFDataProcessor)
annotation AOFData {
	static class AOFDataProcessor extends AbstractClassProcessor {
		// copy-pasted from DataProcessor.java, should have been copied from DataProcessor.xtend
		override doTransform(MutableClassDeclaration it, extension TransformationContext context) {
		    extension val util = new DataProcessor.Util(context)
		    extension val getterUtil = new AccessorsProcessor.Util(context)
		    extension val ehUtil = new EqualsHashCodeProcessor.Util(context)
		    extension val toStringUtil = new ToStringProcessor.Util(context)
		    extension val requiredArgsUtil = new FinalFieldsConstructorProcessor.Util(context)
		    dataFields.forEach[it |
		        if ((primarySourceElement as FieldDeclaration).modifiers.contains(Modifier.VAR)) {
		          addError("Cannot use the \'var\' keyword on a data field")
		        }
		        setFinal(true)
//		        type.
//				type = "org.eclipse.papyrus.aof.core.IOne".findTypeGlobally.newTypeReference(type)
		    ]
		    if ((needsFinalFieldConstructor || (findAnnotation(FinalFieldsConstructor.findTypeGlobally) != null))) {
		      addFinalFieldsConstructor(requiredArgsUtil, context)
		    }
		    if (!hasHashCode) {
		      addHashCode(dataFields, hasSuperHashCode);
		    }
		    if (!hasEquals) {
		      addEquals(dataFields, hasSuperEquals)
		    }
		    if (!hasToString) {
		      if (superConstructor === null) {
/*
		        addToString(dataFields, toStringConfig ?: new ToStringConfiguration)
/*/				// specific variant of addToString that handles singleLine parameter
		      	val config = toStringConfig ?: new ToStringConfiguration
		      	val sl = findAnnotation(AOFData.findTypeGlobally).getBooleanValue("singleLine")
		      	val cls = it
				addMethod("toString") [
					primarySourceElement = cls.primarySourceElement
					returnType = string
					addAnnotation(newAnnotationReference(Override))
					addAnnotation(newAnnotationReference(Pure))
					body = '''
						«ToStringBuilder» b = new «ToStringBuilder»(this);
						«IF config.skipNulls»b.skipNulls();«ENDIF»
						«IF config.singleLine||sl»b.singleLine();«ENDIF»
						«IF config.hideFieldNames»b.hideFieldNames();«ENDIF»
						«IF config.verbatimValues»b.verbatimValues();«ENDIF»
						«FOR field : cls.dataFields»
							b.add("«field.simpleName»", this.«field.simpleName»«IF field.type.isBox(context)».get()«ENDIF»);
						«ENDFOR»
						return b.toString();
					'''
				]
/**/
		      } else {
		        addReflectiveToString(toStringConfig ?: new ToStringConfiguration)
		      }
		    }
		    dataFields.forEach[it |
		        if (shouldAddGetter) {
		          addGetter(getterType?.toVisibility ?: Visibility.PUBLIC)
		        }
		    ]
		}

		def isBox(TypeReference it, extension TransformationContext context) {
			"org.eclipse.papyrus.aof.core.ISingleton".findTypeGlobally.isAssignableFrom(type)
		}

		def addFinalFieldsConstructor(MutableClassDeclaration it, extension FinalFieldsConstructorProcessor.Util requiredArgsUtil, extension TransformationContext context) {
			if (finalFieldsConstructorArgumentTypes.empty) {
				val anno = findAnnotation(FinalFieldsConstructor.findTypeGlobally)
				anno.addWarning('''There are no final fields, this annotation has no effect''')
				return
			}
			if (hasFinalFieldsConstructor) {
				addError(constructorAlreadyExistsMessage)
				return
			}
			addConstructor [
				primarySourceElement = declaringType.primarySourceElement
				makeFinalFieldsConstructor(requiredArgsUtil, context)
			]
		}

		static val EMPTY_BODY = Pattern.compile("(\\{(\\s*\\})?)?")

		def makeFinalFieldsConstructor(MutableConstructorDeclaration it, extension FinalFieldsConstructorProcessor.Util requiredArgsUtil, extension TransformationContext context) {
			if (declaringType.finalFieldsConstructorArgumentTypes.empty) {
				val anno = findAnnotation(FinalFieldsConstructor.findTypeGlobally)
				anno.addWarning('''There are no final fields, this annotation has no effect''')
				return
			}
			if (declaringType.hasFinalFieldsConstructor) {
				addError(declaringType.constructorAlreadyExistsMessage)
				return
			}
			if (!parameters.empty) {
				addError("Parameter list must be empty")
			}
			if (body !== null && !EMPTY_BODY.matcher(body.toString).matches) {
				addError("Body must be empty")
			}
			val superParameters = declaringType.superConstructor?.resolvedParameters ?: #[]
			superParameters.forEach [ p |
				addParameter(p.declaration.simpleName, p.resolvedType)
			]
			val fieldToParameter = newHashMap
			declaringType.finalFields.forEach [ p |
				p.markAsInitializedBy(it)
				val param = addParameter(p.simpleName, if(p.type.isBox(context)) p.type.actualTypeArguments.get(0) else p.type ?: object)
				fieldToParameter.put(p, param)
			]
			body = '''
				super(«superParameters.join(", ")[declaration.simpleName]»);
				«FOR arg : declaringType.finalFields»
					«IF arg.type.isBox(context)»
						this.«arg.simpleName» = org.eclipse.papyrus.aof.core.AOFFactory.INSTANCE.create«arg.type.type.simpleName.substring(1)»(«fieldToParameter.get(arg).simpleName»);
					«ELSE»
						this.«arg.simpleName» = «fieldToParameter.get(arg).simpleName»;
					«ENDIF»
				«ENDFOR»
			'''
		}
	}
	val singleLine = false
}