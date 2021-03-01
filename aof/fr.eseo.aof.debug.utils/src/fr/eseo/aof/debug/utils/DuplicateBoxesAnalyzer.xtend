/****************************************************************
 *  Copyright (C) 2020 ESEO
 *
 *  This program and the accompanying materials are made
 *  available under the terms of the Eclipse Public License 2.0
 *  which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 *  Contributors:
 *    - Frédéric Jouault
 *
 *  version 1.0
 *
 *  SPDX-License-Identifier: EPL-2.0
 ****************************************************************/

package fr.eseo.aof.debug.utils

import fr.eseo.aof.debug.utils.PipesWalker.PipesVisitorAdapter
import java.util.ArrayList
import java.util.HashMap
import java.util.HashSet
import java.util.List
import java.util.Map
import java.util.Stack
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.IUnaryFunction
import org.eclipse.papyrus.aof.core.impl.Box
import org.eclipse.papyrus.aof.core.impl.operation.Operation
import org.eclipse.papyrus.aof.core.impl.utils.FactoryObserver
import org.eclipse.papyrus.aof.emf.impl.FeatureDelegate

import static org.eclipse.papyrus.aof.core.impl.Box.*
import org.eclipse.papyrus.aof.emf.impl.ListFeatureDelegate
import com.google.common.collect.HashMultimap
import java.util.IdentityHashMap

class DuplicateBoxesAnalyzer implements BoxesAnalyzer {
	val boxes = new ArrayList<IBox<Object>>
	val stackTracePerBox = new IdentityHashMap<IBox<?>, Throwable>

	val FactoryObserver<IBox<?>> factoryObserver = [index, it |
		boxes.add(it as IBox<Object>)
		stackTracePerBox.put(it, new Exception)
	]

	new() {
		// DONE: check if there is already a factoryObserver
		// because there can only be one
		if(Box.factoryObserver != null) {
			println('''warning: overriding already registered Box factory observer «Box.factoryObserver»''')
		}
		Box.factoryObserver = factoryObserver
	}

	val boxesToIgnore = new HashSet<IBox<Object>>
	def mark() {
		boxesToIgnore.addAll(boxes)
	}

	override analyze() {
//        findDuplicateBoxes
        findDuplicateBoxesWithForwardWalking
	}

    def isAllContentsRoot(IBox<?> box) {
        stackTracePerBox.get(box).stackTrace.get(8).methodName == "_allContents"
    }

    def isEmptyConstant(IBox<?> box) {
            box == IBox.BAG || box == IBox.SEQUENCE || box == IBox.OPTION
        ||
            box == IBox.ONE || box == IBox.ORDERED_SET  || box == IBox.SET
    }

    def isProxy(IBox<?> box) {
        (!box.isPropertyBox) && (!box.observers.empty) && box.observers.get(0).class.name.matches(".*ListFeatureDelegate\\$ReverseAdapter$")
    }

    def isPropertyBox(IBox<?> box) {
        PipesWalker.javaGet(box as Box<?>, Box, "delegate") instanceof FeatureDelegate<?>
    }

