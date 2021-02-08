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

package fr.eseo.atol.gen

import com.google.common.collect.HashBasedTable
import java.util.HashMap
import java.util.function.DoubleSupplier
import java.util.function.Supplier
import javafx.beans.property.BooleanProperty
import javafx.beans.property.ObjectProperty
import javafx.beans.property.ReadOnlyDoublePropertyBase
import javafx.beans.property.ReadOnlyObjectProperty
import javafx.beans.property.ReadOnlyObjectPropertyBase
import javafx.beans.property.ReadOnlyProperty
import javafx.beans.property.ReadOnlyStringProperty
import javafx.beans.property.ReadOnlyStringPropertyBase
import javafx.beans.property.SimpleDoubleProperty
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.beans.property.StringProperty
import javafx.beans.value.WritableNumberValue
import javafx.collections.ObservableList
import javafx.scene.Node
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.IOne
import org.eclipse.papyrus.aof.core.IOption
import org.eclipse.papyrus.aof.core.ISequence
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver
import org.eclipse.xtend.lib.annotations.Data

class JFXUtils {
	//TODO: no cache on toBox methods, is it OK ?
	static val cache = new HashMap<Object, IBox<?>>

	def static <E> toBox(ObservableList<E> ol) {
		if (cache.containsKey(ol)) {
			return cache.get(ol) as ISequence<E>
		}
		val ret = AOFFactory.INSTANCE.<E>createSequence
		ol.forEach[ret.add(it)]
		val obs = new DefaultObserver<E> {

			override added(int index, E element) {
				ol.add(index, element)
			}

			override moved(int newIndex, int oldIndex, E element) {
				ol.add(newIndex, ol.remove(oldIndex))
			}

			override removed(int index, E element) {
				ol.remove(index)
			}

			override replaced(int index, E newElement, E oldElement) {
				ol.set(index, newElement)
			}
		}

		ret.addObserver(obs)
		// TODO: ol to ret, if/when we need bidir
		cache.put(ol, ret)
		ret
	}

	def static <E> toBox(ReadOnlyObjectProperty<E> prop) {
		if (cache.containsKey(prop)) {
			return cache.get(prop) as IOption<E>
		}
		val ret = AOFFactory.INSTANCE.createOption(prop.value)
		if(prop instanceof ObjectProperty<?>) {
			val prop_ = prop as ObjectProperty<E>
			val obs = new DefaultObserver<E> {
				override added(int index, E element) {
					prop_.value = element
				}
	
				override moved(int newIndex, int oldIndex, E element) {
					throw new IllegalStateException
				}
	
				override removed(int index, E element) {
//					throw new IllegalStateException	// TODO: why is this method called?
				}
	
				override replaced(int index, E newElement, E oldElement) {
					prop_.value = newElement
				}
			}
			ret.addObserver(obs)
			prop.addListener([property, oldVal, newVal | 
				obs.disabled = true
				ret.set(newVal)
				obs.disabled = false
			])
		} else {
			prop.addListener([property, oldVal, newVal | 
				ret.set(newVal)
			])
		}

		cache.put(prop, ret)
		ret
	}

	def static toBox(ReadOnlyProperty<Number> prop) {
		if (cache.containsKey(prop)) {
			return cache.get(prop) as IOption<Number>
		}
		val ret = AOFFactory.INSTANCE.createOption(prop.value)
		if(prop instanceof WritableNumberValue) {
			val obs = new DefaultObserver<Number> {
				override added(int index, Number element) {
					prop.value = element
				}
	
				override moved(int newIndex, int oldIndex, Number element) {
					throw new IllegalStateException
				}
	
				override removed(int index, Number element) {
//					throw new IllegalStateException	// TODO: why is this method called?
				}
	
				override replaced(int index, Number newElement, Number oldElement) {
					prop.value = newElement
				}
			}
			ret.addObserver(obs)
			prop.addListener([property, oldVal, newVal | 
				obs.disabled = true
				ret.set(newVal)
				obs.disabled = false
			])
		} else {
			prop.addListener([property, oldVal, newVal | 
				ret.set(newVal.doubleValue)
			])
		}

		cache.put(prop, ret)
		ret
	}

	def static toBox(ReadOnlyStringProperty prop) {
		if (cache.containsKey(prop)) {
			return cache.get(prop) as IOption<String>
		}
		val ret = AOFFactory.INSTANCE.createOption(prop.value)
		if(prop instanceof StringProperty) {
			val obs = new DefaultObserver<String> {
				override added(int index, String element) {
					prop.value = element
				}
	
				override moved(int newIndex, int oldIndex, String element) {
					throw new IllegalStateException
				}
	
				override removed(int index, String element) {
//					throw new IllegalStateException	// TODO: why is this method called?
				}
	
				override replaced(int index, String newElement, String oldElement) {
					prop.value = newElement
				}
			}
			ret.addObserver(obs)
			prop.addListener([property, oldVal, newVal | 
				obs.disabled = true
				ret.set(newVal)
				obs.disabled = false
			])
		} else {
			prop.addListener([property, oldVal, newVal | 
				ret.set(newVal)
			])
		}

		cache.put(prop, ret)
		ret
	}

	def static <E> toBox(BooleanProperty ol) {
		if (cache.containsKey(ol)) {
			return cache.get(ol) as IOne<Boolean>
		}
		val ret = AOFFactory.INSTANCE.createOne(ol.value)
		val obs = new DefaultObserver<Boolean> {

			override added(int index, Boolean element) {
				ol.set(element)
			}

			override moved(int newIndex, int oldIndex, Boolean element) {
			}

			override removed(int index, Boolean element) {
				throw new UnsupportedOperationException('''Cannot remove value in one''')
			}

			override replaced(int index, Boolean newElement, Boolean oldElement) {
				ol.set(newElement)
			}
		}

		ret.addObserver(obs)
		cache.put(ol, ret)
		// TODO: ol to ret, if/when we need bidir
		ret
	}

