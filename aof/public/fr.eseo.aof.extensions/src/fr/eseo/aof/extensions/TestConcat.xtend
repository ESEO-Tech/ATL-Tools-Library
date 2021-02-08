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

package fr.eseo.aof.extensions

import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox

class TestConcat {
	def static createTestBox(int base) {
		AOFFactory.INSTANCE.createSequence((1..3).map[it + base] as Integer[])
	}

	def static void main(String[] args) {
		val bs = createTestBox(0)
		bs.inspect("bs: ")
		val cs = createTestBox(3)
		cs.inspect("cs: ")
		val ds = bs.concat(cs)
		ds.inspect("ds: ")
		new BoxFuzzer(bs, [BoxFuzzer.rand.nextInt], [
			SortedBy.assertEquals(bs.snapshot.concat(cs), ds)
		])
		new BoxFuzzer(cs, [BoxFuzzer.rand.nextInt], [
			SortedBy.assertEquals(bs.snapshot.concat(cs), ds)
		])
		new BoxFuzzer(bs, [BoxFuzzer.rand.nextInt], [
			SortedBy.assertEquals(bs.snapshot.concat(cs), ds)
		])
	}
}