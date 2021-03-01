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
 
 package fr.eseo.jatl.atltypeinference

import java.io.StringBufferInputStream
import java.util.ArrayList
import java.util.HashMap
import java.util.Map
import javax.xml.parsers.DocumentBuilderFactory
import javax.xml.xpath.XPathConstants
import javax.xml.xpath.XPathFactory
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.m2m.atl.common.ATL.MatchedRule
import org.eclipse.m2m.atl.common.ATL.Rule
import org.eclipse.m2m.atl.common.OCL.OclModelElement
import org.eclipse.m2m.atl.common.OCL.StringExp
import org.eclipse.m2m.atl.common.OCL.VariableExp
import org.eclipse.xtend.lib.annotations.Data
import org.w3c.dom.Attr
import org.w3c.dom.NodeList

@Data
class XMLConcreteSyntaxVariableResolver implements FloatingVariableResolver {
	val FloatingVariableResolver parent
	val Iterable<Resource> svg

	def Rule rule(EObject it) {
		if(it instanceof Rule) {
			it
		} else if(eContainer !== null) {
			eContainer.rule
		} else {
			null
		}
	}

	val xmlVariablesCache = new HashMap<Rule, Map<String, Object>>

	override extraRuleVariables(Rule it) {
		val ret = xmlVariables
		if(it instanceof MatchedRule) {
			if(isAbstract) {
				val common = new HashMap
				children.map[extraRuleVariables].indexed.forEach[
					if(key == 0) {
						common.putAll(value)
					} else {
						// TODO: common supertype instead of first encountered
						common.keySet.retainAll(value.keySet)
					}
				]
				ret.putAll(common)
			}
		}
		ret
	}

	def xmlVariables(Rule it) {
		xmlVariablesCache.computeIfAbsent(it)[
			outPattern.elements.map[
				val type = type
				if(type instanceof OclModelElement) {
					if(type.name == "Group") {
						return bindings.findFirst[propertyName == "content"]
					}
				}
				null
			].filter[
				it !== null
			].map[
				value
			].filter(StringExp).flatMap[
				val xmlDoc = DocumentBuilderFactory.newInstance.newDocumentBuilder.parse(new StringBufferInputStream('''
					<?xml version="1.0" encoding="UTF-8"?>
					<g>«stringSymbol»</g>
				'''))
				val nl = XPathFactory.newInstance.newXPath.compile("//*[@id]").evaluate(xmlDoc, XPathConstants.NODESET) as NodeList
				val ret = new ArrayList
				for(var i = 0 ; i < nl.length ; i++) {
					ret.add(nl.item(i))
				}
				ret
			].toMap([
				(it.attributes.getNamedItem("id") as Attr).value.replaceAll("^\\.", "")
			])[
				switch nodeName {
					case "line": "Line".find
					case "rect": "Rectangle".find
					case "text": "Text".find
					case "circle": "Circle".find
					case "polygon": "Polygon".find
					case "title": "Title".find
					case "clipPath": "ClipPath".find
					default: {
						System.err.println('''Warning: unsupported SVG element: «nodeName»''')
						null
					}
				}
			]
		]
	}

	val findCache = new HashMap

	def find(String className) {
		findCache.computeIfAbsent(className)[
			val classes = svg.flatMap[allContents.toIterable].filter(EClass)
			val ret = classes.findFirst[it.name == className]
			ret
		]
	}

	override floatingVariableInferredType(VariableExp it) {
		val rule = rule
		if(rule !== null) {
			val ret = rule.xmlVariables.get(it.referredVariable.varName)
			if(ret !== null) {
				return ret
			}
		}
		parent.floatingVariableInferredType(it)
	}

	def static register(ATLTypeInference it) {
		val svg = getModel("SVG")
		if(svg !== null) {
			floatingVariableResolver = new XMLConcreteSyntaxVariableResolver(
				floatingVariableResolver,
				svg
			)
		}
	}
}