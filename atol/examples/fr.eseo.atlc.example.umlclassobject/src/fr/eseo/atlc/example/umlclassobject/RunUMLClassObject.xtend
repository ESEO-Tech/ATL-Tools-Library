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

package fr.eseo.atlc.example.umlclassobject

import fr.eseo.atlc.constraints.Constraint
import fr.eseo.atol.gen.AbstractRule
import fr.eseo.atol.gen.plugin.constraints.solvers.Constraints2Cassowary
import fr.eseo.atol.javafx.JFX
import fr.eseo.atol.javafx.JFX.Figure
import java.util.Collections
import java.util.HashMap
import java.util.Random
import java.util.Stack
import javafx.application.Application
import javafx.geometry.Insets
import javafx.scene.Node
import javafx.scene.Scene
import javafx.scene.control.TextInputDialog
import javafx.scene.input.KeyEvent
import javafx.scene.input.MouseButton
import javafx.scene.layout.Background
import javafx.scene.layout.BackgroundFill
import javafx.scene.layout.CornerRadii
import javafx.scene.layout.HBox
import javafx.scene.layout.Pane
import javafx.scene.paint.Color
import javafx.scene.shape.Circle
import javafx.scene.shape.Line
import javafx.scene.shape.Polygon
import javafx.scene.shape.Polyline
import javafx.scene.shape.Rectangle
import javafx.scene.shape.Shape
import javafx.scene.text.Text
import javafx.scene.transform.Scale
import javafx.stage.Stage
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.IOne
import org.eclipse.uml2.uml.Association
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Classifier
import org.eclipse.uml2.uml.Element
import org.eclipse.uml2.uml.Generalization
import org.eclipse.uml2.uml.InstanceSpecification
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.Property
import org.eclipse.uml2.uml.Slot
import org.eclipse.uml2.uml.UMLPackage
import org.eclipse.uml2.uml.resource.UMLResource

import static extension fr.eseo.aof.exploration.OCLByEquivalence.*
import static extension fr.eseo.atol.gen.JFXUtils.*
import fr.eseo.atlc.constraints.Expression

/*
 * Interactors:
 *	- C to add a Class
 *	- O to add an object having for classifier the Class that has just been clicked on
 *	- P to add one of:
 *		- a Property to the Class that has just been clicked on
 *		- a Slot to the object that has just been clicked on
 *			- using either one of
 *				- the attribute that was selected before the object, if there is one, and it is valid for the object, and not already used
 *				- the first valid attribute that is not already used
 *	- A to add one of:
 *		- an Association between the last two Classes that have just been clicked on
 *		- a Link between the last two objects that have just been clicked on
 *			- typed by either one of
 *				- the Association selected before the two classes, if there is one, and if it is compatible
 *				- the first compatible Association
 *	- D to remove the last touched element (Class, Property, Association, Generalization, object, link, or Slot)
 *	- S to reserialize the model
 *	- I to add a Generalization between the last too Classes that have just been clicked on
 *		- from the oldest to the newest: the first clicked extends the last clicked
 *	- B (resp. with SHIFT) to add (resp. REMOVE) a "bend" to the Generalization that has just been clicked on
 *		- when removing a bend: either remove the clicked one, or the last one (if none clicked)
 *	- R to toggle between normal working mode, and randomized mode
 *		- In randomized mode, constraints are unregistered from solvers, and coordinates are randomized
 */
class RunUMLClassObject extends Application {
	var Constraints2Cassowary c2casClass
	var Constraints2Cassowary c2casObject

	var Model source = null

	val Pane left = new Pane
	val Pane right = new Pane

	val transfoClass = new UMLClass2JFX
	extension val UML UMLMM = transfoClass.UMLMM
	val transfoObject = new UMLObject2JFX

	val target2Source = new HashMap<Node, Element>

	val scaleFactor = 1.3

	def static void main(String[] args) {
		launch(args)
	}

	def operator_elvis(double lhs, double rhs) {
		if (lhs == 0) rhs else lhs
	}

