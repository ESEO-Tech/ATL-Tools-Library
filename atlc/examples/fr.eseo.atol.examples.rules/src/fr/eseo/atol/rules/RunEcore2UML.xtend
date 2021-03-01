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

import fr.eseo.atol.gen.ATOLInterpreter
import fr.eseo.atol.gen.AbstractRule
import java.io.File
import java.io.FileWriter
import java.nio.charset.Charset
import java.nio.file.FileSystems
import java.nio.file.Files
import java.util.Collection
import java.util.Collections
import java.util.HashMap
import java.util.HashSet
import java.util.List
import java.util.Set
import java.util.function.BiConsumer
import javax.xml.transform.OutputKeys
import javax.xml.transform.TransformerException
import javax.xml.transform.TransformerFactory
import javax.xml.transform.stream.StreamResult
import javax.xml.transform.stream.StreamSource
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.ETypeParameter
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.resource.impl.URIMappingRegistryImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.xmi.XMIResource
import org.eclipse.emf.ecore.xmi.XMLResource
import org.eclipse.emf.ecore.xmi.impl.EcoreResourceFactoryImpl
import org.eclipse.m2m.atl.common.ATL.ATLPackage
import org.eclipse.m2m.atl.common.OCL.OCLPackage
import org.eclipse.m2m.atl.common.PrimitiveTypes.PrimitiveTypesPackage
import org.eclipse.uml2.types.TypesPackage
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Classifier
import org.eclipse.uml2.uml.DataType
import org.eclipse.uml2.uml.EnumerationLiteral
import org.eclipse.uml2.uml.Generalization
import org.eclipse.uml2.uml.MultiplicityElement
import org.eclipse.uml2.uml.NamedElement
import org.eclipse.uml2.uml.Operation
import org.eclipse.uml2.uml.Package
import org.eclipse.uml2.uml.Parameter
import org.eclipse.uml2.uml.ParameterableElement
import org.eclipse.uml2.uml.Property
import org.eclipse.uml2.uml.TemplateParameter
import org.eclipse.uml2.uml.TemplateSignature
import org.eclipse.uml2.uml.UMLPackage
import org.eclipse.uml2.uml.resource.UML402UMLResource
import org.eclipse.uml2.uml.resource.UMLResource
import org.eclipse.uml2.uml.resources.util.UMLResourcesUtil
import org.eclipse.xtend.core.xtend.XtendPackage
import org.eclipse.xtext.xbase.XbasePackage
import org.eclipse.xtext.xbase.annotations.xAnnotations.XAnnotationsPackage
import org.eclipse.xtext.xtype.XtypePackage
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Parameterized
import org.junit.runners.Parameterized.Parameters

import static org.junit.Assert.*

@RunWith(Parameterized)
class RunEcore2UML {
	static val checkAsserts = true
	static val rs = new ResourceSetImpl

	static val saveOptions = new HashMap => [
//			put(XMLResource.OPTION_USE_ENCODED_ATTRIBUTE_STYLE, false)
			// trying to mimic original UML.ecore to simplify comparison with diff
//			put(XMLResource.OPTION_LINE_WIDTH, 80)
			// this URI handler is here to make the serialized .ecore file closer to UML.ecore
			/* Remaining differences between original UML.ecore and round-tripped output we get as of 20180605:
			 * - EStructuralFeature.{volatile,transient,unsettable} have no equivalent in UML
			 * - some URIs have several variants (see remark below about http...Ecore vs. platform...Ecore.ecore
			 * - EClass.interface is not handled yet (only used for ActivityContent)
			 * Some brittle fixes:
			 * - EEnumLiteral.value has no equivalent in UML, but the values used in UML.ecore can be recomputed with indexOf
			 * Remaining differences between original Ecore.ecore and round-tripped output we get as of 20180605:
			 * - EReference.resolveProxies has no equivalent in UML
			 * - EStructuralFeature.{transient,unsettable}
			 * - order of DataTypes at the end of the .xmi file
			 */
			put(XMLResource.OPTION_URI_HANDLER, new URIHandler)
		]

