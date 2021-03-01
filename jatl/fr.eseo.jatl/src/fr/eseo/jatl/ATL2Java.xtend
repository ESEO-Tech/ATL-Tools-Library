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
import com.google.common.collect.ListMultimap
import com.google.common.collect.Multimaps
import java.util.ArrayList
import java.util.Collection
import java.util.HashMap
import java.util.HashSet
import java.util.List
import java.util.Map
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EEnum
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.m2m.atl.common.ATL.Binding
import org.eclipse.m2m.atl.common.ATL.Helper
import org.eclipse.m2m.atl.common.ATL.InPatternElement
import org.eclipse.m2m.atl.common.ATL.LazyMatchedRule
import org.eclipse.m2m.atl.common.ATL.Library
import org.eclipse.m2m.atl.common.ATL.LocatedElement
import org.eclipse.m2m.atl.common.ATL.MatchedRule
import org.eclipse.m2m.atl.common.ATL.Module
import org.eclipse.m2m.atl.common.ATL.OutPatternElement
import org.eclipse.m2m.atl.common.ATL.Unit
import org.eclipse.m2m.atl.common.OCL.Attribute
import org.eclipse.m2m.atl.common.OCL.OclAnyType
import org.eclipse.m2m.atl.common.OCL.OclModelElement
import org.eclipse.m2m.atl.common.OCL.Operation
import org.eclipse.m2m.atl.emftvm.compiler.AtlResourceFactoryImpl
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeParameterDeclaration
import org.eclipse.xtend.lib.macro.file.FileLocations
import org.eclipse.xtend.lib.macro.file.FileSystemSupport
import org.eclipse.xtend2.lib.StringConcatenationClient

/*
 *	TODO:
 *		- use ATLTypeInference to insert casts when possible?
 *	Missing features:
 *		- rules
 *			- improved dispatch
 *			- batch mode
 *		- refining mode
 *			- DONE rules
 *			- automatic applications
 *	Possible issues:
 *		- collisions between
 *			- attribute and operation helpers
 *			- operation helpers and rules
 *				=> already a possibility in classical ATL, but maybe not in all the same cases
 *		- collisions  between contexted & context-less operation helpers 
 *	Differences with ATL (which may need to be fixed):
 *		- global/context-less attribute helpers are only evaluated on demand
 *	Differences with ATOL:
 *		- operations are not cached
 */
