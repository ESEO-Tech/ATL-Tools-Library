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

import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.IOne
import org.eclipse.papyrus.aof.core.IPair
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver

/*
 * AOF implementation of edit-lens paper example
 */
class EditLensExample {
	val static factory = AOFFactory.INSTANCE

	// Simpler than init2, but modifying b results in non-chronological inspects
	// it would be simpler to base "inspect" on a "prependObserver" method
	def static Pair<IBox<IPair<String, String>>, IBox<IPair<String, String>>> init1() {
		val common = factory.createSequence("Schubert", "Shumann")
		val leftOnly = factory.createSequence("1797-1828", "1810-1856")
		val rightOnly = factory.createSequence("Austria", "Germany")

		leftOnly.bindShape(rightOnly)

		val a = common.zip(leftOnly, false).inspect("left=")
		val b = common.zip(rightOnly, false).inspect("right=")
		a -> b
	}

	// More complex than init1, modifying b results in chronological inspects, but each step of initial b computation is inspected
	def static Pair<IBox<IPair<String, String>>, IBox<IPair<String, String>>> init2() {
		val common = factory.createSequence()
		val leftOnly = factory.createSequence()
		val rightOnly = factory.createSequence("Austria", "Germany")

		val a = factory.createSequence(
			factory.createPair("Schubert", "1797-1828"),
			factory.createPair("Shumann", "1810-1856")
		)
		a.inspect("left=")
		common.zip(leftOnly, false).bind(a)

		leftOnly.bindShape(rightOnly)

		val b = factory.createSequence()
		b.inspect("right=")
		b.bind(common.zip(rightOnly, false))

		a -> b
	}

	def static void main(String[] args) {
		val ab = init1
		println("INIT DONE, STARTING MODIFICATIONS")
		val a = ab.key
		val b = ab.value

		// ok
		a.add(factory.createPair("Monteverdi", "1567-1643"))

		// result is correct BUT
		// this gets propagated although no change occurs (because AOF1 needs to propagate "no-change" events, which AOF2 will hopefully not)
		b.updateRight(2, "Italy")

		// ok
		b.updateLeft(1, "Schumann")

		// result is correct BUT
		// this gets "amplified" (i.e., one moved => 6 replaced) because the forward zip gets notified from both inputs separately
		// hopefully, AOF2 should get rid of this event "amplification"
		a.move(0, 2)
	}

	static def <L, R> updateLeft(IBox<IPair<L, R>> box, int index, L newValue) {
		box.set(index, factory.createPair(newValue, box.get(index).right))
	}

	static def <L, R> updateRight(IBox<IPair<L, R>> box, int index, R newValue) {
		box.set(index, factory.createPair(box.get(index).left, newValue))
	}

	static def <E, F> bindShape(IBox<E> left, IBox<F> right) {
		val active = factory.createOne(true)	// shared state to "silence" the other observer
		left.unidirBindShape(right, active)
		right.unidirBindShape(left, active)
	}

	static def <E, F> unidirBindShape(IBox<E> left, IBox<F> right, IOne<Boolean> active) {
		left.addObserver(new DefaultObserver<E> {
			override added(int index, Object element) {
				if(active.get) {
					active.set(false)
					right.add(index, null)
					active.set(true)
				}
			}
			override moved(int newIndex, int oldIndex, Object element) {
				if(active.get) {
					active.set(false)
					right.move(newIndex, oldIndex)
					active.set(true)
				}
			}
			override removed(int index, Object element) {
				if(active.get) {
					active.set(false)
					right.removeAt(index)
					active.set(true)
				}
			}
			override replaced(int index, Object newElement, Object oldElement) {
				// nothing to do
			}
		});
	}
}