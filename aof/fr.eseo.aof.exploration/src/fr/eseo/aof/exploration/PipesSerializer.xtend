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

package fr.eseo.aof.exploration

import fr.eseo.aof.exploration.helperboxes.Naturals
import java.io.PrintStream
import java.io.PrintWriter
import java.io.StringWriter
import java.util.HashMap
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.impl.Box
import org.eclipse.papyrus.aof.core.impl.operation.CollectSurjective
import org.eclipse.papyrus.aof.core.impl.operation.Concat
import org.eclipse.papyrus.aof.core.impl.operation.Inspect
import org.eclipse.papyrus.aof.core.impl.operation.Operation
import org.eclipse.papyrus.aof.core.impl.operation.Size
import org.eclipse.papyrus.aof.core.impl.operation.ZipWith
import org.eclipse.papyrus.aof.core.impl.utils.FactoryObserver

import static org.eclipse.papyrus.aof.core.impl.Box.*

/*
 * This is a simplified version of SerializePipes from privateTests/
 * But some things related to Closure class are hardcoded
 */
class PipesSerializer {
	val boxes = new HashMap<IBox<?>, String>
	val pattern = '''(	at («PipesSerializer.this.class.name»|org.eclipse.papyrus.aof.core.impl.).*
)+'''
	new() {
		Box.factoryObserver =
//		[int index, IBox<?> element |
		new FactoryObserver<IBox<?>> {
			override added(int index, IBox<?> element) {
				val sw = new StringWriter()
				new Exception().printStackTrace(new PrintWriter(sw))
				val location = sw.toString.replaceFirst(pattern, '''	...
''')
				boxes.put(element, location)
			}
		}
//		] as FactoryObserver<IBox<?>>
	}

	def serialize(String fileName) {
		println(boxes.size)

		val out = new PrintStream(fileName)
		out.println("@startuml")
		out.println("hide empty description")

		boxes.entrySet.forEach[
			val box = it.key as Box
			val desc = it.value

			val boxId = box.id
			var boxColor = "orange"

			// TODO: generalize
			if(desc.matches('''(?s).*\$Node\.<init>.*''')) {
					boxColor = ROOT_BOX_COLOR	// rootBox
			}

			box.observers.forEach[
				var observer = it
				var observerClassName = observer.getClass().getName()

				// unwrap SilentObserver
				if(observerClassName.equals(OPERATION_PACKAGE + "Operation$SilentObserver")) {	// necessary because SilentObserver is private
					observer = javaGet(observer, "wrappedObserver")
					observerClassName = observer.getClass().getName()
				}

				if(observerClassName.startsWith(OPERATION_PACKAGE)) {
					val Operation<?> op = javaGet(observer, "this$0")	// remark: Bind does not extend Operation
					val opName = op.class.getSimpleName
					var opId = opName + "_" + op.hashCode()

					if(op instanceof Inspect<?>) {
						out.println('''state "Inspect '«(op.javaGet("label") as String).trim»'" as «opId» #«INSPECT_COLOR»''');
					}

					val label = observer.getClass().getSimpleName().replaceAll("Observer$", "")

					if(
						switch op {
							Concat<?>: label == "Left"
							CollectSurjective<?, ?>: true
							Size<?>: true
							ZipWith<?, ?, ?>: label == "Right" && op.javaGet(ZipWith, "unzipper") == null
							default: false
						}
					) {
						val resultBox = op.javaGet(Operation, "resultBox") as IBox<?>
						out.println(opId + UNIDIR_ARROW + resultBox.id);
					}

					if("Result".equals(label)) {
						out.println(opId + BIDIR_ARROW + boxId + " : " + label);
					} else {
						out.println(boxId + BIDIR_ARROW + opId + " : " + label);
					}
				} else {
//					println('''Unknown observer: «observer.class»''')
//					println(observer.class.declaredFields.map[it.name])
					val retBoxId = (observer.javaGet("val$ret") as IBox<?>).id
					val retBoxName = retBoxId
					val opId = '''«observer.class.enclosingMethod.name»_«retBoxId»'''
					val label = "TSET"
//					println('''Unknown observer: «opId»''')
					out.println(boxId + UNIDIR_ARROW + opId + " : " + label);
					out.println(opId + UNIDIR_ARROW + retBoxName + " : " + label);
				}
			]

			out.println('''state "[[#{«box.sanitize»\\n«desc.sanitize»}«box.name»]]" as «boxId» #«boxColor»''')
		]

		out.println("@enduml")
		out.close()
		Runtime.runtime.exec('''plantuml -tsvg «fileName»''')
		Box.factoryObserver = null	// TODO: could be done at the beginning, but then we would not notice concurrency exceptions
	}

	private def static String sanitize(Object s) {
		s
			.toString
			.replaceAll("\r?\n", '''\\\\n''')
			.replaceAll("\t", "    ")
//			.replaceAll("\\[", " ")
//			.replaceAll("\\]", " ")
			.replaceAll('"', "'")
	}

	private def static <E> E javaGet(Object o, String fieldName) {
		o.javaGet(o.class, fieldName)
	}

	private def static <E> E javaGet(Object o, Class<?> c, String fieldName) {
		val field = c.getDeclaredField(fieldName)
		field.accessible = true
		field.get(o) as E
	}

	private def static String id(IBox<?> box) {
		'''box_«box.hashCode()»'''
	}

	private def static String name(IBox<?> box) {
		switch box {
			case IBox.BAG: "BAG"
			case IBox.ORDERED_SET: "OSET"
			case IBox.SEQUENCE: "SEQ"
			case IBox.SET: "SET"
			case IBox.ONE: "ONE"
			case IBox.OPTION: "OPT"
			default: box.constraints.toString
		}
	}
	private final static String OPERATION_PACKAGE = "org.eclipse.papyrus.aof.core.impl.operation.";
	private final static String BIDIR_ARROW = "-->";			// corresponds to an Observer
	private final static String UNIDIR_ARROW = "-[#blue]->";	// no corresponding Observer
	private final static String ROOT_BOX_COLOR = "lightgreen";	// or TERMINAL_BOX
	private final static String INSPECT_COLOR = "lightblue";

	val c = IBox.ONE	// force initialization so that it does not happen during serialization, thus triggering a ConcurrentModificationException
	val d = Naturals.size	// force initialization so that it does not appear in serializations
}