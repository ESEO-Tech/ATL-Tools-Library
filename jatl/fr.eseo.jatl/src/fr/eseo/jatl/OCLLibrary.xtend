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

import com.google.common.collect.ImmutableMap
import com.google.common.collect.ImmutableSet
import java.util.ArrayList
import java.util.Collection
import java.util.List
import java.util.HashMap
import java.util.Map
import java.util.Set
import java.util.stream.Collectors
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource

interface OCLLibrary {
	// utils
	// variant that caches null values too
	def <K, V> computeIfAbsent(Map<K, V> it, K key, (K)=>V mappingFunction) {
		val current = get(key)
		if(current !== null) {
			if(current === nullMarker) {
				null
			} else {
				current
			}
		} else {
			val ret = mappingFunction.apply(key)
			if(ret !== null) {
				put(key, ret)
			} else {
				// this cast is not absolutely correct
				// but is Ok as long as the it Map is only accessed through this method
				put(key, nullMarker as V)
			}
			ret
		}
	}
	val nullMarker = new Object

	// syntax
	// casting to anything because Java cannot properly infer types in all cases
	def <A, B, E> let(A v, (A)=>B f) {
		f.apply(v) as E
	}

	def <E extends EObject> E refSetValue(E it, String name, Object value) {
		eSet(eClass.getEStructuralFeature(name), value)
		it
	}

	def <E extends EObject> E refAddValue(E it, String name, Object value) {
		(eGet(eClass.getEStructuralFeature(name)) as Collection<Object>).add(value)
		it
	}

	def <E extends EObject> E refAddAllValue(E it, String name, Collection<?> value) {
		(eGet(eClass.getEStructuralFeature(name)) as Collection<Object>).addAll(value)
		it
	}

	// ATL/OCL operations
	def operator_NOT(boolean o) {
		!o
	}

	def operator_AND(boolean l, boolean r) {
		l && r
	}

	def operator_OR(boolean l, boolean r) {
		l || r
	}

	def operator_NEQ(Object l, Object r) {
		if(l instanceof String) {
			!l.equals(r)
		} else {
			l !== r
		}
	}

	def operator_EQ(Object l, Object r) {
		//println(l + " == " + r + "=>" + (l == r))
		l == r
/*
		if(l instanceof String) {
			l.equals(r)
		} else {
			l === r
		}
*/
	}

	def operator_GT(int l, int r) {
		l > r
	}

	def operator_GT(int l, double r) {
		l > r
	}

	def operator_GT(double l, int r) {
		l > r
	}

	def operator_GT(double l, double r) {
		l > r
	}

	def operator_LT(int l, int r) {
		l < r
	}

	def operator_LT(int l, double r) {
		l < r
	}

	def operator_LT(double l, int r) {
		l < r
	}

	def operator_LT(double l, double r) {
		l < r
	}

	def operator_GE(int l, int r) {
		l >= r
	}

	def operator_GE(int l, double r) {
		l >= r
	}

	def operator_GE(double l, int r) {
		l >= r
	}

	def operator_GE(double l, double r) {
		l >= r
	}

	def operator_LE(int l, int r) {
		l <= r
	}

	def operator_LE(int l, double r) {
		l <= r
	}

	def operator_LE(double l, int r) {
		l <= r
	}

	def operator_LE(double l, double r) {
		l <= r
	}

	def operator_PLUS(String l, String r) {
		l + r
	}

	def operator_PLUS(int l, int r) {
		l + r
	}

	def operator_PLUS(int l, double r) {
		l + r
	}

	def operator_PLUS(double l, int r) {
		l + r
	}

	def operator_PLUS(double l, double r) {
		l + r
	}

	def operator_MINUS(int l, int r) {
		l - r
	}

	def operator_MINUS(int l, double r) {
		l - r
	}

	def operator_MINUS(double l, int r) {
		l - r
	}

	def operator_MINUS(double l, double r) {
		l - r
	}

	def operator_MINUS(int o) {
		-o
	}

	def operator_MINUS(double o) {
		-o
	}



	def int size(Collection<?> it) {
		length
	}