	static class URIHandler implements XMLResource.URIHandler {
		var URI baseURI
		override deresolve(URI uri) {
			if(uri.trimFragment == baseURI) {
				uri.trimSegments(uri.segmentCount)
			} else if(uri.trimFragment.toString == "http://www.eclipse.org/uml2/5.0.0/Types") {
				URI.createURI("platform:/plugin/org.eclipse.uml2.types/model/Types.ecore").appendFragment(uri.fragment)
			// always for some elements: EModelElement, EObject, EAnnotation, EClass, EString, EPackage
			// others (i.e., EJavaObject, EMap, EDiagnosticChain) can appear as either URI 
			} else if(uri.trimFragment.toString == "http://www.eclipse.org/emf/2002/Ecore" && uri.fragment.matches("EModelElement|EObject|EAnnotation|EClass|EString|EPackage$")) {
				URI.createURI("platform:/plugin/org.eclipse.emf.ecore/model/Ecore.ecore").appendFragment(uri.fragment)
			} else {
				uri
			}
		}
		
		override resolve(URI uri) {
			uri
		}
		
		override setBaseURI(URI uri) {
			this.baseURI = uri
		}
	}

	def static void main(String[] args) {
		init
//		println((Thread.currentThread.contextClassLoader as URLClassLoader).URLs.map[
//			URLDecoder.decode(it.file, "UTF-8")
//		].join(":"))

//		UMLUtil.init(rs)


		// load a sample
		var r = rs.getResource(URI
			.createFileURI("../fr.eseo.atol.examples.ecore2jfx/models/test.ecore"), true)
		// or use Ecore itself
		r = EcorePackage.eINSTANCE.EClass.eResource

		// or use UML.ecore
		r = UMLPackage.eINSTANCE.class_.eResource

		// or use Alf.ecore
//		r = AlfPackage.eINSTANCE.assignableElement.eResource

		// or use last parameter
		r = data.last.get(1) as Resource

		new RunEcore2UML("", r, true).testTuplePatterns
	}

	@Parameters(name = "{index}: {0}")
	def static Collection<Object[]> data() {
		init
		#[
			#["Ecore", EcorePackage.eINSTANCE.EClass.eResource, false],
			#["UML", UMLPackage.eINSTANCE.class_.eResource, true],
			#["ATL", {
				val r = rs.createResource(URI.createURI("testcases/ATL/ATL-out-original.ecore"))
				r.contents.addAll(
					EcoreUtil.copyAll(#[
						ATLPackage.eINSTANCE.module.eResource.contents,
						OCLPackage.eINSTANCE.oclExpression.eResource.contents,
						PrimitiveTypesPackage.eINSTANCE.string.eResource.contents
					].flatten.toList)
				)
				r.save(saveOptions)
				r
			}, false],
			#["Xbase", {
				val r = rs.createResource(URI.createURI("testcases/xbase/xbase-out-original.ecore"))
				r.contents.addAll(
					EcoreUtil.copyAll(#[
						XbasePackage.eINSTANCE.XAbstractFeatureCall.eResource.contents,
						org.eclipse.xtext.common.types.TypesPackage.eINSTANCE.jvmAnnotationAnnotationValue.eResource.contents
					].flatten.toList)
				)
				r.save(saveOptions)
				r
			}, true],
			#["Xtend", {
				val r = rs.createResource(URI.createURI("testcases/xtend/xtend-out-original.ecore"))
				r.contents.addAll(
					EcoreUtil.copyAll(#[
						XtendPackage.eINSTANCE.xtendClass.eResource.contents,
						XtypePackage.eINSTANCE.XComputedTypeReference.eResource.contents,
						XAnnotationsPackage.eINSTANCE.XAnnotation.eResource.contents,
						XbasePackage.eINSTANCE.XAbstractFeatureCall.eResource.contents,
						org.eclipse.xtext.common.types.TypesPackage.eINSTANCE.jvmAnnotationAnnotationValue.eResource.contents
					].flatten.toList)
				)
				r.save(saveOptions)
				r
			}, true],
			#["test1", rs.getResource(URI.createFileURI("testcases/test1/test1-in.ecore"), true), true],
			{
				val alf = getAlf
				if(alf !== null) {
					#["Alf", alf, true]
				} else {
					#["Alf not found, skipping", null, false]
				}
			}
		]
	}

	def static getAlf() {
//		try {
//			AlfPackage.eINSTANCE.assignedSource.eResource
//		} catch(NoClassDefFoundError e) {
//			null
//		}
		try {
			val c = java.lang.Class.forName("org.eclipse.papyrus.uml.alf.AlfPackage")
			val eINSTANCE = c.getField("eINSTANCE").get(null) as EPackage
			eINSTANCE.getEClassifier("AssignedSource").eResource
		} catch(ClassNotFoundException e) {
			null
		}
	}

	static var inited = false

