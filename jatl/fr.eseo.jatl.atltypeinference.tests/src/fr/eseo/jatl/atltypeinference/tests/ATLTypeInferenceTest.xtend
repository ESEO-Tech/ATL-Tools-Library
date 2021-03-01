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
 
 package fr.eseo.jatl.atltypeinference.tests

import fr.eseo.jatl.atltypeinference.ATLTypeInference
import fr.eseo.jatl.atltypeinference.XMLConcreteSyntaxVariableResolver
import java.util.List
import java.util.Map
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.m2m.atl.common.ATL.ATLPackage
import org.eclipse.m2m.atl.common.OCL.Attribute
import org.eclipse.m2m.atl.common.OCL.IfExp
import org.eclipse.m2m.atl.common.OCL.IteratorExp
import org.eclipse.m2m.atl.common.OCL.LetExp
import org.eclipse.m2m.atl.common.OCL.OCLPackage
import org.eclipse.m2m.atl.common.OCL.Operation
import org.eclipse.m2m.atl.emftvm.compiler.AtlResourceFactoryImpl
import org.eclipse.uml2.uml.UMLPackage
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Parameterized
import org.junit.runners.Parameterized.Parameter
import org.junit.runners.Parameterized.Parameters

/*
 * TODO:
 *	- ATL compatibility ideas (also for ATOL
 *		- specify that calling a lazy rule without further navigation results in the first element
 *			- but any navigation on its result if to access other target elements
 *			- an explicit resolve could also do that to replace resolveTemp
 *	- transform this class into a JUnit test class
 *	- handle generics in some way (see OCLLibrary for some commented examples)
 *	- add a pseudo OclModelElement-based type (e.g., INFER!PLEASE) to infer type
 *		- or use an annotation
 */
 @RunWith(Parameterized)
class ATLTypeInferenceTest {
	@Parameters(name = "{0}")
	def static List<Object[]> main() {
		val rs = new ResourceSetImpl
		rs.resourceFactoryRegistry.extensionToFactoryMap.put("atl", new AtlResourceFactoryImpl)
		//XcoreStandaloneSetup.doSetup()	// cannot work until we use the same ANTLR for ATL (TODO: switch to more recent version of ATL)
		#[
			#["TestCases", #{
				"IN"	-> #[
							rs.getResource(URI.createFileURI(
								"../fr.eseo.jatl.atltypeinference/TestCases.atl"
							), true)
						]
			}, #[]],
			#["NonTypingTestCases", #{
				"IN"	-> #[
							rs.getResource(URI.createFileURI(
								"NonTypingTestCases.atl"
							), true)
						]
			}, #[]],
			#["Sequence2TCSVG", #{
				"IN"	->	#[
								rs.getResource(URI.createFileURI(
/*
									"../fr.eseo.atlc2tcsvg/resources/Sequence2TCSVG.atl"
/*/
									"resources/data/Sequence2TCSVG.atl"
/**/
							), true)
						],
				"SVG"	->	#[rs.getResource(URI.createFileURI("../fr.eseo.atlc2tcsvg/resources/SVG.ecore"), true)],
				"Seq"	->	#[rs.getResource(URI.createFileURI("../fr.eseo.atlc2tcsvg/resources/Seq.ecore"), true)],
				"Constraints"	-> #[]
			}, #[]],
			#["ATLTypeInference", #{
				"IN"	->	#[
								rs.getResource(URI.createFileURI(
//									"../fr.eseo.jatl.atltypeinference/ATLTypeInference.atl"
									"resources/data/ATLTypeInference.atl"
								), true),
								rs.getResource(URI.createFileURI(
									"../fr.eseo.jatl.atltypeinference/ATLTypeInferenceToEcore.atl"
								), true),
								rs.getResource(URI.createFileURI(
									"../fr.eseo.jatl.atltypeinference/ATLTypingHelpers.atl"
								), true)
							]
			}, #[
					rs.getResource(URI.createFileURI(
						"../fr.eseo.jatl.atltypeinference/ATOLLibrary.atl"
					), true)
			]],
			#["UML2Ecore", #{
				"IN"	->	#[
								rs.getResource(URI.createFileURI(
									"../examples/fr.eseo.atol.examples.rules/testcases/UML2Ecore.atl"
								), true)
							],
				"UML"	->	#[UMLPackage.eINSTANCE.eResource]
			}, #[
					rs.getResource(URI.createFileURI(
						"../fr.eseo.jatl.atltypeinference/ATOLLibrary.atl"
					), true)
			]],
