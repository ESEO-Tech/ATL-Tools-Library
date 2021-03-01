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

package fr.eseo.atol.rules

import fr.eseo.atlc.constraints.Constraint
import fr.eseo.atlc.constraints.Expression
import fr.eseo.atlc.constraints.ExpressionGroup
import fr.eseo.atol.gen.AbstractRule
import fr.eseo.atol.gen.plugin.constraints.solvers.Constraints2Cassowary
import fr.eseo.atol.gen.plugin.constraints.solvers.Constraints2Choco
import fr.eseo.atol.gen.plugin.constraints.solvers.Constraints2Minicp
import fr.eseo.atol.gen.plugin.constraints.solvers.Constraints2Xcsp
import fr.eseo.atol.rules.JFX.Figure
import java.util.Collections
import java.util.List
import javafx.application.Application
import javafx.scene.Node
import javafx.scene.Scene
import javafx.scene.input.KeyEvent
import javafx.scene.input.MouseButton
import javafx.scene.layout.Pane
import javafx.scene.shape.Rectangle
import javafx.stage.Stage
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.impl.EcoreResourceFactoryImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.uml2.uml.NamedElement

import static extension fr.eseo.aof.exploration.OCLByEquivalence.*
import static extension fr.eseo.atol.gen.JFXUtils.*
import static extension fr.eseo.atol.rules.A.*
import static extension fr.eseo.atol.rules.NamedElementExtensions.*

class RunEcore2JFXGenerated extends Application {
	val IBox<Node> nodes
	val IBox<ExpressionGroup> constraints
	var Constraints2Cassowary c2cas
	var Constraints2Choco c2choco
	var Constraints2Minicp c2mini
	var Constraints2Xcsp c2xcsp

	def static void main(String[] args) {
		launch(args)
	}

	new() {
		(IBox.ONE as IBox<?> as IBox<NamedElement>).name
		Ecore.ENamedElement.defaultInstance = Ecore.EClass.defaultInstance
		// Init meta model
		val rs = new ResourceSetImpl

		rs.resourceFactoryRegistry.extensionToFactoryMap.put(
			"ecore",
			new EcoreResourceFactoryImpl
		)
		rs.resourceFactoryRegistry.extensionToFactoryMap.put(
			"xmi",
			new XMIResourceFactoryImpl
		)

        // create a resource
		val resource = rs.getFileResource("../fr.eseo.atol.examples.ecore2jfx/models/test.ecore");
//        val ps = resource.allContents.filter(EPackage).toList
//        val cs = resource.allContents.filter(EClass).toList

/*
        val transfo = new Ecore2javafx
/*/
//        val transfo = new Ecore2JavaFXModel
/**/
		val transfo = new Ecore2JavaFXGenerated

		val tgt = transfo.Package(
			resource.contents.get(0) as EPackage
		).g
		extension val JFX = transfo.JFXMM
		val figures = AOFFactory.INSTANCE.createOne(tgt).closure[
			it._children
		]
		nodes = figures.collectMutable[
			it?._nodes ?: AbstractRule.emptySequence
		]//.inspect("nodes: ")
		constraints = figures.collectMutable[
			it?._constraints ?: AbstractRule.emptySequence
		]//.inspect("constraints: ")

		c2cas = new Constraints2Cassowary(transfo.JFXMM, transfo.EcoreMM)
		c2cas.apply(constraints.select[solver == "cassowary"].collect[it as Expression])
		c2cas.solve
//		c2cas.suggestValue(nodes.select(Rectangle).get(0).widthProperty, 100) // no change because this suggest don't change anything
//		c2cas.suggestValue(nodes.select(Rectangle).get(0).widthProperty, 300) // this trigger update
//		c2cas.solve // keeps 300 because stay is working
		// suggest triggers an update even if autosolve is set to false

		c2choco = new Constraints2Choco(transfo.JFXMM, transfo.EcoreMM)
		c2choco.apply(constraints.select[solver == "choco"].collect[it as Expression])
		c2choco.solve

		c2mini = new Constraints2Minicp(transfo.JFXMM)
		c2mini.apply(constraints.select[solver == "minicp"].collect[it as Expression])
		c2mini.solve

		c2xcsp = new Constraints2Xcsp(transfo.JFXMM)
		c2xcsp.apply(constraints.collect[it as Expression])

		// does not work anymore because variables are not contained in constraints
//		val resSave2 = rs.createResource(URI.createFileURI("out-constraints.xmi"))
//		resSave2.contents.addAll(constraints)
//		resSave2.save(Collections.EMPTY_MAP);


		nodes.filter[_movable.get].forEach[
			onPress
			onDrag
		]
	}

	// target element accessor for ListPatterns
	def static g(List<Object> l) {
		l.get(0) as Figure
	}


	override start(Stage stage) throws Exception {
		// Setup GUI stuff
		val root = new Pane()

		val scene = new Scene(root, 800, 800);
		stage.setScene(scene);
		stage.setTitle("Ecore2JFX");
		stage.show();

		//Quit app on escape keypress
		scene.addEventHandler(KeyEvent.KEY_PRESSED, [KeyEvent t |
			switch t.getCode {
				case ESCAPE: {
					stage.close
				}
				case SPACE: {
					c2cas.debug
					c2choco.debug
					c2mini.debug
				}
				default: {
				}
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
							c2cas.suggestValue(t.xProperty, e.x - dx)
							c2cas.suggestValue(t.yProperty, e.y - dy)
//							println("call resolve")
//							c2cas.solve
							e.consume
						}
						default: {
						}
					}
				}
		]
	}
}