	def applyTransformation(JFX jfx, UML uml, IBox<Figure> figures, Pane pane, IBox<IBox<Expression>> solverConstraints) {
		extension val JFXClass = jfx

		pane.background = new Background(
			new BackgroundFill(Color.WHITE, CornerRadii.EMPTY, Insets.EMPTY)
		)

		// get the constraints before the nodes to ensure solver is called and variables exist before nodes are visibles
		// this is necessary to randomize positions of newly added Rectangles
		val constraints = figures.collectMutable[
			it?._constraints ?: AbstractRule.emptySequence
		]//.inspect("constraints: ")
		val nodes = figures.collectMutable[
			it?._nodes ?: AbstractRule.emptySequence
		]//.inspect("class nodes: ")

		val solver = new Constraints2Cassowary(jfx, uml, null)
//		solver.apply(constraints.collect[it as Constraint])
		solverConstraints.set(0, constraints.collect[it as Expression])
		solver.apply(solverConstraints.collectMutable[it ?: AbstractRule.emptySequence])
		solver.solve

		val rand = new Random
		nodes.select[_movable(it).get].collect[
			onPress
			onDrag
			if(it instanceof Rectangle) {
				solver.suggestValue(xProperty, rand.nextDouble * (pane.width ?: 400) / scaleFactor)
				solver.suggestValue(yProperty, rand.nextDouble * (pane.height ?: 400) / scaleFactor)
			} else if(it instanceof Circle) {
				solver.suggestValue(centerXProperty, rand.nextDouble * (pane.width ?: 400) / scaleFactor)
				solver.suggestValue(centerYProperty, rand.nextDouble * (pane.height ?: 400) / scaleFactor)
			}
			null
		]

		nodes.select[_editable(it).get].collect[
			onDoubleClick
			null
		]

		pane.children.toBox.bind(
//			nodes.select(Arrow).collect[it as Node]
//			.concat(
//				nodes.select(Rectangle).collect[it as Node]
//			).concat(
//				nodes.select(Text).collect[it as Node]
//			).concat(
//				nodes.select(Line).collect[it as Node]
//			)
			nodes
		)

		solver
	}

	val IBox<IBox<Expression>> classConstraints = AOFFactory.INSTANCE.createOption
	var IBox<Expression> actualClassConstraints
	val IBox<IBox<Expression>> objectConstraints = AOFFactory.INSTANCE.createOption
	var IBox<Expression> actualObjectConstraints

	def initTransformation() {
		transfoClass.Class.registerCustomTrace = [s, t |
			target2Source.put(t.r, s.s)
			target2Source.put(t.txt, s.s)
		]
		transfoClass.Property.registerCustomTrace = [s, t |
			target2Source.put(t.txt, s.s)
		]
		transfoObject.Object.registerCustomTrace = [s, t |
			target2Source.put(t.r, s.s)
			target2Source.put(t.txt1, s.s)
			target2Source.put(t.txt2, s.s)
			target2Source.put(t.txt3, s.s)
		]
		transfoObject.Slot.registerCustomTrace = [s, t |
			target2Source.put(t.txt1, s.s)
			target2Source.put(t.txt2, s.s)
		]
		transfoObject.Link.registerCustomTrace = [s, t |
			target2Source.put(t.txt, s.s)
		]
		transfoClass.Association.registerCustomTrace = [s, t |
			target2Source.put(t.txt, s.s)
		]
		transfoClass.Generalization.registerCustomTrace = [s, t |
			target2Source.put(t.p, s.s)
		]
		extension val JFXClass = transfoClass.JFXMM
//		extension val JFXObject = transfoObject.JFXMM

		UML.TypedElement.defaultInstance = UML.Property.defaultInstance
		UML.NamedElement.defaultInstance = UML.Class.defaultInstance
		UML.StructuredClassifier.defaultInstance = UML.Class.defaultInstance

		source = loadModel(
			if(parameters.raw.empty) {
				"models/Sample1.uml"
			} else {
				parameters.raw.get(0)
			}
		)

		val figuresObject = transfoObject.Model(source).t._children.closure[
			it._children
		]
		c2casObject = applyTransformation(transfoObject.JFXMM, transfoObject.UMLMM, figuresObject, right, objectConstraints)
		actualObjectConstraints = objectConstraints.get(0)

		val figuresClass = transfoClass.Model(source).t._children.closure[
			it._children
		]
		c2casClass = applyTransformation(transfoClass.JFXMM, transfoClass.UMLMM, figuresClass, left, classConstraints)
		actualClassConstraints = classConstraints.get(0)
	}

