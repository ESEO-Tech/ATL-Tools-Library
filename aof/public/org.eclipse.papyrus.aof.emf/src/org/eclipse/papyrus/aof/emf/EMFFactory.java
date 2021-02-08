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
package org.eclipse.papyrus.aof.emf;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.papyrus.aof.core.AOFFactory;
import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IFactory;
import org.eclipse.papyrus.aof.core.IMetaClass;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.eclipse.papyrus.aof.emf.impl.EMFMetaClass;

/**
 * Implements EMF default factory.
 * <p>
 * This factory is derived from {@link AOFFactory} thus allowing the creation intermediate boxes introduced by AOF
 * transformations (or mappings).
 * <p>
 * It emulates meta-model AOF-M3 for the meta-metamodel Ecore of the EMF platform.
 * <p>
 * The following example illustrates the Ecore metamodel <code>Person</code> written in Xcore:
 * 
 * <pre>
 * class Person {
 *    String[1] name = "Name"
 *    int age
 *    unique String[] emails
 *    refers Person parent opposite children
 *    refers unordered Person[] children opposite parent
 * }
 * </pre>
 * 
 * Note that AOF-M3 is as expressive as Xcore regarding the unique, unordered constraints (see {@link AOFFactory}).
 * <p>
 * The following Java interfaces, generated from the Ecore model, illustrates the difference between AOF metamodels and
 * EMF ones (see {@link AOFFactory}) :
 * 
 * <pre>
 * public interface Person extends EObject {
 * 	String getName();
 * 
 * 	void setName(String value);
 * 
 * 	int getAge();
 * 
 * 	void setAge(int value);
 * 
 * 	EList&lt;String&gt; getEmails();
 * 
 * 	Person getParent();
 * 
 * 	void setParent(Person value);
 * 
 * 	EList&lt;Person&gt; getChildren();
 * }
 * </pre>
 * 
 * Platform-independent implementation of methods allowing the manipulation meta-model <code>Person</code> given in
 * {@link IFactory}, can be written in the Ecore platform-depend manner, as follows:
 * 
 * <pre>
 * public Person createPerson(String name, int age, String... emails) {
 * 	Person person = PopulationFactory.eINSTANCE.createPerson();
 * 	person.setName(name);
 * 	person.setAge(25);
 * 	person.getEmails().addAll(Arrays.asList(emails));
 * 	return person;
 * }
 * 
 * public void addChild(Person parent, Person child) {
 * 	parent.getChildren.add(child);
 * 	// opposite property &quot;child.parent&quot; managed by EMF
 * }
 * </pre>
 *
 */
public class EMFFactory extends AOFFactory {

	/**
	 * Singleton instance of this factory
	 */
	public static IFactory INSTANCE = new EMFFactory();

	private Map<EClass, IMetaClass<?>> metaClassesCache = new HashMap<EClass, IMetaClass<?>>();

	/**
	 * Returns the meta-class representing the specified platform-dependent meta-class, which must be an {@link EClass}.
	 * <p>
	 * Note that a Java class can be also given as the platform-class once the Java code has been generated from the
	 * Ecore metamodel.
	 * 
	 * @param platformClass
	 *            an Ecore class instance of {@link EClass}, or a Java class instance of {@link Class}
	 * @throws IllegalArgumentException
	 *             if the specified class is neither an instance of {@link EClass}, nor an instance of {@link Class}
	 */
	@Override
	public <A> IMetaClass<A> getMetaClass(Object platformClass) {
		if (platformClass instanceof EClass) {
			EClass emfClass = (EClass) platformClass;
			IMetaClass<A> ret = (IMetaClass<A>) metaClassesCache.get(emfClass);
			if (ret == null) {
				ret = new EMFMetaClass(emfClass);
				metaClassesCache.put(emfClass, ret);
			}
			return ret;
		} else if (platformClass instanceof Class<?>) {
			return super.getMetaClass(platformClass);
		} else {
			throw new IllegalArgumentException("Class " + platformClass + " is neither a Java class, nor an EMF class");
		}
	}

	/**
	 * Creates and returns the box representing the specified property of a given object.
	 * <p>
	 * The property must be a string representing the property name, or a
	 * {@link org.eclipse.emf.ecore.EStructuralFeature}
	 * <p>
	 * Refer to the main documentation of interface {@link IFactory} that gives a concrete example of use.
	 * <p>
	 * The returned box currently aligns the semantics of AOF boxes to the semantics of Ecore structural features as
	 * follows:
	 * <p>
	 * <ol>
	 * <li>Feature with cardinality [0..1] is not mapped to an option box but to a one box with a null value.
	 * <li>Feature with cardinality [1..1] is mapped to a one box with a null default value.
	 * <li>Feature with cardinality [n..*] is always mapped to an ordered box: an ordered set if the feature is unique,
	 * otherwise a sequence.
	 * </ol>
	 * <p>
	 * These alignments currently facilitate the implementation of AOF. They will be improved in next releases of AOF.
	 * 
	 * @return the box representing the specified property of a given objects
	 * @throws IllegalArgumentException
	 *             if the property type is nor a string, neither a {@link org.eclipse.emf.ecore.EStructuralFeature} of
	 *             if the property has not been found in meta-class <code>C</code> of the specified object.
	 */
	@Override
	public <A, B> IBox<B> createPropertyBox(A object, Object property) {
		IMetaClass<A> metaClass;
		if (object instanceof EObject) {
			EObject eobject = (EObject) object;
			metaClass = getMetaClass(eobject.eClass());
		} else {
			metaClass = getMetaClass(object.getClass());
		}
		IUnaryFunction<A, IBox<B>> accessor = metaClass.getPropertyAccessor(property);
		return accessor.apply(object);
	}

}
