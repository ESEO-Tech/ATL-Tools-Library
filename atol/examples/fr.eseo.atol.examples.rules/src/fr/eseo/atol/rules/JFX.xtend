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

import fr.eseo.atlc.constraints.ExpressionGroup
import fr.eseo.atol.gen.Metaclass
import java.util.HashMap
import java.util.Map
import javafx.beans.property.ObjectProperty
import javafx.geometry.VPos
import javafx.scene.Node
import javafx.scene.paint.Paint
import javafx.scene.shape.Circle
import javafx.scene.shape.Line
import javafx.scene.shape.Rectangle
import javafx.scene.shape.Shape
import javafx.scene.text.Text
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IOne

import static fr.eseo.atol.gen.MetamodelUtils.*

import static extension fr.eseo.atol.gen.JFXUtils.*

public class JFX {
    public static val Metaclass<Text> Text = [new Text()]
    public static val Metaclass<Line> Line = [new Line()]
    public static val Metaclass<Circle> Circle = [new Circle()]
    public static val Metaclass<Rectangle> Rectangle = [new Rectangle()]
    public static val Metaclass<Figure> Figure = [new Figure()]

	static class Figure {
		val nodes = AOFFactory.INSTANCE.<Node>createSequence
		val constraints = AOFFactory.INSTANCE.<ExpressionGroup>createSequence
		val children = AOFFactory.INSTANCE.<Figure>createSequence
	}

	def _id(Node e) {
		e.idProperty
	}

	def _text(Text e) {
		e.textProperty
	}

	def _width(Rectangle r) {
		r.widthProperty
	}

	def _nodes(Figure it) {
		nodes
	}

	def _constraints(Figure it) {
		constraints
	}

	def _children(Figure it) {
		children
	}

	def asMutableString(ObjectProperty<Paint> it) {
		toBox.collect([it?.toString], [Paint.valueOf(it)])
	}

	// specific property lambdas must return IBoxes (see ATOLGen)
	public val __stroke = [
		_stroke.asMutableString
//		_stroke.collectString([it?.toString], [Paint.valueOf(it)])
	]

	public val __fill = [_fill.asMutableString]

	def _stroke(Shape it) {
		it.strokeProperty
	}

	def _fill(Shape it) {
		it.fillProperty
	}

	public val __movable = [_movable]

	val movableNodes = new HashMap<Node, IOne<Boolean>>

	def <K, V> fluentPut(Map<K, V> it, K k, V v) {
		put(k, v)
		v
	}

	def _movable(Node it) {
		movableNodes.get(it) ?:
			movableNodes.fluentPut(it, AOFFactory.INSTANCE.createOne(false))
	}

	public val __textOrigin = <Text, VPos>enumConverterBuilder([textOriginProperty.toBox], VPos, "")

	// readonly
	def _height(Text it) {
		layoutBoundsProperty.collectDouble[height]
	}

	// Problem with this version: returns an IBox whereas Constraints2Cassowary:
	// - expects a DoubleProperty
	// - needs to know that it is read-only
//	def _height(Text it) {
//		layoutBoundsProperty.toBox.collect[height]
//	}

	// readonly
	def _width(Text it) {
		layoutBoundsProperty.collectDouble[width]
	}
}
