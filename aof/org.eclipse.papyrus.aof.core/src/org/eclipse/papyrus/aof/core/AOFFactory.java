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

import java.lang.reflect.Modifier;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.eclipse.papyrus.aof.core.impl.AOFMetaClass;
import org.eclipse.papyrus.aof.core.impl.BaseFactory;

/**
 * Implements AOF default factory.
 * <p>
 * This factory is used for creating intermediate boxes introduced by transformations (or mappings). Other platform
 * factories do <b>not</b> have re-implements all <code>create<BoxType>()</code> methods: they can simply inherits from
 * this factory class.
 * <p>
 * It defines a simple meta-metamodel AOF-M3 based on a direct use of AOF boxes for representing object properties.
 * <p>
 * All derived factory classes are responsible to emulate AOF-M3 by providing platform-dependent methods
 * {@link IFactory#getMetaClass(Object)} and {@link IFactory#createPropertyBox(Object, Object)}. Example provided in
 * {@link IFactory} illustrate the platform-independence mechanism.
 * 
 * <p>
 * The following example illustrates how metamodel <code>Person</code> is implemented using <code>AOFFactory</code>:
 * 
 * <pre>
 * static IFactory factory = AOFFactory.INSTANCE;
 * 
 * public class Person {
 * 	private IOne&lt;String&gt; name = factory.createOne(&quot;Name&quot;);
 * 	private IOption&lt;Integer&gt; age = factory.createOption();
 * 	private IOrderedSet&lt;String&gt; emails = factory.createOrderedSet();
 * 	private IOption&lt;Person&gt; parent = factory.createOption();
 * 	private ISet&lt;Person&gt; children = factory.createSet();
 * 
 * 	public IOne&lt;String&gt; getName() {
 * 		return name;
 * 	}
 * 
 * 	public IOption&lt;Integer&gt; getAge() {
 * 		return age;
 * 	}
 * 
 * 	public IOrderedSet&lt;String&gt; getEmails() {
 * 		return emails;
 * 	}
 * 
 * 	public IOption&lt;Person&gt; getParent() {
 * 		return parent;
 * 	}
 * 
 * 	public ISet&lt;Person&gt; getChildren() {
 * 		return children;
 * 	}
 * }
 * </pre>
 * 
 * AOF-M3 considers that each property is represented by an AOF box, accessible in a platform-independent way using
 * {@link IFactory#createPropertyBox(Object, Object)}, or in a platform-dependent as the previous example illustrates.
 * <p>
 * Platform-independent implementation of methods allowing the manipulation meta-model <code>Person</code> given in
 * {@link IFactory}, can be written in the AOF platform-depend manner, as follows:
 * 
 * <pre>
 * public Person createPerson(String name, int age, String... emails) {
 * 	Person person = new Person();
 * 	person.getName().set(name);
 * 	person.getAge().set(25);
 * 	person.getEmails().assign(emails);
 * 	return person;
 * }
 * 
 * public void addChild(Person parent, Person child) {
 * 	parent.getChildren.add(child);
 * 	child.setParent(parent);
 * }
 * </pre>
 *
 */
public class AOFFactory extends BaseFactory {

	/**
	 * Singleton instance of this factory
	 */
	public static IFactory INSTANCE = new AOFFactory();

	/**
	 * Constructs of this factory by initializing default instances for the standard Java types.
	 * <p>
	 * The default values are defined as follows:
	 * <p>
	 * <ul>
	 * <li> {@link java.lang.String} : ""
	 * <li> {@link java.lang.Boolean} : false
	 * <li> {@link java.lang.Integer} : 0
	 * <li> {@link java.lang.Long} : 0L
	 * <li> {@link java.lang.Short} : (short) 0
	 * <li> {@link java.lang.Byte} : (byte) 0
	 * <li> {@link java.lang.Character} : ' '
	 * <li> {@link java.lang.Double} : 0.0
	 * <li> {@link java.lang.Float} : 0.0f
	 * <li>{@link java.lang.Date} : new Date(0)
	 * </ul>
	 */
	public AOFFactory() {
		getMetaClass(String.class).setDefaultInstance("");
		getMetaClass(Boolean.class).setDefaultInstance(false);
		getMetaClass(Integer.class).setDefaultInstance(0);
		getMetaClass(Long.class).setDefaultInstance(0L);
		getMetaClass(Short.class).setDefaultInstance((short) 0);
		getMetaClass(Byte.class).setDefaultInstance((byte) 0);
		getMetaClass(Character.class).setDefaultInstance(' ');
		getMetaClass(Double.class).setDefaultInstance(0.0);
		getMetaClass(Float.class).setDefaultInstance(0.0f);
		getMetaClass(Date.class).setDefaultInstance(new Date(0));
	}

	private Map<Class<?>, IMetaClass<?>> metaClassesMap = new HashMap<Class<?>, IMetaClass<?>>();

	/**
	 * Returns the meta-class representing the specified platform-dependent meta-class, which must be a Java class.
	 * <p>
	 * Refer to the main documentation of interface {@link IFactory} that gives a concrete example of use.
	 * 
	 * @param platformClass
	 *            a Java class, instance of {@link java.lang.Class}
	 * @throws IllegalArgumentException
	 *             if the specified class is not an instance of {@link java.lang.Class}
	 */
	@Override
	public <A> IMetaClass<A> getMetaClass(Object platformClass) {
		if (platformClass instanceof Class<?>) {
			if (!metaClassesMap.containsKey(platformClass)) {
				Class<A> javaClass = (Class<A>) platformClass;
				IMetaClass<A> metaClass = new AOFMetaClass<A>(javaClass);
				metaClassesMap.put(javaClass, metaClass);
			}
			return (IMetaClass<A>) metaClassesMap.get(platformClass);
		} else {
			throw new IllegalArgumentException("Class " + platformClass + " is not a Java class");
		}
	}

	/**
	 * Creates and returns the box representing the specified property of a given object.
	 * <p>
	 * The property must be a string representing the property name.
	 * <p>
	 * Refer to the main documentation of interface {@link IFactory} that gives a concrete example of use.
	 * 
	 * @return the box representing the specified property of a given objects
	 * @throws IllegalArgumentException
	 *             if the property type is not a string,
	 *             of if the property has not been found in class <code>C</code> of the specified object.
	 */
	@Override
	public <A, B> IBox<B> createPropertyBox(A object, Object property) {
		if (!Modifier.isPublic(object.getClass().getModifiers())) {
			throw new IllegalArgumentException("Class for object " + object + " must pe public");
		}
		IMetaClass<A> metaClass = getMetaClass(object.getClass());
		if (property instanceof String) {
			IUnaryFunction<A, IBox<B>> accessor = metaClass.getPropertyAccessor((String) property);
			return accessor.apply(object);
		} else {
			throw new IllegalArgumentException("Property " + property + " must be specified by a string representing its name");
		}
	}


}
