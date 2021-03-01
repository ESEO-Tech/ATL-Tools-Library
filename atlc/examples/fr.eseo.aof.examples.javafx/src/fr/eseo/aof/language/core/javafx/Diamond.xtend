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
import javafx.scene.shape.Line
import javafx.scene.shape.Rectangle

class Diamond extends Group {
	val Line topLeft = new Line
	val Line topRight = new Line
	val Line bottomLeft = new Line
	val Line bottomRight = new Line
	val Rectangle rectangle = new Rectangle

	val DoubleProperty xProperty = new SimpleDoubleProperty(this, "x")
	val DoubleProperty yProperty = new SimpleDoubleProperty(this, "y")
	val DoubleProperty widthProperty = new SimpleDoubleProperty(this, "width")
	val DoubleProperty heightProperty = new SimpleDoubleProperty(this, "height")

	new() {
		this.children.add(topLeft)
		this.children.add(topRight)
		this.children.add(bottomLeft)
		this.children.add(bottomRight)
		this.children.add(rectangle)

		rectangle.fill = Color.TRANSPARENT

		rectangle.xProperty.addListener([update])
		rectangle.yProperty.addListener([update])
		rectangle.widthProperty.addListener([update])
		rectangle.heightProperty.addListener([update])

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

	private def update() {
		val topCenterX = rectangle.x + rectangle.width / 2
		val topCenterY = rectangle.y

		val leftCenterX = rectangle.x
		val leftCenterY = rectangle.y + rectangle.height / 2

		val rightCenterX = rectangle.x + rectangle.width
		val rightCenterY = rectangle.y + rectangle.height / 2

		val bottomCenterX = rectangle.x + rectangle.width / 2
		val bottomCenterY = rectangle.y + rectangle.height
		
		topLeft.startX = topCenterX
		topLeft.startY = topCenterY
		topLeft.endX = leftCenterX
		topLeft.endY = leftCenterY
		
		topRight.startX = topCenterX
		topRight.startY = topCenterY
		topRight.endX = rightCenterX
		topRight.endY = rightCenterY
		
		bottomLeft.startX = leftCenterX
		bottomLeft.startY = leftCenterY
		bottomLeft.endX = bottomCenterX
		bottomLeft.endY = bottomCenterY
		
		bottomRight.startX = rightCenterX
		bottomRight.startY = rightCenterY
		bottomRight.endX = bottomCenterX
		bottomRight.endY = bottomCenterY
	}
}
