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

package fr.eseo.atol.gen.plugin.constraints.common

import java.util.ArrayList
import java.util.LinkedHashMap
import java.util.List
import java.util.Map
import java.util.Stack
import java.util.concurrent.TimeUnit

class Stopwatch {
	val Stack<com.google.common.base.Stopwatch> timers = new Stack
	var Map<String, List<Long>> timings = new LinkedHashMap
	val List<Map<String, List<Long>>> runs = new ArrayList
	var printLive = false

	def reset() {
		timers.clear
		runs.clear
		timings.clear
	}

	def changeRun() {
		runs.add(timings)
		timings = new LinkedHashMap
	}

	def start() {
		timers.push(com.google.common.base.Stopwatch.createStarted)
	}

	def record(String label) {
		val timer = timers.pop
		timer.stop
		if (printLive)
			println('''«label»: «timer.elapsed(TimeUnit.MICROSECONDS)»us''')

		if (timings.containsKey(label)) {
			timings.get(label).add(timer.elapsed(TimeUnit.MICROSECONDS))
		}
		else {
			val tmp = new ArrayList
			tmp.add(timer.elapsed(TimeUnit.MICROSECONDS))
			timings.put(label, tmp)
		}
	}

	def printTimings() {
		runs.forEach[run, idx |
			println('''****** Run «idx» ******''')
			run.entrySet.forEach[
				val label = key
				val times = value
				if (times.size > 1) {
					val sum = times.fold(0l, [$0 + $1])
					val sortedTimes = times.sort
					val median = if (times.size % 2 == 0) (sortedTimes.get(times.size/2) + sortedTimes.get(times.size/2 - 1)) / 2.0d else sortedTimes.get(times.size/2)
					val avg = sum / times.size as double
					println('''«label»: «sum»us (avg: «avg»us, median: «median»us)''')
				}
				else {
					println('''«label»: «times.get(0)»us''')
				}
			]
		]
	}

	def getAsCSV(boolean printLabels) {
		var header = 
		if (printLabels) {
			'''«FOR label : runs.get(0).entrySet.map[key] SEPARATOR ','»«label»«ENDFOR»'''
		}
		else {
			""
		}
		var lines = runs.map[ run |
			val times = run.entrySet.map[value].map[fold(0l, [$0 + $1])]
			'''«FOR time : times SEPARATOR ','»«time»«ENDFOR»'''
		].join("\n")
		header + "\n" + lines
	}
}