	def loadModel(String path) {
		val rs = new ResourceSetImpl

		rs.resourceFactoryRegistry.extensionToFactoryMap.put(
			UMLResource.FILE_EXTENSION,
			UMLResource.Factory.INSTANCE
		)
		rs.packageRegistry.put(
			UMLPackage.eNS_URI,
			UMLPackage.eINSTANCE
		)
		rs.packageRegistry.put(
			"http://www.eclipse.org/uml2/4.0.0/UML",
			UMLPackage.eINSTANCE
		)

		val resource = rs.getResource(URI.createFileURI(path), true)
		resource.contents.get(0) as Model
	}

	override start(Stage stage) throws Exception {
		// Setup GUI stuff
		val scale = new Scale(scaleFactor,scaleFactor,0,0)
		val root = new HBox
		root.children.addAll(left, right)
		val scene = new Scene(root, 800, 800);
		stage.setScene(scene);
		stage.setTitle("UML Class and Object Diagrams");
		stage.show();
		root.transforms.add(scale)

		left.prefWidthProperty.bind(scene.widthProperty.divide(2*scaleFactor))
		right.prefWidthProperty.bind(scene.widthProperty.divide(2*scaleFactor))

		left.style = "-fx-border-color: #000000;"
		right.style = "-fx-border-color: #000000;"

		// moved transformation initialisation after scene is shown so that Panes have width & height
		// FIXME: on my computer height is OK, height is KO
		initTransformation

		//Quit app on escape keypress
		scene.addEventFilter(KeyEvent.KEY_PRESSED, [KeyEvent t |
			switch t.getCode {
				case ESCAPE: {
					stage.close
				}
				case SPACE: {
					c2casClass.debug
					c2casObject.debug
				}
				case C: {
					source.packagedElements.add(
						UML.Class.newInstance=>[
							name = "<unnamed Class>"
						]
					)
				}
				case O: {
					if(touchedElements.size >= 1) {
						val cl = touchedElements.pop.value
						if(cl instanceof Class) {
							source.packagedElements.add(
								UML.InstanceSpecification.newInstance=>[
									name = "<unnamed Object>"
									classifiers += cl
								]
							)
						}
					}
				}
				case A: {
					if(touchedElements.size >= 2) {
						val c1 = touchedElements.pop.value
						val c2 = touchedElements.pop.value
						switch c1 {
							Class: {
								if(c2 instanceof Class) {
									source.packagedElements +=
										UML.Association.newInstance=>[
											name = "<unnamed Association>"
											memberEnds += UML.Property.newInstance=>[
												type = c1
												name = "<unnamed Association end>"
											]
											memberEnds += UML.Property.newInstance=>[
												type = c2
												name = "<unnamed Association end>"
											]
											ownedEnds += memberEnds
										]
								}
							}
							InstanceSpecification: {
								if(c2 instanceof InstanceSpecification) {
									val c1t = c1.classifiers.get(0)
									val c2t = c2.classifiers.get(0)
									val selectedAssoc = if(touchedElements.empty()) {
										null
									} else {
										val sa = touchedElements.pop.value
										if(sa instanceof Association) {
											if(sa.matches(c1t, c2t)) {
												sa
											} else {
												null
											}
										} else {
											null
										}
									}
									val assoc = selectedAssoc ?: source.packagedElements.filter(Association).findFirst[
										matches(c1t, c2t)
									]
									if(assoc !== null) {
										val m1 = assoc.memberEnds.get(0)
										val m2 = assoc.memberEnds.get(1)
										source.packagedElements +=
											UML.InstanceSpecification.newInstance=>[
												classifiers += assoc
												if(c1t.conformsTo(m1.type)) {
													slots += UML.Slot.newInstance=>[
														definingFeature = m1
														values += UML.InstanceValue.newInstance=>[
															instance = c1
														]
													]
													slots += UML.Slot.newInstance=>[
														definingFeature = m2
														values += UML.InstanceValue.newInstance=>[
															instance = c2
														]
													]
												} else {
													slots += UML.Slot.newInstance=>[
														definingFeature = m2
														values += UML.InstanceValue.newInstance=>[
															instance = c1
														]
													]
													slots += UML.Slot.newInstance=>[
														definingFeature = m1
														values += UML.InstanceValue.newInstance=>[
															instance = c2
														]
													]
												}
											]
/*
											// Ideally, we could only create the partial link below, and let a solver repair the model by finding an Association
											UML.InstanceSpecification.newInstance=>[
												slots += UML.Slot.newInstance=>[
													values += UML.InstanceValue.newInstance=>[
														instance = c1
													]
												]
												slots += UML.Slot.newInstance=>[
													values += UML.InstanceValue.newInstance=>[
														instance = c2
													]
												]
											]
											// This + repairing after interaction (e.g., removing attribute => removing slot) are occurrences of "using domain constraints
											// to build interactions" (or to repair after simplistic actions)
 */
									}
								}
							}
						}
					}
				}
				case B: {
					if(!touchedElements.empty()) {
						val ts = touchedElements.pop
						val el = ts.value
						if(el instanceof Generalization) {
							if(t.isShiftDown) {
								if(el._waypoints.length > 0) {
									val n = ts.key
									switch n {
										Circle case el._waypoints.contains(n): {
											el._waypoints.remove(n)
										}
										default: {
											el._waypoints.removeAt(el._waypoints.length - 1)
										}
									}
								}
							} else {
								el._waypoints.add(new Circle=>[
									stroke = Color.BLACK
									transfoClass.JFXMM._movable(it).set(0, true)
									target2Source.put(it, el)
								])
								// TODO: suggest positions
							}
						}
					}
				}
				case I: {
					if(touchedElements.size >= 2) {
						val c1 = touchedElements.pop.value
						val c2 = touchedElements.pop.value
						switch c1 {
							Class: {
								if(c2 instanceof Class) {
									c2.generalizations +=
										UML.Generalization.newInstance=>[
											general = c1
										]
								}
							}
						}
					}
				}
				case P: {
					if(touchedElements.size >= 1) {
						val el = touchedElements.pop.value
						switch el {
							Class: {
								el.ownedAttributes +=
									UML.Property.newInstance=>[
										name = "testAttribute" + el.ownedAttributes.map["_"].join
									]
							}
							InstanceSpecification: {
								val elt = (el.classifiers.get(0) as Class)
								val selectedAttribute = if(touchedElements.empty()) {
									null
								} else {
									val sa = touchedElements.pop.value
									if(sa instanceof Property) {
										if(elt.getAllAttributes.contains(sa) && !el.slots.exists[s | s.definingFeature === sa]) {
											sa
										} else {
											null
										}
									} else {
										null
									}
								}
								val na = selectedAttribute ?: elt.getAllAttributes().findFirst[a |
									!el.slots.exists[s |
										s.definingFeature === a
									]
								]
								if(na !== null) {
									el.slots +=
										UML.Slot.newInstance=>[
											definingFeature = na
											values += UML.LiteralInteger.newInstance=>[
												value = 0
											]
										]
								}
							}
						}
					}
				}
				case R: {
					if(classConstraints.length === 0) {
						classConstraints.set(0, actualClassConstraints)
						c2casClass.sync
						objectConstraints.set(0, actualObjectConstraints)
						c2casObject.sync
					} else {
						classConstraints.clear
						left.randomize
						objectConstraints.clear
						right.randomize
					}
				}
				case D: {
					if(!touchedElements.empty()) {
						val el = touchedElements.pop.value
						switch(el) {
							Generalization: {
								el.specific = null
								el.general = null
							}
							Association,
							Class: {
								el.package.packagedElements.remove(el)
							}
							InstanceSpecification: {
								el.nearestPackage.packagedElements.remove(el)
							}
							Property: {
								el.class_.ownedAttributes.remove(el)
							}
							Slot: {
								el.owningInstance.slots.remove(el)
							}
						}
					}
				}
				case S: {
					source.eResource.setURI(URI.createFileURI("reserialized.uml"))
					source.eResource.save(Collections.emptyMap)
				}
				default: {
					return	// not clearing toucheElements if key not supported
				}
			}
			touchedElements.clear
		]);
	}

