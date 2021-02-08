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

package fr.eseo.atlc.example.scheduling.transfo

import com.google.common.collect.BiMap
import com.google.common.collect.HashBiMap
import fr.eseo.atlc.constraints.Expression
import fr.eseo.atlc.constraints.ExpressionGroup
import fr.eseo.atlc.example.scheduling.Period
import fr.eseo.atlc.example.scheduling.Project
import fr.eseo.atlc.example.scheduling.SchedulingFactory
import fr.eseo.atlc.example.scheduling.SchedulingPackage
import fr.eseo.atlc.example.scheduling.Task
import fr.eseo.atol.gen.AbstractRule
import fr.eseo.atol.gen.plugin.constraints.common.Constraints
import fr.eseo.atol.gen.plugin.constraints.common.ConstraintsHelpers
import fr.eseo.atol.gen.plugin.constraints.common.Stopwatch
import fr.eseo.atol.gen.plugin.constraints.solvers.Constraints2Cassowary
import fr.eseo.atol.gen.plugin.constraints.solvers.Constraints2Choco
import fr.eseo.atol.javafx.Arrow
import fr.eseo.atol.javafx.JFX.Figure
import java.util.HashMap
import java.util.List
import java.util.Map
import java.util.Random
import javafx.application.Application
import javafx.beans.property.BooleanProperty
import javafx.beans.property.SimpleBooleanProperty
import javafx.scene.Node
import javafx.scene.Scene
import javafx.scene.control.ListView
import javafx.scene.control.cell.CheckBoxListCell
import javafx.scene.input.KeyEvent
import javafx.scene.input.MouseButton
import javafx.scene.layout.BorderPane
import javafx.scene.layout.Pane
import javafx.scene.shape.Line
import javafx.scene.shape.Rectangle
import javafx.scene.text.Text
import javafx.stage.Stage
import javafx.util.StringConverter
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.IOne
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver

import static fr.eseo.atol.gen.plugin.constraints.common.ConstraintsHelpers.*

import static extension fr.eseo.aof.exploration.OCLByEquivalence.*
import static extension fr.eseo.atol.gen.JFXUtils.*

class RunSchedulingGenerator extends Application {
	val IBox<Node> nodes
	val IBox<ExpressionGroup> constraints
	var Constraints2Cassowary c2cas
	var Constraints2Choco c2cho
	extension Constraints = new Constraints
	val r = new Random

	val root = new Pane

	val transfo = new Scheduling2JFX

	val Project project

	val hideLine = AOFFactory.INSTANCE.createOne(false)

	val BiMap<EObject, Node> transformationCache = HashBiMap.create

	val Map<Rectangle, Period> semesterCache = new HashMap

	val Map<Expression, BooleanProperty> constraintsState = new HashMap

	val Stopwatch timer = new Stopwatch

	def static void main(String[] args) {
		launch(args)
	}

