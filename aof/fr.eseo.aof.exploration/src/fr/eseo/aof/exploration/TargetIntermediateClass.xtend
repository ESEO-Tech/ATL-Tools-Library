/****************************************************************
 *  Copyright (C) 2020 ESEO
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

package fr.eseo.aof.exploration

import com.google.common.collect.BiMap
import com.google.common.collect.HashBiMap
import fr.eseo.aof.xtend.utils.AOFData
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.IOne

class TargetIntermediateClass {
	@AOFData(singleLine=true)
	static class SA {
		IOne<String> s
	}

	@AOFData(singleLine=true)
	static class TA {
		IOne<TB> b
	}

	@AOFData(singleLine=true)
	static class TB {
		IOne<String> s
//		@Opposite(name="b")	// TODO
//		IOne<TA> a
	}

//	annotation Opposite {
//		String name
//	}

	def static transform(IBox<SA> source) {
		source.collectTo(HashBiMap.create, [
			val ret = new TA(new TB(null))
			ret.b.collectMutable[
				it?.s ?: emptyOne
			].bind(it.s)
			ret
		], [
			val ret = new SA(null)
			ret.s.bind(it.b.collectMutable[
				it?.s ?: emptyOne
			])
			ret
		])
	}

	static val factory = AOFFactory.INSTANCE

	def static void main(String[] args) {
		val source = factory.createSequence(new SA("test"))

		val target = source.transform

		source.inspect("source=")
		target.inspect("target=")

//		source.add(new SA("test2"))

//		target.add(new TA(new TB("test2")))

		target.add(new TA(null))
//		target.get(1).b.set(new TB("test2"))

//		println(source)

		// TODO: implement a technique to compare (e.g., canonicalization)
		val targetp = source.transform.inspect("target'=")
		if(targetp.toString != target.toString) {
			println("error: target' != target")
		}
	}

	def static <A, B> IBox<B> collectTo(IBox<A> box, BiMap<A, B> cache, (A)=>B collector, (B)=>A reverseCollector) {
		box.collect([
			if(cache.containsKey(it)) {
				cache.get(it)
			} else {
				val ret = collector.apply(it)
				cache.put(it, ret)
				ret
			}
		], [
			if(cache.containsValue(it)) {
				cache.inverse.get(it)
			} else {
				val ret = reverseCollector.apply(it)
				cache.put(ret, it)
				ret
			}
		])
	}

	def static <E> emptyOne() {
		IBox.ONE as IOne<E>
	}
}