//*
			#["Ecore2UML", #{
				"IN"	->	#[
								rs.getResource(URI.createFileURI(
									"../examples/fr.eseo.atol.examples.rules/testcases/Ecore2UML.atl"
								), true)
							],
				"UML"	->	#[UMLPackage.eINSTANCE.eResource]
			}, #[
					rs.getResource(URI.createFileURI(
						"../fr.eseo.jatl.atltypeinference/ATOLLibrary.atl"
					), true)
			]],
/**/
			#["UMLObject2JFX", #{
				"IN"	->	#[
								rs.getResource(URI.createFileURI(
									"../examples/fr.eseo.atlc.example.umlclassobject/src/fr/eseo/atlc/example/umlclassobject/UMLObject2JFX.atl"
								), true),
								rs.getResource(URI.createFileURI(
									"../examples/fr.eseo.atlc.example.umlclassobject/src/fr/eseo/atlc/example/umlclassobject/CommonDiagramHelpers.atl"
								), true)
								// TODO: +xtend helpers in UMLObject2JFX.xtend?
							],
				"UML"	->	#[UMLPackage.eINSTANCE.eResource],
				"JFX"	->	#[
								rs.getResource(URI.createFileURI(
									"../examples/fr.eseo.aof.examples.javafx/models/javafx.ecore"
								), true)
							],
				"Constraints"	-> #[]
			}, #[
					rs.getResource(URI.createFileURI(
						"../fr.eseo.jatl.atltypeinference/ATOLLibrary.atl"
					), true)
			]],
			#["UMLClass2JFX", #{
				"IN"	->	#[
								rs.getResource(URI.createFileURI(
									"../examples/fr.eseo.atlc.example.umlclassobject/src/fr/eseo/atlc/example/umlclassobject/UMLClass2JFX.atl"
								), true),
								rs.getResource(URI.createFileURI(
									"../examples/fr.eseo.atlc.example.umlclassobject/src/fr/eseo/atlc/example/umlclassobject/CommonDiagramHelpers.atl"
								), true)
								// TODO: +xtend helpers in UMLObject2JFX.xtend?
							],
				"UML"	->	#[UMLPackage.eINSTANCE.eResource],
				"JFX"	->	#[
								rs.getResource(URI.createFileURI(
									"../examples/fr.eseo.aof.examples.javafx/models/javafx.ecore"
								), true)
							],
				"Constraints"	-> #[]
			}, #[
					rs.getResource(URI.createFileURI(
						"../fr.eseo.jatl.atltypeinference/ATOLLibrary.atl"
					), true)
			]]
/*
			,#["CPS2Deployment-explicitRuleCall", #{
				"IN"	->	#[
								rs.getResource(URI.createFileURI(
									"../../aof/private/org.eclipse.incquery.examples.cps.xform.m2m.atl/src/fr/eseo/atol/examples/cps/CPS2Deployment-explicitRuleCall.atl"
								), true)
							],
				"CPS"	->	#[
								rs.getResource(URI.createFileURI(
									System.getProperty("user.home") + "/git/org.eclipse.viatra.examples/cps/domains/org.eclipse.viatra.examples.cps.model/model/model.ecore"
								), true)
							],
				"Deployment"	->	#[
									rs.getResource(URI.createFileURI(
										System.getProperty("user.home") + "/git/org.eclipse.viatra.examples/cps/domains/org.eclipse.viatra.examples.cps.deployment/model/deployment.ecore"
									), true)
								]
			}, #[
					rs.getResource(URI.createFileURI(
						"../fr.eseo.jatl.atltypeinference/ATOLLibrary.atl"
					), true)
			]]
/**/
		]
	}

	def static <E> E trustMe(Object it) {
		it as E
	}

	@Parameter(0)
	public String name
	@Parameter(1)
	public Map<String, List<Resource>> models
	@Parameter(2)
	public Iterable<Resource> extraBuiltinLibraries

	@Test
	def void test() {
		println("**** " + name)
		val rs = new ResourceSetImpl
		rs.resourceFactoryRegistry.extensionToFactoryMap.put("atl", new AtlResourceFactoryImpl)

		//  Map<String, List<Resource>>
		val commonModels =
				#{
					"Ecore"			-> #[EcorePackage.eINSTANCE.eResource],
					"OCLLibrary"	-> #[
											extraBuiltinLibraries,
											#[
												rs.getResource(URI.createFileURI(
													"../fr.eseo.jatl.atltypeinference/OCLLibrary.atl"
												), true)
											]
										].flatten,
					"ATL"			-> #[
										OCLPackage.eINSTANCE.eResource,
										ATLPackage.eINSTANCE.eResource
									]
				}

		extension val ti = new ATLTypeInference(
			trustMe(models.union(commonModels))
		)

		XMLConcreteSyntaxVariableResolver.register(ti)

		check
