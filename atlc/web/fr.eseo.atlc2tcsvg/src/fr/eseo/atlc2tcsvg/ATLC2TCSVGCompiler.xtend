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

import com.beust.jcommander.JCommander
import com.beust.jcommander.ParameterException
import com.google.common.base.Charsets
import com.google.common.collect.BiMap
import com.google.common.collect.HashBiMap
import com.google.common.collect.ImmutableMap
import com.google.common.io.CharStreams
import fr.eseo.atlc.constraints.ConstraintsPackage
import fr.eseo.jatl.atltypeinference.ATLTypeInference
import fr.eseo.jatl.atltypeinference.XMLConcreteSyntaxVariableResolver
import java.io.FileWriter
import java.io.InputStreamReader
import java.nio.file.Files
import java.nio.file.Paths
import java.util.ArrayList
import java.util.Collections
import java.util.HashMap
import java.util.HashSet
import java.util.Map
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xcore.XcoreStandaloneSetup
import org.eclipse.emf.ecore.xmi.impl.EcoreResourceFactoryImpl
import org.eclipse.m2m.atl.common.ATL.ATLPackage
import org.eclipse.m2m.atl.common.ATL.CalledRule
import org.eclipse.m2m.atl.common.ATL.Helper
import org.eclipse.m2m.atl.common.ATL.LazyMatchedRule
import org.eclipse.m2m.atl.common.ATL.Library
import org.eclipse.m2m.atl.common.ATL.LocatedElement
import org.eclipse.m2m.atl.common.ATL.MatchedRule
import org.eclipse.m2m.atl.common.ATL.Module
import org.eclipse.m2m.atl.common.ATL.OutPatternElement
import org.eclipse.m2m.atl.common.ATL.Rule
import org.eclipse.m2m.atl.common.ATL.Unit
import org.eclipse.m2m.atl.common.OCL.Attribute
import org.eclipse.m2m.atl.common.OCL.BooleanExp
import org.eclipse.m2m.atl.common.OCL.IfExp
import org.eclipse.m2m.atl.common.OCL.IntegerExp
import org.eclipse.m2m.atl.common.OCL.IterateExp
import org.eclipse.m2m.atl.common.OCL.IteratorExp
import org.eclipse.m2m.atl.common.OCL.LetExp
import org.eclipse.m2m.atl.common.OCL.NavigationOrAttributeCallExp
import org.eclipse.m2m.atl.common.OCL.NumericExp
import org.eclipse.m2m.atl.common.OCL.OCLPackage
import org.eclipse.m2m.atl.common.OCL.OclExpression
import org.eclipse.m2m.atl.common.OCL.OclFeature
import org.eclipse.m2m.atl.common.OCL.OclFeatureDefinition
import org.eclipse.m2m.atl.common.OCL.OclModelElement
import org.eclipse.m2m.atl.common.OCL.OclType
import org.eclipse.m2m.atl.common.OCL.Operation
import org.eclipse.m2m.atl.common.OCL.OperationCallExp
import org.eclipse.m2m.atl.common.OCL.OperatorCallExp
import org.eclipse.m2m.atl.common.OCL.PrimitiveExp
import org.eclipse.m2m.atl.common.OCL.RealExp
import org.eclipse.m2m.atl.common.OCL.SequenceExp
import org.eclipse.m2m.atl.common.OCL.StringExp
import org.eclipse.m2m.atl.common.OCL.TupleExp
import org.eclipse.m2m.atl.common.OCL.VariableExp
import org.eclipse.m2m.atl.emftvm.compiler.AtlResourceFactoryImpl

import static extension fr.eseo.atlc2tcsvg.XMLUtils.processXML

class ATLC2TCSVGCompiler {
	ResourceSet rs
	Parameters parameters
	Map<String, EPackage> metamodels
	
	Module mainModule

	extension ATLTypeInference atlType

	def static void main(String[] args) {
		val param = new Parameters
		val argParser = JCommander.newBuilder.addObject(param).build
		try {
			argParser.parse(args)
		}
		catch (ParameterException e) {
			println('''Error: «e.message»''')
			argParser.usage
			System.exit(1)
		}
		if (param.help) {
			argParser.usage
		}
		else {
			val compiler = new ATLC2TCSVGCompiler(param)
			try {
				compiler.compile
			}
			catch (Exception e) {
				println('''Error: «e.message»''')
				if (param.verbose) {
					e.printStackTrace
				}
				System.exit(1)
			}
		}
	}

