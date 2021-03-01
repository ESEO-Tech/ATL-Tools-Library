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

package fr.eseo.atol.gen.plugin.constraints.solvers

import fr.eseo.atlc.mutation.MutationFactory
import fr.eseo.atlc.mutation.MutationPackage
import fr.eseo.atlc.mutation.ObjectSelector
import fr.eseo.atol.gen.plugin.constraints.common.Stopwatch
import java.util.HashMap
import java.util.Random
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl
import org.eclipse.m2m.atl.emftvm.EmftvmFactory
import org.eclipse.m2m.atl.emftvm.ExecEnv
import org.eclipse.m2m.atl.emftvm.util.ClassModuleResolver

class LocalSearch {
	var () => Double updateFitness // TODO : should be updated automatically by incremental ATL
	val fr.eseo.atlc.constraints.LocalSearch configuration
	var () => void repair

	var EObject source
	var Resource resource

	var ObjectSelector classSelector
	var ObjectSelector featureSelector

	val HashMap<String, ExecEnv> environments = new HashMap

	val Random rnd = new Random(System.currentTimeMillis)
	var Stopwatch timer

	val EReference isEncapsulatedByReference
	new(fr.eseo.atlc.constraints.LocalSearch configuration) {
		this.configuration = configuration
		source = configuration.source as EObject

		classesReference = source.eClass.EReferences.findFirst[name == "classes"]
		featuresReference = source.eClass.EReferences.findFirst[name == "features"]
		isEncapsulatedByReference = featuresReference.EReferenceType.EAllReferences.findFirst[name == "isEncapsulatedBy"]

		initMutations
		initEnviromnets
	}

	def setFitness(() => Double updateFitness) {
		this.updateFitness = updateFitness
	}

	def setRepair(() => void repair) {
		this.repair = repair
	}

	def getConfiguration() {
		configuration
	}

	def setTimer(Stopwatch timer) {
		this.timer = timer
	}

	def initMutations() {
		MutationPackage.eINSTANCE.class

		val rs = new ResourceSetImpl
		rs.resourceFactoryRegistry.extensionToFactoryMap.put(
			"xmi",
			new XMIResourceFactoryImpl
		)
		rs.packageRegistry.put(
			MutationPackage.eNS_URI,
			MutationPackage.eINSTANCE
		)
		resource = rs.createResource(URI.createURI('mutations.xmi'))

		classSelector = MutationFactory.eINSTANCE.createObjectSelector
		classSelector.name = 'class'
		resource.contents.add(classSelector)

		featureSelector = MutationFactory.eINSTANCE.createObjectSelector
		featureSelector.name = 'feature'
		resource.contents.add(featureSelector)
	}

	def initEnviromnets() {
		environments.clear
		
		val srcMM = EmftvmFactory.eINSTANCE.createMetamodel
		srcMM.resource = source.eClass.EPackage.eResource
		
		val mutMM = EmftvmFactory.eINSTANCE.createMetamodel
		mutMM.resource = MutationPackage.eINSTANCE.eResource

		val moduleResolver = new ClassModuleResolver(configuration.callingClass)

		val inModel = EmftvmFactory.eINSTANCE.createModel
		inModel.resource = source.eResource
		
		val mutModel = EmftvmFactory.eINSTANCE.createModel
		mutModel.resource = classSelector.eResource
			
		configuration.mutationRules.forEach[ moduleName |
			val env = EmftvmFactory.eINSTANCE.createExecEnv

			//TODO: MM names should not be hardcoded
			env.registerMetaModel("CRA", srcMM)
			env.registerMetaModel("Mutation", mutMM)

			env.loadModule(moduleResolver, moduleName)

			//TODO: model names should not be hardcoded
			env.registerInOutModel("IN", inModel)
			env.registerInputModel("M", mutModel)

			environments.put(moduleName, env)
		]
	}

	//TODO: these selection operators should not be hardcoded here
	val EReference classesReference
	def selectRandomClass() {
		val classes = source.eGet(classesReference) as EList<?>
		classes.get(rnd.nextInt(classes.size))
	}

	val EReference featuresReference
	def selectRandomFeature() {
		val features = source.eGet(featuresReference) as EList<?>
		features.get(rnd.nextInt(features.size))
	}

	def applyTransformation(String ruleName) {
		val env = environments.get(ruleName)

		//TODO: should not be hardcoded
		switch ruleName {
			case 'RemoveClass': {
				if ((source.eGet(classesReference) as EList<?>).size == 0)
					return;
				classSelector.selected = selectRandomClass
			}
			case 'DecapsulateFeature': {
				featureSelector.selected = selectRandomFeature
			}
			case 'EncapsulateFeature': {
				if ((source.eGet(classesReference) as EList<?>).size == 0)
					return;
				
				featureSelector.selected = selectRandomFeature
				classSelector.selected = selectRandomClass

				oldClass = (featureSelector.selected as EObject).eGet(isEncapsulatedByReference)
			}
		}

		env.run(null)
	}

	var Object oldClass
	def rollback() {
		classSelector.selected = oldClass

		applyTransformation('EncapsulateFeature')
	}
	
	def selectMutationOperator() {
//		val nbClasses = (source.eGet(classesReference) as EList).size
//		val nbFeatures = (source.eGet(featuresReference) as EList).size
//		
//		if (nbClasses > nbFeatures) {
//			configuration.mutationRules.get(1+rnd.nextInt(configuration.mutationRules.size-1))
//		}
//		configuration.mutationRules.get(rnd.nextInt(configuration.mutationRules.size))
		'EncapsulateFeature'
	}

	def optimize() {
		switch configuration.name {
			case 'simulated annealing': simulatedAnnealing
			case 'hill climber': hillClimber
			default: throw new UnsupportedOperationException('''Unsupported local search method "«configuration.name»"''')
		}
 	}

	def hillClimber() {
		var Double bestFitness = updateFitness.apply
		var EObject bestModel = EcoreUtil.copy(source)
		val Double fitness = updateFitness.apply

//		while
	}

	def simulatedAnnealing() {
		var epoch = 0
		val MAX_EPOCH = 100000
		var Double bestFitness = updateFitness.apply
		var EObject bestModel = EcoreUtil.copy(source)
		var Double fitness = updateFitness.apply

		while (epoch < MAX_EPOCH) {
			val temperature = (epoch + 1.0) / MAX_EPOCH
			val rule = selectMutationOperator

			timer?.start
			applyTransformation(rule)
			timer?.record('apply mutation')
			
			timer?.start
			val fitnessAfter = updateFitness.apply
			timer?.record('fitness function')
			
			if ((fitnessAfter > fitness) || 
				(Math.exp((fitness - fitnessAfter) / temperature) >= rnd.nextDouble)
			) {
				if (fitnessAfter > bestFitness) {
//					println('''Found new best fitness, new «bestFitness», old «fitnessAfter» at epoch «epoch»''')
					bestModel = null
					bestModel = EcoreUtil.copy(source)
					bestFitness = fitnessAfter					
				}
				fitness = fitnessAfter
			}
			else {
				timer?.start
				rollback
				timer?.record('apply rollback mutation')
			}

			if (epoch % 100 == 0) {
				timer?.start
				repair.apply
				timer?.record('repair solving')
			}
			epoch++
		}
		configuration.source = bestModel
	}
}
