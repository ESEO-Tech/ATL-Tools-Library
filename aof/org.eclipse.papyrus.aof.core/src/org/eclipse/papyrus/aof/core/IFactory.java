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
 * Represents the box factory used to create boxes and objects related to boxes.
 * <p>
 * It provides <code>createXxxx</code> methods that allow the creation of boxes of any type, as well as pairs, boxes
 * that represent properties, and meta-classes.
 * <p>
 * Most of the methods are platform-independent, except methods {@link #createPropertyBox(Object, Object)} and
 * {@link #getMetaClass(Object)} that must be implemented by platform-specific factories. Such factories provide their
 * own platform-dependent meta-metamodels, such as {@link AOFFactory} for AOF meta-metamodel, and
 * {@link org.eclipse.papyrus.aof.emf.EMFFactory} for Ecore.
 * <p>
 * A meta-model can be defined in a platform-independent manner using UML, and element of transformations and mapping
 * using OCL. Our example named "Population" defines metamodel <code>Person</code> represented as a UML class defining
 * properties <code>name: String</code>, <code>emails: Sequence(String)</code>, <code>parent: Person</code> and
 * <code>children: Set(Person)</code>.
 * 
 * Such <code>Person</code> type is implemented in Java depending on the target factory: see {@link AOFFactory}, or
 * {@link org.eclipse.papyrus.aof.emf.EMFFactory}, as examples.
 * <p>
 * However, AOF provides core interfaces that allows the manipulation of meta-model in platform-dependent way, as the
 * following code illustrates:
 * 
 * <pre>
 * // Platform-dependent static initializations
 * 
 * static IFactory factory = AOFFactory.INSTANCE;
 * static IMetaClass&lt;Person&gt; PERSON = factory.getMetaClass(Person.class);
 * 
 * // Platform-independent meta-model manipulation
 * 
 * Person createPerson(String name, int age, String... emails) {
 * 	Person person = PERSON.newInstance();
 * 	IBox&lt;String&gt; nameProperty = factory.createPropertyBox(person, &quot;name&quot;);
 * 	IBox&lt;Integer&gt; ageProperty = factory.createPropertyBox(person, &quot;age&quot;);
 * 	IBox&lt;String&gt; emailsProperty = factory.createPropertyBox(person, &quot;emails&quot;);
 * 	nameProperty.set(name);
 * 	ageProperty.set(age);
 * 	emailsProperty.assign(emails);
 * 	return person;
 * }
 * 
 * void addChild(Person parent, Person child) {
 * 	IBox&lt;Person&gt; childrenProperty = factory.createPropertyBox(parent, &quot;children&quot;);
 * 	IBox&lt;Person&gt; parentProperty = factory.createPropertyBox(child, &quot;parent&quot;);
 * 	childrenProperty.add(child);
 * 	parentProperty.set(parent);
 * }
 * </pre>
 * 
 * These two static definitions and methods are used along the examples given in the documentation of {@link IBox}
 * active operation methods.
 * <p>
 * Platform-dependent implementation of the two methods are also provided in the documentation of {@link AOFFactory} and
 * {@link org.eclipse.papyrus.aof.emf.EMFFactory}.
 *
 */
public interface IFactory {

	// platform-independent operations

	/**
	 * Returns a new box with the specified constraints and containing the given elements.
	 * <p>
	 * In case of a collection with no duplicates, i.e.
	 * <code>!constraints.isSingleton() && constraints.isUnique()</code>), duplicates that appear in the given elements
	 * are discarded, as method {@link org.eclipse.papyrus.aof.core.IBox#assign(Object...)} does.
	 * <p>
	 * In case of a singleton, the last element of given elements defines the initial contents of the singleton. If the
	 * singleton is a one box, the first element of the given elements defines the default element of the one box.
	 * <p>
	 * If list of given elements is empty, the returned box is empty. However, if the returned box is a one, the
	 * <code>null</code> element is added to the box, and also defines its default element; calling
	 * <code>createBox</code> in such a case should thus be performed carefully.
	 * <p>
	 * Illustrative examples:
	 * <ul>
	 * <li> <code>createBox(IConstraints.SEQUENCE, 1, 2, 3)</code> returns a
	 * {@link org.eclipse.papyrus.aof.core.ISequence} containing elements 1,2 and 3</li>
	 * <li> <code>createBox(IConstraints.SET, 1, 2, 2, 3, 3, 3)</code> returns a
	 * {@link org.eclipse.papyrus.aof.core.ISet} containing elements 1,2 and 3</li>
	 * <li> <code>createBox(IConstraints.OPTION, 1, 2, 3)</code> returns a {@link org.eclipse.papyrus.aof.core.IOption}
	 * containing element 3</li>
	 * <li> <code>createBox(IConstraints.ONE, 1, 2, 3)</code> returns a {@link org.eclipse.papyrus.aof.core.IOne}
	 * containing element 3 and with default value 1</li>
	 * <li> <code>createBox(IConstraints.ONE)</code> returns a {@link org.eclipse.papyrus.aof.core.IOne} containing
	 * element <code>null</code> and with default element <code>null</code></li>
	 * </ul>
	 * 
	 * @param constraints
	 *            the constraints that defines the type of the returned box
	 * @param elements
	 *            the initial contents of the returned box
	 * @param <E>
	 *            type of the elements of the returned box
	 * @return a new box with the specified constraints and containing the given elements
	 * @throws IllegalStateException
	 *             if the specified constraints is not a legal constraints (see
	 *             {@link org.eclipse.papyrus.aof.core.IConstraints#isLegal()})
	 */
	<E> IBox<E> createBox(IConstraints constraints, E... elements);

	/**
	 * Returns a new empty option box.
	 * <p>
	 * There is no strict equivalence with OCL since OCL does not consider any <code>Option</code> type.
	 * 
	 * @param <E>
	 *            type of the elements of the returned box
	 * @return an empty option box
	 */
	<E> IOption<E> createOption();

	/**
	 * Returns a new option box containing the specified element.
	 * <p>
	 * There is no strict equivalence with OCL since OCL does not consider any <code>One</code> type.
	 * 
	 * @param element
	 *            the element to be add to the returned box
	 * @param <E>
	 *            type of the elements of the returned box
	 * @return a new option box containing the specified element
	 */
	<E> IOption<E> createOption(E element);

	/**
	 * Returns a new one box with a specified default element, and containing the same default element.
	 * <p>
	 * There is no strict equivalence with OCL since OCL does not consider any <code>One</code> type.
	 * 
	 * @param defaultElement
	 *            the element to be defined as the default element and added to the returned box
	 * @param <E>
	 *            type of the elements of the returned box
	 * @return a new one box with a specified default element, and containing the same default element
	 */
	<E> IOne<E> createOne(E defaultElement);

	/**
	 * Returns a new one box with a specified default element, and containing a specified initial element.
	 * <p>
	 * There is no strict equivalence with OCL since OCL does not consider any <code>One</code> type.
	 * 
	 * @param defaultElement
	 *            the element to be defined as the default element
	 * @param initialAlement
	 *            the element to be added to the returned box
	 * @param <E>
	 *            type of the elements of the returned box
	 * @return a new one box with a specified default element, and containing the specified initialAlement
	 */
	<E> IOne<E> createOne(E defaultElement, E initialAlement);

	/**
	 * Returns a new set box containing the specified elements.
	 * <p>
	 * Any duplicate of the specified element is discarded. For example, <code>createSet(1,2,2,3,3,3)</code> returns the
	 * same box than <code>createSet(1,2,3)</code>.
	 * <p>
	 * The AOF expression <code>this.createSet(<elements>)</code> is equivalent to OCL expression
	 * <code>Set{<elements>}</code>.
	 * 
	 * @param elements
	 *            the element to be added to the returned box
	 * @param <E>
	 *            type of the elements of the returned box
	 * @return a new set box containing the specified elements
	 */
	<E> ISet<E> createSet(E... elements);

	/**
	 * Returns a new ordered set box containing the specified elements.
	 * <p>
	 * Any duplicate of the specified element is discarded. For example, <code>createOrderedSet(1,2,2,3,3,3)</code>
	 * returns the same box than <code>createOrderedSet(1,2,3)</code>.
	 * <p>
	 * The AOF expression <code>this.createOrderedSet(<elements>)</code> is equivalent to OCL expression
	 * <code>OrderedSet{<elements>}</code>.
	 * 
	 * @param elements
	 *            the element to be added to the returned box
	 * @param <E>
	 *            type of the elements of the returned box
	 * @return a new set box containing the specified elements
	 */
	<E> IOrderedSet<E> createOrderedSet(E... elements);

	/**
	 * Returns a new sequence box containing the specified elements.
	 * <p>
	 * The AOF expression <code>this.createSequence(<elements>)</code> is equivalent to OCL expression
	 * <code>Sequence{<elements>}</code>.
	 * 
	 * @param elements
	 *            the element to be added to the returned box
	 * @param <E>
	 *            type of the elements of the returned box
	 * @return a new set box containing the specified elements
	 */
	<E> ISequence<E> createSequence(E... elements);

	/**
	 * Returns a new bag box containing the specified elements.
	 * <p>
	 * The AOF expression <code>this.createBag(<elements>)</code> is equivalent to OCL expression
	 * <code>Bag{<elements>}</code>.
	 * 
	 * @param elements
	 *            the element to be added to the returned box
	 * @param <E>
	 *            type of the elements of the returned box
	 * @return a new set box containing the specified elements
	 */
	<E> IBag<E> createBag(E... elements);

	/**
	 * Returns a new pair containing the specified left and right elements.
	 * <p>
	 * The AOF expression <code>this.createPair(l, r)</code> is equivalent to OCL expression
	 * <code>Tuple{left: l, right: r}</code>.
	 * 
	 * @param left
	 *            element at left
	 * @param right
	 *            element at right
	 * @param <L>
	 *            type of element at left
	 * @param <R>
	 *            type of element at right
	 * @return a new pair containing the specified left and right elements
	 */
	<L, R> IPair<L, R> createPair(L left, R right);


	// platform-dependent operations

	/**
	 * Creates and returns a new box representing the specified property of a given object.
	 * <p>
	 * The specification of the property is platform-dependent: it could a either a string representing the property
	 * name, or a instance of a platform-defined class representing a property.
	 * <p>
	 * Refer to the main documentation of interface {@link IFactory} that gives a concrete example of use.
	 * 
	 * @param object
	 *            object owning the property
	 * @param property
	 *            property owned by the object
	 * @param <C>
	 *            type of the owning object
	 * @param <P>
	 *            type of the property
	 * @return a new box representing the specified property of a given objects
	 * @throws IllegalArgumentException
	 *             if the property type does not conform to the platform property class,
	 *             of if the property has not been found in class <code>C</code> of the specified object.
	 */
	<C, P> IBox<P> createPropertyBox(C object, Object property);

	/**
	 * Returns the meta-class for the specified platform-dependent class.
	 * <p>
	 * Refer to the main documentation of interface {@link IFactory} that gives a concrete example of use.
	 * 
	 * @param platformClass
	 *            platform-dependent class
	 * @return the platform-independent meta-class representing the platform-dependent class
	 * @throws IllegalArgumentException
	 *             if the specified class is not a valid platform-dependent class
	 */
	<C> IMetaClass<C> getMetaClass(Object platformClass);

}