//		checks(ti)
	}

	// Also implemented in ATL, which is the version we use by default
	def static checks(extension ATLTypeInference ti) {
/*
--		ATL!Operation.allInstances()->collect(e |
--			let actual : OclType = e.body.inferredType in
--			let expected : OclType = e.returnType.toPlatform in
--			(
--			 	if e.class.oclIsUndefined() then
--					'<' + e.type.name + '>'
--				else
--					e.class.name
--				endif + '.' + e.name + '@' + e.location).assertEquals(expected, actual, 'returnType')
--		),
*/
			for(op : Operation.allInstancesFrom("IN")) {
				val actual = op.body.inferredType
				val expected = op.returnType.toPlatform
				if(actual !== expected) {
					println("Operation " + op.name + ": " + actual.asTypeString + " should be " + expected.asTypeString)
				}
			}
			for(attr : Attribute.allInstancesFrom("IN")) {
				val actual = attr.initExpression.inferredType
				val expected = attr.type.toPlatform
				if(actual !== expected) {
					println("Attribute " + attr.name + ": " + actual.asTypeString + " should be " + expected.asTypeString)
				}
			}
/*
		-- IteratorExps with predicate lambdas
--		ATL!IteratorExp.allInstances()->select(e | thisModule.iteratorsWithPredicate->includes(e.name))->collect(e |
--			let actual : OclType = e.body.inferredType in
--			let expected : OclType = 'Boolean'.primitiveType in
--			('select@' + e.location).assertEquals(expected, actual, 'body')
--		),
*/
			for(e : IteratorExp.allInstancesFrom("IN").filter[ti.iteratorsWithPredicate.contains(name)]) {
				val actual = e.body.inferredType
				val expected = "Boolean".primitiveType
				if(actual !== expected) {
					println("IteratorExp with predicate at " + e.location + ": " + actual.asTypeString + " should be " + expected.asTypeString)
				}
			}
/*
--		-- IfExp.condition
--		ATL!IfExp.allInstances()->collect(e |
--			let actual : OclType = e.condition.inferredType in
--			let expected : OclType = 'Boolean'.primitiveType in
--			('IfExp@' + e.location).assertEquals(expected, actual, 'condition')
--		),
*/
			for(e : IfExp.allInstancesFrom("IN")) {
				val actual = e.condition.inferredType
				val expected = "Boolean".primitiveType
				if(actual !== expected) {
					println("IfExp condition at " + e.location + ": " + actual.asTypeString + " should be " + expected.asTypeString)
				}
			}
/*
--		-- LetExp
--		ATL!LetExp.allInstances()->collect(e |
--			let actual : OclType = e.variable.initExpression.inferredType in
--			let expected : OclType = e.variable.type.toPlatform in
--			('LetExp@' + e.location).assertEquals(expected, actual, 'initExpression')
--		),
*/
			for(e : LetExp.allInstancesFrom("IN")) {
				val actual = e.variable.initExpression.inferredType
				val expected = e.variable.type.toPlatform
				if(actual !== expected) {
					println("LetExp at " + e.location + ": " + actual.asTypeString + " should be " + expected.asTypeString)
				}
			}
/*
--		-- Binding value
--		ATL!Binding.allInstances()->collect(e |
--			let actual : OclType = e.value.inferredType in
--			let expected : OclType = e.outPatternElement.type.toPlatform.navigableProperties->any(p |
--				p.name = e.propertyName
--			).actualType in
--			if expected.isClass then
--				''	-- TODO: this depends on the rule(s) matched by the source elements...
--			else
--				('Binding@' + e.location).assertEquals(expected, actual, 'value')
--			endif
--		),
*/
/*
--		ATL!OperationCallExp.allInstances()->collect(e | e.inferredType)	-- force resolution of all operations to detect unfound ones
*/
	}
}