	new() {
		extension val JFX = transfo.JFXMM
		extension val CR = transfo.SchedulingMM
		ConstraintsHelpers.RIGHT_LEFT_DEP = true
		// Init meta model
		val rs = new ResourceSetImpl

		rs.resourceFactoryRegistry.extensionToFactoryMap.put(
			"xmi",
			new XMIResourceFactoryImpl
		)
		rs.packageRegistry.put(
			SchedulingPackage.eNS_URI,
			SchedulingPackage.eINSTANCE
		)

		// create a resource
//		val resource = rs.getFileResource("data.xmi");
		val resource = rs.getFileResource("data-simplified.xmi");
		project = resource.contents.get(0) as Project
		val NbPeriods = project.numberOfPeriods
		project.periods.addAll(
			(0..<NbPeriods).map[ n |
				SchedulingFactory.eINSTANCE.createPeriod => [
					number = n
					term = if (n%2 == 0) 'fall' else 'winter'
				]
			]
		)

		//TODO: sum() operation is not available in ATOL compiler yet
		//DONE: should be moved to a preprocessing refining number
//		project.slots.forEach[s |
//			s._totalCost.bind(
//				new Sum(s._tasks.cost.collect[doubleValue], 0.0, [$0+$1], [$0-$1]).result.collect[floatValue]
//			)
//		]
		val refiningTransfo = new SchedulingConstraints
		refiningTransfo.refine(resource)

		project.tasks.forEach[
			period = project.periods.get(0)
		]

		/* TODO: add list of variable relations
		 * if a relation is variable it cannot be compile with AOF navigation (collectMutable)
		 * compiler needs to know which one can be modified by the solver
		 * 	- ideally add an option to compiler plugin with lsit of relations that are variables
		 *  - right now, hard code these relations in ConstraintCompiler
		 * talk about road blocks about relation abstraction
		 */



		// assign each course to its suggested semester
		//TODO: should be moved to a preprocessing refining number
		// c.semesterNumber <- c.institute.semesters.indexOf(c.semester)
//		project.tasks.forEach[c |
//			c._periodNumber.bind(
//				c._period.collect([s |
//					if (s !== null)
//						s.getNumber
//					else
//						0
//				], [n |
//					project.periods.filter[getNumber == n].get(0)
//				])
//			)
//			c.period = project.periods.get(0)
////			defaultSemester.filter[k, v|
////				v.contains(c.code)
////			].forEach[k, v|
////				c.semesterNumber = k
////			]
//		]

		val courses_pairs = project._tasks.collect[it -> transfo.Task(it).g]
		val courses = courses_pairs.collect[value]
		val semesters_pairs = project._periods.collect[it -> transfo.Period(it).g]
		val semesters = semesters_pairs.collect[value]

		// TODO: make this incremental (e.g., by changing TupleRule.trace into a BiMap)
		courses_pairs.forEach[p |
			p.value.nodes.filter(Rectangle).forEach[
				transformationCache.put(p.key, it)
			]
		]
		semesters_pairs.forEach[p |
			p.value.nodes.filter(Rectangle).forEach[
				transformationCache.put(p.key, it)
				semesterCache.put(it, p.key)
			]
		]

		val figures = semesters.concat(courses).closure[
			it._children
		]
		nodes = figures.collectMutable[
			it?._nodes ?: AbstractRule.emptySequence
		]//.inspect("nodes: ")
		constraints = figures.collectMutable[
			it?._constraints ?: AbstractRule.emptySequence
		]//.inspect("constraints: ")

		val allConstraints =
			constraints
				.union(
					refiningTransfo.allContents(resource, null).collect[
						refiningTransfo.trace.get(it)
					].select[it !== null].collectMutable[
						if(it === null) {
							return AbstractRule.emptySequence
						}
						AOFFactory.INSTANCE.createSequence(
							values.filter(ExpressionGroup) as ExpressionGroup[]
						)
					]
				)

		allConstraints.addObserver(new DefaultObserver<ExpressionGroup>() {
			override added(int index, ExpressionGroup element) {
				val state = new SimpleBooleanProperty
				state.value = true
				state.toBidirBox.inspect("change value of " + state)
				constraintsState.put(element, state)
			}

			override moved(int newIndex, int oldIndex, ExpressionGroup element) {}

			override removed(int index, ExpressionGroup element) {
				constraintsState.remove(element)
			}

			override replaced(int index, ExpressionGroup newElement, ExpressionGroup oldElement) {
				removed(index, oldElement)
				added(index, newElement)
			}
		})

		allConstraints.forEach[
			val state = new SimpleBooleanProperty
			state.value = true
			constraintsState.put(it, state)
		]

		val FALSE = AOFFactory.INSTANCE.createOne(false)
		val activeConstraints = allConstraints.selectMutable[
			if (it === null) return FALSE
			constraintsState.get(it).toBidirBox
		]

		c2cho = new Constraints2Choco(transfo.JFXMM, transfo.SchedulingMM)
		c2cho.timer = timer
		c2cho.defaultLowerBound = 0
		c2cho.defaultUpperBound = 6
		c2cho.apply(activeConstraints.select[solver == "choco"].collect[it as Expression])
		c2cho.solve

		c2cas = new Constraints2Cassowary(transfo.JFXMM, transfo.SchedulingMM)
		c2cas.apply(activeConstraints.select[solver == "cassowary"].collect[it as Expression])
		c2cas.solve

		nodes.filter[_movable.get].forEach[
			onPress
			onDrag
		]
		nodes.filter[_hideable.get].forEach[
			visibleProperty.toBox.bind(hideLine)
		]
	}

