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

import javafx.scene.Group
import javafx.scene.shape.Line
import javafx.scene.shape.Rectangle
import javafx.beans.property.DoubleProperty
import javafx.beans.property.SimpleDoubleProperty
import javafx.scene.paint.Color
import javafx.scene.paint.Paint

class DiamondArrow extends Group {
	var angle = Math.toRadians(0)
	val Line topLeft = new Line
	val Line topRight = new Line
	val Line bottomLeft = new Line
	val Line bottomRight = new Line
	val Rectangle rectangle = new Rectangle

	/*val DoubleProperty xProperty = new SimpleDoubleProperty(this, "x")
	val DoubleProperty yProperty = new SimpleDoubleProperty(this, "y")
	val DoubleProperty widthProperty = new SimpleDoubleProperty(this, "width")
	val DoubleProperty heightProperty = new SimpleDoubleProperty(this, "height")*/
	
	val DoubleProperty fromXProperty = new SimpleDoubleProperty(this, "fromX")
	val DoubleProperty fromYProperty = new SimpleDoubleProperty(this, "fromY")
	val DoubleProperty widthProperty = new SimpleDoubleProperty(this, "width")
	val DoubleProperty heightProperty = new SimpleDoubleProperty(this, "height")
	var Paint topLeftColor = null ;
	var Paint topRightColor = null ;
	var Paint bottomLeftColor = null ;
	var Paint bottomRightColor = null ;

	new() {
		this.children.add(topLeft)
		this.children.add(topRight)
		this.children.add(bottomLeft)
		this.children.add(bottomRight)
		this.children.add(rectangle)
		
		rectangle.fill = Color.TRANSPARENT
		
		/*rectangle.xProperty.addListener([update])
		rectangle.yProperty.addListener([update])
		rectangle.widthProperty.addListener([update])
		rectangle.heightProperty.addListener([update])

		rectangle.xProperty.bindBidirectional(xProperty)
		rectangle.yProperty.bindBidirectional(yProperty)
		rectangle.widthProperty.bindBidirectional(widthProperty)
		rectangle.heightProperty.bindBidirectional(heightProperty)*/
		
		topLeft.startXProperty.addListener([update])
		topLeft.startYProperty.addListener([update])
		rectangle.widthProperty.addListener([update])
		rectangle.heightProperty.addListener([update])
		
		topLeft.startXProperty.bindBidirectional(fromXProperty)
		topLeft.startYProperty.bindBidirectional(fromYProperty)
		/*topRight.startXProperty.bindBidirectional(fromXProperty)
		topRight.startYProperty.bindBidirectional(fromYProperty)*/
		
		rectangle.widthProperty.bindBidirectional(widthProperty)
		rectangle.heightProperty.bindBidirectional(heightProperty)
		/*bottomRight.endXProperty.bindBidirectional(toXProperty)
		bottomRight.endYProperty.bindBidirectional(toYProperty)*/
		
		width = 20
		height = 30
	}
	
	def getTopLeftColor() {
		topLeftColor
	}
	
	def setTopLeftColor(Paint c) {
		this.topLeftColor = c
	}
	
	def getTopRightColor() {
		topRightColor
	}
	
	def setTopRightColor(Paint c) {
		this.topRightColor = c
	}
	
	def getBottomLeftColor() {
		bottomLeftColor
	}
	
	def setBottomLeftColor(Paint c) {
		this.bottomLeftColor = c
	}
	
	def getBottomRightColor() {
		bottomRightColor
	}
	
	def setBottomRightColor(Paint c) {
		this.bottomRightColor = c
	}
	

	def getFromX() {
		topLeft.startX
	}

	def getFromY() {
		topLeft.startY
	}
	
	def getToX() {
		bottomLeft.endX
	}

	def getToY() {
		bottomLeft.endY
	}

	def getWidth() {
		rectangle.width
	}

	def getHeight() {
		rectangle.height
	}
	
	def setWidth(int width) {
		rectangle.width = width
	}

	def setHeight(int height) {
		rectangle.height = height
	}
	
	def getAngle() {
		angle
	}
	
	def setAngle(double angle) {
		this.angle = angle
		update
	}

	def getFromXProperty() {
		fromXProperty
	}

	def getFromYProperty() {
		fromYProperty
	}

	def getWidthProperty() {
		widthProperty
	}

	def getHeightProperty() {
		heightProperty
	}

	private def update() {
		/*val topCenterX = rectangle.x + rectangle.width / 2
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
		bottomRight.endY = bottomCenterY*/
		
		val width = rectangle.width
		val height = rectangle.height
		val sideLength = Math.sqrt(Math.pow(width / 2, 2) + Math.pow(height / 2, 2))
		val angleOnTop = Math.atan(width / height)
		
		topLeft.stroke = topLeftColor
		topRight.stroke = topRightColor
		bottomLeft.stroke = bottomLeftColor
		bottomRight.stroke = bottomRightColor
		
		topRight.startX = topLeft.startX
		topRight.startY = topLeft.startY
				
		topLeft.endX = topLeft.startX + sideLength * Math.sin(angle - angleOnTop)
		topLeft.endY = topLeft.startY + sideLength * Math.cos(angle - angleOnTop)
		
		topRight.endX = topRight.startX + sideLength * Math.sin(angle + angleOnTop)
		topRight.endY = topRight.startY + sideLength * Math.cos(angle + angleOnTop)
		
		bottomLeft.startX = topLeft.endX
		bottomLeft.startY = topLeft.endY
		bottomLeft.endX = topLeft.startX + height * Math.sin(angle)
		bottomLeft.endY = topLeft.startY + height * Math.cos(angle)
		
		bottomRight.startX = topRight.endX
		bottomRight.startY = topRight.endY
		bottomRight.endX = topRight.startX + height * Math.sin(angle)
		bottomRight.endY = topRight.startY + height * Math.cos(angle)
	}
}
