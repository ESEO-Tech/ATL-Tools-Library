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

import com.google.common.collect.BiMap
import com.google.common.collect.HashBasedTable
import com.google.common.collect.HashBiMap
import com.google.common.collect.HashMultimap
import com.google.common.collect.Multimap
import com.google.common.collect.Table
import java.awt.Button
import java.awt.Frame
import java.awt.Panel
import java.lang.reflect.Field
import java.lang.reflect.InvocationHandler
import java.lang.reflect.Method
import java.lang.reflect.Parameter
import java.lang.reflect.Proxy
import java.util.ArrayList
import java.util.Collection
import java.util.HashMap
import java.util.HashSet
import java.util.LinkedHashMap
import java.util.LinkedHashSet
import java.util.List
import java.util.Map
import java.util.Set
import java.util.function.Predicate
import java.util.stream.Collectors
import javax.swing.JButton
import javax.swing.JFrame
import javax.swing.JPanel
import org.eclipse.emf.common.util.DelegatingEList
import org.eclipse.emf.common.util.Enumerator
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EEnum
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EParameter
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.m2m.atl.common.ATL.Binding
import org.eclipse.m2m.atl.common.ATL.Helper
import org.eclipse.m2m.atl.common.ATL.MatchedRule
import org.eclipse.m2m.atl.common.ATL.Module
import org.eclipse.m2m.atl.common.ATL.OutPatternElement
import org.eclipse.m2m.atl.common.ATL.Unit
import org.eclipse.m2m.atl.common.OCL.Attribute
import org.eclipse.m2m.atl.common.OCL.BooleanExp
import org.eclipse.m2m.atl.common.OCL.CollectionOperationCallExp
import org.eclipse.m2m.atl.common.OCL.EnumLiteralExp
import org.eclipse.m2m.atl.common.OCL.IfExp
import org.eclipse.m2m.atl.common.OCL.IntegerExp
import org.eclipse.m2m.atl.common.OCL.IteratorExp
import org.eclipse.m2m.atl.common.OCL.LetExp
import org.eclipse.m2m.atl.common.OCL.NavigationOrAttributeCallExp
import org.eclipse.m2m.atl.common.OCL.OclExpression
import org.eclipse.m2m.atl.common.OCL.OclModelElement
import org.eclipse.m2m.atl.common.OCL.OclType
import org.eclipse.m2m.atl.common.OCL.OclUndefinedExp
import org.eclipse.m2m.atl.common.OCL.Operation
import org.eclipse.m2m.atl.common.OCL.OperationCallExp
import org.eclipse.m2m.atl.common.OCL.RealExp
import org.eclipse.m2m.atl.common.OCL.SequenceExp
import org.eclipse.m2m.atl.common.OCL.SetExp
import org.eclipse.m2m.atl.common.OCL.StringExp
import org.eclipse.m2m.atl.common.OCL.TupleExp
import org.eclipse.m2m.atl.common.OCL.VariableDeclaration
import org.eclipse.m2m.atl.common.OCL.VariableExp
import org.eclipse.m2m.atl.emftvm.compiler.AtlResourceFactoryImpl
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.m2m.atl.common.ATL.LocatedElement
import org.eclipse.m2m.atl.common.ATL.LazyMatchedRule

/*
 * Working on this interpreter made it possible to identify issues in UML2Ecore & Ecore2UML that make them work only with AOF
 * unless much extra work is done. Some of the more complex cases have been fixed in the .atl files, but others are still
 * handled here, which is not a really good solution. 
 */
class ATOLInterpreter {
	val Unit unit
	val Map<String, EPackage> mms
	val Multimap<String, (Object)=>Object> attributeHelpers = HashMultimap.create
	val Multimap<String, Operation> operationHelpers = HashMultimap.create

	def addAttributeHelper(String name, (Object)=>Object evaluator) {
		attributeHelpers.put(name, evaluator)
		this
	}