	def randomize(Pane pane) {
		val rand = new Random
		pane.children.filter(Shape).forEach[
			switch it {
				Polygon,
				Polyline: {
					for(var i = 0 ; i < pointsProp.size ; i += 2) {
						pointsProp.set(i, rand.nextDouble * (pane.width ?: 400) / scaleFactor)
						pointsProp.set(i + 1, rand.nextDouble * (pane.height ?: 400) / scaleFactor)
					}
				}
				Line: {
					startXProperty.set(rand.nextDouble * (pane.width ?: 400) / scaleFactor)
					startYProperty.set(rand.nextDouble * (pane.height ?: 400) / scaleFactor)
					endXProperty.set(rand.nextDouble * (pane.width ?: 400) / scaleFactor)
					endYProperty.set(rand.nextDouble * (pane.height ?: 400) / scaleFactor)
				}
				default: {
					xProp.set(rand.nextDouble * (pane.width ?: 400) / scaleFactor)
					yProp.set(rand.nextDouble * (pane.height ?: 400) / scaleFactor)
					if(it instanceof Rectangle) {
						width = rand.nextDouble * (Math.max(100, pane.width) ?: 0) / scaleFactor
						height = rand.nextDouble * (Math.max(100, pane.height) ?: 0) / scaleFactor
					}
				}
			}
		]
	}

