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

import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.impl.operation.Operation
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver

class Sum<E> extends Operation<E> {

//	val IBox<E> sourceBox
	val E neutral
	val (E, E)=>E plus
	val (E, E)=>E minus

	def +(E a, E b) {
		plus.apply(a, b)
	}

	def -(E a, E b) {
		minus.apply(a, b)
	}

	new(IBox<E> sourceBox, E neutral, (E, E)=>E plus, (E, E)=>E minus) {
//		this.sourceBox = sourceBox
		this.neutral = neutral
		this.plus = plus
		this.minus = minus
		result.set(0, sourceBox.reduce[$0+$1] ?: neutral)
		registerObservation(sourceBox, new DefaultObserver<E> {
			override added(int index, E element) {
				result.set(0, result.get(0) + element)
			}
			override moved(int newIndex, int oldIndex, E element) {
				// nothing to do
			}
			override removed(int index, E element) {
				result.set(0, result.get(0) - element)
			}
			override replaced(int index, E newElement, E oldElement) {
				result.set(0, result.get(0) - oldElement + newElement)
			}
		})
	}

	override isOptional() {
		false
	}

	override isSingleton() {
		true
	}

	override isOrdered() {
		true
	}

	override isUnique() {
		true
	}

	override getResultDefautElement() {
		neutral
	}

//	def static void main(String[] args) {
//		val bs = AOFFactory.INSTANCE.createSequence(1, 2, 3, 4, 5, 6)
//		bs.inspect("bs: ")
//		val cs = new Sum(bs).result
//		cs.inspect("cs: ")
//		new BoxFuzzer(bs, [BoxFuzzer.rand.nextInt], [
//			SortedBy.assertEquals("", bs.reduce[$0+$1]?:0, cs.get(0))
//		])
//	}
}