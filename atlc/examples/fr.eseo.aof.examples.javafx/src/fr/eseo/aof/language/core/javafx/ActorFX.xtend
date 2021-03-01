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

package fr.eseo.aof.language.core.javafx

import javafx.beans.property.DoubleProperty
import javafx.beans.property.SimpleDoubleProperty
import javafx.scene.Group
import javafx.scene.paint.Color
import javafx.scene.shape.Circle
import javafx.scene.shape.Line
import javafx.scene.shape.Rectangle

class ActorFX extends Group {
	static val phiArm = Math.toRadians(20);
	val Circle head = new Circle
	val Line body = new Line
	val Line leftArm = new Line
	val Line rightArm = new Line
	val Line leftLeg = new Line
	val Line rightLeg = new Line
	val Rectangle rectangle = new Rectangle

	val DoubleProperty xProperty = new SimpleDoubleProperty(this, "x")
	val DoubleProperty yProperty = new SimpleDoubleProperty(this, "y")
	val DoubleProperty widthProperty = new SimpleDoubleProperty(this, "width")
	val DoubleProperty heightProperty = new SimpleDoubleProperty(this, "height")

	new() {
		this.children.add(head)
		this.children.add(body)
		this.children.add(leftArm)
		this.children.add(rightArm)
		this.children.add(leftLeg)
		this.children.add(rightLeg)
		this.children.add(rectangle)
		head.fill = null
		head.stroke = Color.BLACK
		
		rectangle.fill = Color.TRANSPARENT

		rectangle.xProperty.addListener([updateMember])
		rectangle.yProperty.addListener([updateMember])
		rectangle.widthProperty.addListener([updateMember])
		rectangle.heightProperty.addListener([updateMember])

		rectangle.xProperty.bindBidirectional(xProperty)
		rectangle.yProperty.bindBidirectional(yProperty)
		rectangle.widthProperty.bindBidirectional(widthProperty)
		rectangle.heightProperty.bindBidirectional(heightProperty)
	}

	def getX() {
		rectangle.x
	}

	def getY() {
		rectangle.y
	}

	def getWidth() {
		rectangle.width
	}

	def getHeight() {
		rectangle.height
	}

	def setX(double value) {
		rectangle.x = value
	}

	def setY(double value) {
		rectangle.y = value
	}

	def setWidth(double value) {
		rectangle.width = value
	}

	def setHeight(double value) {
		rectangle.height = value
	}

	def getXProperty() {
		xProperty
	}

	def getYProperty() {
		yProperty
	}

	def getWidthProperty() {
		widthProperty
	}

	def getHeightProperty() {
		heightProperty
	}

	private def updateMember() {
		// Inspired by http://stackoverflow.com/questions/13249275/javafx-2-draw-arrows
		rectangle.height = rectangle.width * 2

		head.radius = rectangle.width * 0.4
		head.centerX = rectangle.x + rectangle.width /2
		head.centerY = rectangle.y + head.radius

		body.startX = head.centerX
		body.startY = head.centerY + head.radius
		body.endX = body.startX
		body.endY = body.startY + 0.7 * rectangle.width

		val dyArm = Math.tan(phiArm) * rectangle.width / 2

		leftArm.startX = body.startX
		leftArm.startY = body.startY + 0.7 * rectangle.width / 2
		leftArm.endX = rectangle.x
		leftArm.endY = leftArm.startY - dyArm

		rightArm.startX = body.startX
		rightArm.startY = body.startY + 0.7 * rectangle.width / 2
		rightArm.endX = rectangle.x + rectangle.width
		rightArm.endY = rightArm.startY - dyArm

		leftLeg.startX = body.endX
		leftLeg.startY = body.endY
		leftLeg.endX = rectangle.x
		leftLeg.endY = rectangle.y + rectangle.height

		rightLeg.startX = body.endX
		rightLeg.startY = body.endY
		rightLeg.endX = rectangle.x + rectangle.width
		rightLeg.endY = rectangle.y + rectangle.height
	}
}
