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

import com.google.common.collect.ImmutableList
import com.google.common.collect.ImmutableMap
import com.google.common.collect.ImmutableSet
import com.google.common.collect.Multiset
import java.util.Collection
import java.util.HashMap
import java.util.List
import java.util.Map
import java.util.Set
import java.util.stream.Collectors
import org.eclipse.m2m.atl.common.ATL.InPatternElement
import org.eclipse.m2m.atl.common.ATL.MatchedRule
import org.eclipse.m2m.atl.common.ATL.OutPatternElement
import org.eclipse.m2m.atl.common.OCL.BagExp
import org.eclipse.m2m.atl.common.OCL.BagType
import org.eclipse.m2m.atl.common.OCL.BooleanExp
import org.eclipse.m2m.atl.common.OCL.BooleanType
import org.eclipse.m2m.atl.common.OCL.CollectionType
import org.eclipse.m2m.atl.common.OCL.EnumLiteralExp
import org.eclipse.m2m.atl.common.OCL.IfExp
import org.eclipse.m2m.atl.common.OCL.IntegerExp
import org.eclipse.m2m.atl.common.OCL.IntegerType
import org.eclipse.m2m.atl.common.OCL.IterateExp
import org.eclipse.m2m.atl.common.OCL.IteratorExp
import org.eclipse.m2m.atl.common.OCL.LetExp
import org.eclipse.m2m.atl.common.OCL.MapExp
import org.eclipse.m2m.atl.common.OCL.MapType
import org.eclipse.m2m.atl.common.OCL.NavigationOrAttributeCallExp
import org.eclipse.m2m.atl.common.OCL.OclAnyType
import org.eclipse.m2m.atl.common.OCL.OclExpression
import org.eclipse.m2m.atl.common.OCL.OclModelElement
import org.eclipse.m2m.atl.common.OCL.OclType
import org.eclipse.m2m.atl.common.OCL.OclUndefinedExp
import org.eclipse.m2m.atl.common.OCL.OperationCallExp
import org.eclipse.m2m.atl.common.OCL.OperatorCallExp
import org.eclipse.m2m.atl.common.OCL.OrderedSetExp
import org.eclipse.m2m.atl.common.OCL.OrderedSetType
import org.eclipse.m2m.atl.common.OCL.RealType
import org.eclipse.m2m.atl.common.OCL.SequenceExp
import org.eclipse.m2m.atl.common.OCL.SequenceType
import org.eclipse.m2m.atl.common.OCL.SetExp
import org.eclipse.m2m.atl.common.OCL.SetType
import org.eclipse.m2m.atl.common.OCL.StringExp
import org.eclipse.m2m.atl.common.OCL.StringType
import org.eclipse.m2m.atl.common.OCL.TupleExp
import org.eclipse.m2m.atl.common.OCL.TupleType
import org.eclipse.m2m.atl.common.OCL.VariableDeclaration
import org.eclipse.m2m.atl.common.OCL.VariableExp
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend2.lib.StringConcatenationClient

@FinalFieldsConstructor
class OCL2Java extends CompilationHelpers {
	dispatch def TypeReference convert_(OclType it, (String)=>TypeReference typeParameters) {
		if(class == OclType) {
			Class.newTypeReference
		} else {
			throw new UnsupportedOperationException('''Cannot convert «it»''')
		}
	}

	dispatch def TypeReference convert_(OclAnyType it, (String)=>TypeReference typeParameters) {
		Object.newTypeReference
	}
	
	dispatch def TypeReference convert_(BooleanType it, (String)=>TypeReference typeParameters) {
		Boolean.newTypeReference
	}

	dispatch def TypeReference convert_(RealType it, (String)=>TypeReference typeParameters) {
		Double.newTypeReference
	}

	dispatch def TypeReference convert_(IntegerType it, (String)=>TypeReference typeParameters) {
		Integer.newTypeReference
	}