	new(String filePath, Map<String, EPackage> mms) {
		this.mms = mms

		val rs = new ResourceSetImpl
		rs.resourceFactoryRegistry.extensionToFactoryMap.put("atl", new AtlResourceFactoryImpl)

		val r = rs.getResource(URI.createFileURI(filePath), true)
		unit = r.contents.get(0) as Unit
		if(unit instanceof Module) {
			unit.elements.filter(Helper).map[definition.feature].filter(Attribute).forEach[h |
				attributeHelpers.put(h.name)[o |
					// TODO: implicit collect
					if(h.definition.context_.context_.toClass.isInstance(o)) {
						return h.initExpression.eval(new SimpleNamedEnvironment(rootEnv, "self", o))
					}
				]
			]
			unit.elements.filter(Helper).map[definition.feature].filter(Operation).forEach[
				operationHelpers.put(name, it)
			]
		}
	}

	val rootEnv = new Environment<VariableDeclaration>(null) {
		override Object internalGet(VariableDeclaration variable) {
			throw new IllegalArgumentException('''variable not found: «variable.varName» (declared @«variable.location»)''')
		}
	}

	@Data
	static abstract class Environment<V> {
		val Environment<V> parent
		final def Object get(V variable) {
			internalGet(variable)
		}
		abstract def Object internalGet(V variable)
	}

	val Table<String, List<?>, Map<String, ?>> trace = HashBasedTable.create

	def Map<String, OutPatternElement> getAllOutPatternElements(MatchedRule it) {
		val ret = superRule?.allOutPatternElements ?: new LinkedHashMap
		outPattern.elements.forEach[
			ret.put(varName, it)
		]
		ret
	}

	def Map<String, Binding> getAllBindings(OutPatternElement it) {
		val ret = (outPattern.rule as MatchedRule).superRule?.allOutPatternElements?.get(varName)?.allBindings ?: new LinkedHashMap
		bindings.forEach[
			ret.put(propertyName, it)
		]
		ret
	}

