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

package fr.eseo.aof.debug.utils

import java.util.ArrayList
import java.util.Collection
import java.util.HashMap
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.IOne
import org.eclipse.papyrus.aof.core.impl.Box
import org.eclipse.papyrus.aof.core.impl.utils.FactoryObserver

import static org.eclipse.papyrus.aof.core.impl.Box.*

class BoxProfiler implements BoxesAnalyzer {
	val pack = "org.eclipse.incquery"
	val boxesByLocation = new HashMap<StackTraceElement, Collection<IBox<?>>>

	var nbBoxes = 0
	var nbOnes = 0
	val int step

	val FactoryObserver<IBox<?>> factoryObserver = [index, it |
		val location = Thread.currentThread.stackTrace.findFirst[stackTraceElement |
			stackTraceElement.className.startsWith(pack)
		]

		var boxes = boxesByLocation.get(location)
		if(boxes == null) {
			boxes = new ArrayList
			boxesByLocation.put(location, boxes)
		}
		boxes.add(it)

		nbBoxes++
		if(it instanceof IOne) {
			nbOnes++
		}
		if(nbBoxes % step == 0) {
			println('''Allocated «nbBoxes» boxes (including «nbOnes» IOnes) so far («(Runtime.runtime.totalMemory - Runtime.runtime.freeMemory) / 1048576»)...''')
		}
	]

	new(int step) {
		this.step = step
		// DONE: check if there is already a factoryObserver
		// because there can only be one
		if(Box.factoryObserver != null) {
			println('''warning: overriding already registered Box factory observer «Box.factoryObserver»''')
		}
		Box.factoryObserver = factoryObserver
	}
	
	override analyze() {
		println('''Allocated «nbBoxes» boxes.''')
		boxesByLocation.entrySet.sortBy[
			-it.value.size
		].forEach[
			println('''«it.value.size» at «it.key»''')
		]
		
	}
	
	override dispose() {
		if(Box.factoryObserver == factoryObserver) {
			Box.factoryObserver = null
		}
	}
	
	override nbBoxes() {
		println('''Allocated «nbOnes» IOnes.''')
		nbBoxes
	}
}
