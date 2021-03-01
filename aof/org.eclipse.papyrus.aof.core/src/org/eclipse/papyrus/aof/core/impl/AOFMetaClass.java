/*******************************************************************************
 *  Copyright (c) 2015 ESEO.
 *  All rights reserved. This program and the accompanying materials
 *  are made available under the terms of the Eclipse Public License v1.0
 *  which accompanies this distribution, and is available at
 *  http://www.eclipse.org/legal/epl-v10.html
 *
 *  Contributors:
 *     Olivier Beaudoux - initial API and implementation
 *******************************************************************************/
package org.eclipse.papyrus.aof.core.impl;

import java.beans.IntrospectionException;
import java.beans.Introspector;
import java.beans.PropertyDescriptor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IMetaClass;
import org.eclipse.papyrus.aof.core.IUnaryFunction;

public class AOFMetaClass<C> extends BaseMetaClass<C> {

	private Class<C> javaClass;

	public AOFMetaClass(Class<C> javaClass) {
		this.javaClass = javaClass;
	}

	@Override
	protected C computeDefaultInstance() {
		try {
			return newInstance();
		} catch (Exception e) {
			return null;
		}
	}

	// IMetaClass

	@Override
	public boolean isInstance(Object object) {
		return javaClass.isInstance(object);
	}

	@Override
	public C newInstance() {
		try {
			return javaClass.newInstance();
		} catch (Exception e) {
			throw new IllegalStateException("Default constructor of class " + javaClass + " is not defined, or not accessible, or generates an exception", e);
		}
	}

	@Override
	public boolean isSubTypeOf(IMetaClass<?> that) {
		if (that instanceof AOFMetaClass) {
			AOFMetaClass thatAOFClass = (AOFMetaClass) that;
			return thatAOFClass.javaClass.isAssignableFrom(this.javaClass);
		} else {
			throw new IllegalArgumentException("Meta-class " + that + " must be an instance of " + AOFMetaClass.class);
		}
	}

	private HashMap<Object, PropertyAccessor> cache = new HashMap<Object, PropertyAccessor>();

	@Override
	public <B> IUnaryFunction<C, IBox<B>> getPropertyAccessor(Object property) {
		if (!cache.containsKey(property)) {
			if (property instanceof String) {
				Method readMethod = null;
				try {
					for (PropertyDescriptor descriptor : Introspector.getBeanInfo(javaClass).getPropertyDescriptors()) {
						if (descriptor.getName().equals(property)) {
							readMethod = descriptor.getReadMethod();
						}
					}
				} catch (IntrospectionException e) {
				}
				if (readMethod == null) {
					throw new IllegalArgumentException("Property " + property + " not defined in class " + javaClass);
				} else {
					cache.put(property, new PropertyAccessor(readMethod));
				}
			} else {
				throw new IllegalArgumentException("Property " + property + " must be defined as a Java String");
			}

		}
		return cache.get(property);
	}

	// Object

	@Override
	public String toString() {
		return javaClass.toString();
	}


	private class PropertyAccessor<B> implements IUnaryFunction<C, IBox<B>> {

		private Method readMethod;

		public PropertyAccessor(Method readMethod) {
			this.readMethod = readMethod;
		}

		@Override
		public IBox<B> apply(C object) {
			IBox<B> result = null;
			try {
				result = (IBox<B>) readMethod.invoke(object);
			} catch (IllegalAccessException e) {
				throw new IllegalArgumentException("cannot access property reader " + readMethod, e);
			} catch (IllegalArgumentException e) {
				throw new IllegalArgumentException("cannot access property reader " + readMethod, e);
			} catch (InvocationTargetException e) {
				throw new IllegalArgumentException("cannot access property reader " + readMethod, e);
			}
			return result;
		}
	}

}