	def register1To1(String ruleName, Object in, Object out) {
		trace.put(ruleName, #[in], #{ruleName.getRule.outPattern.elements.get(0).varName -> out})
	}

	def register(String ruleName, Object...inout) {
		val rule = ruleName.getRule
		val in = rule.inPattern.elements.indexed.map[inout.get(key)].iterator.toList
		val out = new LinkedHashMap(rule.outPattern.elements.indexed.toMap([value.varName])[inout.get(key + in.length)])
		trace.put(ruleName, in, out)
	}

	def getRule(String ruleName) {
		(unit as Module).elements
			.filter(MatchedRule).filter[name == ruleName].findFirst[true]
	}

	def Map<String, ?> apply(String ruleName, Object...args) {
		if(ruleName == "ParameterSubstitution2EGenericType") {
			println("there")
		}
		val ret_ = trace.get(ruleName, args.toList)
		if(ret_ !== null) {
			return ret_
		}

		val rule = ruleName.getRule
		check('''rule «ruleName» not found''', rule !== null)

		val ipes = rule.inPattern.elements
		check('''invalid number of arguments to «ruleName»: «args.length», should be «ipes.length»''', ipes.length === args.length)


		if(!rule.children.empty) {
			val r = rule.children.findFirst[cr |
				cr.inPattern.elements.indexed.forall[ipe |
					ipe.value.type.mmEClass.isInstance(args.get(ipe.key))
				]
			]?.name
			if(r !== null) {
				return r.apply(args)
			} if(rule.isIsAbstract) {
				return null
			}
		}

		val isRefining = rule.module.isRefining && !(rule instanceof LazyMatchedRule)
		val opes = rule.allOutPatternElements

		val firstOpe = opes.values.findFirst[true]
		val ret = new LinkedHashMap(opes.values.toMap([varName])[ope |
			if(isRefining && ope === firstOpe) {
				args.get(0) as EObject
			} else {
				ope.type.mmEClass.newInstance
			}
		])

		trace.put(ruleName, args.toList, ret)

		val map = new HashMap
		ipes.forEach[ipe, i |
			map.put(ipe.varName, args.get(i))
		]
		opes.values.forEach[ope, i |
			map.put(ope.varName, ret.get(ope.varName))
		]
		val env = new Environment<VariableDeclaration>(rootEnv) {
			override internalGet(VariableDeclaration variable) {
				if(map.containsKey(variable.varName)) {
					map.get(variable.varName)	// resolving using varName for the sake of inherited bindings'VariableExps
				} else {
					getParent.get(variable)
				}
			}
		}
		rule.variables.forEach[
			map.put(varName, initExpression.eval(env))	// augmenting env via its internal Map
		]

		opes.values.forEach[ope |
			val t = ret.get(ope.varName)
			ope.allBindings.values.forEach[binding |
				try {
					val v = binding.value.eval(env)
					if(v instanceof Collection<?>) {
						val v_ = v.filterNull.toList
						t.set(binding.propertyName, v_)
					} else if(v !== null) {
						t.set(binding.propertyName, v)
					}
				} catch(Exception e) {
					warning('''error executing binding «ruleName».«ope.varName».«binding.propertyName»''')
					e.printStackTrace(System.out)
				}
				
			]
		]

		ret
	}

	dispatch def EClass mmEClass(OclType it) {
		error('''cannot convert to EClass: «it»''')
	}

	dispatch def EClass mmEClass(OclModelElement it) {
		val ep = mms.get(model.name)
		ep.getEClassifier(name) as EClass
	}

	dispatch def Object eval(OclExpression it, Environment<VariableDeclaration> env) {
		warning('''unsupported kind of expression: «it»''')
	}

	def Object makeFlat(Collection<?> it) {
		stream.flatMap[e |
			switch e {
				Collection<?>: (e.makeFlat as Collection<?>).stream
				default: #[e].stream
			}
		].collect(Collectors.toList)
	}

	dispatch def toClass(OclType it) {
		error('''cannot convert type «it»''')
	}

	dispatch def toClass(OclModelElement it) {
		mmEClass.instanceClass
	}

	dispatch def Object eval(NavigationOrAttributeCallExp it, Environment<VariableDeclaration> env) {
		val sourceVal = source.eval(env)
		sourceVal?.navigate(name, it)
	}

	def Object navigate(Object o, String name, NavigationOrAttributeCallExp it) {
		val candidateHelpers = attributeHelpers.get(name)
		for(h : candidateHelpers) {
			return h.apply(o)
		}
		try {
			switch o {
				String: switch name {
					case "firstToLower": o.toFirstLower
					default: error('''unsupported attribute on String: «name»''')
				}
				Map<String, ?>: o.get(name)
				EObject:
					o.get(name)
				Collection<?>: {
					o.map[e | e.navigate(name, it)].iterator.toList.makeFlat
				}
				default:
					error('''unsupported field access on «o»''')
			}
		} catch(Exception e) {
			throw new RuntimeException('''«location»''', e)
		}
	}

	@Data
	static class SimpleEnvironment<V> extends Environment<V> {
		val V variable
		val Object value
		override internalGet(V variable) {
			if(variable === this.variable) {
				this.value
			} else {
				getParent.get(variable)
			}
		}
	}

	@Data
	static class SimpleNamedEnvironment extends Environment<VariableDeclaration> {
		val String variable
		val Object value
		override internalGet(VariableDeclaration variable) {
			if(variable.varName == this.variable) {
				this.value
			} else {
				getParent.get(variable)
			}
		}
	}

	dispatch def Object eval(LetExp it, Environment<VariableDeclaration> env) {
		val varValue = it.variable.initExpression.eval(env)
		val newEnv = new SimpleEnvironment<VariableDeclaration>(env, variable, varValue)
		in_.eval(newEnv)
	}

	dispatch def Object eval(OperationCallExp it, Environment<VariableDeclaration> env) {
		val src = it.source
		if(src instanceof VariableExp) {
			if(src.referredVariable.varName == "thisModule") {
				val argVal = arguments.map[eval(env)]
				val firstArg = argVal.get(0)
				return switch firstArg {
					case null: null
					// TODO: handle all args with zip semantics
					Collection<?>: firstArg.indexed.map[e |
						apply(operationName, argVal.indexed.map[
							val v = value
							if(e.key === 0) {
								e.value
							} else if(v instanceof Collection<?>) {
								v.get(e.key)
							} else {
								v
							}
						].toList.toArray)
					].iterator.toList
					case operationHelpers.containsKey(operationName): {
						// TODO: improve operation selection
						val op = operationHelpers.get(operationName).get(0)
						val map = op.parameters.indexed.toMap([
							value.varName
						], [
							argVal.get(key)
						])
						val opEnv = new Environment<VariableDeclaration>(env) {
							override internalGet(VariableDeclaration variable) {
								map.get(variable.varName)
							}
						}
//						println('''«operationName»(«map»)''')
						op.body.eval(opEnv)

					}
					default: apply(operationName, argVal.toArray)
				}
			}
		}
		val sourceVal = src.eval(env)
		switch operationName {
			case "oclIsUndefined": sourceVal === null
			case "oclIsKindOf": {
				val type = arguments.get(0).eval(env)
				switch type {
					EClass: type.isInstance(sourceVal)
					Class<?>: type.isInstance(sourceVal)
					default: error('''cannot call oclIsKindOf with argument «type»''')
				}
			}
			case "=": sourceVal == arguments.get(0).eval(env)
			case "<>": sourceVal != arguments.get(0).eval(env)
			case "+": {
				val argVal = arguments.get(0).eval(env)
				switch sourceVal {
					String: sourceVal + argVal
					default: if(sourceVal instanceof Double || argVal instanceof Double) {
						(sourceVal as Number).doubleValue + (argVal as Number).doubleValue
					} else {
						(sourceVal as Number).intValue + (argVal as Number).intValue
					}
				}
			}
			case "-": {
				val srcVal = sourceVal as Number
				val argVal = arguments.get(0).eval(env) as Number
				if(sourceVal instanceof Double || argVal instanceof Double) {
					srcVal.doubleValue - argVal.doubleValue
				} else {
					srcVal.intValue - argVal.intValue
				}
			}
			case "*": {
				val srcVal = sourceVal as Number
				val argVal = arguments.get(0).eval(env) as Number
				if(sourceVal instanceof Double || argVal instanceof Double) {
					srcVal.doubleValue * argVal.doubleValue
				} else {
					srcVal.intValue * argVal.intValue
				}
			}
			case "/": {
				val srcVal = sourceVal as Number
				val argVal = arguments.get(0).eval(env) as Number
				if(sourceVal instanceof Double || argVal instanceof Double) {
					srcVal.doubleValue / argVal.doubleValue
				} else {
					srcVal.intValue / argVal.intValue
				}
			}
			case "and": switch sourceVal {
				Boolean: sourceVal && arguments.get(0).eval(env) as Boolean
				default: error('''cannot and: «sourceVal»''')
			}
			case "not": switch sourceVal {
				Boolean: !sourceVal
				default: error('''cannot not: «sourceVal»''')
			}
			case ">": switch sourceVal {
				Integer: sourceVal > arguments.get(0).eval(env) as Integer
				default: error('''cannot compare: «sourceVal»''')
			}
			case "oclAsType": sourceVal
			case "__immutable": sourceVal
			case "debug": {
				if(arguments.empty) {
					println(sourceVal)
				} else {
					println('''«(arguments.get(0).eval(env))»: «sourceVal»''')
				}
				sourceVal
			}
			default: error('''unsupported operation: «operationName»''')
		}
	}

	dispatch def Object eval(CollectionOperationCallExp it, Environment<VariableDeclaration> env) {
		val sourceVal_ = source.eval(env)	// TODO: wrap non-collection into a collection
		val sourceVal = if(sourceVal_ instanceof Collection<?>) {
			sourceVal_
		} else {
			#[sourceVal_]
		}
		switch operationName {
			case "collectTo": {
				if(arguments.length > 1) {
					error('''unsupported: multiple rules in collectTo''')
				}
				val r = arguments.get(0).eval(env) as String
				sourceVal?.filter[it !== null].map[e | apply(r, e)]?.iterator?.toList
			}
			case "select": {
				val argVal = arguments.get(0).eval(env) as EClass
				sourceVal.filter[e | argVal.isInstance(e)].iterator.toList
			}
			case "asSet": {
				new LinkedHashSet(sourceVal)
			}
			case "first": {
				if(sourceVal.empty) {
					null
				} else {
					sourceVal.get(0)
				}
			}
			case "asOne": {
				if(sourceVal.empty) {
					arguments.get(0).eval(env)
				} else {
					sourceVal.get(0)
				}
			}
			case "indexOf": {
				sourceVal.toList.indexOf(arguments.get(0).eval(env))
			}
			case "size": {
				sourceVal.size
			}
			case "notEmpty": {
				!sourceVal.empty
			}
			case "isEmpty": {
				sourceVal.empty
			}
			case "sum": {
				(sourceVal as Collection<Number>).reduce[
					if($0 instanceof Double || $1 instanceof Double) {
						$0.doubleValue + $1.doubleValue
					} else {
						$0.intValue + $1.intValue
					}
				] ?: 0
			}
			case "sumDoubles": {
				if(sourceVal.empty) {
					println("empty sumDOubles")
				}
				val ret = (sourceVal as Collection<Number>).reduce[
					$0.doubleValue + $1.doubleValue
				] ?: 0.0
				println("test " + ret)
				ret
			}
			case "concat": {
				val ret = new ArrayList
				ret.addAll(sourceVal)
				ret.addAll(arguments.get(0).eval(env) as Collection<?>)
				ret
			}
			default: error('''unsupported collection operation: «operationName»''')
		}
	}

	def <E> Collection<E> closure(Collection<E> it, Set<E> seen, (E)=>Collection<E> body) {
		val ret = new ArrayList
		ret.addAll(it)
		it.forEach[e |
			ret.addAll(body.apply(e).closure(seen, body))
		]
		ret
	}

	dispatch def Object eval(IteratorExp it, Environment<VariableDeclaration> env) {
		if(name == "zipWith") {
			val t = (source as TupleExp)
			return (t.get("left").eval(env) as Collection<?>).zipWith(t.get("right").eval(env) as Collection<?>)[l, r |
				body.eval(
					new SimpleEnvironment(
						new SimpleEnvironment(env, iterators.get(0), l),
						iterators.get(1), r
					)
				)
			]
		}
		val sourceVal_ = source.eval(env)
		val sourceVal = if(sourceVal_ instanceof Collection<?>) {
			sourceVal_
		} else {
			#[sourceVal_]
		}
		switch name {
			case "collect": {
				sourceVal.map[e |
					body.eval(new SimpleEnvironment(env, iterators.get(0), e))
				].iterator.toList
				.makeFlat	// TODO: only makeFlat if inner is not immutable
			}
			case "select": {
				sourceVal.filter[e |
					body.eval(new SimpleEnvironment(env, iterators.get(0), e)) as Boolean
				].iterator.toList
			}
			case "reject": {
				sourceVal.filter[e |
					!body.eval(new SimpleEnvironment(env, iterators.get(0), e)) as Boolean
				].iterator.toList
			}
			case "closure": {
				(sourceVal as Collection<Object>).closure(new HashSet)[e |
					body.eval(new SimpleEnvironment(env, iterators.get(0), e)) as Collection<Object>
				]
			}
			default: error('''unsupported iterator expression: «name»''')
		}
	}

	def <A, B, C> zipWith(Collection<A> l, Collection<B> r, (A,B)=>C body) {
		val ret = new ArrayList

		val n = Math.min(l.size, r.size)
		for(var i = 0 ; i < n ; i++) {
			ret.add(body.apply(l.get(i), r.get(i)))
		}

		ret
	}

	def get(TupleExp it, String name) {
		tuplePart.findFirst[varName == name].initExpression
	}

	dispatch def Object eval(OclModelElement it, Environment<VariableDeclaration> env) {
		mmEClass
	}

	dispatch def Object eval(IfExp it, Environment<VariableDeclaration> env) {
		if(condition.eval(env) as Boolean) {
			thenExpression.eval(env)
		} else {
			elseExpression.eval(env)
		}
	}

	dispatch def Object eval(EnumLiteralExp it, Environment<VariableDeclaration> env) {
		name
	}

	def get(EObject it, String featureName) {
//		println('''«it».«featureName»''')
		val f = eClass.getEStructuralFeature(featureName) ?:
			eClass.getEStructuralFeature(featureName.replaceAll("[0-9]*$", ""))
		val ret = eGet(f)
		if(ret instanceof Enumerator) {
			return ret.name
		}
		ret
	}

	def set(EObject it, String featureName, Object value) {
		if("eGenericType" == featureName) {
			println("here")
		}
		val f = eClass.getEStructuralFeature(featureName)
		val t = f.EType
		if(t instanceof EEnum) {
			if("public" == value) return;	// TODO: why do we need this for visibility="public" not to be serialized (like with ATOLGen)?
			eSet(f, t.EPackage.EFactoryInstance.createFromString(t, value as String))
		} else if(f.many && !(value instanceof Collection<?>)) {
			(eGet(f) as Collection<Object>).add(value)
		} else if(value instanceof Collection<?>) {
			val v = value.makeFlat as Collection<?>
			if(f.many) {
				eSet(f, v)
			} else {
				if(!v.empty) {
					eSet(f, v.get(0))
					if(v.size > 1) {
						warning('''more than one element in collection used to set a single-valued property''')
					}
				}
			}
		} else {
			eSet(f, value)
		}
	}

	dispatch def Object eval(VariableExp it, Environment<VariableDeclaration> env) {
		env.get(referredVariable)
	}

	dispatch def Object eval(OclUndefinedExp it, Environment<VariableDeclaration> env) {
		null
	}

	dispatch def Object eval(TupleExp it, Environment<VariableDeclaration> env) {
		tuplePart.toMap([
			varName
		])[
			initExpression.eval(env)
		]
	}

	dispatch def Object eval(SetExp it, Environment<VariableDeclaration> env) {
		elements.map[eval(env)].iterator.toSet
	}

	dispatch def Object eval(SequenceExp it, Environment<VariableDeclaration> env) {
		elements.map[eval(env)].iterator.toList
	}

	dispatch def Object eval(BooleanExp it, Environment<VariableDeclaration> env) {
		booleanSymbol
	}

	dispatch def Object eval(IntegerExp it, Environment<VariableDeclaration> env) {
		integerSymbol
	}

	dispatch def Object eval(RealExp it, Environment<VariableDeclaration> env) {
		realSymbol
	}

	dispatch def Object eval(StringExp it, Environment<VariableDeclaration> env) {
		stringSymbol
	}

	def newInstance(EClass it) {
		EPackage.EFactoryInstance.create(it)
	}

	def check(String msg, boolean b) {
		if(!b) {
			unlocatedError(msg)
		}
	}

	def <E> E unlocatedError(String msg) {
		throw new IllegalArgumentException(msg)
	}

	def <E> E error(LocatedElement it, String msg) {
		throw new IllegalArgumentException('''«location»: «msg»''')
	}

	def <E> E warning(String msg) {
		println('''warning: «msg»''')
		null
	}

	def static void main(String[] args) {
//		awtTest
//		swingTest
//		println(ATOLInterpreter.getMethod("newInstance", EClass))
		extension val Refactorer = new Refactorer
//		Class.rename("EClass")
		Method.wrappedBy(EOperation)
			.redirecting("getParameters", "getEParameters")
		Parameter.wrappedBy(EParameter)
//			.redirecting("", "")
		Field.wrappedBy(EAttribute)[type.primitive]
			.redirecting("getType", "getEType")
		Field.wrappedBy(EReference)[!type.primitive]
			.redirecting("getType", "getEType")
		val Class2EClass = Class.wrappedBy(EClass)
			.redirecting("getDeclaredFields", "getEStructuralFeatures")
			.redirecting("getDeclaredOperations", "getEOperations")
			.redirecting("isInterface", "isInterface")
		Class2EClass.wrap(String).EStructuralFeatures.forEach[
			println('''String.«name» : «EType.name»''')
		]
		Class2EClass.unwrap(EcorePackage.eINSTANCE.EReference).fields.forEach[
			println('''EReference.«name» : «type.name»''')
		]

		//Class.getMethod("getFields").rename("getEStructuralFeatures")
//		Class.getMethod("declaredFields").rename("getEStructuralFeatures")
//		Class.getMethod("declaredOperations").rename("getEStructuralFeatures")
//		Method.getMethod("getParameters").rename("getEParameters")

//		new EClassImpl{}.isin
	}

	// TODO:
	//	- setTargetPackage
	static class Refactorer {
		val Map<Class<?>, MethodRefactorer<?, ?>> fmap = new HashMap
		val Map<Class<?>, MethodRefactorer<?, ?>> rmap = new HashMap
		@Data
		static class MethodRefactorer<S, T> {
			val Refactorer refactorer
			val Class<S> s
			val Class<T> t
			val BiMap<String, String> redirections = HashBiMap.create
			def MethodRefactorer<S, T> redirecting(String a, String b) {
				redirections.put(a, b)
				this
			}
			def T wrap(S it) {
				it.doWrap(s, t, redirections.inverse, refactorer)
			}
			def S unwrap(T it) {
				it.doWrap(t, s, redirections, refactorer)
			}
		}

		def static <S, T> doWrap(S it, Class<S> s, Class<T> t, BiMap<String, String> redirections, Refactorer refactorer) {
			Proxy.newProxyInstance(
				Thread.currentThread.contextClassLoader, #[t], new InvocationHandler {
					override invoke(Object proxy, Method method, Object[] args) throws Throwable {
						val tn = redirections.get(method.name)
						if(tn !== null) {
							val ret = s.getMethod(tn).invoke(it, if(args === null) #[] else args)
							ret.convertTo(method.returnType, refactorer)
						} else {
							val tm = s.getMethod(method.name)
							if(tm !== null) {
								tm.invoke(it, if(args === null) #[] else args)
							} else {
								throw new UnsupportedOperationException("TODO: auto-generated method stub")
							}
						}
					}
				}
			) as T
		}

		def static Object convertTo(Object o, Class<?> c, Refactorer refactorer) {
			switch o {
				Object[]: {
					new DelegatingEList.UnmodifiableEList(o.map[convertTo(null, refactorer)])// as Object[]
				}
				List<?>: o.map[convertTo(null, refactorer)] as List<?>
				default: {
					val oc = o.class;
					(refactorer.fmap.get(oc) as MethodRefactorer<Object, Object>).wrap(o)
				}
			}
		}

		def <S, T> MethodRefactorer<S, T> wrappedBy(Class<S> c, Class<T> wrapperInterface) {
			val ret = new MethodRefactorer(this, c, wrapperInterface)
			fmap.put(c, ret)
			rmap.put(wrapperInterface, ret)
			ret
		}

		def <S, T> MethodRefactorer<S, T> wrappedBy(Class<S> c, Class<T> wrapperInterface, Predicate<S> p) {
			val ret = new MethodRefactorer(this, c, wrapperInterface)
			fmap.put(c, ret)
			rmap.put(wrapperInterface, ret)
			ret
		}

		def rename(Class<?> c, String newName) {
			
		}

		def rename(Method c, String newName) {
			
		}
	}

	def static swing2awt() {
		extension val Refactorer = new Refactorer
		JFrame.rename("Frame")
		JPanel.rename("Panel")
		JButton.rename("Panel")
	}

	def static awtTest() {
		val frame = new Frame
		val panel = new Panel
		val button = new Button("test")
		panel.add(button)
		frame.add(panel)
		frame.pack
		frame.setVisible(true)
	}

	def static swingTest() {
		val frame = new JFrame
		val panel = new JPanel
		val button = new JButton("test")
		panel.add(button)
		frame.add(panel)
		frame.pack
		frame.setVisible(true)
	}
}