	def static <E> toBidirBox(BooleanProperty ol) {
		if (cache.containsKey(ol)) {
			return cache.get(ol) as IOne<Boolean>
		}
		val ret = AOFFactory.INSTANCE.createOne(ol.value)
		val obs = new DefaultObserver<Boolean> {

			override added(int index, Boolean element) {
				ol.set(element)
			}

			override moved(int newIndex, int oldIndex, Boolean element) {
			}

			override removed(int index, Boolean element) {
				throw new UnsupportedOperationException('''Cannot remove value in one''')
			}

			override replaced(int index, Boolean newElement, Boolean oldElement) {
				ol.set(newElement)
			}
		}

		ret.addObserver(obs)
		ol.addListener[observable, oldVal, newVal |
			obs.disabled = true
			ret.set(newVal)
			obs.disabled = false
		]
		cache.put(ol, ret)
		ret
	}

	@Data
	static class MyReadOnlyDoubleProperty extends ReadOnlyDoublePropertyBase {
		val Object bean
		val String name
		val DoubleSupplier supplier
		override get() {
			supplier.asDouble
		}
		override fireValueChangedEvent() {
			super.fireValueChangedEvent
		}
	}

	@Data
	static class MyReadOnlyStringProperty extends ReadOnlyStringPropertyBase {
		val Object bean
		val String name
		val Supplier<String> supplier
		override get() {
			supplier.get
		}
		override fireValueChangedEvent() {
			super.fireValueChangedEvent
		}
	}

	@Data
	static class MyReadOnlyObjectProperty<E> extends ReadOnlyObjectPropertyBase<E> {
		val Object bean
		val String name
		val Supplier<E> supplier
		override get() {
			supplier.get
		}
		override fireValueChangedEvent() {
			super.fireValueChangedEvent
		}
	}

	static val collectCache = HashBasedTable.<Object, Object, Object>create

	def static <E, T> collect(ReadOnlyObjectProperty<E> it, (E)=>T collector) {
		if (collectCache.contains(it, collector)) {
			return collectCache.get(it, collector) as MyReadOnlyObjectProperty<T>
		}
		val ret = new MyReadOnlyObjectProperty<T>(it, '''«name».collect[<something>]''')[
			collector.apply(get)
		]
		addListener[
			ret.fireValueChangedEvent
		]
		collectCache.put(it, collector, ret)
		ret
	}

	def static <E> collectDouble(ReadOnlyObjectProperty<E> it, (E)=>Double collector) {
		if (collectCache.contains(it, collector)) {
			return collectCache.get(it, collector) as MyReadOnlyDoubleProperty
		}
		val ret = new MyReadOnlyDoubleProperty(it, '''«name».collect[<something>]''')[
			collector.apply(get)
		]
		addListener[
			ret.fireValueChangedEvent
		]
		collectCache.put(it, collector, ret)
		ret
	}

	def static <E> collectString(ReadOnlyObjectProperty<E> it, (E)=>String collector) {
		if (collectCache.contains(it, collector)) {
			return collectCache.get(it, collector) as MyReadOnlyStringProperty
		}
		val ret = new MyReadOnlyStringProperty(it, '''«name».collect[<something>]''')[
			collector.apply(get)
		]
		addListener[
			ret.fireValueChangedEvent
		]
		collectCache.put(it, collector, ret)
		ret
	}

	def static <E, T> collect(ObjectProperty<E> it, (E)=>T collector, (T)=>E reverseCollector) {
		if (collectCache.contains(it, collector)) {
			return collectCache.get(it, collector) as SimpleObjectProperty<T>
		}
		val ret = new SimpleObjectProperty(it, '''«name».collect[<something>]''')
		ret.addListener[e |
			value = reverseCollector.apply(ret.get)
		]
		addListener[e |
			ret.value = collector.apply(get)
		]
		collectCache.put(it, collector, ret)
		ret
	}

	def static <E> collectDouble(ObjectProperty<E> it, (E)=>Double collector, (Double)=>E reverseCollector) {
		if (collectCache.contains(it, collector)) {
			return collectCache.get(it, collector) as SimpleDoubleProperty
		}
		val ret = new SimpleDoubleProperty(it, '''«name».collect[<something>]''')
		ret.addListener[e |
			value = reverseCollector.apply(ret.get)
		]
		addListener[e |
			ret.value = collector.apply(get)
		]
		collectCache.put(it, collector, ret)
		ret
	}

	def static <E> collectString(ObjectProperty<E> it, (E)=>String collector, (String)=>E reverseCollector) {
		if (collectCache.contains(it, collector)) {
			return collectCache.get(it, collector) as SimpleStringProperty
		}
		val ret = new SimpleStringProperty(it, '''«name».collect[<something>]''')
		ret.addListener[e |
			value = reverseCollector.apply(ret.get)
		]
		addListener[e |
			ret.value = collector.apply(get)
		]
		collectCache.put(it, collector, ret)
		ret
	}

	static def <T> generateId(ReadOnlyProperty<T> prop) {
			val bean = prop.bean
			if (bean instanceof Node) {
				if (bean.id !== null) {
					return bean.id
				}
			}
			return '''«bean.class.simpleName»_«bean.hashCode»'''
		}
}