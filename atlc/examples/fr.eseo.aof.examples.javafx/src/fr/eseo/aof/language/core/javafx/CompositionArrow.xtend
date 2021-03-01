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
import javafx.scene.shape.*
  
class CompositionArrow extends Group {
	static val phi = Math.toRadians(40);
	static val barb = 20
	val Line line = new Line
	val DiamondArrow head = new DiamondArrow

	val DoubleProperty fromXProperty = new SimpleDoubleProperty(this, "fromX")
	val DoubleProperty fromYProperty = new SimpleDoubleProperty(this, "fromY")
	val DoubleProperty toXProperty = new SimpleDoubleProperty(this, "toX")
	val DoubleProperty toYProperty = new SimpleDoubleProperty(this, "toY")
	
	new() {
		this.children.add(line)
		this.children.add(head)
		
		head.fromXProperty.addListener([updateHead])
		head.fromYProperty.addListener([updateHead])
		line.endXProperty.addListener([updateHead])
		line.endYProperty.addListener([updateHead])

		head.fromXProperty.bindBidirectional(fromXProperty)
		head.fromYProperty.bindBidirectional(fromYProperty)
		line.endXProperty.bindBidirectional(toXProperty)
		line.endYProperty.bindBidirectional(toYProperty)
		
		head.topLeftColor = Color.BLUE
		head.topRightColor = Color.BLUE
		head.bottomLeftColor = Color.BLUE
		head.bottomRightColor = Color.BLUE
		
	}

	def getFromX() {
		line.startX
	}

	def getFromY() {
		line.startY
	}

	def getToX() {
		line.endX
	}

	def getToY() {
		line.endY
	}

	def setFromX(double value) {
		line.startX = value
	}

	def setFromY(double value) {
		line.startY = value
	}

	def setToX(double value) {
		line.endX = value
	}

	def setToY(double value) {
		line.endY = value
	}

	def getFromXProperty() {
		fromXProperty
	}

	def getFromYProperty() {
		fromYProperty
	}

	def getToXProperty() {
		toXProperty
	}

	def getToYProperty() {
		toYProperty
	}

	private def updateHead() {
		
		line.startX = head.toX
		line.startY = head.toY
		
		val diffX = line.endX - line.startX
		val diffY = line.endY - line.startY
		
		if(diffY >= 0) {
			head.angle = Math.atan(diffX / diffY)
		} else {
			head.angle = Math.atan(diffX / diffY) + Math.PI
		}
		
		line.startX = head.toX
		line.startY = head.toY
	}

	override toString() {
		'''Composition Arrow[fromX=«line.startX», fromY=«line.startY», toX=«line.endX», toY=«line.endY»]'''
	}
}