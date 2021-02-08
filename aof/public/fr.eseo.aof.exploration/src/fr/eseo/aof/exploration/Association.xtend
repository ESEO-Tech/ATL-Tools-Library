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

import fr.eseo.aof.xtend.utils.AOFData
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.IOne
import org.eclipse.papyrus.aof.core.ISet

// incomplete example
class Association {
	@AOFData(singleLine=true)
	static class A {
		int i
		IOne<B> b
		override toString() {
			'''a«i»'''
		}
	}

	@AOFData(singleLine=true)
	static class B {
		int i
		IOne<A> a
		override toString() {
			'''b«i»'''
		}
	}

	static val factory = AOFFactory.INSTANCE

	def static void main(String[] args) {
		val a_b = factory.<Pair<A,B>>createSet.inspect("a_b=")

		val allAs = factory.createSequence((0..10).map[
			val ret = new A(it, null)
			ret.b.inspect('''a«it».b=''')
			ret.b.bind(a_b.select[it.key == ret].collect([it.value], [ret->it]).asOne(null))
			ret
		].toList.toArray(<A>newArrayOfSize(0)))
		val allBs = factory.createSequence((0..10).map[
			val ret = new B(it, null)
			ret.a.inspect('''b«it».a=''')
			ret.a.bind(a_b.select[it.value == ret].collect([it.key], [it->ret]).asOne(null))
			ret
		].toList.toArray(<B>newArrayOfSize(0)))

		allAs.get(5).b.set(allBs.get(1))
		allAs.get(1).b.set(allBs.get(1))	// error: not detached from the other
//		println(a.b.collectMutable[it?.a ?: TargetIntermediateClass.emptyOne])
	}

	// is this what we need?
	def static <E> ISet<E> nubBy(IBox<E> box, (E,E)=>boolean eq) {
		null
	}
}