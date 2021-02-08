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

package fr.eseo.atol.gen

import com.google.common.collect.ImmutableList
import com.google.common.collect.ImmutableMap
import com.google.common.collect.ImmutableMultiset
import com.google.common.collect.ImmutableSet
import fr.eseo.aof.exploration.OCLByEquivalence
import java.util.ArrayList
import java.util.Collection
import java.util.Collections
import java.util.Comparator
import java.util.HashMap
import java.util.List
import java.util.Map
import java.util.Objects
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.m2m.atl.common.ATL.Binding
import org.eclipse.m2m.atl.common.ATL.Helper
import org.eclipse.m2m.atl.common.ATL.InPattern
import org.eclipse.m2m.atl.common.ATL.InPatternElement
import org.eclipse.m2m.atl.common.ATL.LazyMatchedRule
import org.eclipse.m2m.atl.common.ATL.Library
import org.eclipse.m2m.atl.common.ATL.MatchedRule
import org.eclipse.m2m.atl.common.ATL.Module
import org.eclipse.m2m.atl.common.ATL.ModuleElement
import org.eclipse.m2m.atl.common.ATL.OutPattern
import org.eclipse.m2m.atl.common.ATL.OutPatternElement
import org.eclipse.m2m.atl.common.ATL.PatternElement
import org.eclipse.m2m.atl.common.ATL.Query
import org.eclipse.m2m.atl.common.ATL.RuleVariableDeclaration
import org.eclipse.m2m.atl.common.ATL.Unit
import org.eclipse.m2m.atl.common.OCL.Attribute
import org.eclipse.m2m.atl.common.OCL.BagExp
import org.eclipse.m2m.atl.common.OCL.BagType
import org.eclipse.m2m.atl.common.OCL.BooleanExp
import org.eclipse.m2m.atl.common.OCL.BooleanType
import org.eclipse.m2m.atl.common.OCL.CollectionExp
import org.eclipse.m2m.atl.common.OCL.CollectionOperationCallExp
import org.eclipse.m2m.atl.common.OCL.CollectionType
import org.eclipse.m2m.atl.common.OCL.EnumLiteralExp
import org.eclipse.m2m.atl.common.OCL.IfExp
import org.eclipse.m2m.atl.common.OCL.IntegerExp
import org.eclipse.m2m.atl.common.OCL.IntegerType
import org.eclipse.m2m.atl.common.OCL.Iterator
import org.eclipse.m2m.atl.common.OCL.IteratorExp
import org.eclipse.m2m.atl.common.OCL.LetExp
import org.eclipse.m2m.atl.common.OCL.NavigationOrAttributeCallExp
import org.eclipse.m2m.atl.common.OCL.OclAnyType
import org.eclipse.m2m.atl.common.OCL.OclExpression
import org.eclipse.m2m.atl.common.OCL.OclFeature
import org.eclipse.m2m.atl.common.OCL.OclModelElement
import org.eclipse.m2m.atl.common.OCL.OclType
import org.eclipse.m2m.atl.common.OCL.OclUndefinedExp
import org.eclipse.m2m.atl.common.OCL.Operation
import org.eclipse.m2m.atl.common.OCL.OperationCallExp
import org.eclipse.m2m.atl.common.OCL.OperatorCallExp
import org.eclipse.m2m.atl.common.OCL.OrderedSetExp
import org.eclipse.m2m.atl.common.OCL.OrderedSetType
import org.eclipse.m2m.atl.common.OCL.Parameter
import org.eclipse.m2m.atl.common.OCL.PrimitiveExp
import org.eclipse.m2m.atl.common.OCL.RealExp
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
import org.eclipse.m2m.atl.emftvm.compiler.AtlResourceFactoryImpl
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.IUnaryFunction
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.file.FileLocations
import org.eclipse.xtend.lib.macro.file.FileSystemSupport
import org.eclipse.xtend2.lib.StringConcatenationClient
import org.eclipse.papyrus.aof.core.IBinaryFunction