@Active(ATL2JavaProcessor)
annotation ATL2Java {
	String[] libraries
	Metamodel[] metamodels

	annotation Metamodel {
		String name
		Class<? extends EPackage>[] ePackages
	}

	class ATL2JavaProcessor extends AbstractClassProcessor {

		def <E extends FileLocations & FileSystemSupport> getUnits(ClassDeclaration it, AnnotationReference ann, extension E fl) {
			val libs = ann
						.getStringArrayValue("libraries")
			
			libs.map[tf |
				val rs = new ResourceSetImpl
				rs.resourceFactoryRegistry.extensionToFactoryMap.put("atl", new AtlResourceFactoryImpl)

				val tfPath = getProjectFolder(compilationUnit.filePath).append(tf)

				// to make the compiled xtend file depend on the .atl file
				if(tfPath.exists) {
					tfPath.contentsAsStream.close
				}

				val tfURI = if(tfPath.exists) {tfPath.toURI} else {getProjectFolder(compilationUnit.filePath).toURI.resolve(tf)}

				val r = rs.getResource(URI.createURI(tfURI.toString), true)

				r.contents.get(0) as Unit
			].toList
		}

		override doRegisterGlobals(ClassDeclaration it, extension RegisterGlobalsContext context) {
			val ann = findAnnotation(ATL2Java.findUpstreamType)
			val units = getUnits(ann, context)
			for(rule : units.allRules) {
				registerInterface('''«qualifiedName».«rule.name»SourceTuple''')
				registerInterface('''«qualifiedName».«rule.name»TargetTuple''')
			}
		}

		var id = 0

		override doTransform(MutableClassDeclaration it, extension TransformationContext context) {
			val ann = findAnnotation(ATL2Java.findTypeGlobally)
			val units = getUnits(ann, context)
			val metamodels = ann
						.getAnnotationArrayValue("metamodels")
							.toMap([
								getStringValue("name")
							])[
								getClassArrayValue("ePackages").map[
									Class.forName(name)
										.getField("eINSTANCE").get(null) as EPackage
								]
							]

			try {			
				doTransform(it, context, units, metamodels)
			} catch(Exception e) {
				// remark: this does not capture all exceptions because some are thrown from worker threads (e.g., for method bodies)
				addError('''error: «e» thrown during compilation''')
			}
		}

		def name(Helper it) { 
			val f = definition.feature
			switch f {
				Operation: f.name
				Attribute: f.name
			}
		}

		def type(Helper it) { 
			val f = definition.feature
			switch f {
				Operation: f.returnType
				Attribute: f.type
			}
		}

		def context(Helper it) {
			definition.context_?.context_
		}

		def helpers(Unit it) {
			switch it {
				Library: getHelpers
				Module: elements.filter(Helper)
				default: throw new UnsupportedOperationException('''«it».helpers''')
			}
		}

		def rules(Unit it) {
			switch it {
				Library: #[]
				Module: elements.filter(MatchedRule)
				default: throw new UnsupportedOperationException('''«it».helpers''')
			}
		}

		def <E> min(Iterable<E> it, (E, E)=>boolean gt) {
			var E ret = null
			for(e : it) {
				if(ret === null) {
					ret = e
				} else {
					if(gt.apply(ret, e)) {
						ret = e
					}
				}
			}
			ret
		}

		// TODO: replace with a better implementation 
		def <E> topSortWith(Collection<E> it, (E, E)=>boolean gt) {
			val ret = new ArrayList
			val rem = new HashSet(it)

			while(!rem.empty) {
				val min = rem.min(gt)
				ret.add(min)
				rem.remove(min)
			}

			ret
		}

/*
		def Iterable<MatchedRule> allChildRules(MatchedRule it) {
			children.flatMap[
				#[#[it], allChildRules].flatten
			]
		}
*/

		def doTransform(MutableClassDeclaration cd, extension TransformationContext context, List<Unit> libs, Map<String, List<EPackage>> metamodels) {
			extension val it = new ATL2JavaGenerator(cd, context, metamodels)

			val allHelpers = libs.flatMap[e | e.helpers].toList

			// helpers without context
			for(helper : allHelpers.filter[h | h.context === null]) {
					val feature = helper.definition.feature
					switch feature {
						Operation: addHelperMethod(feature, helper.name)
						Attribute: addHelperMethod(feature, helper.name)
					}
			}

			// dispatching must be handled properly for helpers with context
			val helpers = allHelpers.stream().filter[h |
				h.context !== null
			].collect(
				Multimaps.toMultimap(
					[h | h.name],
					[h | h],
					[ArrayListMultimap.create]
				)
			)
			for(entry : helpers.asMap.entrySet) {
				val helperName =
					if(entry.value.size > 1) {
						val defaultHelper = entry.value.findFirst[h | h.context instanceof OclAnyType]
//						if(entry.key == "inferredType") {
//							println("START")
//						}
						val otherHelpers = entry.value.filter[h |
							!(h.context instanceof OclAnyType)
						].toList.topSortWith[a, b |
							val ac = a.context.convert
							val bc = b.context.convert
							ac.isAssignableFrom(bc)
						]
//						if(entry.key == "inferredType")
//							println("otherHelpers " + otherHelpers.map[
//								val cont = it.context
//								switch cont {
//									OclModelElement: cont.model.name + '!' + cont.name
//									default: cont.toString
//								}
//							])
						val helperName = "__dispatch__" + entry.key
						val commonReturnType = entry.value.get(0).type.convert	// TODO: not assuming they all have the same returnType?
						addMethod(entry.key)[
							addParameter(SELF, Object.newTypeReference)	// TODO: common supertype
							returnType = commonReturnType
//							«»
							body = '''
							«FOR helper : otherHelpers SEPARATOR " else "»
								if(«SELF» instanceof «helper.context.convert») {
									return «helperName»((«helper.context.convert»)«SELF»);
								}«ENDFOR»
							else if(«SELF» instanceof «Map»<?, ?>) {
								// for tuples
								return («commonReturnType»)((«Map»<String, ?>)«SELF»).get("«entry.key»");
							} else {
								«IF defaultHelper !== null»
									return «helperName»((«defaultHelper.context.convert»)«SELF»);
								«ELSE»
									throw new «UnsupportedOperationException»("«entry.key» on " + «SELF»);
								«ENDIF»
							}
						'''
						]
						helperName
					} else {
						entry.key
					}

				for(helper : entry.value) {
					helper.definition.context_
					val feature = helper.definition.feature
					switch feature {
						Operation: addHelperMethod(feature, helperName)
						Attribute: addHelperMethod(feature, helperName)
					}
				}
			}

			for(rule : libs.allRules) {
				val st = rule.sourceTupleInterface
				if(rule.superRule !== null) {
					st.extendedInterfaces = #[rule.superRule.sourceTupleInterface.newTypeReference]
				}
				val tt = rule.targetTupleInterface
				if(rule.superRule !== null) {
					tt.extendedInterfaces = #[rule.superRule.targetTupleInterface.newTypeReference]
				}

				val ipes = rule.inPattern.elements

				// populate source tuple interface + accessors
				for(ipe : ipes) {
					st.addMethod(ipe.varName)[
						returnType = ipe.type.convert
					]
					addMethod(ipe.varName)[
						addParameter("it", st.newTypeReference)
						returnType = ipe.type.convert
						body = '''
							return it.«ipe.varName»();
						'''
					]
				}

				// populate target tuple interface + accessors
				for(ope : rule.allOutPatternElements) {
					tt.addMethod(ope.varName)[
						returnType = ope.type.convert
					]
					addMethod(ope.varName)[
						addParameter("it", tt.newTypeReference)
						returnType = ope.type.convert
						body = '''
							return it.«ope.varName»();
						'''
					]
				}

				if(rule.inPattern.filter !== null) {
					addMethod('''eval«rule.name»Guard''')[
						returnType = Boolean.TYPE.newTypeReference
						for(ipe : ipes) {
							addParameter(ipe.uniqueName, ipe.type.convert)
						}
						body = '''
							return «rule.inPattern.filter.compile[
								throw new UnsupportedOperationException
							]»;
						'''
					]
				}

				if(rule instanceof LazyMatchedRule) {
					// lazy rule
					// println('''lazy rule «rule.module.name».«rule.name»''')
					val cacheName = '''«rule.name»_cache'''
					if(!rule.isAbstract) {
						if(rule.isUnique) {
							addField(cacheName)[
								type = Map.newTypeReference(st.newTypeReference, tt.newTypeReference)
								initializer = '''new «HashMap»<>()'''
							]
						}
						addMethod('''apply«rule.name»''')[
							returnType = tt.newTypeReference
							setDocComment('''
								Method generated from unique lazy rule «rule.module.name».«rule.name»@«rule.location»
							''')
							addParameter("it", st.newTypeReference)
							// «»
							body = '''
								«ipes.compileSourcePattern»
								«FOR ope : rule.allOutPatternElements»
									final «ope.type.convert» «ope.uniqueName» = «newInstance(ope.type as OclModelElement)»;
								«ENDFOR»
								«rule.compileBindings»
								return «rule.compileTargetTuple(tt)»;
							'''
						]
					}
					addMethod('''«rule.name»''')[
						returnType = tt.newTypeReference
						setDocComment('''
							Method generated from unique lazy rule «rule.module.name».«rule.name»@«rule.location»: «rule.children.map[name].join(", ")»
						''')
						for(ipe : ipes) {
							addParameter(ipe.uniqueName, ipe.type.convert)
						}
						body = '''
							// TODO: sort
							«FOR childRule : rule.children»
								if(
									«FOR ipe : ipes SEPARATOR " &&"»
										«ipe.uniqueName» instanceof «childRule.inPattern.elements.findFirst[ipe.varName == varName].type.convert»
									«ENDFOR»
									«IF childRule.inPattern.filter !== null»
										&& eval«childRule.name»Guard(
											«FOR ipe : ipes SEPARATOR ","»
												(«childRule.inPattern.elements.findFirst[ipe.varName == varName].type.convert»)«ipe.uniqueName»
											«ENDFOR»
										)
									«ENDIF»
								) {
									return «childRule.name»(
										«FOR ipe : ipes SEPARATOR ","»
											(«childRule.inPattern.elements.findFirst[ipe.varName == varName].type.convert»)«ipe.uniqueName»
										«ENDFOR»
									);
								} else «ENDFOR» {
								«IF !rule.isAbstract»
									«IF rule.isUnique»
										return «cacheName».computeIfAbsent(
											«rule.compileSourceTuple(st)»,
											«cd.simpleName».this::apply«rule.name»
										);
									«ELSE»
										// TODO: store trace in a Multimap?
										return this.apply«rule.name»(
											«rule.compileSourceTuple(st)»
										);
									«ENDIF»
								«ELSE»
									throw new «UnsupportedOperationException»();
								«ENDIF»
							}
						'''
					]
				} else if(!(rule instanceof LazyMatchedRule) && rule.module.isRefining) {
					// regular rules in refining mode
					//println('''regular rule «rule.module.name».«rule.name»''')
					addMethod('''apply«rule.name»''')[
						returnType = tt.newTypeReference
						setDocComment('''
							Method generated from regular rule «rule.module.name».«rule.name»@«rule.location» in refining mode
						''')
						addParameter("it", st.newTypeReference)
						// «»
						body = '''
							// TODO: cache
							«ipes.compileSourcePattern»
							«FOR ope : rule.allOutPatternElements.indexed»
								// TODO: check that names match?
								final «ope.value.type.convert» «ope.value.uniqueName» = «
										if(ope.key < ipes.length) {
											ipes.get(ope.key).uniqueName
										} else {
											newInstance(ope.value.type as OclModelElement)
										}
									»;
							«ENDFOR»
							«rule.compileBindings»
							return «rule.compileTargetTuple(tt)»;
						'''
					]
				} else {
					throw new UnsupportedOperationException
				}
			}

			// TODO: other cases (e.g., non-unique lazy rules, regular rules in non-refining mode), or errors
		}

		@FinalFieldsConstructor
		static class ATL2JavaGenerator extends OCL2Java {
			def sourceTupleInterface(MatchedRule it) {
				'''«cd.qualifiedName».«name»SourceTuple'''.toString.findInterface
			}

			def targetTupleInterface(MatchedRule it) {
				'''«cd.qualifiedName».«name»TargetTuple'''.toString.findInterface
			}

			def StringConcatenationClient compileSourceTuple(MatchedRule rule, TypeDeclaration st) '''
				new «st»() {
					«FOR ipe : rule.inPattern.elements»
						public «ipe.type.convert» «ipe.varName»() {
							return «ipe.uniqueName»;
						}
					«ENDFOR»

					public boolean equals(Object o) {
						return	o != null &&
								o.getClass() == this.getClass() &&
								«FOR ipe : rule.inPattern.elements SEPARATOR "&&"»
									this.«ipe.varName»().equals(((«st»)o).«ipe.varName»())«ENDFOR»;
					}

					public int hashCode() {
						return
								«FOR ipe : rule.inPattern.elements SEPARATOR "+"»
									this.«ipe.varName»().hashCode()«ENDFOR»;
					}
				}'''

			def StringConcatenationClient compileTargetTuple(MatchedRule rule, TypeDeclaration tt) '''
				new «tt»() {
					«FOR ope : rule.allOutPatternElements»
						public «ope.type.convert» «ope.varName»() {
							return «ope.uniqueName»;
						}
					«ENDFOR»
				}'''

			def StringConcatenationClient compileSourcePattern(Iterable<InPatternElement> ipes) '''
				«FOR ipe : ipes»
					final «ipe.type.convert» «ipe.uniqueName» = it.«ipe.varName»();
				«ENDFOR»
			'''

			def <C extends LocatedElement> C checkedCast(LocatedElement it, Class<C> cl) {
				if(cl.isInstance(it)) {
					it as C
				} else {
					addError(cd, '''expected «eClass.name»@«location» to be a «cl.simpleName», but that was not the case''')
					throw new ClassCastException
				}
			}

			def eStructuralFeature(Binding it) {
				val ec = (checkedCast(outPatternElement.type, OclModelElement).eClassifier as EClass)
				val ret = ec.getEStructuralFeature(propertyName)
				if(ret === null) {
					val message = '''error: «location»: could not find property «propertyName» in «ec.name»'''
					println(message)
					addError(cd, message)
				}
				ret
			}

			def Iterable<Binding> allBindings(MatchedRule it) {
				allTargetPatternElements.asMap.values.flatMap[
					flatMap[bindings].groupBy[propertyName].values.map[head]
				]
			}
	
			def Iterable<OutPatternElement> allOutPatternElements(MatchedRule it) {
				allTargetPatternElements.asMap.values.map[head]
			}

			def ListMultimap<String, OutPatternElement> allTargetPatternElements(MatchedRule it) {
				val ret = ArrayListMultimap.create(Multimaps.forMap(outPattern.elements.toMap[varName]))
				if(superRule !== null) {
					ret.putAll(superRule.allTargetPatternElements)
				}
				ret
			}
	
			def StringConcatenationClient compileBindings(MatchedRule rule) '''
				«FOR binding : rule.allBindings»
					«IF binding.eStructuralFeature.isMany»
						// TODO: when compiled value is not a collection
						«binding.outPatternElement.uniqueName».get«binding.propertyName.toFirstUpper»().addAll(
							«binding.value.compile[
									throw new UnsupportedOperationException
							]»
						);
					«ELSEIF binding.eStructuralFeature.EType instanceof EEnum»
						«binding.outPatternElement.uniqueName».set«binding.propertyName.toFirstUpper»(
							// TODO: when there is no instanceClass? (or require that there is one)
							«binding.eStructuralFeature.EType.instanceClass».get(
								«binding.value.compile[
										throw new UnsupportedOperationException
								]»
							)
						);
					«ELSE»
						«binding.outPatternElement.uniqueName».set«binding.propertyName.toFirstUpper»(
							«binding.value.compile[
									throw new UnsupportedOperationException
							]»
						);
					«ENDIF»
				«ENDFOR»
			'''
		}

		def allRules(Iterable<Unit> it) {
			flatMap[e | e.rules].toList
		}

		def addHelperMethod(extension OCL2Java it, Attribute feature, String helperName) {
			val featureType = feature.type.convert
			val contextType = feature.definition.context_?.context_?.convert
			val cacheName = '''__cache_«helperName»_«id++»'''
			if(contextType !== null) {
				addField(cacheName)[
					type = Map.newTypeReference(contextType, featureType)
					initializer = '''new «HashMap»<>()'''
				]
				addMethod(helperName.escapeMethodName)[
					addParameter(SELF, contextType)
					returnType = featureType
					setDocComment('''
						Method generated from Attribute helper «(feature.eContainer.eContainer.eContainer as Unit).name».«feature.name»@«feature.location»
					''')
					body = '''
						// «feature.location»
						return computeIfAbsent(«cacheName», «SELF», (key) -> «feature.initExpression.compile([
							// TODO
							Object.newTypeReference
						])»);
					'''
				]
			} else {
				addField(cacheName)[
					type = featureType
					initializer = '''null'''
				]
				addMethod(helperName.escapeMethodName)[
					returnType = featureType
					setDocComment('''
						Method generated from Attribute helper «(feature.eContainer.eContainer.eContainer as Unit).name».«feature.name»@«feature.location»
					''')
					body = '''
						// «feature.location»
						return (this.«cacheName» != null)
						?	this.«cacheName»
						:	(this.«cacheName» =
								«feature.initExpression.compile([
									// TODO
								Object.newTypeReference
								])»);
					'''
				]
			}
		}

		def addHelperMethod(extension OCL2Java it, Operation feature, String helperName) {
			addMethod(helperName.escapeMethodName)[m |
				val typeParameters = new HashMap<String, TypeParameterDeclaration>
				val typeParameterGetter = [
					typeParameters.computeIfAbsent(it)[name |
						m.addTypeParameter(name)
					].newTypeReference
				]
				if(feature.definition.context_ !== null) {
					m.addParameter(SELF, feature.definition.context_.context_.convert(typeParameterGetter))
				}
				feature.parameters.forEach[p |
					var rt = p.type.convert(typeParameterGetter)
					m.addParameter(p.uniqueName, rt)
				]
				m.returnType = feature.returnType.convert(typeParameterGetter)
				m.setDocComment('''
					Method generated from Operation helper «(feature.eContainer.eContainer.eContainer as Unit).name».«feature.name»@«feature.location»
				''')
				// TODO: add cache?
				m.body = '''
					// «feature.location»
					return «feature.body.compile(typeParameterGetter)»;
				'''
			]
		}

		def static <E> E debug(E v, String msg) {
			println(msg + ": " + v)
			v
		}
	}
}