//	@BeforeClass// not called before data(), better call it from there
	def static void init() {
		if(!inited) {
			inited = true
			val uri = URI.createURI(UMLResourcesUtil.pluginURL + '/')
			URIMappingRegistryImpl.INSTANCE.put(URI.createURI(UMLResource.LIBRARIES_PATHMAP), uri.appendSegment("libraries").appendSegment(""))
			URIMappingRegistryImpl.INSTANCE.put(URI.createURI(UMLResource.METAMODELS_PATHMAP), uri.appendSegment("metamodels").appendSegment(""))
			URIMappingRegistryImpl.INSTANCE.put(URI.createURI(UMLResource.PROFILES_PATHMAP), uri.appendSegment("profiles").appendSegment(""))
	
			val resourceFactoryRegistry = Resource.Factory.Registry.INSTANCE	// rs.resourceFactoryRegistry
			resourceFactoryRegistry.extensionToFactoryMap.put(
				"ecore",
				new EcoreResourceFactoryImpl
			)
			resourceFactoryRegistry.extensionToFactoryMap.put(
				"uml",
				UML402UMLResource.Factory.INSTANCE
			)
	
			// register default instances for (some) source metamodel types (required by AOF1 for Ecore2UML)
			Ecore.ENamedElement.defaultInstance = Ecore.EClass.defaultInstance
			Ecore.ETypedElement.defaultInstance = Ecore.EAttribute.defaultInstance
			Ecore.EClassifier.defaultInstance = Ecore.EClass.defaultInstance
	
			// register default values for (some) source metamodel types (for UML2Ecore)
			UML.TypedElement.defaultInstance = UML.Property.defaultInstance
			UML.TemplateableElement.defaultInstance = UML.Class.defaultInstance
			UML.ParameterableElement.defaultInstance = UML.Class.defaultInstance
			UML.NamedElement.defaultInstance = UML.Class.defaultInstance
		}
	}

	new(String name, Resource r, boolean requiresExternalElementsRegistrations) {
		this.r = r
		this.mmName = (r?.contents?.get(0) as EPackage)?.name
		this.fileBase = '''testcases/«mmName»/«mmName»-out'''
		this.requiresExternalElementsRegistrations = requiresExternalElementsRegistrations
	}

	var Resource r

	var String mmName

	var String fileBase