	def boolean notEmpty(Collection<?> it) {
		!empty
	}

	def boolean isEmpty(Collection<?> it) {
		empty
	}

	def <E> union(Iterable<E> it, Iterable<E> o) {
		val ret = new ArrayList<E>();
		ret.addAll(it)
		ret.addAll(o)
		ret
	}

	def <K, V> union(Map<K, V> it,Map<K, V> o) {
/*
		val ret = new HashMap(it);
		ret.putAll(o)
		ret
*/
		ImmutableMap.builder.putAll(it).putAll(o).build
	}

	def sum(Collection<String> it) {
		it.stream().collect(Collectors.joining());
	}

	def <E> prepend(Object it, E v) {
		val ret = new ArrayList<E>()
		ret.add(v)
		ret.addAll(it as Iterable<E>)
		return ret
	}

	def <E> includes(Collection<E> it, E v) {
		contains(v)
	}

	def <E> E debug(E it) {
		System.err.println(it)
		it
	}

	def oclIsUndefined(Object it) {
		it === null
	}

	def Set<String> getExcludedMessagePrefixes()

	def <E> E debug(E it, String message) {
		if(message.matches("^[A-Za-z0-9_]*-.*")) {
			val type = message.split("-").get(0)
			if(excludedMessagePrefixes.contains(type)) {
				return it
			}
		}
		System.err.println(message + ": " + it)
		it
	}

	def oclType(EObject it) {
		eClass.instanceClass
	}

	def Class<Class> oclType(Class<?> it) {
		Class
	}

	def toString(Object it) {
		it.toString
	}

	def oclIsKindOf(Object it, Class<?> type) {
		type.isInstance(it)
	}

	def <E> E refImmediateComposite(Object it) {
		switch it {
			EObject: eContainer as E
			default: throw new UnsupportedOperationException
		}
	}

	def <E> asOrderedSet(Iterable<? extends E> it) {
		ImmutableSet.copyOf(it)
	}

	def startsWith(String it, String o) {
		it.startsWith(o)
	}

	def <E> first(Collection<E> it) {
		if(empty) {
			null
		} else {
			get(1)
		}
	}

	def <E> oclAsType(Object it, Class<E> c) {
		it as E
	}

	def Iterable<Resource> getModel(String name)

	def <E> Collection<E> allInstancesFrom(Class<E> it, String modelName) {
		val r = getModel(modelName)
		if(r === null) {
			throw new UnsupportedOperationException("model " + modelName)
		}
		r.flatMap[res | allInstancesFrom(res)].toList
	}

	def <E> Iterable<E> allInstancesFrom(Class<E> it, Resource r) {
		r.allContents.filter(it).toList
	}

	def <K, E> E get(Map<K, ?> it, K key) {
		get(key) as E
	}

	def <K, V> including(Map<K, V> it, K key, V value) {
		ImmutableMap.builder.putAll(it).put(key, value).build	
	}

	def <K, V> containsKey(Map<K, V> it, K key) {
		containsKey(key)	
	}

	def <K, V> getKeys(Map<K, V> it) {
		keySet
	}

	def <E> E get(Collection<E> it, int idx) {
		switch it {
			List<E>: get(idx - 1)
			default: throw new IllegalStateException
		}
	}

	// ATOL extensions
	def <A, B> Collection<Pair<A, B>> zip(Collection<A> l, Collection<B> r) {
		val ret = new ArrayList<Pair<A, B>>
		for(var i = 0 ; i < l.length && i < r.length ; i++) {
			ret.add(l.get(i + 1) -> r.get(i + 1))
		}
		ret
	}

	def <A, B> left(Pair<A, B> it) {
		key
	}

	def <A, B> right(Pair<A, B> it) {
		value
	}

	def <E, C extends E> select(Collection<E> it, Class<C> cl) {
		filter(cl)
	}

	def <E, C extends E> Collection<C> select(E it, Class<C> cl) {
		if(cl.isInstance(it)) {
			#[it as C]
		} else {
			#[]
		}
	}

	def notEmpty(Object it) {
		it !== null
	}
}