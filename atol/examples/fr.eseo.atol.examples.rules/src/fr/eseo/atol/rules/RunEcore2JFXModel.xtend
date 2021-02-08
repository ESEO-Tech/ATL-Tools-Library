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

import fr.eseo.atlc.constraints.Expression
import fr.eseo.atol.gen.AbstractRule
import fr.eseo.atol.gen.plugin.constraints.solvers.Constraints2Cassowary
import fr.eseo.atol.rules.JFXModel.Figure
import java.util.Collections
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.ENamedElement
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.impl.EcoreResourceFactoryImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.uml2.uml.NamedElement

import static extension fr.eseo.aof.exploration.OCLByEquivalence.*
import static extension fr.eseo.atol.rules.A.*
import static extension fr.eseo.atol.rules.NamedElementExtensions.*

interface A {
	static def getFileResource(ResourceSet rs, String file) {
		rs.getResource(URI.createFileURI(file), true)
	}
}

interface NamedElementExtensions {
	static def name(IBox<NamedElement> b) {
		
	}
}

interface ENamedElementExtensions {
	static def name(IBox<ENamedElement> b) {
		
	}
}


class RunEcore2JFXModel {
	def static void main(String[] args) {
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
        val transfo = new Ecore2JavaFXModel
/**/
//		val transfo = new Ecore2JavaFXGenerated

		val tgt = transfo.Package(
			resource.contents.get(0) as EPackage
		).g
		extension val JFX = new JFXModel
		val figures = AOFFactory.INSTANCE.createOne(tgt).closure[
			it._children
		]
		val nodes = figures.collectMutable[
			it?._nodes ?: AbstractRule.emptySequence
		].inspect("nodes: ")
		val constraints = figures.collectMutable[
			it?._constraints ?: AbstractRule.emptySequence
		].inspect("constraints: ")
//        val res1 = ps.map[transfo.Package.apply1To1(
//        	it
//        )].toList
//        val res2 = cs.map[
//        	println(it)
//        	transfo.Class.apply1To1(it)
//        ].toList
//        
//        res1.forEach[println(it)]
//        res2.forEach[println(it)]
        val c = constraints.collect[it as Expression]
        val c2c = new Constraints2Cassowary(transfo.JFXMM, transfo.EcoreMM)
        c2c.apply(c)
        c2c.solve
        // suggest expect a DoubleProperty, so it won't work
//        c2c.suggestValue(nodes.select(Rectangle).get(0).widthProperty, 100) // no change because this suggest don't change anything
//        c2c.suggestValue(nodes.select(Rectangle).get(0).widthProperty, 300) // this trigger update
        c2c.solve // keeps 300 because stay is working
        // suggest triggers an update even if autosolve is set to false

		val resSave = rs.createResource(URI.createFileURI("outmodel-fx.xmi"))
        resSave.contents.addAll(nodes)
//        res1.forEach[it.forEach[resSave.contents.add(it)]]
//        res2.forEach[it.forEach[resSave.contents.add(it)]]
//        
        resSave.save(Collections.EMPTY_MAP);

		val resSave2 = rs.createResource(URI.createFileURI("out-constraints.xmi"))
		resSave2.contents.addAll(constraints)        
        resSave2.save(Collections.EMPTY_MAP);
	}

	// target element accessor for ListPatterns
	def static g(List<Object> l) {
		l.get(0) as Figure
	}
}