	// target element accessor for ListPatterns
	def static g(List<Object> l) {
		l.get(0) as Figure
	}

	override start(Stage stage) throws Exception {
		// Setup GUI stuff
		val layout = new BorderPane
		layout.center = root
		val constraintsPanel = new ListView<ExpressionGroup>
		layout.right = constraintsPanel
		constraintsPanel.prefWidth = 500
		val scene = new Scene(layout, 800, 800);
		stage.setScene(scene);
		stage.setTitle("scheduling");
		stage.show();

		//Quit app on escape keypress
		scene.addEventFilter(KeyEvent.KEY_PRESSED, [KeyEvent t |
			switch t.getCode {
				case ESCAPE: {
					stage.close
				}
				case SPACE: {
					c2cas.debug
					c2cho.debug
				}
				case H: hideLine.toggle
				case R: {
					val maxX = scene.width * 0.9
					val maxY = 600 * 0.9
					randomizePositions(maxX, maxY)
				}
				case A: {
				}
				case D: {
					val courses = project.tasks.last
					if (courses !== null) {
						val c = courses
						c.requisitedBy.forEach[source.requisites.remove(it)]
						c.corequisitedBy.forEach[source.corequisites.remove(it)]
						c.period = null
						EcoreUtil.delete(c)

						c2cho.solve
					}
				}
				default: {}
			}
		]);

		root.children.toBox.bind(
				nodes.select(Arrow).collect[it as Node]
			.concat(
				nodes.select(Rectangle).collect[it as Node]
			).concat(
				nodes.select(Text).collect[it as Node]
			).concat(
				nodes.select(Line).collect[it as Node]
			)
		)
		root.style = "-fx-background-color: #ffffff;"

		constraintsPanel.cellFactory = CheckBoxListCell.forListView([
			constraintsState.get(it)
		], new StringConverter<ExpressionGroup>() {
			override fromString(String string) {
				null
			}

			override toString(ExpressionGroup cstr) {
				cstr.prettyPrint
			}
		})

		constraintsPanel.items.toBox.bind(constraints)
		
		

		randomizePositions(scene.width * 0.9, 600 * 0.9)
	}

	def randomizePositions(double maxX, double maxY) {
		for (n : nodes) {
			switch (n) {
				Rectangle: {
					c2cas.suggestValue(n.xProperty, r.nextDouble * maxX)
					c2cas.suggestValue(n.yProperty, r.nextDouble * maxY)
				}
			}
		}
	}

	def toggle(IOne<Boolean> it) {
		set(!get)
	}

	var dx = 0.0
	var dy = 0.0

	def onPress(Node it) {
		onMousePressed = [e |
			val t = e.target
			switch t {
				Rectangle: {
					dx = e.x - t.x
					dy = e.y - t.y
					e.consume
				}
			}
		]
	}

	def onDrag(Node it) {
		onMouseDragged = [e |
			val t = e.target
			switch t {
				Rectangle:
					switch (e.button) {
						case MouseButton.PRIMARY: {
							val smNodes = semesterCache.filter[k, v | k.contains(e.x, e.y)]
							if (!smNodes.empty) {
								val p = smNodes.entrySet.get(0)
								val s = p.value
								val c = transformationCache.inverse.get(t) as Task //TODO; check if exists elsewhere

								if (c.period != s) {
//									timer.reset
//									timer.start
									c2cho.suggest(c, 'period', s)
									if (!c2cho.solve) {
										println("No solution found, ignoring suggestion")
									}
//									timer.record("suggest + solve")
//									timer.changeRun
//									timer.printTimings
								}
								c2cas.suggestValue(t.xProperty, e.x - dx)
								c2cas.suggestValue(t.yProperty, e.y - dy)
							}
							e.consume
						}
						default: {}
					}
				}
		]
	}
	
	static def getFileResource(ResourceSet rs, String file) {
		rs.getResource(URI.createFileURI(file), true)
	}
}