	def matches(Association it, Classifier c1t, Classifier c2t) {
		val m1 = memberEnds.get(0)
		val m2 = memberEnds.get(1)
			(
				c1t.conformsTo(m1.type)
			&&
				c2t.conformsTo(m2.type)
			)
		||
			(
				c1t.conformsTo(m2.type)
			&&
				c2t.conformsTo(m1.type)
			)
	}

	def toggle(IOne<Boolean> it) {
		set(!get)
	}

	var dx = 0.0
	var dy = 0.0

	val touchedElements = new Stack<Pair<Node, Element>>
	def onPress(Node it) {
		onMousePressed = [e |
			val t = e.target
			switch t {
				Text,
				Rectangle,
				Circle: {
					dx = e.x - t.xProp.get
					dy = e.y - t.yProp.get
					e.consume
					
				}
			}
			val s = target2Source.get(t)
			if(s !== null) {
				touchedElements.push(t as Node -> s)
			}
		]
	}

	static dispatch def xProp(Rectangle it) {
		xProperty
	}

	static dispatch def xProp(Text it) {
		xProperty
	}

	static dispatch def xProp(Circle it) {
		centerXProperty
	}

	static dispatch def yProp(Rectangle it) {
		yProperty
	}

	static dispatch def yProp(Text it) {
		yProperty
	}

	static dispatch def yProp(Circle it) {
		centerYProperty
	}

	static dispatch def pointsProp(Polygon it) {
		points
	}

	static dispatch def pointsProp(Polyline it) {
		points
	}

	def onDrag(Node it) {
		onMouseDragged = [e |
			val t = e.target
			switch t {
				Text,
				Rectangle,
				Circle:
					switch (e.button) {
						case MouseButton.PRIMARY: {
							var Constraints2Cassowary solver =
								if (e.sceneX <= scene.width / 2) {
									c2casClass
								}
								else {
									c2casObject
								}

							if (solver.hasVariable(t.xProp) && solver.hasVariable(t.yProp)) {
								solver.suggestValue(t.xProp, e.x - dx)
								solver.suggestValue(t.yProp, e.y - dy)
							}

							e.consume
						}
						default: {}
					}
				}
		]
	}

	def onDoubleClick(Node it) {
		if (it instanceof Text) {
			onMouseClicked = [e |
				if (e.clickCount == 2) {
					val dialog = new TextInputDialog(text)
					dialog.title = "Change name"

					val newText = dialog.showAndWait
					if (newText.present && !newText.get.empty) {
						text = newText.get
					}
				}
			]
		}
	}
}