	new(Parameters params) {
		this.parameters = params

		initResource

		metamodels = new HashMap
		val transfoResource = loadTransformation
		mainModule = transfoResource.contents.get(0) as Module

		if (parameters.metamodels.filter[it.endsWith("xcore")].size > 0) {
			XcoreStandaloneSetup.doSetup
		}

		parameters.metamodels.forEach[loadMetamodel(it)]
		metamodels.put('Constraints', ConstraintsPackage.eINSTANCE)

		val oclLib = ATLTypeInference.getResourceAsStream("OCLLibrary.atl")
		val oclLibraryResource = rs.createResource(URI.createURI("OCLLibrary.atl"))
		oclLibraryResource.load(oclLib, Collections.EMPTY_MAP)

		val commonModels =
			#{
				"Ecore"			-> #[EcorePackage.eINSTANCE.eResource],
				"OCLLibrary"	-> #[
										oclLibraryResource
									],
				"ATL"			-> #[
									OCLPackage.eINSTANCE.eResource,
									ATLPackage.eINSTANCE.eResource
								],
				"Constraints"	-> #[],
				"IN"			-> #[transfoResource]
			}
		val metamodels = new HashMap(commonModels)
		this.metamodels.filter[$1 != 'Constraints'].forEach[k, v| metamodels.put(k, #[v.eResource])]

		atlType = new ATLTypeInference(
			metamodels
		)
		XMLConcreteSyntaxVariableResolver.register(atlType)
//		atlType.check
	}

	private def initResource() {
		rs = new ResourceSetImpl
		rs.resourceFactoryRegistry.extensionToFactoryMap.put("atl", new AtlResourceFactoryImpl)
		rs.resourceFactoryRegistry.extensionToFactoryMap.put('ecore', new EcoreResourceFactoryImpl)
	}

	def loadTransformation() {
		try {
			val transfo = rs.getResource(URI.createURI(parameters.inputPath), true)
			val fileName = parameters.inputPath.split('/').last

			transfo.errors.forEach[
				System.err.println('''error in «fileName»:«line»-«column» - «message»''')
			]
			transfo.warnings.forEach[
				System.err.println('''warning in «fileName»:«line»-«column» - «message»''')
			]
			if (!transfo.errors.empty) {
				throw new UnsupportedOperationException('''File «fileName» contains syntax errors.''')
			}
			transfo
		}
		catch (Exception e) {
			System.err.println('''Error reading input file "«parameters.inputPath»"''')
			if (parameters.verbose) {
				e.printStackTrace
			}
			System.exit(1)
		}
	}

	def loadMetamodel(String path) {
		try {
			// MMName=path
			val parts = path.split("=")
			var MMname = ""
			var MMPath = path
			if (parts.size > 1) {
				MMname = parts.get(0)
				MMPath= parts.drop(1).join('=')
			}

			val r = rs.getResource(URI.createURI(MMPath), true)

			val actualMMName = MMname
			r.contents.filter(EPackage).forEach[
				metamodels.put(actualMMName.empty ? name : actualMMName, it)
			]
		} catch (Exception e) {
			System.err.println('''Error loading metamode file "«path»"''')
			if (parameters.verbose) {
				e.printStackTrace
			}
			System.exit(1)
		}
	}

	def compile() {
		val res = compileModule(mainModule)

		if (parameters.outputPath !== null) {
			var out = new FileWriter(parameters.outputPath)
			out.write(res.toString)
			out.close
		}
		else {
			println(res)
		}
	}

	private def compileModule(Module it) {
		val baseURL = if (!parameters.hostname.empty) {
			'''«parameters.protocol»://«parameters.hostname»/«parameters.baseURL»'''
		} else {
			parameters.baseURL
		}
		// this compiler does not support calling rules (does it makes sense in TCSVG anyway ?)
		// we register all Rules name so that they can be silently ignored
		'''
			<svg xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg" xmlns:c="http://myconstraints">
				<script><![CDATA[
					«readFile('OCLLibrary.js')»

					«elements.filter(Helper).map[compileHelpers].join»
				]]></script>
				<defs>
					«elements.filter(Rule).map[compileRule].join»
				</defs>
			
				«FOR svg : parameters.embededSVGPath»
				«readFile(svg)»
				«ENDFOR»
			
				«FOR url : parameters.styleURL»
				<link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" href="«url»" type="text/css"/>
				«ENDFOR»
				«FOR css : parameters.embededStylePath»
				<style><![CDATA[
					«readFile(css)»
				]]></style>
				«ENDFOR»
			
				<script href="«baseURL»«parameters.cassowaryJSPath»"/>
				<script href="«baseURL»«parameters.tcsvgJSPath»"/>
				«FOR src : parameters.localStripts»
				<script href="«src»"/>
				«ENDFOR»
				«FOR script : parameters.embededScriptPath»
				<script><![CDATA[
					«readFile(script)»
				]]></script>
				«ENDFOR»
			</svg>
		'''
	}

	private def readFile(String path) {
		if (Files.exists(Paths.get(path))) {
			val contentBuilder = new StringBuilder
			Files.lines(Paths.get(path)).forEach[contentBuilder.append(it).append("\n")]
			contentBuilder.toString
		}
		else {
			val fin = class.getResourceAsStream(path)
			CharStreams.toString(new InputStreamReader(fin, Charsets.UTF_8))
		}
	}

	private def compileHelpers(Helper it) {
		'''
			// «location»
			function «definition.feature.JSFunctionName»(«compileHelperParameters») {
				«IF hasConstraintsTag»
					return new tcsvg.Constraints().and(«definition.feature.compileATLHelper(true)»);
				«ELSE»
					return «definition.feature.compileATLHelper(false)»;
				«ENDIF»
			}
		'''
	}

	private def String compileHelperParameters(Helper it) {
		val feature = definition.feature
		switch (feature) {
			Attribute: {
				if (definition.context_ !== null) {
					'self'
				}
				else {
					''
				}
			}
			Operation: {
				if (definition.context_ !== null) {
					val params = new ArrayList<String>(#['self'])
					params.addAll(feature.parameters.map[varName])
					params.join(', ')
				}
				else {
					feature.parameters.map[it.varName].join(', ')
				}
			}
			default: throw new UnsupportedOperationException('''unexpected class "«feature.class.simpleName»" at «location»''')
		}
	}

	private def hasConstraintsTag(LocatedElement it) {
		commentsBefore.findFirst[matches("^--\\s+@constraints")] !== null
	}

	val BiMap<Operation, String> functionNames = HashBiMap.create

	private dispatch def String getJSFunctionName(Operation it) {
		functionNames.computeIfAbsent(it) [
			val definition = eContainer as OclFeatureDefinition
			val functionName = if (definition.context_ !== null) {
				val context = definition.context_.context_
				switch context {
					OclModelElement: '''«context.model.name»__«context.name»__«name»'''
					default: '''«context.class.simpleName»__«name»'''
				}
			}
			else {
				'''«name»'''
			}
			if (functionNames.containsValue(functionName)) {
				var i = 2
				while (functionNames.containsValue('''«functionName»_«i»''')) i++
				'''«functionName»_«i»'''
			}
			else {
				functionName
			}
		]
	}

	private dispatch def String getJSFunctionName(Attribute it) {
		val definition = eContainer as OclFeatureDefinition
		if (definition.context_ !== null) {
			val context = definition.context_.context_
			switch context {
				OclModelElement: '''__attribute__«context.model.name»__«context.name»__«name»'''
				default: '''__attribute__«context.class.simpleName»__«name»'''
			}
		}
		else {
			'''__attribute__«name»'''
		}
	}

	private dispatch def compileATLHelper(OclFeature it, boolean isConstraint) {
		throw new UnsupportedOperationException('''Unexpected class "«class.simpleName»" at «debugLocation»''')
	}

	private dispatch def compileATLHelper(Attribute it, boolean isConstraint) {
		'''
			«initExpression.compileExpression(isConstraint)»
		'''
	}

	private dispatch def compileATLHelper(Operation it, boolean isConstraint) {
		'''
			«body.compileExpression(isConstraint)»
		'''
	}

	private dispatch def String compileExpression(OclExpression it, boolean isConstraint) {
		throw new UnsupportedOperationException('''Unexpected class "«class.simpleName»" at «debugLocation»''')
	}

	private dispatch def String compileExpression(IfExp it, boolean isConstraint) {
		'''
		(«condition.compileExpression(false)») ? (
			«thenExpression.compileExpression(isConstraint)»
		) : (
			«elseExpression.compileExpression(isConstraint)»
		)'''
	}

	private dispatch def String compileExpression(LetExp it, boolean isConstraint) {
		'''
		((«variable.varName») => (
			«in_.compileExpression(isConstraint)»
		))(«variable.initExpression.compileExpression(isConstraint)»)'''
	}

	private dispatch def String compileExpression(IterateExp it, boolean isConstraint) {
		'''
			(OCLLibrary.iterate(«source.compileExpression(isConstraint)», «result.initExpression.compileExpression(isConstraint)»,
				(«result.varName», «iterators.get(0).varName») => «body.compileExpression(isConstraint)»
			))
		'''
	}

	private dispatch def String compileExpression(IteratorExp it, boolean isConstraint) {
		switch name {
			case 'collect': '''OCLLibrary.collect(«source.compileExpression(isConstraint)», («iterators.get(0).varName») => «body.compileExpression(isConstraint)»)'''
			case 'forAll': '''OCLLibrary.iterate(«source.compileExpression(isConstraint)», «IF isConstraint»new Constraints()«ELSE»true«ENDIF», (cur, acc) => cur«IF isConstraint».and(acc)«ELSE» && acc«ENDIF»)'''
			case 'zipWith': {
				if (!(source instanceof TupleExp)) {
					throw new UnsupportedOperationException('''Expected Tuple as source of zipWith operation at «debugLocation»''')
				}
				val src = source as TupleExp
				if (src.tuplePart.size != 2) {
					throw new UnsupportedOperationException('''Expected exactly two member in source Tuple of zipWith operation at «debugLocation» got «src.tuplePart.size»''')
				}
				val leftVal = src.tuplePart.get(0).initExpression.compileExpression(isConstraint)
				val rightVal = src.tuplePart.get(1).initExpression.compileExpression(isConstraint)
				'''OCLLibrary.zipWith(«leftVal», «rightVal» ,(«FOR i : iterators SEPARATOR ', '»«i.varName»«ENDFOR») => («body.compileExpression(isConstraint)»))'''
			}
			default: throw new UnsupportedOperationException('''Iterator operation «name» not supported at «debugLocation»''')
		}
	}

	private dispatch def String compileExpression(OperatorCallExp it, boolean isConstraint) {
		if (isConstraint) return compileConstraintExpression

		switch (operationName) {

			case '-': {
				if (arguments.empty) {
					'''(«operationName» «source.compileExpression(false)»)'''
				}
				else {
					'''«source.compileExpression(false)» «operationName» «arguments.get(0).compileExpression(false)»'''
				}
			}

			case 'not':	'''(! («source.compileExpression(false)»))'''
			case 'and': '''«source.compileExpression(false)» && «arguments.get(0).compileExpression(false)»'''
			case 'or': '''«source.compileExpression(false)» || «arguments.get(0).compileExpression(false)»'''
			case 'xor': '''(«source.compileExpression(false)» ? !«arguments.get(0).compileExpression(false)» : «arguments.get(0).compileExpression(false)»)'''
			case 'implies': '''(«source.compileExpression(false)» ? «arguments.get(0).compileExpression(false)» : true)'''

			case '+',
			case '*',
			case '/',
			case '<',
			case '>',
			case '<=',
			case '>=': {
				'''«source.compileExpression(false)» «operationName» «arguments.get(0).compileExpression(false)»'''
			}
			case '<>': '''«source.compileExpression(false)» != «arguments.get(0).compileExpression(false)»'''
			default:
				'''«source.compileExpression(false)».«operationName»(«FOR a : arguments SEPARATOR ', '»«a.compileExpression(false)»«ENDFOR»)'''
		}
	}

	private dispatch def String compileExpression(OperationCallExp it, boolean isConstraint) {
		val operation = it.operation

		switch operation {
			LazyMatchedRule: '''«arguments.get(0).compileExpression(isConstraint)»''' // ignore rule call and pass the source
			Operation: {
				val unit = operation.unit
				switch unit {
					case mainModule: {
						if (source.isThisModule) {
							'''«operation.JSFunctionName»(«FOR a: arguments SEPARATOR ', '»«a.compileExpression(isConstraint)»«ENDFOR»)'''
						}
						else {
							'''«operation.JSFunctionName»(«source.compileExpression(isConstraint)»«FOR a: arguments BEFORE ', ' SEPARATOR ', '»«a.compileExpression(isConstraint)»«ENDFOR»)'''
						}
					}
					Library case unit.name == "OCLLibrary":
						'''OCLLibrary.«operationName»(«source.compileExpression(false)»«FOR a : arguments BEFORE ', ' SEPARATOR ', '»«a.compileExpression(false)»«ENDFOR»)'''
					default: throw new UnsupportedOperationException('''cannot compile operation «operationName» at «debugLocation»''')
				}
			}
			EOperation:
				if (isConstraint && operation.name == 'stay') {
					'''«source.compileExpression(true)».st(«compileStrengthStay»)'''
				}
				else {
					'''«source.compileExpression(isConstraint)».«operation.name»(«FOR a : arguments SEPARATOR ', '»«a.compileExpression(isConstraint)»«ENDFOR»)'''
				}
			default:
				switch operationName {
					case 'stay': '''«source.compileExpression(true)».st(«compileStrengthStay»)'''
					case 'toConstant': '''«source.compileExpression(true)»''' //TODO should compile to actual constant
					default: throw new UnsupportedOperationException('''cannot compile operation «operationName» at «debugLocation»''')
				}
		}
	}

	private dispatch def String compileExpression(NavigationOrAttributeCallExp it, boolean isConstraint) {
		if (isConstraint) return compileConstraintExpression

		val src = property
		switch src {
			ImmutableMap<String, Object>,
			EAttribute,
			EReference: '''«source.compileExpression(false)».«name»'''

			Attribute: '''«src.JSFunctionName»(«source.compileExpression(false)»)'''
			default: throw new UnsupportedOperationException('''cannot infer source type of «name» attrbute call at «debugLocation»''')
		}
	}

	private dispatch def String compileExpression(IntegerExp it, boolean isConstraint) {
		if (isConstraint) {
			'''(new tcsvg.Expression(«integerSymbol»))'''
		}
		else {
			'''«it.integerSymbol»'''
		}
	}

	private dispatch def String compileExpression(RealExp it, boolean isConstraint) {
		if (isConstraint) {
			'''(new tcsvg.Expression(«realSymbol»))'''
		}
		else {
			'''«realSymbol»'''
		}
	}

	private dispatch def String compileExpression(BooleanExp it, boolean isConstraint) {
		if (isConstraint) {
			'''(new tcsvg.Constraints())'''
		}
		else {
			'''«booleanSymbol»'''
		}
	}

	private dispatch def String compileExpression(StringExp it, boolean isConstraint) {
		'''«stringSymbol»'''
	}

	private dispatch def String compileExpression(VariableExp it, boolean isConstraint) {
		if (isConstraint) {
			var refVar = referredVariable
			if (refVar.varName == 'self') 	return '''«referredVariable.varName»'''
			if (refVar.eContainer === null)	return '''this.«referredVariable.varName»'''
			if (refVar instanceof OutPatternElement)	return '''this.«referredVariable.varName»'''
			return '''«referredVariable.varName»'''
		}
		else {
			'''«referredVariable.varName»'''
		}
	}

	private dispatch def String compileConstraintExpression(OclExpression it) {
		throw new UnsupportedOperationException('''Unexpected class "«class.simpleName»"''')
	}

	private dispatch def String compileConstraintExpression(OperatorCallExp it) {
		val operators = #{
			'+' -> 'plus',
			'-' -> 'minus',
			'/' -> 'div',
			'*' -> 'times',
			'=' -> 'eq',
			'>=' -> 'ge',
			'<=' -> 'le',
			'and' -> 'and'
		}
		switch (operationName) {
			case '-': {
				if (arguments.empty) {
					'''«source.compileExpression(true)».neg'''
				}
				else {
					'''
						«source.compileExpression(true)»
					.minus(
						«arguments.get(0).compileExpression(true)»
					)'''
				}
			}

			case 'implies': '''
			(«source.compileExpression(false)» ?
				«arguments.get(0).compileExpression(true)»
			: new tcsvg.Constraints())''' //TODO this is not suitable for incremental computation

			case 'and',
			case '+',
			case '*',
			case '/':'''
				«source.compileExpression(true)»
			.«operators.get(operationName)»(
				«arguments.get(0).compileExpression(true)»
			)'''

			case '=',
			case '<=',
			case '>=': {
				val strength = extractStrenth
			'''
				«source.compileExpression(true)»
			.«operators.get(operationName)»(
				«arguments.get(0).compileExpression(true)»
				«IF parameters.debug», "«debugLocation»"«ENDIF»
			)«IF !(strength.empty)».setPriority(c.Strength.«strength»)«ENDIF»'''
			}

			default:
				throw new UnsupportedOperationException('''Operator "«operationName»" not supported in constraints at «debugLocation»''')
		}
	}

	private dispatch def String compileConstraintExpression(NavigationOrAttributeCallExp it) {
		if (source instanceof VariableExp && (source as VariableExp).referredVariable.varName == 'thisModule') {
			val src = property
			if (src instanceof Attribute) {
				if (!src.hasConstraintsTag) {
					return '''(new tcsvg.Expression(«src.JSFunctionName»()))'''
				}
				else {
					return '''«src.JSFunctionName»()'''
				}
			}
			else {
				throw new UnsupportedOperationException('''Cannot find global attribute helper with name «name» at «debugLocation»''')
			}
		}
		else {
			val src = property
			switch src {
				ImmutableMap<String, Object>,
				EAttribute,
				EReference: '''«source.compileExpression(true)».«name»'''

				Attribute: {
					if (src.hasConstraintsTag) {
						 '''«src.JSFunctionName»(«source.compileExpression(true)»)'''
					}
					else {
						'''(new tcsvg.Expression(«src.JSFunctionName»(«source.compileExpression(true)»)))'''
					}
				}
				default: throw new UnsupportedOperationException('''cannot find attribute «name» at «debugLocation»''')
			}
		}
	}

	private dispatch def String compileConstraintExpression(OperationCallExp it) {
		val operation = it.operation

		switch operation {
			LazyMatchedRule: '''«arguments.get(0).compileExpression(true)»''' // ignore rule call and pass the source
			Operation: {
				val unit = operation.unit
				switch unit {
					case mainModule: {
						if (source.isThisModule) {
							'''«operation.JSFunctionName»(«FOR a: arguments SEPARATOR ', '»«a.compileExpression(true)»«ENDFOR»)'''
						}
						else {
							'''«operation.JSFunctionName»(«source.compileExpression(true)»«FOR a: arguments BEFORE ', ' SEPARATOR ', '»«a.compileExpression(true)»«ENDFOR»)'''
						}
					}
					Library case unit.name == "OCLLibrary":
						'''OCLLibrary.«operationName»(«source.compileExpression(false)»«FOR a : arguments BEFORE ', ' SEPARATOR ', '»«a.compileExpression(false)»«ENDFOR»)'''
					default: throw new UnsupportedOperationException('''cannot compile operation «operationName» at «debugLocation»''')
				}
			}
			EOperation:
				if (operation.name == 'stay') {
					'''«source.compileExpression(true)».st(«compileStrengthStay»«IF parameters.debug», "«debugLocation»"«ENDIF»)'''
				}
				else {
					'''«source.compileExpression(true)».«operation.name»(«FOR a : arguments SEPARATOR ', '»«a.compileExpression(true)»«ENDFOR»«IF parameters.debug», "«debugLocation»"«ENDIF»)'''
				}
			default:
				//FIXME : used to handle stay on Integer / Real, should be added to an ATLc lib for typing
				switch operationName {
					case 'stay': '''«source.compileExpression(true)».st(«compileStrengthStay»«IF parameters.debug», "«debugLocation»"«ENDIF»)'''
					case 'toConstant': '''«source.compileExpression(true)»''' //TODO : should compile to constant
					default: throw new UnsupportedOperationException('''cannot compile operation «operationName» at «debugLocation»''')
				}
		}
	}

	private def compileStrengthStay(OperationCallExp it) {
		if (arguments.size == 0 || arguments.size > 2) {
			throw new UnsupportedOperationException('''cannot compile stay at «debugLocation», wrong number of parameter, expected 1 or 2 got «arguments.size»''')
		}
		val strength = arguments.get(0)
		if (strength instanceof StringExp) {
			if (arguments.size == 1) {
				'''c.Strength.«strength.stringSymbol.toLowerCase»'''
			}
			else {
				val weight = arguments.get(1)
				if (! (weight instanceof NumericExp)) {
					throw new UnsupportedOperationException('''Cannot compile stay at «debugLocation», second argument must be a number, got «weight.class.simpleName»''')
				}
				'''c.Strength.«strength.stringSymbol.toLowerCase», «weight.compileExpression(false)»'''
			}
		}
		else {
			throw new UnsupportedOperationException('''cannot compile stay at «debugLocation», expected String as first argument, got «strength.class.simpleName»''')
		}
	}

	private def String extractStrenth(OclExpression it) {
		val pattern = "(--\\s*)(weak|medium|strong|required)((\\s+)(\\d+(\\.\\d+)?))?.*"
		val foundStrength = commentsAfter.map[toLowerCase].findFirst[matches(pattern)]
		if (foundStrength !== null) {
			val ret = foundStrength.replaceAll(pattern, "$2, $5")
			if (ret.endsWith(', ')) {
				'''«ret» undefined'''
			}
			else {
				ret
			}
		}
		else {
			''
		}
	}

	private dispatch def isThisModule(OclExpression it) {
		false
	}

	private dispatch def isThisModule(VariableExp it) {
		referredVariable.varName == 'thisModule'
	}

	private def Unit getUnit(EObject it) {
		if (it instanceof Unit) {
			it
		}
		else if (eContainer !== null) {
			eContainer.unit
		}
		else {
			null
		}
	}

	private dispatch def compileRule(CalledRule it) {
		throw new UnsupportedOperationException('''Cannot compile called rule "«name»" at «debugLocation»''')
	}

	private dispatch def compileRule(LazyMatchedRule it) {
		if (isAbstract) {
			return ''''''
		}

		if (inPattern.elements.size > 1) {
			// TODO : how can when handle rules with multiple sources, only the first one is 'this' ?
			throw new UnsupportedOperationException('''Cannot compile rules with more than one source element, «name» at «debugLocation»''')
		}

		val constraints = outPattern.elements.filter[(type as OclModelElement).model.name == "Constraints"]
		val shapes = outPattern.elements.filter[(type as OclModelElement).model.name == "SVG"]

		if (shapes.filter[(type as OclModelElement).name == 'Group'].size > 1) {
			throw new UnsupportedOperationException('''excepted at most one SVG!Group per rule at «debugLocation», got «shapes.filter[(type as OclModelElement).name == 'Group'].size»''')
		}

		val group = shapes.findFirst[(type as OclModelElement).name == 'Group']

		if (group === null) {
			val compiledShapes = shapes.map[compileOutPatternElement].join('\n')
			val movables = movableElements.join(' ')
			movableElements.clear
			return '''
				<!-- «debugLocation» -->
				<g id="«name.normalizeRuleName»"«IF !movables.empty» movable="«movables»"«ENDIF»>
					«compiledShapes»
					<!-- constraints -->
					«FOR c : constraints»
						«c.compileConstraintGroup»
					«ENDFOR»
				</g>
			'''
		}

		if (shapes.size != 1) {
			val attributes = group.bindings.filter[!#{'content', 'children'}.contains(propertyName)].filter[value instanceof PrimitiveExp]
			val children = group.bindings.findFirst[propertyName == 'children']
			if (!(children.value instanceof SequenceExp)) {
				throw new UnsupportedOperationException('''expected a Sequence of children at «debugLocation», got «children.value.class.simpleName»''')
			}
			val compiledChildren = (children.value as SequenceExp).elements.filter(VariableExp).map[referredVariable].filter(OutPatternElement).map[compileOutPatternElement].join("\n")
			val movables = movableElements.join(',')
			movableElements.clear
			return '''
			<!-- «debugLocation» -->
			<g id="«name.normalizeRuleName»" «FOR a : attributes SEPARATOR ' '»«a.propertyName»="«a.value.primitiveValue»"«ENDFOR»«IF !movables.empty» movable="«movables»"«ENDIF»>
				«compiledChildren»
				<!-- constraints -->
				«FOR c : constraints»
					«c.compileConstraintGroup»
				«ENDFOR»
			</g>
			'''
		}
		else {
			val attributes = group.bindings.filter[propertyName != "content"].filter[value instanceof PrimitiveExp]
			return '''
			<!-- «debugLocation» -->
			<g id="«name.normalizeRuleName»" «FOR a : attributes SEPARATOR ' '»«a.propertyName»="«a.value.primitiveValue»"«ENDFOR»>
				«group.compileInlineXML»
				<!-- constraints -->
				«FOR c : constraints»
					«c.compileConstraintGroup»
				«ENDFOR»
			</g>
			'''
		}
	}

	private dispatch def primitiveValue(OclExpression it) {
		throw new UnsupportedOperationException('''attribute value at «debugLocation» is not a primitive value, got «class.simpleName»''')
	}

	private dispatch def primitiveValue(PrimitiveExp it) {
		compileExpression(false)
	}

	private dispatch def compileRule(MatchedRule it) {
		throw new UnsupportedOperationException('''Cannot compile non lazy rule "«name»" at «debugLocation»''')
	}

	private def normalizeRuleName(String it) {
		return parameters.lowercaseRules ? toLowerCase : it
	}

	val processedOutPatterns = new HashSet<OutPatternElement>
	val movableElements = new ArrayList<String>

	private def String compileOutPatternElement(OutPatternElement it) {
		if (processedOutPatterns.contains(it)) return ""

		processedOutPatterns.add(it)
		val primitiveAttributes = bindings.filter[!#{'content', 'children'}.contains(propertyName)]
			.filter[value instanceof PrimitiveExp].map[
				switch propertyName {
					case 'mouseTransparent': '''pointer-events="none"'''
					case 'movable': {
						if ((value instanceof BooleanExp) && (value instanceof BooleanExp).booleanValue) {
							movableElements.add((eContainer as OutPatternElement).varName)
							''''''
						}
						else {
							'''"pointer-events"="none"'''
						}
					}
					default: '''«propertyName»="«value.primitiveValue»"'''
				}
			].join(' ')
		val paramsAttribute = bindings.filter[!#{'content', 'children'}.contains(propertyName)]
			.filter[value instanceof NavigationOrAttributeCallExp].map[
				val v = value as NavigationOrAttributeCallExp
				val src =  it.outPatternElement.type.toPlatform.navigableProperties.findFirst[p |
					p.name == it.propertyName
				] as EStructuralFeature // TODO use ATLTypeInference helper when implemented
				'''«propertyName»-value="param(«v.name») «IF src.defaultValueLiteral.empty»default«ELSE»«src.defaultValueLiteral»«ENDIF»"'''
			].join(' ')
		val tagName = type.toSVGElement
		var String inlineXML = ""
		var String children = ""
		var String contentValue = ""
		if (bindings.findFirst[propertyName == 'content'] !== null) {
			val content = bindings.findFirst[propertyName == 'content']
			if (content.value instanceof StringExp) {
				inlineXML = compileInlineXML
			}
			else {
				if (!(content.value instanceof NavigationOrAttributeCallExp)) throw new UnsupportedOperationException('''only attribute call are supported at «debugLocation», got «content.value.class.simpleName»''')
				contentValue = '''content-value="param(«(content.value as NavigationOrAttributeCallExp).name»)"'''
				inlineXML = "default"
			}
		}
		if (bindings.findFirst[propertyName == 'children'] !== null) {
			val c = bindings.findFirst[propertyName == 'children'].value
			if (c instanceof SequenceExp) {
				children = c.elements.filter(VariableExp).map[referredVariable].filter(OutPatternElement).map[compileOutPatternElement].join('\n')
			}
			else {
				throw new UnsupportedOperationException('''expected a Sequence of children at «debugLocation», got «c.class.simpleName»''')
			}
		}
		if (inlineXML.empty && children.empty) {
			'''<«tagName» id=".«varName»" «primitiveAttributes» «paramsAttribute»/>'''
		}
		else {
			'''
			<«tagName» id=".«varName»" «contentValue» «primitiveAttributes» «paramsAttribute» >
				«inlineXML»
				«children»
			</«tagName»>
			'''
		}
	}

	private dispatch def toSVGElement(OclType it) {
		throw new UnsupportedOperationException('''cannot find corresponding SVG tag for «it» at «debugLocation»''')
	}

	val SVGMMtoSVGTag = #{
		'Group' -> 'g',
		'Circle' -> 'circle',
		'Rectangle' -> 'rect',
		'Text' -> 'text',
		'Line' -> 'line',
		'ClipPath' -> 'clipPath',
		'Polygon' -> 'polygon'
	}

	private dispatch def toSVGElement(OclModelElement it) {
		if (model.name != 'SVG') {
			throw new UnsupportedOperationException('''cannot find corresponding SVG tag at «debugLocation», metamodel is not SVG''')
		}
		if (SVGMMtoSVGTag.containsKey(name)) {
			return SVGMMtoSVGTag.get(name)
		}
		else {
			throw new UnsupportedOperationException('''cannot find corresponding SVG tag for «name» at «debugLocation»''')
		}
	}

	private def String compileInlineXML(OutPatternElement it) {
		val content = bindings.findFirst[propertyName == 'content']?.value
		if (content === null) return ""

		switch content {
			StringExp: {
				val contentSVG = '''
				<?xml version="1.0" encoding="UTF-8"?>
				<data>
					«content.stringSymbol»
				</data>'''

				return contentSVG.processXML
			}
			default: throw new UnsupportedOperationException('''expected string for property "content" at «debugLocation», got «content.class.simpleName»''')
		}
	}

	val suggestedVariables = new ArrayList<String>

	private def compileConstraintGroup(OutPatternElement it) {
		val srcName = (outPattern.rule as MatchedRule).inPattern.elements.get(0).varName
		val cstrs = bindings.findFirst[propertyName == 'expressions']?.value as SequenceExp
		if (cstrs === null) { // compile constraints with label
			'''
				«FOR b : bindings»
					<constraints name="«b.propertyName»">
						{
							let «srcName» = this;
							«suggestedVariables.clear»
							«val constraints = b.value.compileExpression(true)»
							«FOR s : suggestedVariables»
							«s»;
							«ENDFOR»
							«IF parameters.legacyTCSVGConstraints»
								«constraints».add();
							«ELSE»
								return «constraints»;
							«ENDIF»
					}
					</constraints>
				«ENDFOR»
			'''
		}
		else { // old way
			'''
				<constraints>
					«FOR c : cstrs.elements»
						{
							let «srcName» = this;
							«IF parameters.legacyTCSVGConstraints»
								«c.compileExpression(true)».add();
							«ELSE»
								return «c.compileExpression(true)»;
							«ENDIF»
						}
					«ENDFOR»
				</constraints>
			'''
		}
	}

	dispatch private def debugLocation(OclExpression it) {
		'''«eResource.URI.lastSegment» - «location»'''
	}

	dispatch private def debugLocation(Rule it) {
		'''«eResource.URI.lastSegment» - «location»'''
	}

	dispatch private def debugLocation(Helper it) {
		'''«eResource.URI.lastSegment» - «location»'''
	}
}
