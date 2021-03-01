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

import fr.eseo.jatl.atltypeinference.ATLTypeInferenceMemorizer
import fr.eseo.jatl.atltypeinference.XMLConcreteSyntaxVariableResolver
import java.nio.file.Files
import java.nio.file.Paths
import java.util.List
import java.util.Map
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.xmi.XMLResource
import org.eclipse.m2m.atl.common.ATL.ATLPackage
import org.eclipse.m2m.atl.common.OCL.OCLPackage
import org.eclipse.m2m.atl.common.OCL.OclExpression
import org.eclipse.m2m.atl.common.OCL.OclModelElement
import org.eclipse.m2m.atl.common.OCL.VariableExp
import org.eclipse.m2m.atl.emftvm.compiler.AtlResourceFactoryImpl
import org.junit.Assert
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
class ATLTypeInferenceMemorizerTest {
	@Parameters(name = "{0}")
	def static List<Object[]> main() {
		ATLTypeInferenceTest.main
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

		extension val ti = new ATLTypeInferenceMemorizer(
			trustMe(models.union(commonModels))
		)

		XMLConcreteSyntaxVariableResolver.register(ti)

		for(oe : OclExpression.allInstancesFrom('IN').reject[
			if(it instanceof VariableExp) {
				referredVariable.varName == "thisModule"
			} else {
				false
			}
		]) {
			val inferredType = inferredType(oe)
			if(inferredType !== null) {
				val type = t(ToOCL(
					inferredType
				))
//				println(type)
			    oe.setType(type);
			}
		}

		for(source : models.get('IN')) {
			val actualFilePath = '''resources/actual/«source.URI.lastSegment».inferred.xmi'''
			val expectedFilePath = '''resources/expected/«source.URI.lastSegment».inferred.xmi'''

			val target = rs.createResource(URI.createFileURI(actualFilePath))
			for(om : OclModelElement.allInstancesFrom(source).map[model].toSet.filter[eResource !== source]) {
				source.contents.add(om)
			}

			target.contents.addAll(
				EcoreUtil.copyAll(source.contents)
			)
			val options = #{
				XMLResource.OPTION_PROCESS_DANGLING_HREF -> XMLResource.OPTION_PROCESS_DANGLING_HREF_THROW
			}
			target.save(options)


			val actualContents = Files.readAllLines(Paths.get(actualFilePath)).join("\n")
			val expectedContents = Files.readAllLines(Paths.get(expectedFilePath)).join("\n")
			Assert.assertEquals(expectedContents.normalize, actualContents.normalize)
		}
	}

	def normalize(String it) {
		replaceAll(" location=\"[^\"]*\"", "")
		.replaceAll(" *<commentsBefore>[^<]*</commentsBefore>\n", "")
		.replaceAll(" *<commentsAfter>[^<]*</commentsAfter>\n", "")
	}
}