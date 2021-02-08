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

import fr.eseo.atlc.constraints.Expression
import fr.eseo.atlc.example.graf.GrafPackage
import fr.eseo.atlc.example.graf.Graph
import fr.eseo.atol.gen.AbstractRule
import fr.eseo.atol.gen.plugin.constraints.solvers.Constraints2Cassowary
import javafx.application.Application
import javafx.scene.Node
import javafx.scene.Scene
import javafx.scene.input.KeyEvent
import javafx.scene.input.MouseButton
import javafx.scene.layout.Pane
import javafx.scene.shape.Circle
import javafx.stage.Stage
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl
import org.eclipse.papyrus.aof.core.IBox

import static extension fr.eseo.atol.gen.JFXUtils.*

class RunGraf extends Application {
	val IBox<Node> nodes
	val IBox<Expression> constraints
	var Constraints2Cassowary c2cas
	
	def static void main(String[] args) {
		launch(args)
	}

	new() {
		val transfo = new Graf2JFX
		extension val JFX = transfo.JFXMM //get extension to add _nodes, _children, _constraints and _movable extension methods
		
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
		val resource =rs.getResource(URI.createFileURI("data.xmi"), true)

		val target = transfo.Graph(
			resource.contents.get(0) as Graph // get the Graph from the resource
		).g // apply the transformation to it and get the g element of the rule

		val figures = target._children
		nodes = figures.collectMutable[			// recover all Nodes
			it?._nodes ?: AbstractRule.emptySequence
		]//.inspect("nodes: ")
		constraints = figures.collectMutable[	// recover all Constraint
			it?._constraints ?: AbstractRule.emptySequence
		].collect[it as Expression]//.inspect("constraints: ") //we use collect as a casting mechanism here because AOF

		// feed generated constraints to the constraint solver
		c2cas = new Constraints2Cassowary(transfo.JFXMM, transfo.GrafMM)
		c2cas.apply(constraints)
		c2cas.solve

		// apply listeners to the movable elements
		nodes.filter[_movable.get].forEach[
			onPress
			onDrag
		]
	}
	
	override start(Stage stage) throws Exception {
		// Setup GUI stuff
		val Pane root = new Pane
		val scene = new Scene(root, 800, 800);
		stage.setScene(scene);
		stage.setTitle("Graf");
		stage.show();

		//Quit app on escape keypress
		scene.addEventHandler(KeyEvent.KEY_PRESSED, [KeyEvent t |
			switch t.getCode {
				case ESCAPE: {
					stage.close
				}
				case SPACE: {
					c2cas.debug
				}
				default: {}
			}
		]);
		root.children.toBox.bind(nodes)
	}

	var dx = 0.0
	var dy = 0.0

	def onPress(Node it) {
		onMousePressed = [e |
			val t = e.target
			switch t {
				Circle: {
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