//	val requiringExternalElementsRegistrations = #["uml", "alf", "xbase", "xtend"]
	var requiresExternalElementsRegistrations = false

	@Test
	def void testTuplePatterns() {
		if(r === null) return	// skipping unavailable test cases

		val e2ut = new Ecore2UML
		val u2et = new UML2Ecore

//		if(requiringExternalElementsRegistrations.contains(mmName)) {
		if(requiresExternalElementsRegistrations) {
			rs.registerExternalElementsForEcore2UML(e2ut.EDataType2PrimitiveType, e2ut.EClassifier2TemplateSignature, e2ut.ETypeParameter2ClassifierTemplateParameter, e2ut.EClass2Class)
		}

//		if(requiringExternalElementsRegistrations.contains(mmName)) {
		if(requiresExternalElementsRegistrations) {
			rs.registerExternalElementsForUML2Ecore(u2et.DataType2EDataType, u2et.Class2EClass)
		}

		testEcore2UML2Ecore([
			e2ut.EPackage2Package(it).t
		])[
			u2et.Package2EPackage(it).t
		]
	}

	@Test
	def void testListPatterns() {
		if(r === null) return	// skipping unavailable test cases

		val e2ut = new Ecore2UMLListPatterns
		val u2et = new UML2EcoreListPatterns

//		if(requiringExternalElementsRegistrations.contains(mmName)) {
		if(requiresExternalElementsRegistrations) {
			rs.registerExternalElementsForEcore2UML(e2ut.EDataType2PrimitiveType, e2ut.EClassifier2TemplateSignature, e2ut.ETypeParameter2ClassifierTemplateParameter, e2ut.EClass2Class)
		}

//		if(requiringExternalElementsRegistrations.contains(mmName)) {
		if(requiresExternalElementsRegistrations) {
			rs.registerExternalElementsForUML2Ecore(u2et.DataType2EDataType, u2et.Class2EClass)
		}

		testEcore2UML2Ecore([
			e2ut.EPackage2Package(it).t
		])[
			u2et.Package2EPackage(it).t
		]
	}

	@Test
	def void testATOLInterpreter() {
		if(r === null) return	// skipping unavailable test cases

		val mms = #{
			"Ecore" -> EcorePackage.eINSTANCE,
			"UML" -> UMLPackage.eINSTANCE
		}
		val e2ut = new ATOLInterpreter("testcases/Ecore2UML.atl", mms)
		val u2et = new ATOLInterpreter("testcases/UML2Ecore.atl", mms)

		if(requiresExternalElementsRegistrations) {
			rs.registerExternalElementsForEcore2UML(
				[e2ut.register1To1("EDataType2PrimitiveType", $0, $1)],
				[e2ut.register1To1("EClassifier2TemplateSignature", $0, $1)],
				[e2ut.register("ETypeParameter2ClassifierTemplateParameter", $0, $1, $2)],
				[e2ut.register1To1("EClass2Class", $0, $1)]
			)
		}

		if(requiresExternalElementsRegistrations) {
			rs.registerExternalElementsForUML2Ecore(
				[u2et.register1To1("DataType2EDataType", $0, $1)],
				[u2et.register1To1("Class2EClass", $0, $1)]
			)
		}

		testEcore2UML2Ecore([
			e2ut.apply("EPackage2Package", it).get("t") as Package
		])[
			u2et.apply("Package2EPackage", it).get("t") as EPackage
		]
	}

	def testEcore2UML2Ecore((EPackage)=>Package e2u, (Package)=>EPackage u2e) {
		r
			.ecore2UML(e2u)
			.uml2Ecore(u2e)
	}

	def ecore2UML(Resource r, (EPackage)=>Package e2u) {
		// Transform to UML
		val t = rs.createResource(URI.createFileURI('''«fileBase».uml''')) as XMLResource
		t.contents.addAll(
			r.contents.map[
				e2u.apply(it as EPackage)
			]
//			.apply(
//				new SourceTupleEPackage2Package(r.contents.get(0) as EPackage)
//			).t
//			.apply(
//				ImmutableList.of(r.contents.get(0))
//			).get(0) as EObject
		)

		// setting xmi:ids to qualified names
		t.setXMIIDs

		t.save(Collections.emptyMap)
		transform('''«fileBase».uml''', '''«fileBase»-sorted.uml''')
		// not necessary each time (but better to do it here than with xsltproc because of differences like encoding, ordering lower vs. upper case):
		transform('''«fileBase»-official.uml''', '''«fileBase»-official-sorted.uml''')
		if(checkAsserts) {
			assertFileEquals("The UML files differ", 
				'''«fileBase»-expected.uml''', 
				'''«fileBase».uml'''
			)
		}
		t
	}

	def readFile(String f) {
		Files.readAllLines(FileSystems.^default.getPath(f), Charset.forName("utf-8")).join("\n")
	}

	def assertFileEquals(String msg, String expected, String actual) {
		assertEquals(msg, 
			expected.readFile,
			actual.readFile
		)
	}

	def uml2Ecore(Resource t, (Package)=>EPackage u2e) {
		// Transforming back to Ecore
		val t2 = rs.createResource(URI.createFileURI('''«fileBase».ecore'''))

		t2.contents.addAll(
			t.contents.map[
				u2e.apply(it as Package)
			]
//			.apply(
//				new SourceTuplePackage2EPackage(t.contents.get(0) as Package)
//			).t
//			.apply(
//				ImmutableList.of(t.contents.get(0))
//			).get(0) as EObject
		)
		t2.save(saveOptions)

		transform('''«fileBase».ecore''', '''«fileBase»-adapted.ecore''')
		// not necessary each time (but better to do it here than with xsltproc because of differences like encoding, ordering lower vs. upper case):
		transform('''«fileBase»-original.ecore''', '''«fileBase»-original-adapted.ecore''')
		if(checkAsserts) {
			assertFileEquals("The Ecore files differ", 
				'''«fileBase»-expected.ecore''', 
				'''«fileBase».ecore''' 
			)
		}
		t2
	}

	static class StringExt {
		def static replace(String it, String a, String b) {
			replaceFirst(a, b)
		}
	}

	def transform(String in, String out) {
		val fin = new File(in)
		if(fin.exists) {
			val xmlInput = new StreamSource(fin)
			val xsl = new StreamSource(new File(
				if(in.endsWith(".uml")) {
					"testcases/adaptUMLForDiff.xsl"
				} else {
					"testcases/adaptEcoreForDiff.xsl"
				}
			))
			val xmlOutput = new StreamResult(new FileWriter(out))
			
			try {
				// https://stackoverflow.com/questions/1384802/java-how-to-indent-xml-generated-by-transformer
			    val tf = TransformerFactory.newInstance => [
			    	setAttribute("indent-number", "2")
			    ]
			    tf.newTransformer(xsl) => [
					setOutputProperty(OutputKeys.INDENT, "yes")
				    transform(xmlInput, xmlOutput)
			    ]
			} catch (TransformerException e) {
				throw new RuntimeException(e)
			}
		}
	}

	// target element accessor for ListPatterns
	def <E> t(List<Object> l) {
		l.get(0) as E
	}

	interface TriConsumer<A, B, C> {
		def void accept(A a, B b, C c)
	}

	// only when applying Ecore2UML to the UML metamodel itself!
	def static registerExternalElementsForEcore2UML(ResourceSet rs, AbstractRule EDataType2DataType, AbstractRule EClassifier2TemplateSignature, AbstractRule ETypeParameter2ClassifierTemplateParameter, AbstractRule EClass2Class) {
		rs.registerExternalElementsForEcore2UML(
			[EDataType2DataType.register1To1($0, $1)],
			[EClassifier2TemplateSignature.register1To1($0, $1)],
			[ETypeParameter2ClassifierTemplateParameter.register($0, $1, $2)],
			[EClass2Class.register1To1($0, $1)]
		)
	}

	def static registerExternalElementsForEcore2UML(ResourceSet rs, BiConsumer<EDataType, DataType> EDataType2DataType, BiConsumer<EClassifier, TemplateSignature> EClassifier2TemplateSignature, TriConsumer<ETypeParameter, TemplateParameter, ParameterableElement> ETypeParameter2ClassifierTemplateParameter, BiConsumer<EClass, Class> EClass2Class) {
		rs.registerExternalElements([e, u |
	       	EDataType2DataType
	       	.accept(e, u)
//	       	.register(
///*
//				new SourceTupleEDataType2DataType(e),
//				new TargetTupleEDataType2DataType(u as DataType)
///*/
//	       		e,
//	       		u// as DataType
///**/
//	       	)
			if(u.ownedTemplateSignature !== null) {
				EClassifier2TemplateSignature.accept(
					e,
					u.ownedTemplateSignature
				)
				u.ownedTemplateSignature.ownedParameters.forEach[up, i |
					ETypeParameter2ClassifierTemplateParameter.accept(
						e.ETypeParameters.get(i),
						up,
						up.parameteredElement
					)
				]
			}
		])[e, u |
	       	EClass2Class
	       	.accept(e, u)
//	       	.register(
///*
//				new SourceTupleEClass2Class(e),
//				new TargetTupleEClass2Class(u as Class)
///*/
//	       		e,
//	       		u// as DataType
///**/
//	       	)
			// WONTFIX[not necessary]: register TemplateSignature if necessary (like for EDataType2DataType)
		]
	}

	def static getDataType(extension Resource r, String it) {
		EObject as DataType
	}

	def static getClass(extension Resource r, String it) {
		EObject as Class
	}

	def static registerExternalElements(ResourceSet rs, BiConsumer<EDataType, DataType> f, BiConsumer<EClass, Class> g) {
        val umlPrimTypes = rs.getResource(URI.createURI(UMLResource.UML_PRIMITIVE_TYPES_LIBRARY_URI), true) as XMIResource
        val ecorePrimTypes = rs.getResource(URI.createURI(UMLResource.ECORE_PRIMITIVE_TYPES_LIBRARY_URI), true) as XMIResource
        val ecoreMM = rs.getResource(URI.createURI(UMLResource.ECORE_METAMODEL_URI), true) as XMIResource

       	f.accept(
       		TypesPackage.eINSTANCE.boolean,
       		umlPrimTypes.getDataType("Boolean")
       	)
       	f.accept(
       		TypesPackage.eINSTANCE.string,
       		umlPrimTypes.getDataType("String")
       	)
       	f.accept(
       		TypesPackage.eINSTANCE.real,
       		umlPrimTypes.getDataType("Real")
       	)
       	f.accept(
       		TypesPackage.eINSTANCE.integer,
       		umlPrimTypes.getDataType("Integer")
       	)
       	f.accept(
       		TypesPackage.eINSTANCE.unlimitedNatural,
       		umlPrimTypes.getDataType("UnlimitedNatural")
       	)
       	f.accept(
       		EcorePackage.eINSTANCE.EBoolean,
       		ecorePrimTypes.getDataType("EBoolean")
       	)
       	f.accept(
       		EcorePackage.eINSTANCE.EString,
       		ecorePrimTypes.getDataType("EString")
       	)
       	f.accept(
       		EcorePackage.eINSTANCE.EDiagnosticChain,
       		ecorePrimTypes.getDataType("EDiagnosticChain")
       	)
       	f.accept(
       		EcorePackage.eINSTANCE.EMap,
       		ecorePrimTypes.getDataType("EMap")
       	)
       	f.accept(
       		EcorePackage.eINSTANCE.EJavaObject,
       		ecorePrimTypes.getDataType("EJavaObject")
       	)
       	// For ALF:
       	f.accept(
       		EcorePackage.eINSTANCE.EIntegerObject,
       		ecorePrimTypes.getDataType("EIntegerObject")
       	)
       	f.accept(
       		EcorePackage.eINSTANCE.EBigInteger,
       		ecorePrimTypes.getDataType("EBigInteger")
       	)
//       	// For ATL:
//       	f.accept(
//       		PrimitiveTypesPackage.eINSTANCE.string,
//       		ecorePrimTypes.getDataType("EString")
//       	)
       	// For Xbase:
       	f.accept(
       		EcorePackage.eINSTANCE.EChar,
       		ecorePrimTypes.getDataType("EChar")
       	)
       	f.accept(
       		EcorePackage.eINSTANCE.EInt,
       		ecorePrimTypes.getDataType("EInt")
       	)
       	f.accept(
       		EcorePackage.eINSTANCE.ELong,
       		ecorePrimTypes.getDataType("ELong")
       	)
       	f.accept(
       		EcorePackage.eINSTANCE.EShort,
       		ecorePrimTypes.getDataType("EShort")
       	)
       	f.accept(
       		EcorePackage.eINSTANCE.EByte,
       		ecorePrimTypes.getDataType("EByte")
       	)
       	f.accept(
       		EcorePackage.eINSTANCE.EDouble,
       		ecorePrimTypes.getDataType("EDouble")
       	)
       	f.accept(
       		EcorePackage.eINSTANCE.EFloat,
       		ecorePrimTypes.getDataType("EFloat")
       	)

       	g.accept(
       		EcorePackage.eINSTANCE.EObject,
       		ecoreMM.getClass("EObject")
       	)
       	g.accept(
       		EcorePackage.eINSTANCE.EModelElement,
       		ecoreMM.getClass("EModelElement")
       	)
       	g.accept(
       		EcorePackage.eINSTANCE.EClass,
       		ecoreMM.getClass("EClass")
       	)
       	g.accept(
       		EcorePackage.eINSTANCE.EAnnotation,
       		ecoreMM.getClass("EAnnotation")
       	)
       	g.accept(
       		EcorePackage.eINSTANCE.EPackage,
       		ecoreMM.getClass("EPackage")
       	)
       	g.accept(
       		EcorePackage.eINSTANCE.ENamedElement,
       		ecoreMM.getClass("ENamedElement")
       	)
	}

	// only when applying UML2Ecore to the UML metamodel itself!
	def static registerExternalElementsForUML2Ecore(ResourceSet rs, AbstractRule DataType2EDataType, AbstractRule Class2EClass) {
		rs.registerExternalElementsForUML2Ecore([DataType2EDataType.register1To1($0, $1)], [Class2EClass.register1To1($0, $1)])
	}

	def static registerExternalElementsForUML2Ecore(ResourceSet rs, BiConsumer<DataType, EDataType> DataType2EDataType, BiConsumer<Class, EClass> Class2EClass) {
		rs.registerExternalElements([e, u |
	       	DataType2EDataType
	       	.accept(u, e)
//	       	.register(
///*
//				new SourceTupleDataType2EDataType(u as DataType),
//				new TargetTupleDataType2EDataType(e)
///*/
//	       		u,
//	       		e
///**/
//	       	)
		])[e, u |
	       	Class2EClass
	       	.accept(u, e)
//	       	.register(
///*
//				new SourceTupleClass2EClass(u as Class),
//				new TargetTupleClass2EClass(e)
///*/
//	       		u,
//	       		e
///**/
//	       	)
		]
	}

	def static String getPluginURL(java.lang.Class<?> c) {
		var url = c.getResource(c.simpleName + ".class").toString
		url.replaceAll("![^!]*$", "!")
	}

	def static setXMIIDs(XMLResource it) {
		contents.forEach[e, i |
			setXMIIDs(e, null, null, true, i, new HashSet)
		]
	}

	def static void setXMIIDs(extension XMLResource t, EObject it, String parentID, String propertyName, boolean many, int index, Set<String> usedIDs) {
		var nestedUsedIDs_ = usedIDs
		var id =
			switch it {
				Classifier case propertyName == "nestedClassifier",
				EnumerationLiteral, Property, Operation, Parameter case name !== null: '''«parentID»-«name»'''
				Classifier case propertyName != "ownedParameteredElement": {
					nestedUsedIDs_ = new HashSet
					name
				}
				default: {
					'''«
						IF parentID !== null»«parentID»-«ENDIF
						»_«
						IF propertyName !== null»«propertyName»«ENDIF
						»«IF many»«IF propertyName !== null».«ENDIF»«index»«ENDIF»'''
				}
			}
		val baseID = id
		var k = 1
		while(usedIDs.contains(id)) {
			id = '''«baseID».«k»'''
			k++
		}
		setID(id)
		usedIDs.add(id)

		val nestedUsedIDs = nestedUsedIDs_
		for(ref : eClass.EAllReferences.filter[containment]) {
			val v = eGet(ref)
			if(ref.many) {
				val id_ = id;
				(v as Iterable<EObject>).forEach[e, i |
					t.setXMIIDs(e, id_, ref.name, ref.many, i, nestedUsedIDs)
				]
			} else if(v !== null) {
				t.setXMIIDs(v as EObject, id, ref.name, ref.many, -1, nestedUsedIDs)
			}
		}
	}

	def static oldSetXMIIDs(extension XMLResource t) {
		allContents.forEach[
			if(it instanceof NamedElement) {
				if(qualifiedName !== null) {
					setID(it, qualifiedName)
					switch it {
						MultiplicityElement: {
							setID(lowerValue, '''«qualifiedName».lower''')
							setID(upperValue, '''«qualifiedName».upper''')
						}
						Classifier: {
							templateBindings.forEach[b, i |
								val id = '''«qualifiedName»-_templateBinding.«i»'''
								setID(b, id)
								b.parameterSubstitutions.forEach[p, j |
									setID(p, '''«id»-_parameterSubstitution.«j»''')
								]
							]
							val id = '''«qualifiedName»-_ownedTemplateSignature'''
							setID(ownedTemplateSignature, id)
							ownedTemplateSignature?.ownedParameters?.forEach[p, i |
								val id2 = '''«id»-_ownedParameter.«i»'''
								setID(p, id2)
								setID(p.ownedParameteredElement, '''«id2»-_ownedParameteredElement''')
							]
						}
					}
				}
			} else if(it instanceof Generalization) {
				setID(it, specific.qualifiedName + '.extends.' + general.qualifiedName)
			}
		]
	}
}
