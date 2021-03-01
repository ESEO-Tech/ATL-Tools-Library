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

package fr.eseo.atlc.example.graf.transfo

import com.google.common.collect.EvictingQueue
import fr.eseo.atlc.constraints.Constraint
import fr.eseo.atlc.constraints.Expression
import fr.eseo.atlc.example.graf.GrafFactory
import fr.eseo.atlc.example.graf.GrafPackage
import fr.eseo.atlc.example.graf.Graph
import fr.eseo.atol.gen.plugin.constraints.solvers.Constraints2Cassowary
import java.util.ArrayList
import java.util.HashMap
import java.util.Queue
import javafx.application.Application
import javafx.scene.Group
import javafx.scene.Node
import javafx.scene.Scene
import javafx.scene.input.KeyEvent
import javafx.scene.input.MouseButton
import javafx.scene.input.MouseEvent
import javafx.scene.layout.Pane
import javafx.scene.shape.Circle
import javafx.stage.Stage
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl
import org.eclipse.papyrus.aof.core.IBox

import static extension fr.eseo.atol.gen.JFXUtils.*

class RunGraf extends Application {
	var mouseX = 0.0
	var mouseY = 0.0
	val Graph graf
	val IBox<Group> nodes
	val IBox<Constraint> constraints
	var Constraints2Cassowary c2cas

	val target2Source = new HashMap<Node, EObject>
	
	def static void main(String[] args) {
		launch(args)
	}

	new() {
//		val transfo = new Graf2JFX
//		extension val JFX = transfo.JFXMM
		val transfo = new GrafTCSVG2JFX
		extension val JFX = transfo.SVGMM //get extension to add _nodes, _children, _constraints and _movable extension methods
		extension val GrafMM = transfo.GrafMM //get extension to add _nodes, _arcs

		transfo.Node.registerCustomTrace = [s, t |
			target2Source.put(t.t, s.s)
			target2Source.put(t.circle, s.s)
			target2Source.put(t.label, s.s)
		]
		transfo.Arc.registerCustomTrace = [s, t |
			target2Source.put(t.t, s.s)
			target2Source.put(t.line, s.s)
		]


		// Init meta model and EMF stuff
		val rs = new ResourceSetImpl

		rs.resourceFactoryRegistry.extensionToFactoryMap.put(
			"xmi",
			new XMIResourceFactoryImpl
		)
        rs.packageRegistry.put(
			GrafPackage.eNS_URI,
			GrafPackage.eINSTANCE
		)

		// create a resource & load model from file
		val resource =rs.getResource(URI.createFileURI("data2.xmi"), true)
//		val resource =rs.getResource(URI.createFileURI("data.xmi"), true)
		graf = resource.contents.get(0) as Graph

		val nodesResults = graf._nodes.collect[transfo.Node(it)]
		val arcs = graf._arcs.collect[transfo.Arc(it)]

		this.nodes = arcs.collect[
			it.t
		].concat(
			nodesResults.collect[
				it.t
			]
		)
		constraints = nodesResults.collect[it.cstr].concat(arcs.collect[it.cstr])

		// feed generated constraints to the constraint solver
		c2cas = new Constraints2Cassowary(JFX, transfo.GrafMM)
		c2cas.apply(constraints.collect[it as Expression])
		c2cas.solve

		// apply listeners to the movable elements
		this.nodes.children.selectMutable[_movable].collect[
			onPress
			onDrag
			''
		]
	}
	
	override start(Stage stage) throws Exception {
		// Setup GUI stuff
		val Pane root = new Pane
		val scene = new Scene(root, 800, 800);
		stage.setScene(scene);
		stage.setTitle("Graf");
		stage.show();

		scene.stylesheets.add("/fr/eseo/atlc/example/graf/transfo/style.css")

		//Quit app on escape keypress
		scene.addEventHandler(KeyEvent.KEY_PRESSED, [KeyEvent t |
			switch t.getCode {
				case ESCAPE: {
					stage.close
				}
				case SPACE: {
					c2cas.debug
				}
				case N: {
					val n = GrafFactory.eINSTANCE.createNode => [
						xinit = mouseX
						yinit = mouseY
						label = '''node«graf.nodes.size»'''
					]
					graf.nodes.add(n)
				}
				case E: {
					if (latestTwoClickedNodes.size == 2) {
						val src = target2Source.get(latestTwoClickedNodes.poll) as fr.eseo.atlc.example.graf.Node
						val tgt = target2Source.get(latestTwoClickedNodes.poll) as fr.eseo.atlc.example.graf.Node
						val arc = GrafFactory.eINSTANCE.createArc => [
							source = src
							target = tgt
						]
						graf.arcs.add(arc)
					}
				}
				case D: {
					if (!latestTwoClickedNodes.empty) {
						val nodeToRemove = target2Source.get(latestTwoClickedNodes.poll) as fr.eseo.atlc.example.graf.Node
						val edgesToRemove = new ArrayList(nodeToRemove.incommingArcs)
						edgesToRemove.addAll(nodeToRemove.outgoingArcs)
						edgesToRemove.forEach[ // error with propagation when using removeAll
							graf.arcs.remove(it)
						]
						graf.nodes.remove(nodeToRemove)
						latestTwoClickedNodes.remove(nodeToRemove)
					}
				}
				default: {}
			}
		]);
		scene.addEventHandler(MouseEvent.MOUSE_MOVED, [MouseEvent e |
			mouseX = e.x
			mouseY = e.y
		])
		root.children.toBox.bind(this.nodes as IBox<?> as IBox<Node>)
	}

	val Queue<Node> latestTwoClickedNodes = EvictingQueue.create(2)

	var dx = 0.0
	var dy = 0.0

	def onPress(Node it) {
		onMousePressed = [e |
			val t = e.target
			switch t {
				Circle: {
					if (latestTwoClickedNodes.last != t) {
						latestTwoClickedNodes.add(t)
					}
					dx = e.x - t.centerX
					dy = e.y - t.centerY
					e.consume
				}
			}
		]
	}

	def onDrag(Node it) {
		onMouseDragged = [e |
			val t = e.target
			switch t {
				Circle:
					switch (e.button) {
						case MouseButton.PRIMARY: {
							c2cas.suggestValue(t.centerXProperty, e.x - dx)
							c2cas.suggestValue(t.centerYProperty, e.y - dy)
							e.consume
						}
						default: {
						}
					}
				}
		]
	}
}