    def findDuplicateBoxesWithForwardWalking() {
        val boxesPerPath = HashMultimap.<Object, IBox<?>>create
        val visitedBoxes = new HashSet
        println('''Analyzing «boxes.size» boxes...''')
        boxes.filter[box |
                box.isPropertyBox
            ||
                box.isAllContentsRoot
            ||
                box.isEmptyConstant
            ||
                box.isProxy
        ].forEach[box, i |
            visitedBoxes.add(box)
            val path = new Stack<List<Object>>
            if(box.isProxy) {
//                path.add(#[box])
                return  // no need to process proxy boxes because processing property boxes should be enough
            }
            new PipesWalker().accept(box, new PipesVisitorAdapter {
                override visit(IBox<?> vbox) {
                    if(vbox === box) {
                    	if(box.isAllContentsRoot) {
		                    path.push(#["allContents", box])
                    	}
                        return  // ignore original source box
                    }
// TODO: ignore CollectBox inner boxes -> CollectBox
                    visitedBoxes.add(vbox)
                    if(!boxesPerPath.get(path).contains(vbox)) {    // for boxes that are computed from several paths (e.g., via zipWith)
	                    if(!boxesPerPath.get(path).empty) {
	                        val otherPath = boxesPerPath.entries.findFirst[key == path].key
	                        stackTracePerBox.get(vbox).printStackTrace(System.out)
	                        println("found one duplicate box for path: " + path)
	                    }
                        boxesPerPath.put(path.clone, vbox)
                    } else {
                        println("already visited box")
                    }
                }
                override enterOperation(Operation<?> operation, String operationName, Object...arguments) {
//                          println(''' «operationName»«arguments.toList»''')
                    path.push(#[operationName, arguments.process])
                }
                override leaveOperation(Operation<?> operation, String operationName, Object...arguments) {
                    val popped = path.pop
                    if(popped != #[operationName, arguments.process]) {
                        throw new RuntimeException
                    }
                }
                override propertyBox(IBox<?> box, EObject object, EStructuralFeature feature) {
    //                          println(''' prop: «object.eClass.name»@«Integer.toHexString(object.hashCode)».«feature.name»''')
                    path.push(#[object, feature])
                }
                override rootBox(IBox<?> box) {
                    // should only be proxyBoxes of property boxes & constant boxes from Box
    //                          println(''' root''')
    //                          stackTracePerBox.get(box).printStackTrace(System.out)
                    path.push(#[box])
                }
            })
        ]
        val nonVisitedBoxes = new ArrayList
        boxes.forEach[box |
            if(!visitedBoxes.contains(box)) {
                // TODO: track all non visited boxes (e.g., but putting a breakpoint on the next line)
                nonVisitedBoxes.add(box)
            }
        ]
        println('''Visited «visitedBoxes.size»/«boxes.size» boxes, and did not visit «nonVisitedBoxes.size»/«boxes.size» non-property root boxes boxes.''')
		println(boxes.filter[
			isPropertyBox
		].size)
		println(boxes.filter[
			isAllContentsRoot
		].size)
		println(boxes.filter[
			isEmptyConstant
		].size)
		println(boxes.filter[
			isProxy
		].size)

        val sortedDuplicateLists = boxesPerPath.asMap.entrySet.filter[value.size > 1].sortBy[-value.size]
        sortedDuplicateLists.forEach[
        	val boxes = value.filter[!boxesToIgnore.contains(it)].toList
        	if(boxes.size >= 2) {
        		println(key)
	            println('''«boxes.size» boxes, the first one being created at:''')
	            println(System.identityHashCode(boxes.get(0)))
	            stackTracePerBox.get(boxes.get(0)).printStackTrace(System.out)
	            println('''the second one being created at:''')
	            println(System.identityHashCode(boxes.get(1)))
	            stackTracePerBox.get(boxes.get(1)).printStackTrace(System.out)
	            // TODO: handle SelectBy arguments in PipesWalker
	            println("other box creation points, and path not shown (use debugger).")
            }
        ]
    }

	def findDuplicateBoxes() {
		val boxesPerPath = new HashMap<Object, List<IBox<?>>>
		var duplicateBoxes = 0
		for(box : boxes) {
			duplicateBoxes = processBox(box, boxesPerPath, duplicateBoxes, stackTracePerBox)
		}
		if(duplicateBoxes > 0) {
			val pathsPerBoxes = new HashMap<List<IBox<?>>, Object>
			boxesPerPath.forEach[k, v|
				pathsPerBoxes.put(v, k)
			]
			val sortedDuplicateLists = boxesPerPath.values.sortBy[it.size]
			for(dupList : sortedDuplicateLists) {
				println(dupList.size)
			}
			println(pathsPerBoxes.get(sortedDuplicateLists.last))
			stackTracePerBox.get(sortedDuplicateLists.last.get(0)).printStackTrace(System.out)
			stackTracePerBox.get(sortedDuplicateLists.last.last).printStackTrace(System.out)
		}
		println('''Found «duplicateBoxes» duplicate boxes out of «boxes.size» total boxes''')
	}

    def process(Object...arguments) {
        arguments.map[
            switch it {
                IUnaryFunction<?, ?>: {
                    // TODO: check superclasses?
                    if(it.class.superclass != Object) {
                        println("warning: specific superclass")
                    }
                    val vals = it.class.declaredFields.map[f |
                        f.accessible = true
                        f.get(it)
                    ].toArray.toList
                    #[it.class, vals]
//                          val cn = it.class.name.replaceFirst("^.*\\.", "")
//                          switch cn {
//                              case "EMFMetaClass$PropertyAccessor": it
//                              case cn.startsWith("CPS2DeploymentAOFTransformation$"): {
//                                  // TODO: not actually true if the function depends on external state (e.g., captured variable)
//                                  it.class
//                              }
//                              default: {
//                                  it  //throw new RuntimeException
//                              }
//                          }
                }
                default: it
            }
        ].toArray.toList
    }

	// TODO: perform a first pass to be able to reverse navigate the pipes
	// even without ResultObservers
	private def processBox(IBox<Object> box, Map<Object, List<IBox<?>>> boxesPerPath, int duplicateBoxes, Map<IBox<?>, Throwable> stackTracePerBox) {
		var ret = duplicateBoxes
//		println(box)
		val path = new Stack<List<Object>>
		val pipesWalker = new PipesWalker
		val pipesVisitor = new PipesVisitorAdapter {
			override enterOperation(Operation<?> operation, String operationName, Object...arguments) {
//							println('''	«operationName»«arguments.toList»''')
				path.push(#[operationName, arguments.process])
			}
			override leaveOperation(Operation<?> operation, String operationName, Object...arguments) {
//							val popped = path.pop
//							if(popped != #[operationName, arguments]) {
//								throw new RuntimeException
//							}
			}
			override propertyBox(IBox<?> box, EObject object, EStructuralFeature feature) {
//							println('''	prop: «object.eClass.name»@«Integer.toHexString(object.hashCode)».«feature.name»''')
				path.push(#[object, feature])
			}
			override rootBox(IBox<?> box) {
				// should only be proxyBoxes of property boxes & constant boxes from Box
//							println('''	root''')
//							stackTracePerBox.get(box).printStackTrace(System.out)
			}
		}
		pipesWalker.accept(box, pipesVisitor, false)
		if(!path.isEmpty) {
			if(!(path.last.get(0) instanceof EObject)) {
				stackTracePerBox.get(box).printStackTrace
				println("root-less box!")
			}
			var l = boxesPerPath.get(path)
			if(l == null) {
				l = new ArrayList
				boxesPerPath.put(path, l)
			} else {
				ret++
			}
			l.add(box)
		}
		return ret
	}

	override dispose() {
		if(Box.factoryObserver == factoryObserver) {
			Box.factoryObserver = null
		}
	}
	
	override nbBoxes() {
		boxes.size
	}
	
}