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
package org.eclipse.papyrus.aof.core;


/**
 * Represents platform-independent meta-classes.
 * <p>
 * All platforms must provide an implementation of this interface by wrapping the platform-dependent class into an
 * <code>IMetaClass</code> instance. Factory classes, such as {@link org.eclipse.papyrus.aof.core.AOFFactory}, provide
 * access to meta-classes through method {@link org.eclipse.papyrus.aof.core.AOFFactory#getMetaClass(Object)}.
 *
 * @param <C>
 *            class that the meta-class represents as an object
 */
public interface IMetaClass<C> {

	/**
	 * Returns whether the specified object is an instance of this meta-class.
	 * 
	 * @param object
	 *            instance to check
	 * @return true is the object is an instance of this meta-class, false otherwise
	 */
	boolean isInstance(Object object);

	/**
	 * Returns whether this meta-class is a sub-type of the specified meta-class.
	 * 
	 * @param that
	 *            meta-class to test
	 * @return
	 *         true this meta-class is a sub-type of the specified meta-class, false otherwise
	 */
	boolean isSubTypeOf(IMetaClass<?> that);

	/**
	 * Returns a new instance of this meta-class.
	 * 
	 * @return a new instance of this meta-class.
	 * @throws IllegalStateException
	 *             if the default constructor is not defined, or not accessible, or generates an exception
	 */
	C newInstance();

	/**
	 * Returns the default instance of this meta-class.
	 * <p>
	 * Each meta-class must be associated with a default instance, representing the "zero" value of the meta-class.
	 * <p>
	 * If the default instance has not been previously defined by calling {@link #setDefaultInstance(Object)}, the
	 * method try to instantiate this meta-class by invoking the default constructor. If the instantiation succeeds, the
	 * resulting instance becomes the default instance; if it fails, an <code>IllegalStateException</code> is thrown.
	 * <p>
	 * Since standard Java types such as <code>Integer</code>, <code>Boolean</code>, <code>Double</code>, and
	 * <code>String</code>, defined in package <code>java.lang</code> do not provide default public constructors, all
	 * platforms must define the default value for such types.
	 * 
	 * @return default instance this meta-class
	 * @throws IllegalStateException
	 *             if no default instance has been explicitly defined,
	 *             or this meta-class instantiation cannot be performed to create the default instance
	 */
	C getDefaultInstance();

	/**
	 * Sets explicitly the default instance of this meta-class.
	 * <p>
	 * This method must be called for defining default instances of abstract classes, or user-define classes that do not
	 * have a default constructor.
	 * <p>
	 * A default instance can never be null.
	 * <p>
	 * It must never be called twice, and thus cannot be used for standard Java types defined in package
	 * <code>java.lang</code>.
	 * 
	 * @param defaultInstance
	 *            the default instance of this meta-class
	 * @throws IllegalArgumentException
	 *             if the specified default instance is null
	 * @throws IllegalStateException
	 *             if the default instance has been already defined for this meta-classes,
	 *             or if the default instance is not an instance of this meta-classes.
	 */
	void setDefaultInstance(C defaultInstance);

	/**
	 * Returns a property accessor for the specified property.
	 * <p>
	 * The property specification is platform-dependent: it could be a string representing the property name, or a
	 * platform dependent object representing the property.
	 * <p>
	 * A property is represented by a box that holds the property value.
	 * <p>
	 * The accessor is provided as a unary function that returns the box for a given instance of this meta-class.
	 * 
	 * @param property
	 *            platform dependent object representing the property of this meta-class
	 * @param <E>
	 *            type of the property, that corresponds the elements contained in the box representing the property
	 * @return
	 *         the unary function that allows retrieving the property box for a given instance of this meta-class
	 * @throws IllegalArgumentException
	 *             if the property is not defined in this meta-class,
	 *             or if the property is not specified as an instance of the class required by the platform.
	 */
	<E> IUnaryFunction<C, IBox<E>> getPropertyAccessor(Object property);

}
