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
import javafx.scene.shape.Line

class Arrow extends Group {
	static val phi = Math.toRadians( 40 );
	static val barb = 20
	val Line line = new Line
	val Line head1 = new Line
	val Line head2 = new Line

	val DoubleProperty fromXProperty = new SimpleDoubleProperty(this, "fromX")
	val DoubleProperty fromYProperty = new SimpleDoubleProperty(this, "fromY")
	val DoubleProperty toXProperty = new SimpleDoubleProperty(this, "toX")
	val DoubleProperty toYProperty = new SimpleDoubleProperty(this, "toY")

	new() {
		this.children.add(line)
		this.children.add(head1)
		this.children.add(head2)

		line.startXProperty.addListener([updateHead])
		line.startYProperty.addListener([updateHead])
		line.endXProperty.addListener([updateHead])
		line.endYProperty.addListener([updateHead])

		line.startXProperty.bindBidirectional(fromXProperty)
		line.startYProperty.bindBidirectional(fromYProperty)
		line.endXProperty.bindBidirectional(toXProperty)
		line.endYProperty.bindBidirectional(toYProperty)
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
		// Inspired by http://stackoverflow.com/questions/13249275/javafx-2-draw-arrows
		val x1 = line.startX
		val y1 = line.startY
		val x2 = line.endX
		val y2 = line.endY
		val dx = x2 - x1
		val dy = y2 - y1
		val theta = Math.atan2(dy, dx)
		var rho = theta + phi

		var x = x2 - barb * Math.cos( rho );
	    var y = y2 - barb * Math.sin( rho );
	    head1.setStartX( x2 );
	    head1.setStartY( y2 );
	    head1.setEndX( x );
	    head1.setEndY( y );
	    rho = theta - phi;
	    x = x2 - barb * Math.cos( rho );
	    y = y2 - barb * Math.sin( rho );
	    head2.setStartX( x2 );
	    head2.setStartY( y2 );
	    head2.setEndX( x );
	    head2.setEndY( y );
	}

	override toString() {
		'''Arrow[fromX=«line.startX», fromY=«line.startY», toX=«line.endX», toY=«line.endY»]'''
	}

}