	dispatch def TypeReference convert_(TupleType it, (String)=>TypeReference typeParameters) {
		Object.newTypeReference
		//tupleClasses.get(ATOLGenProcessor.toCanonic(it)).key.findClass.newTypeReference
	}

	def eClassifier(OclModelElement it) {
		packages.get(model.name)?.map[p | p.getEClassifier(name)]?.findFirst[it !== null]
	}

	dispatch def TypeReference convert_(OclModelElement it, (String)=>TypeReference typeParameters) {
		if(model.name == "TP") {
			return typeParameters.apply(name)
		}
		val eClassifier = eClassifier
		if(eClassifier === null) {
			if(model.name != "INFER") {
				val msg = "Could not find: " + model.name + "!"  + name + " " + it.location + " " + it
				println(msg)
				addError(cd, msg)
			}
			null
		} else {
			eClassifier.instanceClass.newTypeReference
		}
	}

	dispatch def TypeReference convert_(StringType it, (String)=>TypeReference typeParameters) {
		String.newTypeReference
	}

	dispatch def TypeReference convert_(CollectionType it, (String)=>TypeReference typeParameters) {
		Collection.newTypeReference(elementType.convert(typeParameters))
	}

	dispatch def TypeReference convert_(MapType it, (String)=>TypeReference typeParameters) {
		Map.newTypeReference(keyType.convert(typeParameters), valueType.convert(typeParameters))
	}

	dispatch def TypeReference convert_(SetType it, (String)=>TypeReference typeParameters) {
		Set.newTypeReference(elementType.convert)
	}

	dispatch def TypeReference convert_(OrderedSetType it, (String)=>TypeReference typeParameters) {
		Set.newTypeReference(elementType.convert)
	}

	dispatch def TypeReference convert_(BagType it, (String)=>TypeReference typeParameters) {
		Multiset.newTypeReference(elementType.convert)
	}

	dispatch def TypeReference convert_(SequenceType it, (String)=>TypeReference typeParameters) {
		List.newTypeReference(elementType.convert)
	}

	def TypeReference convert(OclType it, (String)=>TypeReference...typeParameters) {
		convert_(if(typeParameters.length > 0) {typeParameters.get(0)} else {[Object.newTypeReference]})
	}

	def dispatch StringConcatenationClient compile(OclExpression it, (String)=>TypeReference typeParameters) {
		throw new UnsupportedOperationException('''Unsupported expression: «it»''')
	}

	def dispatch StringConcatenationClient compile(OclUndefinedExp it, (String)=>TypeReference typeParameters) '''
		null'''

	def dispatch StringConcatenationClient compile(IfExp it, (String)=>TypeReference typeParameters) '''
		((«condition.compile(typeParameters)») ?
			«thenExpression.compile(typeParameters)»
		:
			«elseExpression.compile(typeParameters)»)'''

	def StringConcatenationClient newInstance(OclModelElement source) {
		// TODO: get EPackage interface instead of impl
		val pack = packages.get(source.model.name)?.findFirst[p |
			p.EClassifiers.exists[ec | ec.name == source.name]
		]?.getClass
		if(pack === null) {
			val msg = "Could not find: " + source.model.name + "!"  + source.name + " " + source.location + " " + source
			println(msg)
			addError(cd, msg)
		}
		return '''
					(«source.convert»)«pack».eINSTANCE.getEFactoryInstance().create(«pack».eINSTANCE.get«source.name»())'''
	}

	def dispatch StringConcatenationClient compile(OperationCallExp it, (String)=>TypeReference typeParameters) {
		switch operationName {
			case source instanceof VariableExp && (source as VariableExp).referredVariable.varName == "thisModule": {
				'''
					«operationName»(
						«FOR arg : arguments SEPARATOR ","»
							«arg.compile(typeParameters)»
						«ENDFOR»
					)'''
			}
			case operationName == "newInstance" && source instanceof OclModelElement: {
				return newInstance(source as OclModelElement)
			}
			default: '''
				«operationName»(
					«source.compile(typeParameters)»
					«FOR arg : arguments»
						,«arg.compile(typeParameters)»
					«ENDFOR»
				)'''
		}
	}

