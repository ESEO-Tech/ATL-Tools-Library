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

package fr.eseo.atlc2tcsvg

import java.io.StringWriter
import java.util.regex.Pattern
import javax.xml.parsers.DocumentBuilderFactory
import javax.xml.transform.OutputKeys
import javax.xml.transform.TransformerFactory
import javax.xml.transform.dom.DOMSource
import javax.xml.transform.stream.StreamResult
import org.eclipse.xtext.util.StringInputStream
import org.w3c.dom.Attr
import org.w3c.dom.Element
import org.w3c.dom.Node
import org.w3c.dom.Text

class XMLUtils {
	static def String processXML(String it) {
		val output = new StringBuilder
		val xmlDoc = DocumentBuilderFactory.newInstance.newDocumentBuilder.parse(new StringInputStream(it))
		val nodes = xmlDoc.documentElement.childNodes

		for (var i = 0; i < nodes.length; i++) {
			val node = nodes.item(i)
			if (node instanceof Element) {
				node.process
				output.append('''«node.saveNode»
				''')
			}
		}


		output.toString
	}

	static val tagsWithContent = #{
		'text',
		'title'
	}

	static private dispatch def void process(Element it) {
		if (tagsWithContent.contains(tagName)) {
			for (var i = 0; i < attributes.length; i++) {
				attributes.item(i).process
			}
			for (var i = 0; i < childNodes.length; i++) {
				val node = childNodes.item(i)
				if (node instanceof Text) {
					if (!node.data.trim.empty) {
						val param = node.data.trim.param
						it.setAttribute('content-value', '''param(«param.key»)''')
						node.data = param.value
					}
				}
				else {
					childNodes.item(i).process
				}
			}
		}
		else {
			for (var i = 0; i < attributes.length; i++) {
				attributes.item(i).process
			}
			for (var i = 0; i < childNodes.length; i++) {
				childNodes.item(i).process
			}
		}
	}

	static private dispatch def void process(Text it) {
		val param = data.param
		if (!param.value.empty) {
			data = '''param(«param.key») «param.value»'''
		}
	}

	static private dispatch def void process(Attr it) {
		firstChild.process
	}

	static private dispatch def void process(Object it) {
		throw new UnsupportedOperationException('''unexpected class''')
	}

	static private def Pair<String, String> getParam(String it) {
		val tagRegex = '''\$\{([^?}]+)(\?+([^}]*))?\}'''
		val regexp = Pattern.compile(tagRegex)
		val matcher = regexp.matcher(it)
		if (matcher.find) {
			// only take first tag and ignore next ones
			val property = matcher.group(1).split('\\.').drop(1).join('.')
			val defaultValue = if (matcher.group(3) === null) 'default' else matcher.group(3)
			property -> defaultValue
		}
		else {
			it -> ''
		}
	}

	static val transformer = TransformerFactory.newInstance.newTransformer

	static private def saveNode(Node it) {
		transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, 'yes')
		val output = new StringWriter
		val result = new StreamResult(output)
		transformer.transform(new DOMSource(it), result)
		output.toString.trim
	}
}