// TODO[compiler]:
//	- ALMOST DONE fix tuple pattern inheritance for super rules that are not abstract
//		- replace wrapping constructor with factory method for all target tuple patterns
//			- this will fix it for super rules that are not abstract, and is not a problem for the others
//			=> temporarily added an unchecked cast
//		- DONE add appropriate type arguments to TupleRule type arguments
//			- and wrap class literals by calls to TupleRule.gen so that the right Class<?> type arguments can be inferred
//	- add errors
//		- when using @ATOLGen without some attributes
//	- separate the immutable part to support immutable compilation
//		- supporting immutable collections would require duplicating collection code, but this is already necessary
//		for immutable collections
//	- test on viatra benchmark
//		- then publish and recontact TomTom
//	- test incrementality (e.g., on viatra benchmark)
//	- refactor compiler to improve it
//	- add ATL error&warning markers to .atl file instead of to .xtend file
//		but there is no support for this from xtend
//	- add SMAP entry for ATL so that we can debug at the ATL level
//		but xtend does not give us access to
//			- output line numbers
//			- SMAP
//		we could annotate the generated Java file with comments (like we already do for bindings)
//		and leverage that information to generate a SMAP afterwards
//	- why is the transformation parsed more than twice (i.e., once for registering globals and one for code generation) during a compilation?
//	- collapse sequences of functions into one collect, for instance:
//		OCL:			not mutableA.oclIsUndefined()
//		Current Java:	mutableA.collect((e) -> e == null).collect((e) -> !e)
//		Objective:		mutableA.collect((e) -> !(e == null))
//			Or:			mutableA.collect((e) -> e != null)
// TODO[ATL features]:
//	- support for multiple source metamodels
//	- tuples & zip
//	- regular rules
//	- guards
// TODO[semantics]:
//	- aligned ATOL semantics with ATL semantics (may require "improving" ATL semantics)
//		- rule inheritance
//			- child rule selection in ATL could improve prioritizing more specific rules by considering source pattern
//			element types (even though this is only a partial order)
//				- there is an example for this in UML2Ecore.atl (Enumeration2EEnum vs. DataType2PrimitiveType)
// DONE:
//	- make ListPatternCompiler work again?
//		at least useful to improve modularity of compiler
//	- Why are some classes imported, and others fully qualified? is it because we use CharSequence as return type of compile methods?
//		- should we return StringConcatenation{,Client} from compile method? => YES
//	- rule inheritance
//	- automate some tests (e.g., Ecore2UML & UML2Ecore on UML.ecore & Ecore.ecore with result diff)
//	- zipWith (using a tuple discarded by the compiler)
//	- handle the case of non-abstract rules with children
//		- works for TemplateParameter2ETypeParameter in UML2Ecore
@Active(ATOLGenProcessor)
annotation ATOLGen {
	/**
	 * Path to transformation, relative to project. Must be in the same project as the class using this annotation.
	 */
	String transformation
	Metamodel[] metamodels
	String[] libraries = #[]
	PatternKind patternKind = PatternKind.Tuple
	Class<? extends Extension>[] extensions = #[]

	enum PatternKind {
		List, Tuple
	}
	
	annotation Metamodel {
		String name
		Class<?> impl
	}

	interface Extension {
		def StringConcatenationClient compileBinding(Binding binding, CompilationHelper compilationHelper)
	}

	@Data
	static abstract class PatternCompiler {

		def boolean registersClasses() {
			false
		}

		def void registerClasses(Module it, ClassDeclaration c, extension RegisterGlobalsContext context) {}

		def void populateClasses(Module it, extension CompilationHelper compilationHelper) {}

		def StringConcatenationClient header(LazyMatchedRule rule, ClassDeclaration cd, extension TransformationContext context, extension CompilationHelper compilationHelper);
		
		def TypeReference type(LazyMatchedRule it, ClassDeclaration cd, extension TransformationContext context, extension CompilationHelper compilationHelper)

		abstract def StringConcatenationClient computeCollectTo(OperationCallExp it, extension CompilationHelper compilationHelpers)
		
		def abstract Class<? extends AbstractRule> ruleClass()
		
		def StringConcatenationClient accessTargetElement(NavigationOrAttributeCallExp it, extension CompilationHelper compilationHelper)
	}

	@Data
	static class ListPatternCompiler extends PatternCompiler {

		override header(LazyMatchedRule rule, ClassDeclaration cd, extension TransformationContext context, extension CompilationHelper compilationHelper) {
			'''
				new «ListRule»(«ImmutableList».of(
					«IF rule.inPattern.elements.forall[type instanceof OclModelElement]»
						«FOR e : rule.inPattern.elements SEPARATOR ","»
							«e.type.convertToMetaclass»
						«ENDFOR»
					«ELSE»«ENDIF»
				), «ImmutableList».of(
					«FOR e : rule.outPattern.allElements SEPARATOR ","»
						«e.type.convertToMetaclass»
					«ENDFOR»
				), (in, out) -> {
					«FOR e : rule.inPattern.elements.indexed»
						«e.value.type.convert» «e.value.varName» = («e.value.type.convert»)in.get(«e.key»);
					«ENDFOR»
					«FOR e : rule.outPattern.allElements.indexed»
						«e.value.type.convert» «e.value.varName» = («e.value.type.convert»)out.get(«e.key»);
					«ENDFOR»
			'''
		}

		override type(LazyMatchedRule it, ClassDeclaration cd, extension TransformationContext context, extension CompilationHelper compilationHelper) {
			ListRule.newTypeReference
		}

		override computeCollectTo(OperationCallExp it, extension CompilationHelper compilationHelpers) {
			'''
				«ListRule».collectTo(
					«
						source.compile
					»,
					«
						arguments.actualRules.map[
							'''this.«name»'''
						].join(", ")
					»
				)'''
		}

		override ruleClass() {
			ListRule
		}

		def List<String> calledRule(OclExpression it, extension CompilationHelper compilationHelper) {
			switch it {
				OperationCallExp case operationName == "collectTo": {
					arguments.actualRules.findFirst[true].outPattern.allElements.map[varName]
				}
				OperationCallExp case calledRule !== null: {
					calledRule.outPattern.allElements.map[varName]
				}
				IteratorExp: {
					body.calledRule(compilationHelper)
				}
				IfExp: {
					thenExpression.calledRule(compilationHelper)
				}
				default: {
					println('''«cd.simpleName»:warning: could not get rule called for «eClass.name» at «location»''')
					null
				}
			}
		}

		override accessTargetElement(NavigationOrAttributeCallExp it, extension CompilationHelper compilationHelper) {
			val cr = source.calledRule(compilationHelper)
			val tgtIdx = if(cr !== null) {
				cr.indexOf(name)
			} else {
				0
			}
			// TODO: use lift
			if(isMutable) {
				'''
					«source.compile».collect((«internalIteratorName») ->
						«internalIteratorName» == null ?
							null
						:
							«AbstractRule».autoCast(«internalIteratorName».get(«tgtIdx»))
					)'''
			} else {
				'''«AbstractRule».autoCast(«source.compile».get(«tgtIdx»))'''
			}
		}

		def StringConcatenationClient ruleCall(MatchedRule it) {
			'''
				this.«name».apply(
					«ImmutableList».of(
						«FOR it : inPattern.elements SEPARATOR ","»
							«varName»
						«ENDFOR»
					)
				)'''
		}

		override populateClasses(Module it, extension CompilationHelper compilationHelper) {
			val cd = cd as MutableClassDeclaration
			extension val context = compilationHelper.context
			elements.filter(LazyMatchedRule).forEach[
				cd.addMethod(name)[m |
					inPattern.elements.forEach[
						m.addParameter(varName, type.convert)
					]
					m.returnType = ImmutableList.newTypeReference(Object.newTypeReference)
					if(children.empty) {
						m.body = '''
							return «ruleCall»;'''
					} else {
						val v = inPattern.elements.map[varName].toList
						m.body = '''
							return
								«FOR rule : #[it].allRules»
									(«FOR e : rule.inPattern.elements.indexed SEPARATOR "&&"»«
										v.get(e.key)» instanceof «e.value.type.convert
									»«ENDFOR») ?
										«rule.ruleCall»
									:«ENDFOR»(«FOR e : inPattern.elements.indexed SEPARATOR "&&"»«
										v.get(e.key)» == null«ENDFOR») ?
									null
								:
									«AbstractRule».throwException(
										new «UnsupportedOperationException»("No rule matching (" + «
										FOR e : inPattern.elements.indexed SEPARATOR '+, "+"'»«
											v.get(e.key)
										»«ENDFOR» + ")")
									)
							;
						'''
					}
				]
			]
		}
	}

	@Data
	static class TuplePatternCompiler extends PatternCompiler {
		override boolean registersClasses() {
			true
		}

		def String tupleClass(MatchedRule it, ClassDeclaration c, String pos) {
			'''«c.qualifiedName».«pos»Tuple«name»'''
		}

		def sourceTupleClass(MatchedRule it, ClassDeclaration c) {
			tupleClass(c, "Source")
		}

		def targetTupleClass(MatchedRule it, ClassDeclaration c) {
			tupleClass(c, "Target")
		}

		override void registerClasses(Module it, ClassDeclaration c, extension RegisterGlobalsContext context) {
			elements.filter(LazyMatchedRule).forEach[
				registerClass(sourceTupleClass(c))
				registerClass(targetTupleClass(c))
			]
		}

		def List<? extends PatternElement> elements(MatchedRule it, (MatchedRule)=>List<? extends PatternElement> elementsAccessor) {
			if(it === null) {
				#[]
			} else {
				val elements = elementsAccessor.apply(it)
				val ret = new ArrayList(
					superRule.elements(elementsAccessor).map[supE |
						val subE = elements.findFirst[varName == supE.varName]
						if(subE !== null) {
							subE
						} else {
							supE
						}
					].toList
				)
				ret.addAll(elements.filter[a |
					!ret.exists[b | a.varName == b.varName]
				])
				ret
			}
		}

		def subOnlyElements(List<? extends PatternElement> elements, List<? extends PatternElement> superElements) {
			elements.filter[subE | !superElements.exists[supE | subE.varName == supE.varName]]
		}

		def addTypeParameters(LazyMatchedRule it, (MatchedRule)=>List<? extends PatternElement> elementsAccessor, String pos, extension CompilationHelper compilationHelper, boolean addCreationConstructor) {
			extension val context = compilationHelper.context
			val s = tupleClass(cd, pos).findClass
			val superElements = superRule.elements(elementsAccessor)
			superElements.forEach[e |
				if(!children.empty) {
					val sub = elements(elementsAccessor).findFirst[it.varName == e.varName]
					s.addTypeParameter(e.varName.toUpperCase, sub.type.convert).newTypeReference
				}
			]
			elementsAccessor.apply(it).subOnlyElements(superElements).forEach[e |
				if(!children.empty) { 
					s.addTypeParameter(e.varName.toUpperCase, e.type.convert)
				}
			]
		}

		def populateClass(LazyMatchedRule it, (MatchedRule)=>List<? extends PatternElement> elementsAccessor, String pos, extension CompilationHelper compilationHelper, boolean addCreationConstructor) {
			extension val context = compilationHelper.context
			val s = tupleClass(cd, pos).findClass
			val elements = elementsAccessor.apply(it) as List<PatternElement>
			val superElements = superRule.elements(elementsAccessor)
			val supToActual = superElements.toMap([it])[supE |
				elements.findFirst[subE |
					subE.varName == supE.varName
				] ?: supE
			]
			val subOnlyElements = elements.subOnlyElements(superElements)
			val c = s.addConstructor[c |
				c.body = '''
					super(«superElements.map[varName].join(", ")»);
					«FOR e : subOnlyElements»
						this.«e.varName» = «e.varName»;
					«ENDFOR»
				'''
			]
			if(addCreationConstructor && !isAbstract) {
				// adding target element creation constructor
				s.addConstructor[c2 |
					c2.body = '''
						super(«superElements.map[e |
							'''«IF !children.empty»(«supToActual.get(e).varName.toUpperCase»)«ENDIF»«supToActual.get(e).type.convertToMetaclass».newInstance()'''
						].join(", ")»);
						«FOR e : subOnlyElements»
							this.«e.varName» = «
							IF !children.empty
								»(«e.varName.toUpperCase»)«
							ENDIF»«e.type.convertToMetaclass».newInstance();
						«ENDFOR»
					'''
				]
			}
			val sup2Type = new HashMap
			superElements.forEach[e, i |
				val t =
					if(!children.empty) {
						s.typeParameters.get(i).newTypeReference
					} else {
						supToActual.get(e).type.convert
					}
				sup2Type.put(e, t)
				c.addParameter(e.varName, t)
			]
			if(superRule !== null) {
				s.extendedClass = superRule.tupleClass(cd, pos).findClass.newTypeReference(
					superElements.map[
//						supToActual.get(it).type.convert
						sup2Type.get(it)
					]
				)
			}
			subOnlyElements.forEach[e, i |
				val t = if(!children.empty) { 
					s.typeParameters.get(superElements.size + i).newTypeReference
				} else {
					e.type.convert
				}
				c.addParameter(e.varName, t)
				s.addField(e.varName)[f |
					f.type = t
					f.final = true
					f.visibility = Visibility.PUBLIC
				]
			]

			val allElements = new ArrayList(superElements.map[supToActual.get(it)])
			allElements.addAll(subOnlyElements)
			s.addMethod("equals")[
				returnType = Boolean.TYPE.newTypeReference
				addParameter("o", Object.newTypeReference)
				val gen =
					if(s.typeParameters.empty) {
						""
					} else {
						'''<«s.typeParameters.map["?"].join(", ")»>'''
					}
				body = '''
					if(o instanceof «s.simpleName») {
						«s.simpleName»«gen» o2 = («s.simpleName»«gen»)o;
						return
							«FOR it : allElements SEPARATOR " &&"»
								«Objects».equals(this.«varName», o2.«varName»)
							«ENDFOR»
						;
					} else {
						return false;
					}
					
				'''
			]
			s.addMethod("hashCode")[
				returnType = Integer.TYPE.newTypeReference
				body = '''
					return «Objects».hash(«allElements.map[varName].join(", ")»);
				'''
			]

			if(pos == "Source") {
				// adding method to call rule
				val cd = cd as MutableClassDeclaration
				cd.addMethod(name)[m |
					m.returnType = targetTupleClass(cd).findClass.newTypeReference(
						if(children.empty) {
							#[]
						} else {
							outPattern.allElements.map[
								newWildcardTypeReference(type.convert)
							]
						}
					)//(s.typeParameters.map[newWildcardTypeReference])
					allElements.forEach[e |
						m.addParameter(e.varName, e.type.convert)
					]
					m.body = '''
						return
							«IF !children.empty»
								«#[it].allRules.ruleSelector(
									compilationHelper, allElements.map['''«varName»''']
								)»
							«ELSE»
								«name».apply(new «s»(«
									allElements.map[varName].join(", ")
								»))
							«ENDIF»
						;
					'''
				]
			}

			s
		}

		override void populateClasses(Module it, extension CompilationHelper compilationHelper) {
			elements.filter(LazyMatchedRule).forEach[
				addTypeParameters([inPattern.elements], "Source", compilationHelper, false)
				addTypeParameters([outPattern.elements], "Target", compilationHelper, true)
			]
			elements.filter(LazyMatchedRule).forEach[
				populateClass([inPattern.elements], "Source", compilationHelper, false)
				populateClass([outPattern.elements], "Target", compilationHelper, true)
			]
		}

		override header(LazyMatchedRule rule, ClassDeclaration cd, extension TransformationContext context, extension CompilationHelper compilationHelper) {
//			compilationHelper.cd.
//SourceTuple«rule.name», TargetTuple«rule.name»
			val StringConcatenationClient preClass =
				if(rule.children.empty) {
					''''''
				} else {
					'''«TupleRule».gen('''
				}
			val StringConcatenationClient postClass =
				if(rule.children.empty) {
					''''''
				} else {
					''')'''
				}
			'''
				new «rule.type(cd, context, compilationHelper)»(
				«preClass»SourceTuple«rule.name».class«postClass»,
				«preClass»TargetTuple«rule.name».class«postClass»,
				(in, out) -> {
					«FOR e : rule.inPattern.elements»
						«e.type.convert» «e.varName» = in.«e.varName»;
					«ENDFOR»
					«FOR e : rule.outPattern.allElements»
						«e.type.convert» «e.varName» = out.«e.varName»;
					«ENDFOR»
			'''
		}

		override type(LazyMatchedRule it, ClassDeclaration cd, extension TransformationContext context, extension CompilationHelper compilationHelper) {
			TupleRule.newTypeReference(
				sourceTupleClass(cd).toString.findClass.newTypeReference(
					if(children.empty) {
						#[]
					} else {
						inPattern.allElements.map[
							type.convert
						]
					}
				),
				targetTupleClass(cd).toString.findClass.newTypeReference(
					if(children.empty) {
						#[]
					} else {
						outPattern.allElements.map[
							type.convert
						]
					}
				)
			)
		}

		def firstType(MatchedRule it, extension CompilationHelper compilationHelpers) {
			inPattern.elements.findFirst[true].type.convert
		}

		def StringConcatenationClient ruleSelector(Iterable<MatchedRule> it, extension CompilationHelper compilationHelper, String...v) {
//			val extension context = compilationHelper.context
			
			'''
				«FOR rule : it»
					(«FOR e : rule.inPattern.elements.indexed SEPARATOR "&&"»«
						v.get(e.key)» instanceof «e.value.type.convert
					»«ENDFOR») ?
						this.«rule.name».apply(new SourceTuple«rule.name»«
							if(rule.children.empty) {
								''''''
							} else {
								'''
									«FOR e : rule.inPattern.allElements BEFORE "<" SEPARATOR ", " AFTER ">"»«
										e.type.convert
									»«ENDFOR»'''
							}
						»(
							«FOR e : rule.inPattern.elements.indexed SEPARATOR ","»
								(«e.value.type.convert»)«v.get(e.key)»
							«ENDFOR»
						))
					:«ENDFOR»(«FOR e : findFirst[true].inPattern.elements.indexed SEPARATOR "&&"»«
						v.get(e.key)» == null«ENDFOR») ?
					null
				:
					«AbstractRule».throwException(
						new «UnsupportedOperationException»("No rule matching (" + «
						FOR e : findFirst[true].inPattern.elements.indexed SEPARATOR ' + ", " + '»«
							v.get(e.key)
						»«ENDFOR» + ")")
					)
			'''
		}

		override computeCollectTo(OperationCallExp it, extension CompilationHelper compilationHelpers) {
			val rules = arguments.actualRules
			// TODO: support more than one source element
			// TODO: when only one argument, call the rule method instead of duplicating selection
			// when more arguments, it may be better to do rule selection here
			if(!rules.empty) {	// in case no rule was found
				'''
					«source.compile».collect((«internalIteratorName») ->
						«rules.ruleSelector(compilationHelpers, internalIteratorName)»
					)'''
			}
		}

		override ruleClass() {
			TupleRule
		}

		override accessTargetElement(NavigationOrAttributeCallExp it, extension CompilationHelper compilationHelper) {
			// TODO: use lift
			if(isMutable) {
				'''
					«source.compile».collect((«internalIteratorName») ->
						«internalIteratorName» == null ?
							null
						:
							«internalIteratorName».«name»
					)'''
			} else {
				'''«source.compile».«name»'''
			}
		}
	}

	class ATOLGenProcessor extends AbstractClassProcessor {
		var extension PatternCompiler patternCompiler
		public static val boolean immutableTuples = true

		val tupleClasses = new HashMap<Object, Pair<String, TupleType>>
		override doRegisterGlobals(ClassDeclaration it, extension RegisterGlobalsContext context) {
			val annotation = findAnnotation(ATOLGen.findUpstreamType)
			val patternKind = annotation.getEnumValue("patternKind")?.simpleName

			patternCompiler = switch patternKind {
				case PatternKind.List.name: new ListPatternCompiler
				case null,
				case PatternKind.Tuple.name: new TuplePatternCompiler
				default: throw new IllegalStateException('''Unrecognized pattern kind: «patternKind»''')
			}

			val r = annotation.getStringValue("transformation").load(it, context, false)
			val unit = r.contents.get(0)
			if(registersClasses) {
				if(unit instanceof Module) {
					unit.registerClasses(it, context)
				}
			}

			if(!immutableTuples) {
				// register mutable tuple classes
				unit.eAllContents.filter(TupleType).forEach[tt, i |
					tupleClasses.computeIfAbsent(tt.toCanonic)[e |
						val cl = '''«it.qualifiedName».MutableTuple«i»'''
						registerClass(cl)
						cl -> tt
					]
				]
			}
		}

		static def dispatch Object toCanonic(OclType it) {
			throw new UnsupportedOperationException('''Cannot convert to OCL String: «it»''')
		}

		static def dispatch Object toCanonic(SequenceType it) {
			ImmutableList.of("Sequence", elementType.toCanonic)
		}

		static def dispatch Object toCanonic(OclModelElement it) {
			ImmutableList.of("Metaelement", model.name, name)
		}

		static def dispatch Object toCanonic(OclAnyType it) {
			ImmutableList.of("OclAny")
		}

		static def dispatch Object toCanonic(TupleType it) {
			ImmutableList.copyOf(#[#["Tuple"], attributes.map[name]].flatten)
			// We ignore types until we have full static type analysis
			//attributes.stream.collect(ImmutableMap.toImmutableMap([name])[type.toCanonic])
		}

		// TODO: if we use TuplePatternCompiler, then we parse the .atl file twice
		def <E extends FileLocations&FileSystemSupport> load(String tf, ClassDeclaration it, extension E e, boolean addPbmMarkers) {
			val rs = new ResourceSetImpl
			rs.resourceFactoryRegistry.extensionToFactoryMap.put("atl", new AtlResourceFactoryImpl)

			// did not manage to make it work with the tf in another project than the one containing the class being compiled
			val tfPath = getProjectFolder(compilationUnit.filePath).append(tf)
//			tfPath.contents	// to make the compiled xtend file depend on the .atl file
			tfPath.contentsAsStream.close	// same thing without loading the file
			val tfURI = tfPath.toURI

			// TODO:
			// - finish this to get the actual problem model on which we will be able to call MarkerMaker.resetPbmMarkers
			//		problem: workspace is closed (at least according to what we can get from the current class loader)
//			val pbs = if(addPbmMarkers) {
//				val parser = AtlParser.^default
//				val modelFactory = new EMFModelFactory
//				val pbs_ = modelFactory.newModel(parser.problemMetamodel) as EMFModel
//				rs.loadOptions.put("problems", pbs_)
//				pbs_
//			}

			val r = rs.getResource(URI.createURI(tfURI.toString), true)

//			if(addPbmMarkers) {
//				rs.loadOptions.remove("problems")
////				println("test")
//val xtendFile = compilationUnit.class.getDeclaredMethod("getXtendFile").invoke(compilationUnit)
//val eResource = xtendFile.class.getMethod("eResource").invoke(xtendFile)
//val uri = eResource.class.getMethod("getURI").invoke(eResource)
//				val cl = uri.class.classLoader
//				println(cl)
//				println(cl.loadClass(ResourcesPlugin.name).getDeclaredMethod("getWorkspace").invoke(null))
//				println("test2")
//				new MarkerMaker()
////					.resetPbmMarkers(
//					.applyMarkers(
//						ResourcesPlugin.workspace.root.getFileForLocation(new Path(tfPath.toString)),
////						pbs.resource.contents.toArray(<EObject>newArrayOfSize(pbs.resource.contents.size))
//						pbs
//				)
//				println(pbs.resource.contents)
//			}

			r
		}

		def dispatch sourceMetamodelName(Module it) {
			inModels.findFirst[
				true
			].metamodel.name
		}

		def dispatch sourceMetamodelName(Unit it) {
			eAllContents.filter(OclModelElement).findFirst[true].model.name
		}

		override doTransform(MutableClassDeclaration it, extension TransformationContext context) {
			try {
				actualDoTransform(context)
			} catch(Exception e) {
				e.printStackTrace
				throw e
			}
		}
		def actualDoTransform(MutableClassDeclaration it, extension TransformationContext context) {
			val ann = findAnnotation(ATOLGen.findTypeGlobally)
			val tf = ann
						.getStringValue("transformation")
			val mms = ann
						.getAnnotationArrayValue("metamodels")
						.toMap([
							getStringValue("name")
						])[
							getClassValue("impl")
						]
			mms.forEach[k, v |
				addField('''«k»«CompilationHelper.mmSuffix»''')[
					type = v
					initializer = '''new «v»()'''
//					static = true	// DONE: get rid of staticity (currently necessary for tuple classes)
					final = true
					visibility = Visibility.PUBLIC
				]
			]
			val exts = ann.getClassArrayValue("extensions").map[
				Class.forName(it.name).newInstance as Extension
			]
//  org.eclipse.core.resources;bundle-version="3.12.0",
// org.eclipse.xtend.core;bundle-version="2.12.0"
//val xtendFile = compilationUnit.class.getDeclaredMethod("getXtendFile").invoke(compilationUnit)
//val eResource = xtendFile.class.getMethod("eResource").invoke(xtendFile)
//val errorsM = eResource.class.getMethod("getErrors")
//val errors = errorsM.invoke(eResource) as List
//val itf = (errorsM.genericReturnType as ParameterizedType).actualTypeArguments.get(0) as Class<?>
//	errors.add(
//		Proxy.getProxyClass(eResource.class.classLoader, itf)
//			.getConstructor(InvocationHandler)
//			.newInstance(new InvocationHandler {
//				override invoke(Object proxy, Method method, Object[] args) throws Throwable {
//					switch(method.name) {
//						case "getLocation": "/fr.eseo.atol.rules/Ecore2UML.atl"
//						case "getLine",
//						case "getColumn": 1
//						case "getMessage": "YES"
//						default: throw new UnsupportedOperationException
//					}
//				}
//				
//			})
//	)
			val r = tf.load(it, context, true)
			r.errors.forEach[error |
				addError(error.toString)
//				println('''«tf»:error: «error»''')
			]
			r.warnings.forEach[warning |
				addWarning(warning.toString)
//				println('''«tf»:warning: «warning»''')
			]
			if(r.errors.isEmpty) {
				val unit = r.contents.get(0) as Unit
				val extension compilationHelpers = new CompilationHelper(
					it,
					mms,
					context,
					unit.sourceMetamodelName,
					patternCompiler,
					unit,
					exts,
					tupleClasses
				)
				ann.getStringArrayValue("libraries")?.forEach[l |
					val lib = l.load(it, context, true).contents.get(0) as Library
					compilationHelpers.helpers.addAll(lib.helpers)
					processHelpers(context, compilationHelpers, lib)
				]
				compilationHelpers.helpers.addAll(unit.helpers)
				processHelpers(context, compilationHelpers, unit)
				switch unit {
					Module: {
						populateClasses(unit, compilationHelpers)

						// populate mutable tuple classes
						tupleClasses.values.forEach[tc |
							val cl = tc.key.findClass
							tc.value.attributes.forEach[a |
								cl.addField(a.name)[
									type = a.type.convertTupleAttributeType(cl)
									visibility = Visibility.PUBLIC
								]
								addMethod('''_«a.name»''')[
									addParameter("self", cl.newTypeReference)
									returnType = a.type.convertTupleAttributeType(cl)
									body = '''return self.«a.name»;'''
								]
								addMethod('''«a.name»''')[
									addParameter("self", IBox.newTypeReference(cl.newTypeReference))
									returnType = a.type.convertTupleAttributeType(cl)
									// TODO: handle null?
									body = '''return self.collectMutable(e -> e.«a.name»);'''
								]
							]
							cl.addConstructor[
								tc.value.attributes.forEach[a |
									addParameter(a.name, a.type.convertTupleAttributeType(cl))
								]
								body = '''
									«FOR a : tc.value.attributes»
										this.«a.name» = «a.name»;
									«ENDFOR»
								'''
							]
						]

						unit.elements.filter(LazyMatchedRule).filter[
							!isAbstract
						].forEach[rule |
							addField(rule.name)[
								visibility = Visibility.PUBLIC
								type = rule.type(compilationHelpers.cd, context, compilationHelpers)
								final = true
								initializer = '''
	«««					Empty "in" list when not matchable
									«rule.header(cd, context, compilationHelpers)»
										«FOR e : rule.variables»
											«IF e.initExpression.isMutable»
												«IBox.newTypeReference(e.type.convert)» «e.varName» = «e.initExpression.compile»;
											«ELSE»
												«e.type.convert» «e.varName» = «e.initExpression.compile»;
											«ENDIF»
										«ENDFOR»
										«FOR e : rule.outPattern.allElements.indexed»
											«FOR b : e.value.allBindings»
												// «tf»#«b.location»
«««												«FOR ext : exts»
«««													
«««												«ENDFOR»
												«compileBinding(e, b)»
											«ENDFOR»
										«ENDFOR»
									})
								'''
							]
						]
						if(unit.isIsRefining) {
							val refiningRules = unit.elements.filter(MatchedRule).filter[
								!((it instanceof LazyMatchedRule) || isAbstract)
							]
							refiningRules.forEach[rule |
								addMethod('''refine«rule.name»''')[
									// TODO: support additional source elements
									val ipe = rule.inPattern.elements.get(0)
									addParameter(ipe.varName, ipe.type.convert)
									// DONE: support additional target elements
									body = '''
										«IF rule.outPattern.allElements.length > 1»
											«Map»<«String», «Object»> newElements = new «HashMap»<>();
											trace.put(«ipe.varName», newElements);
										«ENDIF»
										«FOR ope : rule.outPattern.allElements.indexed»
											«IF ope.key > 0»
												«ope.value.type.convert» «ope.value.varName» = «ope.value.type.mmClass».«ope.value.type.name».newInstance();
												newElements.put("«ope.value.varName»", «ope.value.varName»);
											«ENDIF»
											«FOR b : ope.value.allBindings»
												// «tf»#«b.location»
												«compileBinding(
													if(ope.key === 0) {
														0 -> ipe
													} else {
														ope
													}, b
												)»
											«ENDFOR»
										«ENDFOR»
									'''
								]
							]
							addMethod("refine")[
								addParameter("r", Resource.newTypeReference)
								body = '''
									«FOR rule : refiningRules»
										onceForEach(allContents(r, «rule.inPattern.elements.get(0).type.convertToMetaclass»),
											(e) -> {
												refine«rule.name»(e);
												return null;
											},
											(e, f) -> {},
											(e, f) -> {}
										);
									«ENDFOR»
								'''
							]
						}
					}
					Query: {
						addMethod("__query")[
							returnType = Object.newTypeReference
							if(unit.body.isMutable) {
								returnType = IBox.newTypeReference(returnType)
							}
							body = '''return «unit.body.compile»;'''
						]
					}
				}
			}
		}

		def processHelpers(MutableClassDeclaration it, extension TransformationContext context, extension CompilationHelper compilationHelpers, Unit unit) {
				unit.helpers.forEach[helper |
					val feature = helper.definition.feature
					switch feature {
						Operation: {
							var rt_ = feature.returnType.convert
							val rt = if(feature.body.isMutable) {
								IBox.newTypeReference(rt_)
							} else {
								rt_
							}
							val params = feature.parameters.map[p |
								var pt = if(p.type.class == CollectionType) {
									IBox.newTypeReference(p.type.convert.actualTypeArguments)
								} else {
									p.type.convert
								}
								p.mangledVarName -> pt
							].toList
							val cacheOp = feature.definition.context_ === null
							if(cacheOp) {
								addField('''_«feature.name»OpCache''')[
									type = Map.newTypeReference(List.newTypeReference, rt)
									initializer = '''new «HashMap»<>()'''
								]
							}
							addMethod(feature.name)[
								returnType = rt
								if(feature.definition.context_ !== null) {
									addParameter(SELF, feature.definition.context_.context_.convert)
								}
								params.forEach[p |
									addParameter(p.key, p.value)
								]
								// DONE: add cache
								if(cacheOp) {
									// TODO: add SELF to __key__ if necessary
									body =	'''
												«ImmutableList» __key__ = ImmutableList.of(
													«FOR p : params SEPARATOR ","»
														«p.key»
													«ENDFOR»
												);
												«rt» ret = _«feature.name»OpCache.get(__key__);
												if(ret == null) {
													// TODO#«feature.body.location»
													ret = «feature.body.compile»;
													_«feature.name»OpCache.put(__key__, ret);
												}
												return ret;
											'''
								} else {
									body = '''
										// TODO#«feature.body.location»
										return «feature.body.compile»;
									'''
								}
							]
						}
						Attribute: {
							var rt_ = feature.type.convert
							if(feature.initExpression.isMutable) {
								val t =
									if(feature.type.class == CollectionType) {
										rt_.actualTypeArguments.get(0)
									} else {
										rt_
									}
								rt_ = IBox.newTypeReference(t)
							}
							val rt = rt_
							val helperContext = feature.definition.context_?.context_
							if(helperContext !== null) {
								var contextType_ = helperContext.convert
								val contextType = if(Collection.newTypeReference.isAssignableFrom(contextType_)) {
									// TODO: handle this better
									IBox.newTypeReference(contextType_.actualTypeArguments.get(0))
								} else {
									contextType_
								}
								// DONE: added cache
								// TODO: make weak?
								addField('''_«feature.name»Cache''')[
									type = Map.newTypeReference(contextType, rt)
									initializer = '''new «HashMap»<>()'''
								]
								addMethod('''_«feature.name»''')[
									addParameter(SELF, contextType)
									returnType = rt
									body =	'''
												«rt» ret = _«feature.name»Cache.get(«SELF»);
												if(ret == null) {
													// TODO#«feature.initExpression.location»
													ret = «feature.initExpression.compile»;
													_«feature.name»Cache.put(«SELF», ret);
												}
												return ret;
											'''
								]
								val cl = it
								addMethod(feature.name)[
									addParameter("b", IBox.newTypeReference(contextType.newWildcardTypeReference))
									// DONE: immutable => collect instead of collectMutable + cache
									if(feature.initExpression.isMutable) {
										// DONE: but collectMutable requires a constant lambda => DO IT
										returnType = rt
										body = '''
											return b.collectMutable(«feature.name»Lambda);'''
										cl.addField('''«feature.name»Lambda''')[
											type = IUnaryFunction.newTypeReference(contextType, rt)
											initializer = expLambda(#[internalIteratorName], '''
												(«internalIteratorName» == null) ?
													«AbstractRule».emptySequence()
												:
													_«feature.name»(«internalIteratorName»)
											''')
										]
									} else {
										// TODO: add cache for immutable features only, because collectMutable already does it
										returnType = IBox.newTypeReference(rt)
										body = '''
											return b.collect((«internalIteratorName») ->
												_«feature.name»(«internalIteratorName»)
											);'''
									}
								]
							} else {
								addField(feature.name)[
									type = rt
									initializer = '''«feature.initExpression.compile»'''
								]
							}
						}
						default: throw new IllegalStateException
					}
				]
		}
	}

	@Data
	class CompilationHelper {
		final extension ClassDeclaration cd
		final Map<String, TypeReference> mms
		final extension TransformationContext context
		// TODO: support more than one source metamodel
		final String sourceMM
		final extension PatternCompiler patternCompiler
		final Unit unit
		val Extension[] extensions
		val Map<Object, Pair<String, TupleType>> tupleClasses

// Begin Type conversion
		dispatch def convertToMetaclass(OclType it) {
			throw new UnsupportedOperationException('''Cannot convert to metaclass: «it»''')
		}

		dispatch def StringConcatenationClient convertToMetaclass(OclModelElement it) {
			'''«model.name.mmClass.newTypeReference».«name»'''
		}

		dispatch def convert(OclType it) {
			throw new UnsupportedOperationException('''Cannot convert «it»''')
		}

		dispatch def convert(OclAnyType it) {
			Object.newTypeReference
		}
		
		dispatch def convert(BooleanType it) {
			Boolean.newTypeReference
		}

		dispatch def convert(RealType it) {
			Double.newTypeReference
		}

		dispatch def convert(IntegerType it) {
			Integer.newTypeReference
		}

		dispatch def convert(TupleType it) {
			Object.newTypeReference
			//tupleClasses.get(ATOLGenProcessor.toCanonic(it)).key.findClass.newTypeReference
		}

		def hasBindingCompiler(Binding it) {
			val type = outPatternElement.type as OclModelElement
			val mmClass = type.model.name.mmClass
			// looking up the method with its Binding parameter cannot work if
			// the project containing the transformation to compile does not import
			// plugin ...atl.common 
//			val bindingType = Binding.newTypeReference
//			if(bindingType !== null) {
//				mmClass.findDeclaredMethod('''__«propertyName»Compiler''', bindingType) !== null
//			} else {
//				false
//			}
			val compilerMethodName = '''__«propertyName»Compiler'''.toString
			mmClass.declaredMethods.exists[m | m.simpleName == compilerMethodName]
		}

		def toJavaClass(String it) {
			Class.forName(it)
		}

		def mmJavaClass(Binding it) {
			val type = outPatternElement.type as OclModelElement
			val mmClass = type.model.name.mmClass
			mmClass.qualifiedName.toJavaClass
		}

		def bindingCompiler(Binding it) {
			mmJavaClass.getDeclaredMethod('''__«propertyName»Compiler''', Binding, CompilationHelper)
		}

		dispatch def specificBox(OclType it, String propertyName) {
			throw new IllegalStateException
		}

		dispatch def specificBox(OclModelElement it, String propertyName) {
			mmClass.findDeclaredField('''__«propertyName»''')
		}

		dispatch def hasSpecificBox(OclType it, String propertyName) {
			false
		}

		dispatch def hasSpecificBox(OclModelElement it, String propertyName) {
			specificBox(propertyName) !== null
		}

		dispatch def mmClass(OclType it) {
			throw new IllegalStateException
		}

		dispatch def mmClass(String it) {
			val mm = mms.get(it)
			if(mm === null) {
				addError(cd, '''Metamodel «it» not found''')
			}
			mm.type as ClassDeclaration
		}

		dispatch def ClassDeclaration mmClass(OclModelElement it) {
			it.model.name.mmClass
		}

		dispatch def convert(OclModelElement it) {
			val field = mmClass.findDeclaredField(name)
			if(field === null) {
				cd.addError('''Cannot find field «name» in «mmClass»''')
			}
			field.type.actualTypeArguments.get(0)
		}

		dispatch def convert(StringType it) {
			String.newTypeReference
		}

		dispatch def TypeReference convert(CollectionType it) {
			Collection.newTypeReference(elementType.convert)
		}

		dispatch def TypeReference convert(SetType it) {
			ImmutableSet.newTypeReference(elementType.convert)
		}

		dispatch def TypeReference convert(OrderedSetType it) {
			ImmutableSet.newTypeReference(elementType.convert)
		}

		dispatch def TypeReference convert(BagType it) {
			ImmutableMultiset.newTypeReference(elementType.convert)
		}

		dispatch def TypeReference convert(SequenceType it) {
			ImmutableList.newTypeReference(elementType.convert)
		}

// End Type conversion


// Begin Expression Compilation
		dispatch def StringConcatenationClient compile(OclExpression it) {
			throw new UnsupportedOperationException('''Cannot compile «it»''')
		}

		// DONE: attribute helpers
		dispatch def StringConcatenationClient compile(NavigationOrAttributeCallExp it) {
			// TODO: support more than one source mm
			val mmName = sourceMM
			if(isTarget) {
				val src = source
				if(src instanceof VariableExp) {
					val v = src.referredVariable
					if(v instanceof OutPatternElement) {
						return '''«(v.type as OclModelElement).model.name»«mmSuffix»._«name»(«v.mangledVarName»)'''
					}
				}
				accessTargetElement(this)
			} else if(source.isThisModule) {
				'''«name»'''
			} else {
				val mut = if(source.isMutable) {
							""
						} else {
							"_"
						}
				val mm = mmName.mmClass
				// TODO: only look for a property in the appropriate class (by inferring the type of it.source)
				if(mm.declaredMethods.exists[m | m.simpleName == name]) {
					if(mm.findDeclaredField('''__«name»''') !== null) {
						if(source.isMutable) {
							// TODO: make the lambda constant (e.g., as a field of the class)
							// so that we can leverage the cache of collectMutable to avoid
							// recomputations => BUT this will break capture
							'''
								«source.compile».collectMutable((«internalIteratorName») ->
									«internalIteratorName» == null ?
										«AbstractRule».emptySequence()
									:
										«mmName»«mmSuffix».__«name».apply(«internalIteratorName»)
								)'''
						} else {
							'''«mmName»«mmSuffix».__«name».apply(«source.compile»)'''
						}
					} else {
						'''«mmName»«mmSuffix».«mut»«name»(«source.compile»)'''
					}
				} else {
					'''«mut»«name»(«source.compile»)'''
				}
			}
		}

		dispatch def StringConcatenationClient compile(VariableExp it) {
			'''«referredVariable.mangledVarName»'''
		}

		dispatch def StringConcatenationClient compile(EnumLiteralExp it) {
			'''"«name»"'''
		}

		dispatch def StringConcatenationClient compile(OclUndefinedExp it) {
			'''null'''
		}

		dispatch def StringConcatenationClient compile(RealExp it) {
			'''«realSymbol»'''
		}

		dispatch def StringConcatenationClient compile(BooleanExp it) {
			'''«booleanSymbol»'''
		}

		dispatch def StringConcatenationClient compile(IntegerExp it) {
			'''«integerSymbol»'''
		}

		dispatch def StringConcatenationClient compile(StringExp it) {
			'''"«stringSymbol»"'''
		}

		def checkMutable(CollectionExp it) {
			if(elements.exists[isMutable]) {
				compilationUnit.addError('''«location»: mutable element in collection''')
			}
		}

		dispatch def StringConcatenationClient compile(BagExp it) {
			checkMutable
			'''
				«AOFFactory».INSTANCE.createBag(
					«FOR it : elements SEPARATOR ","»
						«compile»
					«ENDFOR»
				)'''
		}

		dispatch def StringConcatenationClient compile(OrderedSetExp it) {
			checkMutable
			'''
				«AOFFactory».INSTANCE.createOrderedSet(
					«FOR it : elements SEPARATOR ","»
						«compile»
					«ENDFOR»
				)'''
		}

		dispatch def StringConcatenationClient compile(SequenceExp it) {
			checkMutable
			'''
				«AOFFactory».INSTANCE.createSequence(
					«FOR it : elements SEPARATOR ","»
						«compile»
					«ENDFOR»
				)'''
		}

		dispatch def StringConcatenationClient compile(SetExp it) {
			checkMutable
			'''
				«AOFFactory».INSTANCE.createSet(
					«FOR it : elements SEPARATOR ","»
						«compile»
					«ENDFOR»
				)'''
		}

		dispatch def StringConcatenationClient compileImmutable(OclExpression it) {
			throw new UnsupportedOperationException('''Cannot immutably compile «it»''')
		}

		def StringConcatenationClient expLambda(List<String> params, StringConcatenationClient expression) {
			switch params.length {
//				case 1: {
//					// TODO: find the right types
//					val pt = "Object"
//					val rt = "Object"
//					'''
//						new «IUnaryFunction»<«pt», «rt»>() {
//							public «rt» apply(«pt» «params.get(0)») {
//								return «expression»;
//							}
//						}'''
//				}
//				case 2: {
//					// TODO: find the right types
//					val p1t = "Object"
//					val p2t = "Object"
//					val rt = "Object"
//					'''
//						new «IBinaryFunction»<«p1t», «p2t», «rt»>() {
//							public «rt» apply(«p1t» «params.get(0)», «p2t» «params.get(1)») {
//								return «expression»;
//							}
//						}'''
//				}
				default: expLambdaLambda(params, expression)
			}
		}

		def StringConcatenationClient expLambdaLambda(List<String> params, StringConcatenationClient expression) '''
			(«params.join(", ")») ->
				«expression»
		'''

		dispatch def StringConcatenationClient compileImmutable(CollectionExp it) {
			val StringConcatenationClient cl = switch it {
				SetExp: '''«ImmutableSet»'''
				SequenceExp: '''«ImmutableList»'''
				BagExp: '''«ImmutableMultiset»'''
				OrderedSetExp: '''«ImmutableSet»'''
				default: throw new IllegalStateException
			}
			val mutElems = elements.filter[isMutable].toList
			if(!mutElems.empty) {
				// TODO: support more than one mutable element
				if(mutElems.size == 1) {
					val mutElem = mutElems.get(0)
					'''
						«mutElem.compile».collect(«expLambda(#[internalIteratorName], '''
							«internalIteratorName» == null ?
								null
							:
								«cl».of(
									«FOR it : elements SEPARATOR ","»
										«IF mutElem === it»
											«internalIteratorName»
										«ELSE»
											«it.compile»
										«ENDIF»
									«ENDFOR»
								)
						''')»)'''
				} else {
					throw new UnsupportedOperationException("more than one element in an immutable collection literal")
				}
			} else {
				'''
					«cl».of(
						«FOR it : elements SEPARATOR ","»
							«it.compile»
						«ENDFOR»
					)'''
			}
		}

		dispatch def StringConcatenationClient compile(TupleExp it) {
//			if(isMutable) {	// NO: we do not want to "flatten" tuples with collection parts
//							// or maybe we do, to have immutable tuples that can be keys of Maps, or Sets
//				val mutParts = tuplePart.filter[initExpression.isMutable]
//				if(mutParts.size === 1) {
//					val mutPart = mutParts.findFirst[true]
//					'''«
//						mutPart.initExpression.compile
//					».collect((«internalIteratorName») -> «ImmutableMap».of(«tuplePart.map[
//						'''"«varName»", «
//							if(it === mutPart) {
//								internalIteratorName
//							} else {
//								initExpression.compile
//							}
//						»'''
//					].join(", ")»))'''
//				} else {
//					throw new UnsupportedOperationException("TODO")
//				}
//			} else {

			if(ATOLGenProcessor.immutableTuples) {
				'''
					«ImmutableMap».of(
						«FOR it : tuplePart SEPARATOR ","»
							"«varName»", «initExpression.compile»
						«ENDFOR»
					)'''
			} else {
				// mutable tuple compilation
				val tuple = tupleClasses.get(toCanonicType)
				'''
					new «tuple.key.findClass.newTypeReference»(
						«FOR a : tuple.value.attributes SEPARATOR ", "»
							«tuplePart.findFirst[varName == a.name].initExpression.compile»
						«ENDFOR»
					)
				'''
			}
		}

		static def toCanonicType(TupleExp it) {
			ImmutableList.copyOf(#[#["Tuple"], tuplePart.map[varName]].flatten)
		}

		dispatch def StringConcatenationClient compile(OclModelElement it) {
			val StringConcatenationClient ret = '''«convertToMetaclass»'''
//			println(ret)
			ret
		}

		dispatch def StringConcatenationClient compile(LetExp it) {
			'''
				«AbstractRule».let(
					«variable.initExpression.compile»,
					«expLambda(#[variable.mangledVarName], '''
						«in_.compile»
					''')»
				)'''
		}

		def StringConcatenationClient compileMutable(OclExpression it) {
			if(isMutable) {
				compile
			} else {
				'''«AOFFactory».INSTANCE.createOne(«compile»)'''
			}
		}

		val uniqNames = new HashMap<Pair<OclExpression, String>, String>

		def uniq(OclExpression it, String name) {
			var ret = uniqNames.get(it -> name)
			if(ret === null) {
				mangledVar.counter += 1	// sharing counter with mangledVar
				ret = '''«name»_«mangledVar.counter»'''
				uniqNames.put(it -> name, ret)
			}
			ret
		}

		dispatch def StringConcatenationClient compile(IfExp it) {
			// TODO: correct type in collectMutable
			val cond = uniq("condition")
			if(condition.isMutable) {
				// asOne(null) here to avoid a default "false" to result in a result default computation that duplicate side-effects such as trace link creation
				if(thenExpression.isMutable || elseExpression.isMutable) {
					// TODO: extract lambda of collectMutable into a class field so that
					// we can leverage the internal cache of collectMutable
					//  => BUT this will break capture
					'''
						«condition.compile».asOne(
							null
						).collectMutable(«expLambda(#[cond], '''
							«cond» == null ?
								«AbstractRule».emptySequence()
							:
								((«cond») ?
									(«thenExpression.compileMutable»)
								:
									(«elseExpression.compileMutable»)
								)
							''')»
						)'''
				} else {
					'''
						«condition.compile».asOne(
							null
						).collect((«cond») ->
							«cond» == null ?
								null
							:
								((«cond») ?
									(«thenExpression.compile»)
								:
									(«elseExpression.compile»)
								)
						)'''
				}
			} else {
				'''
					((«condition.compile») ?
						(«thenExpression.compile»)
					:
						(«elseExpression.compile»)
					)'''
			}
		}

		def StringConcatenationClient comp(OperatorCallExp it, StringConcatenationClient operand) {
			'''«switch operationName {
				case "not": "!"
				default: operationName
			}»(«operand»)'''
		}

		def StringConcatenationClient comp(OperatorCallExp it, StringConcatenationClient left, StringConcatenationClient right) {
			switch operationName {
				case "<>",
				case "=":
					'''«
						if(operationName == "<>") {
							"!"
						} else {
							""
						}
					»«Objects».equals(«left», «right»)'''
				default:
					'''«left» «switch operationName {
						case "and": "&&"
						case "or": "||"
						default: operationName
					}» «right»'''
			}
		}

		dispatch def StringConcatenationClient compile(OperatorCallExp it) {
			if(arguments.isEmpty) {
				lift([e | comp(e)], source)
			} else {
				val arg = arguments.get(0)
				lift([comp($0, $1)], source, arg)
			}
		}

		def name(ModuleElement it) {
			switch it {
				Helper: {
					val feature = definition.feature
					switch feature {
						Operation: feature.name
						Attribute: feature.name
						default: throw new IllegalStateException
					}
				}
				LazyMatchedRule: name
				default: throw new IllegalStateException
			}
		}

		def StringConcatenationClient lift((StringConcatenationClient,StringConcatenationClient)=>StringConcatenationClient f, OclExpression l, OclExpression r) {
			if(l.isMutable) {
				if(r.isMutable) {
/*					'''
						«l.compile».zipWith(«r.compile», («internalIteratorName»l, «internalIteratorName»r) ->
							«f.apply('''«internalIteratorName»l''', '''«internalIteratorName»r''')»
						)'''
*/
					'''
						«l.compile».zipWith(«r.compile», «expLambda(#['''«internalIteratorName»l''', '''«internalIteratorName»r'''],
							f.apply('''«internalIteratorName»l''', '''«internalIteratorName»r''')
						)»)'''
				} else {
					'''
						«l.compile».collect(«expLambda(#[internalIteratorName], '''
							«f.apply('''«internalIteratorName»''', r.compile)»
						''')»)'''
				}
			} else {
				if(r.isMutable) {
					'''
						«r.compile».collect((«internalIteratorName») ->
							«f.apply(l.compile, '''«internalIteratorName»''')»
						)'''
				} else {
					'''«f.apply(l.compile, r.compile)»'''
				}
			}
		}

		def StringConcatenationClient lift((StringConcatenationClient)=>StringConcatenationClient f, OclExpression o) {
			if(o.isMutable) {
				'''
					«o.compile».collect((«internalIteratorName») ->
						«f.apply('''«internalIteratorName»''')»
					)'''
			} else {
				'''«f.apply(o.compile)»'''
			}
		}

		dispatch def StringConcatenationClient compile(CollectionOperationCallExp it) {
			switch operationName {
				case "size":  operationCall(operationName)

				default: compileOp
			}
		}

		dispatch def StringConcatenationClient compile(OperationCallExp it) {
			compileOp
		}

		def StringConcatenationClient mathOp(String operationName, StringConcatenationClient...args) {
			'''Math.«operationName»(«FOR arg : args SEPARATOR ', '»«arg»«ENDFOR»)'''
		}

		def StringConcatenationClient safeLength(StringConcatenationClient e) {
			'''((«e») == null) ? 0 : («e»).length()'''
		}

		def StringConcatenationClient compileOp(OperationCallExp it) {
			switch operationName {
			case "cos",
			case "sin": {
				lift([e | operationName.mathOp(e)], source)
			}
			case "atan2": {
				lift([operationName.mathOp($0, $1)], source, arguments.get(0))
			}
			case "toString": {
				// TODO: use lift
				if(source.isMutable) {
					'''
						«source.compile».collect((«internalIteratorName») ->
							«internalIteratorName» == null ?
								null
							:
								«internalIteratorName».toString()
						)'''
				} else {
					'''«source.compile».toString()'''
				}
			}
			case "includes": {
				'''
					«OCLByEquivalence».includes(
						«source.compile»,
						«arguments.findFirst[true].compile»
					)'''
			}
			case "excluding": {
				'''
					«OCLByEquivalence».excluding(
						«source.compile»,
						«arguments.findFirst[true].compile»
					)'''
			}
			case "__immutable": source.compileImmutable
			case "oclIsKindOf": {
				val type = (it.arguments.findFirst[true] as OclType).convert
				// TODO: use lift
				if(source.isMutable) {
					'''
						«it.source.compile».collect((«internalIteratorName») ->
							«internalIteratorName» instanceof «type»
						)'''
				} else {
					'''«it.source.compile» instanceof «type»'''
				}
			}
			case "oclAsType": {
				// TODO: mutable argument?
				val type = (it.arguments.findFirst[true] as OclType).convert
				if(source.isMutable) {
					'''((«IBox.newTypeReference(type)»)(«IBox»<?>)«it.source.compile»)'''
				} else {
					'''((«type»)«it.source.compile»)'''
				}
			}
			case "oclIsUndefined":
				// TODO: use lift
				if(source.isMutable) {
					'''
						«it.source.compile».collect((«internalIteratorName») ->
							«internalIteratorName» == null
						)'''
				} else {
					'''«it.source.compile» == null'''
				}
			case "debug":
//			if(source.isMutable) {
//				'''«source.compile».inspect(«
//						if(arguments.empty) {
//							'''"debug@«location»: "'''
//						} else {
//							'''«arguments.get(0).compile» + ": "'''
//						}
//					»)'''
//			} else {
				'''
					«AbstractRule».debug(
						«source.compile»,
						«
							if(arguments.empty) {
								'''"debug@«location»"'''
							} else {
								'''«arguments.get(0).compile»'''
							}
						»
					)'''
//			}
			case "prepend": '''
				«AOFFactory».INSTANCE.createOne(
					«arguments.get(0).compile»
				).concat(
					«source.compile»
				)'''
			case "flatten": {
				'''
					«source.compile».collectMutable((«internalIteratorName») ->
						«internalIteratorName» == null ?
							«AbstractRule».emptySequence()
						:
							«internalIteratorName»
					)'''
			}
			case "size": 
					lift([e | safeLength(e)], source)
			case "asOrderedSet",
			case "asSet",
			case "select",
			case "isEmpty",
			case "notEmpty",
			case "asOne": operationCall(operationName)
			case "concat": if(arguments.get(0).isMutable) {
				operationCall(operationName)
			} else {
				'''
					«source.compile».«operationName»(
						«AOFFactory».INSTANCE.createOne(«arguments.get(0).compile»)
					)'''
			}
			case "first": if(source.isMutable) {
				operationCall("asOption")
			} else {
				'''«source.compile».get(0)'''
			}
			case "last": if(source.isMutable) {
				throw new UnsupportedOperationException('''«location»: last not supported yet on mutable collections''')
			} else {
				'''«source.compile».reverse().get(0)'''
			}
			case "collectTo": '''
				«it.computeCollectTo(this)»'''
			case calledRule !== null: {
				// TODO: when isMutable
				// TODO: make the following work with ListPatternCompiler
				val mutArgs = arguments.filter[isMutable]
				if(mutArgs.empty) {
					'''
						this.«operationName»(
							«FOR it : arguments SEPARATOR ","»
								«compile»
							«ENDFOR»
						)'''
				} else {
					if(mutArgs.size == 1) {
						val mutArg = mutArgs.get(0)
						'''
							«mutArg.compile».collect((«internalIteratorName») ->
								«internalIteratorName» == null ?
									null
								:
									this.«operationName»(
										«FOR it : arguments SEPARATOR ","»
											«IF it == mutArg»
												«internalIteratorName»
											«ELSE»
												«compile»
											«ENDIF»
										«ENDFOR»
									)
							)'''
					} else if(mutArgs.size == 2) {
						val mutArg0 = mutArgs.get(0)
						val mutArg1 = mutArgs.get(1)
						'''
							«mutArg0.compile».zipWith(«mutArg1.compile», («internalIteratorName»0, «internalIteratorName»1) ->
								«internalIteratorName»0 == null || «internalIteratorName»1 == null ?
									null
								:
									this.«operationName»(
										«FOR it : arguments SEPARATOR ","»
											«IF it === mutArg0»
												«internalIteratorName»0
											«ELSEIF it === mutArg1»
												«internalIteratorName»1
											«ELSE»
												«compile»
											«ENDIF»
										«ENDFOR»
									)
							)'''
					} else {
						throw new UnsupportedOperationException('''More than 2mutable argument to rule call''')
					}
				}
			}
			default: {
				val args = if(source instanceof VariableExp && (source as VariableExp).isThisModule) {
					arguments
				} else {
					#[#[source], arguments].flatten
				}
				'''«operationName»(«
					FOR arg : args SEPARATOR ", "»«
						arg.compile
					»«ENDFOR»)'''
				}
			}
		}

		def StringConcatenationClient operationCall(OperationCallExp it, String operationName) {
			'''
				«source.compile».«operationName»(
					«FOR arg : arguments SEPARATOR ","»
						«arg.compile»
					«ENDFOR»
				)'''
		}

		def moduleElements() {
			switch unit {
				Module: unit.elements
				default: Collections.emptyList
			}
		}

		dispatch def isThisModule(OclExpression it) {
			false
		}
		dispatch def isThisModule(VariableExp it) {
			referredVariable.varName == "thisModule"
		}

		def calledRule(OperationCallExp it) {
			switch source {
				VariableExp case (source as VariableExp).isThisModule:
					moduleElements.filter(LazyMatchedRule).findFirst[e |
						operationName == e.name
					]
				default: null
			}
		}
	
		dispatch def StringConcatenationClient compile(IteratorExp it) {
			switch name {
				case "zipWith": {
					val parts = (source as TupleExp).tuplePart.toMap([varName])[initExpression]
					'''
						«parts.get("left").compile».zipWith(
							«parts.get("right").compile»,
							(«iterators.map[mangledVarName].join(", ")») ->
								«body.compile»
						)'''
				}
				case "closure": {
					'''
						«OCLByEquivalence».closure(
							«source.compile»,
							((«iterators.map[mangledVarName].join(", ")») ->
								«body.compile»
							)
						)'''
				}
				case "forAll": {
					'''
						«OCLByEquivalence».forAll«IF loopExp.isMutable»M«ENDIF»(
							«source.compile»,
							((«iterators.map[mangledVarName].join(", ")») ->
								«body.compile»«IF loopExp.isMutable».asOne(false)«ENDIF»
							)
						)'''
				}
				case "collect": {
					'''
						«source.compile».«
							if(body.isMutable) {
								// TODO: extract lambda to leverage cache
								//  => BUT this will break capture
								"collectMutable"
							} else {
								"collect"
							}
						»(«expLambda(
							iterators.map[mangledVarName],
							'''
								«iterators.findFirst[true].mangledVarName» == null ?
									«IF body.isMutable»
										««« TODO: use appropriate box type
										«AbstractRule».emptySequence()
									«ELSE»
										null
									«ENDIF»
								:
									«body.compile»
							'''
						)»)'''
				}
				case "exists",
				case "any",
				case "reject",
				case "select": {
					val reject = name == "reject"
					'''
						«source.compile».«
							if(body.isMutable) {
								"selectMutable"
							} else {
								"select"
							}
						»(«expLambda(
// is it necessary to check for nullity here?
							iterators.map[mangledVarName],
							'''
								«iterators.findFirst[true].mangledVarName» == null ?
									«IF body.isMutable»
										«AbstractRule».FALSE
									«ELSE»
										false
									«ENDIF»
								:
									«IF body.isMutable»
										«IF reject»
											«body.compile».collect((«internalIteratorName») ->
												(«internalIteratorName» == null) ?
													false
												:
													!«internalIteratorName»
											).asOne(false)
										«ELSE»
											«AbstractRule».asOneD(«body.compile», false)
										«ENDIF»
									«ELSE»
										«IF reject»
											!(«body.compile»)
										«ELSE»
											«body.compile»
										«ENDIF»
									«ENDIF»
							''')
						»)«IF name == "any"».asOption()«ELSEIF name == "exists"».notEmpty()«ENDIF»'''
				}
				case "selectBy": {
					val body = body
					val parts = if(body instanceof OperationCallExp) {
						if(body.operationName == "=") {
							body.source -> body.arguments.get(0)
						}
					}
					if(parts === null) {
						cd.compilationUnit.addError('''«location»: expressions passed to selectBy must be equality checks''')
						return '''ERROR: selectBy without an equality check'''
					}
					'''
						selectBy(
							«source.compile»,
							«parts.key.compile»,
							((«
								iterators.map[mangledVarName].join(", ")
							») ->
								«parts.value.compile»
							)
						)'''
				}
				case "sortedBy": {	// TODO: make sure sortedBy is in the standard library... currently relies on user-defined method
					val iteratorExps = new ArrayList
					iteratorExps.add(it)
					val source = source
					// TODO: support more than two sort criteria
					val actualSource =
						switch source {
						IteratorExp case source.name == "sortedBy": {
							iteratorExps.add(source)
							source.source
						}
						default: source
						}
					'''
						«name»(
							«actualSource.compile»,
							«FOR it : iteratorExps SEPARATOR ","»
								(«iterators.map[mangledVarName].join(", ")») ->
									«body.compile»
							«ENDFOR»
						)'''
				}
				default: {
//					throw new UnsupportedOperationException('''Unsupported iterator: «name» for «it»''')
				// TODO: support user-defined iterators?
				// => could use the following code
					'''
						«name»(«source.compile», («iterators.map[mangledVarName].join(", ")») ->
							«body.compile»
						)'''
				}
			}
		}
// End Expression Compilation


// Begin Mutability Analysis
		dispatch def isMutable(OclExpression it) {
			throw new UnsupportedOperationException('''Cannot determine mutability of «it»''')
		}

		dispatch def isMutable(PrimitiveExp it) {
			false
		}

		dispatch def isMutable(EnumLiteralExp it) {
			false
		}

		dispatch def boolean isMutable(NavigationOrAttributeCallExp it) {
			// TODO: more complex cases (e.g., attribute helpers)
			val source = source
			switch source {
				OperationCallExp:
					if(source.calledRule === null) {
						true
					} else {
						source.isMutable
					}
				VariableExp case source.isThisModule: {
					name.findAttributeHelper.initExpression.isMutable
				 }
				default: true
			}
		}

		dispatch def hname(OclFeature it) {
			throw new IllegalStateException
		}
		dispatch def hname(Operation it) {
			name
		}
		dispatch def hname(Attribute it) {
			name
		}

		def findAttributeHelper(String name) {
			helpers.map[
				definition.feature
			].filter(Attribute).filter[
				definition.context_ === null
			].findFirst[
				hname == name
			]
		}

		dispatch def isMutable(IteratorExp it) {
			true
		}

		dispatch def isMutable(OclUndefinedExp it) {
			false
		}

		def isMutableContext(OperationCallExp it) {
			source.isMutable || arguments.exists[isMutable]
		}

		dispatch def boolean isMutable(OperationCallExp it) {
			switch operationName {
				case calledRule !== null: arguments.exists[isMutable]
				case "oclIsUndefined",
				case "oclIsKindOf",
				case "oclAsType",
				case "debug": isMutableContext
				case "__immutable": (source as CollectionExp).elements.exists[isMutable]	// TODO: what about mutably creating immutable values?
				case "first", case "last": source.isMutable
				case operationName.startsWith("immget"): false	// naming convention for xtend helpers that return immutable values
				default: true 
			}
		}

		dispatch def boolean isMutable(OperatorCallExp it) {
			isMutableContext
		}

		dispatch def boolean isMutable(TupleExp it) {
			false	// even for mutable tuples, tuples themselves are immutable
		}

		dispatch def boolean isMutable(LetExp it) {
			in_.isMutable
		}

		dispatch def boolean isMutable(IfExp it) {
			condition.isMutable ||
			thenExpression.isMutable ||
			elseExpression.isMutable
		}

		dispatch def boolean isMutable(VariableExp it) {
			// TODO: more complex cases
			switch referredVariable {
				PatternElement: false
				Parameter: referredVariable.type instanceof CollectionType
				RuleVariableDeclaration: referredVariable.initExpression.isMutable
				VariableDeclaration case referredVariable.letExp !== null: referredVariable.initExpression.isMutable
				VariableDeclaration case referredVariable.varName == "self" || isThisModule: false
				Iterator: false
				default: throw new UnsupportedOperationException('''Cannot determine mutability of «it»''')
			}
		}

		dispatch def isMutable(CollectionExp it) {
			true	// DONE: should we implement immutable collections? => handled in isMutable(OperationCallExp) with "__immutable"
		}

		dispatch def isMutable(OclType it) {
			false
		}
// End Mutability Analysis

		// some random name unlikely to appear in any actual transformation, to avoid collisions between compiler-generated iterators & those from transformations
		val String internalIteratorName = '''e876435'''

		val varNames = new HashMap<VariableDeclaration, String>
		static class Counter {
			var counter = 0;
		}
		val mangledVar = new Counter

		def mangledVarName(VariableDeclaration it) {
			var ret = varNames.get(it)
			if(ret === null) {
				ret = switch it {
					RuleVariableDeclaration,
					PatternElement: varName
					case varName == "self": SELF
					default: {
						mangledVar.counter += 1
						'''«varName»_«mangledVar.counter»'''
					}
				}
				varNames.put(it, ret)
			}
			ret
		}


// @begin isTarget
		dispatch def isTarget(OclExpression it) {
			throw new UnsupportedOperationException('''Cannot determine whether expression is over source or target: «it»''')
		}
	
		dispatch def isTarget(PrimitiveExp it) {
			true
		}
	
		dispatch def boolean isTarget(CollectionExp it) {
			elements.forall[isTarget]
		}
	
		dispatch def boolean isTarget(IfExp it) {
			// TODO: elseExpression.isTarget should have the same value
			thenExpression.isTarget
		}
	
		dispatch def boolean isTarget(TupleExp it) {
			false	// TODO
		}

		dispatch def boolean isTarget(IteratorExp it) {
			switch name {
				case "reject",
				case "select": source.isTarget
				case "zipWith",
				case "collect": source.isTarget || body.isTarget
				case "selectBy",
				case "sortedBy": false
				default: {
					compilationUnit.addWarning('''Cannot determine whether iterator «name»' is over source or target''')
					false
				}
			}
		}
	
		dispatch def boolean isTarget(VariableExp it) {
			val rv = referredVariable
			switch rv {
				InPatternElement: false
				OutPatternElement: true
				Iterator: rv.loopExpr.source.isTarget
				Parameter: false	// TODO: improve this
				case rv.varName == "self",
				case isThisModule: false
				case rv.initExpression !== null: rv.initExpression.isTarget
				default: throw new UnsupportedOperationException(
					'''Cannot determine whether variable is souce or target: «it»'''
				)
			}
		}
	
		dispatch def boolean isTarget(OperationCallExp it) {
			switch operationName {
				case "collectTo",
				case calledRule !== null: true
				default: source.isTarget
			}
		}
	
		dispatch def boolean isTarget(NavigationOrAttributeCallExp it) {
			source.isTarget
		}
// @end isTarget

		def superPattern(OutPattern it) {
			(rule as MatchedRule).superRule?.outPattern
		}

		def superPattern(InPattern it) {
			(rule as MatchedRule).superRule?.inPattern
		}

		// merge with TuplePatternCompiler.elements?
		def List<OutPatternElement> allElements(OutPattern it) {
			val superPattern = superPattern
			if(superPattern !== null) {
				val ret = new ArrayList(superPattern.allElements.map[supPat |
					val subPat = elements.findFirst[subPat |
						subPat.varName == supPat.varName
					]
					if(subPat === null) {
						supPat
					} else {
						subPat
					}
				].toList)
				val rest = new ArrayList(elements)
				rest.removeAll(ret)
				ret.addAll(rest)
				ret
			} else {
				elements
			}
		}

		def List<InPatternElement> allElements(InPattern it) {
			val superPattern = superPattern
			if(superPattern !== null) {
				val ret = new ArrayList(superPattern.allElements.map[supPat |
					val subPat = elements.findFirst[subPat |
						subPat.varName == supPat.varName
					]
					if(subPat === null) {
						supPat
					} else {
						subPat
					}
				].toList)
				val rest = new ArrayList(elements)
				rest.removeAll(ret)
				ret.addAll(rest)
				ret
			} else {
				it.elements
			}
		}

		def List<Binding> allBindings(OutPatternElement it) {
			val superElement = it.outPattern.superPattern?.elements?.findFirst[e |
				varName == e.varName
			]
			if(superElement !== null) {
				val ret = new ArrayList(superElement.allBindings.filter[supB |
					!bindings.exists[subB |
						subB.propertyName == supB.propertyName
					]
				].toList)
				ret.addAll(bindings)
				ret
			} else {
				bindings
			}
		}

		val SELF = "self_"

		def Comparator<MatchedRule> inheritanceComparator() {
			[a, b |
				// TODO: handle multiple source pattern elements
				val ac = a.inPattern.elements.findFirst[true].type.convert
				val bc = b.inPattern.elements.findFirst[true].type.convert
				val acExtendsBc = bc.isAssignableFrom(ac)
				val bcExtendsAc = ac.isAssignableFrom(bc)
				if(acExtendsBc && bcExtendsAc) {
					0
				} else if(acExtendsBc) {
					-1
				} else {
					1	// actually don't care
				}
			]
		}

		def Iterable<MatchedRule> allRules(Iterable<? extends MatchedRule> it) {
			map[
				#[#[it], children.map[#[it].allRules].flatten]
			].flatten.flatten.filter[
				!isAbstract
			].sortWith(inheritanceComparator)
		}

		def actualRules(List<OclExpression> it) {
			map[
				val name = (it as StringExp).stringSymbol
				val ret = moduleElements.filter(LazyMatchedRule).findFirst[rule | rule.name == name]
				if(ret === null) {
					val m = '''error: «location»: rule «name» not found'''
					cd.compilationUnit.addError(m)
//					println(cd.problems.map[message])
					println(m)
				}
				ret
			].filter[
				it !== null	// in case some rules were not found
			].allRules
		}

		static val mmSuffix = "MM"

		def isMany(PatternElement e, Binding b) {
//			val mmClass = e.type.mmClass
//			val String propertyName = '''_«b.propertyName»'''
//			val method = mmClass.declaredMethods.findFirst[
//				// TODO: improve this expression by also checking argument type
//				// but we only know that e.type is a subtype (or ==) of what we are looking for
////				println('''it.simpleName="«it.simpleName»" == "_«b.propertyName»" ?"''')
//				it.simpleName == propertyName
//			]
//			val returnType = method.parameters.get(0)
//			returnType.findDeclaredMethod
//			if(returnType === null) {
//				false	// TODO: improve this
//			} else {
//				ISingleton.findTypeGlobally.isAssignableFrom(returnType)
//			}
			val metaClass = try {
				(e.type as OclModelElement).metaClass
			} catch(Throwable ex) {
				return false	// TODO: improve this
			}
//			println('''metaClass = «metaClass»''')
			try {
				val method = metaClass.getMethod('''get«b.propertyName.toFirstUpper»''')
//				println('''method = «method»''')
				Collection.isAssignableFrom(method.returnType)
			} catch(NoSuchMethodException ex) {
				false	// TODO: improve this
			}
		}

		def metaClass(OclModelElement e) {
			e.mmClass.findDeclaredField(e.name).type.actualTypeArguments.get(0).type.qualifiedName.toJavaClass
		}

		def StringConcatenationClient compileBinding(Pair<Integer, ? extends PatternElement> e, Binding b) {
			for(ext : extensions) {
				val ret = ext.compileBinding(b, this)
				if(ret !== null) {
					return ret
				}
			}
			'''
«««				«IF b.hasBindingCompiler»
«««					«try {
«««						b.bindingCompiler.invoke(b.mmJavaClass.newInstance, b, this)
«««					} catch(ClassNotFoundException ex) {
«««						cd.compilationUnit.addError("Metamodel classes with binding compilers must be reachable from the ATOL compiler")
«««					}»
				«IF	b.value.isMutable»
					«IF e.value.type.hasSpecificBox(b.propertyName)»
						«patternCompiler.ruleClass».operator_spaceship(«(e.value.type as OclModelElement).model.name»«CompilationHelper.mmSuffix».__«b.propertyName».apply(«e.value.varName»),
							«b.value.compile»
						);
					«ELSE»
«««						«patternCompiler.ruleClass».operator_spaceship(«e.value.varName».«b.propertyName»Property(), «b.value.compile»);
						«patternCompiler.ruleClass».operator_spaceship(«(e.value.type as OclModelElement).model.name»«CompilationHelper.mmSuffix»._«b.propertyName»(«e.value.varName»),
							«b.value.compile»
						);
					«ENDIF»
				«ELSE»
«««					TODO: use property type appropriately (e.g., Enum, multivalued)
					«IF e.value.type.hasSpecificBox(b.propertyName)»
						«(e.value.type as OclModelElement).model.name»«CompilationHelper.mmSuffix».__«b.propertyName».apply(«e.value.varName»).add(
							«b.value.compile»
						);
					«ELSEIF e.value.isMany(b)»
						«e.value.varName».get«b.propertyName.toFirstUpper»().add(
							«b.value.compile»
						);
					«ELSE»
						«e.value.varName».set«b.propertyName.toFirstUpper»(
							«b.value.compile»
						);
					«ENDIF»
				«ENDIF»
			'''
		}

		def convertTupleAttributeType(OclType it, ClassDeclaration tupleClass) {
			IBox.newTypeReference(
				switch it {
					OclModelElement case model.name == "@" && name == "REC": Object.newTypeReference//tupleClass.newTypeReference
					CollectionType: convert.actualTypeArguments.get(0)
					default: convert
				}
			)
		}

		val helpers = new ArrayList<Helper>

		def dispatch helpers(Query it) {
			it.helpers
		}

		def dispatch helpers(Library it) {
			it.helpers
		}

		def dispatch helpers(Module it) {
			elements.filter(Helper)
		}

	}
}