	static public val operatorNames = #{
		"not"	-> "operator_NOT",
		"and"	-> "operator_AND",
		"or"	-> "operator_OR",
		"="		-> "operator_EQ",
		"<>"	-> "operator_NE",
		"<"		-> "operator_LT",
		"<="	-> "operator_LE",
		">"		-> "operator_GT",
		">="	-> "operator_GE",
		"+"		-> "operator_PLUS",
		"-"		-> "operator_MINUS"
	}

	def dispatch StringConcatenationClient compile(OperatorCallExp it, (String)=>TypeReference typeParameters) {
		val opName = operatorNames.get(operationName)
		if(opName === null) {
			println("unsupported operator: " + operationName)
			addError(cd, "unsupported operator: " + operationName)	// TODO: not showing in source file?
		}
		'''
			«opName»(
				«source.compile(typeParameters)»«
				FOR arg : arguments»
					,«arg.compile(typeParameters)»
				«ENDFOR»
			)'''
/*
			if(operationName == "=") {
				return '''oclEquals(«source.compile», «arguments.get(0).compile»)'''
			}
			switch arguments.size() {
				case 0:
					switch operationName {
						default: '''«
								switch operationName {
									case "not": "!"
									default: operationName
								}»(«source.compile»)'''
					}
				case 1:
					switch operationName {
						default: '''(«source.compile» «
								switch operationName {
									case "and": "&&"
									case "or": "||"
									case "=": "=="	// TODO: or equals
									case "<>": "!="	// TODO: or !equals
									default: operationName
								}» «arguments.get(0).compile»)'''
					}
				default: throw new IllegalStateException('''Unsupported operator: «it»''')
			}
*/
	}

	def dispatch StringConcatenationClient compile(IterateExp it, (String)=>TypeReference typeParameters) '''
		«source.compile(typeParameters)».stream().reduce(
			(«result.type.convert(typeParameters)»)(Object)«result.initExpression.compile(typeParameters)»,
			(«result.uniqueName», «iterators.get(0).uniqueName») ->
				«body.compile(typeParameters)»,
			(aaa, bbb) -> {throw new «IllegalStateException»();})'''	// TODO: use a valid combiner?

	def dispatch StringConcatenationClient compile(IteratorExp it, (String)=>TypeReference typeParameters) '''
		«source.compile(typeParameters)».stream().«
			switch name {
				case "any": "filter"
				case "collect": "map"
				case "select": "filter"
				case "reject": "filter"
				case "exists": "anyMatch"
				case "forAll": "allMatch"
				default: throw new UnsupportedOperationException("Unsupported iterator: " + name)
			}
		»((«iterators.get(0).uniqueName») ->
			«switch name {
				case "reject": "!"
				default: ""
			}»«body.compile(typeParameters)»
		)«
			suffix
		»'''

	def StringConcatenationClient suffix(IteratorExp it) {
			switch name {
				case "any": '''.findAny().orElse(null)'''
				case "forAll",
				case "exists": ''''''
				default: '''.collect(«Collectors».toList())'''
			}
	}
	def dispatch StringConcatenationClient compile(NavigationOrAttributeCallExp it, (String)=>TypeReference typeParameters) '''
		«name.escapeMethodName»(«
			if(source instanceof VariableExp && (source as VariableExp).referredVariable.varName == "thisModule") {
				""
			} else {
				source.compile(typeParameters)
			}
		»)'''

	def dispatch StringConcatenationClient compile(TupleExp it, (String)=>TypeReference typeParameters) '''
		«ImmutableMap».builder()
			«FOR e : tuplePart»
				.put("«e.varName.escapeVarName»", «e.initExpression.compile(typeParameters)»)
			«ENDFOR»
			.build()'''

	def dispatch StringConcatenationClient compile(VariableExp it, (String)=>TypeReference typeParameters) '''
		«it.referredVariable.uniqueName»'''

	def dispatch StringConcatenationClient compile(StringExp it, (String)=>TypeReference typeParameters) '''
		"«stringSymbol.replaceAll("\"", "\\\\\"")»"'''

	def dispatch StringConcatenationClient compile(EnumLiteralExp it, (String)=>TypeReference typeParameters) '''
		"«name.replaceAll("\"", "\\\\\"")»"'''

	// remark: we must erase generic types because Java class literals cannot have type arguments
	def dispatch StringConcatenationClient compile(OclType it, (String)=>TypeReference typeParameters) '''
		«convert(typeParameters).type.newTypeReference».class'''

	def dispatch StringConcatenationClient compile(BooleanExp it, (String)=>TypeReference typeParameters) '''
		«booleanSymbol»'''

	def dispatch StringConcatenationClient compile(IntegerExp it, (String)=>TypeReference typeParameters) '''
		«integerSymbol»'''

	def dispatch StringConcatenationClient compile(BagExp it, (String)=>TypeReference typeParameters) '''
		«Multiset».of(
			«FOR e : elements SEPARATOR ","»
				«e.compile(typeParameters)»
			«ENDFOR»
		)'''

	def dispatch StringConcatenationClient compile(OrderedSetExp it, (String)=>TypeReference typeParameters) '''
		«ImmutableSet».of(
			«FOR e : elements SEPARATOR ","»
				«e.compile(typeParameters)»
			«ENDFOR»
		)'''

	def dispatch StringConcatenationClient compile(SequenceExp it, (String)=>TypeReference typeParameters) '''
		«ImmutableList».of(
			«FOR e : elements SEPARATOR ","»
				«e.compile(typeParameters)»
			«ENDFOR»
		)'''

	def dispatch StringConcatenationClient compile(SetExp it, (String)=>TypeReference typeParameters) '''
		«ImmutableSet».of(
			«FOR e : elements SEPARATOR ","»
				«e.compile(typeParameters)»
			«ENDFOR»
		)'''

	def dispatch StringConcatenationClient compile(MapExp it, (String)=>TypeReference typeParameters) '''
		«ImmutableMap».builder()
			«FOR e : elements»
				.put(«e.key.compile(typeParameters)», «e.value.compile(typeParameters)»)
			«ENDFOR»
			.build()'''

	def dispatch StringConcatenationClient compile(LetExp it, (String)=>TypeReference typeParameters) {
		val varType = variable.type.convert
		//println("HERE:" + varType?.type?.qualifiedName)
		'''
			let(	// «location»
				«varType === null
				?	""
				:	{
						val StringConcatenationClient a = '''(«varType»)'''
						a
				}»«variable.initExpression.compile(typeParameters)»,
				(/*«varType»*/ «variable.uniqueName») ->
					«in_.compile(typeParameters)»
			)'''
	}

	def escapeMethodName(String it) {
		switch it {
			case "class": it + "_"
			default: it
		}
	}

	def escapeVarName(String it) {
		switch it {
			case "_",
			case "boolean",
			case "self",
			case "double",
			case "class": it + "_"
			default: it
		}
	}

	var int uniqueNamesCounter = 0

	val uniqueNames = new HashMap<VariableDeclaration, String>

	@Accessors
	val SELF = "self_"

	def MatchedRule rootRule(MatchedRule it) {
		if(superRule === null) {
			it
		} else {
			superRule.rootRule
		}
	}

	def canonic(VariableDeclaration it) {
		switch it {
			InPatternElement: inPattern.rule.rootRule.inPattern.elements.findFirst[ipe | ipe.varName == varName]
			OutPatternElement: (outPattern.rule as MatchedRule).rootRule.outPattern.elements.findFirst[ope | ope.varName == varName]
			default: it
		}
	}

	def uniqueName(VariableDeclaration it) {
		switch it {
			case varName == "self": SELF
			default: uniqueNames.computeIfAbsent(it.canonic)[varName + "_" + uniqueNamesCounter++]
		}
	}
}