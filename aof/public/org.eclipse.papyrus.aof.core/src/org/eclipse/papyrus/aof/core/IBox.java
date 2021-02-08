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
 * Represents the first-class objects of AOF: boxes.
 * <p>
 * A box is a container that can be synchronized with other boxes by using active operations. Every model is considered
 * as a graph of boxes, each box representing an object property.
 * <p>
 * A box is constrained (see {@link org.eclipse.papyrus.aof.core.IConstrained}), readable (see
 * {@link org.eclipse.papyrus.aof.core.IReadable}), writable (see {@link org.eclipse.papyrus.aof.core.IWritable}), and
 * observable (see {@link org.eclipse.papyrus.aof.core.IObservable}).
 * <p>
 * This interface defines all active operations that can be applied to box.
 * <p>
 * Most of the active operations are bidirectional, meaning that the result of the operation can be mutated. The
 * semantics of bidirectionality preserves the initial semantics of the unidirectional version of the operation, meaning
 * that reapplying the operation in the unidirectional direction after having modified the result must always give the
 * same result.
 * <p>
 * Documentation of active operation methods is exhaustive. It is based on two type of boxes: boxes with simple data
 * such as boxes of integers, and boxes with objects instance of a metamodel <code>Person</code> introduced in
 * {@link IFactory}. OCL as often it is possible to illustrate the similarities with AOF. It is also used for easing AOF
 * code examples based on metamodel <code>Person</code>.
 *
 * @param <E>
 *            type of elements of the box
 */
public interface IBox<E> extends IConstrained, IReadable<E>, IWritable<E>, IObservable<E> {

	// Comparison

	/**
	 * Returns whether this box is exactly the same as that box: same constraints <b>and</b> same contents.
	 * <p>
	 * Equality is based on the {@link Object#equals(Object)}, supplemented by null value handling (two null values are
	 * equal).
	 * <p>
	 * This methods does not override {@link Object#equals(Object)} since AOF considers identity equality for boxes:
	 * boxes are used to represent object properties, and two properties can never be equals to preserver integrity.
	 * 
	 * @param that
	 *            box to be compared with this box
	 * @return true if this box is exactly the same as that box, false otherwise
	 */
	boolean sameAs(IBox<E> that);

	// Binding

	/**
	 * Defines a bidirectional binding between this box and that box, and returns a corresponding binding object.
	 * <p>
	 * The two boxes must have exactly the same type, i.e. if
	 * <code>this.getConstraints().equals(that.getConstraints())</code>.
	 * <p>
	 * That box is firstly assigned to this box, thus a bidirectional binding is not commutative.
	 * <p>
	 * In the forward direction, mutating that box implies mutating this box similarly. In the reverse direction,
	 * mutating this box implies mutating that box similarly.
	 * <p>
	 * The returned binding object can be used to disable and enable the binding.
	 * <p>
	 * Binding creation is a key point of AOF that allows the writing of <b>mapping</b> between two existing metamodels.
	 * The following example show a very simple binding between two existing sequence of integers:
	 * 
	 * <pre>
	 * IFactory factory = AOFFactory.INSTANCE;
	 * ISequence<Integer> leftIntegers = factory.createSequence();
	 * ISequence<Integer> rightIntegers = factory.createSequence(1, 2, 3);
	 * IBinding<Integer> binding = leftIntegers.bind(rightIntegers);
	 * assert(leftIntegers.sameAs(rightIntegers);
	 * rightIntegers.append(4);
	 * assert(leftIntegers.sameAs(rightIntegers);
	 * leftIntegers.removeAt(0);
	 * assert(leftIntegers.sameAs(rightIntegers);
	 * binding.disable();
	 * rightIntegers.append(5);
	 * assert(!leftIntegers.sameAs(rightIntegers);
	 * binding.enable();
	 * assert(leftIntegers.sameAs(rightIntegers);
	 * </pre>
	 * <p>
	 * 
	 * <p>
	 * See {@link #collectTo(IUnaryFunction)} for an example of binding between mutable objects.
	 * 
	 * @param that
	 *            box to be bound to this box
	 * @return a corresponding binding object
	 * @throws IllegalArgumentException
	 *             if this and that boxes do have the same type
	 */
	IBinding<E> bind(IBox<E> that);


	// Debug operations

	/**
	 * Creates and returns a snapshot of this box, which is not affected by any subsequent change on this box.
	 * <p>
	 * This method can be useful for debugging purpose.
	 * 
	 * @return a snapshot of this box
	 */
	IBox<E> snapshot();

	/**
	 * Inspects the contents of this box by displaying in the standard console its initial contents, and all its
	 * subsequent mutations.
	 * <p>
	 * The following code illustrates the display performed by the inspection:
	 * 
	 * <pre>
	 * IFactory factory = AOFFactory.INSTANCE;
	 * ISequence&lt;Integer&gt; integers = factory.createSequence(1, 2, 3);
	 * integers.inspect(&quot;ints&quot;);
	 * // displays: &quot;ints=seq(1, 2, 3)&quot;
	 * integers.add(0);
	 * // displays: &quot;ints=seq(1, 2, 3, 0)          &quot;
	 * //           &quot;                  &circ;added(0, 4)&quot;
	 * </pre>
	 * 
	 * This method is very useful for understand each step of the incremental evaluation of active operation side
	 * effects on boxes.
	 * 
	 * @param label
	 *            prefix label displayed used to identify this inspected box
	 * @return this box
	 */
	IBox<E> inspect(String label);

	/**
	 * Inspects the contents of this box by displaying in the standard console
	 * its initial contents, and all its subsequent mutations.
	 * <p>
	 * Specific function <code>toString</code> is used as a replacement of <code>&lt;E&gt;.toString()</code> method.
	 * 
	 * <pre>
	 * IFactory factory = AOFFactory.INSTANCE;
	 * IOrderedSet&lt;String&gt; strings = factory.createOrderedSet("a, "b", "c");
	 * strings.inspect("upper", s -> s.toUpperString()); 
	 * // displays: "upper=oset(A, B, C)"
	 * </pre>
	 * 
	 * @param label
	 *            prefix label displayed used to identify this inspected box
	 * @param toString
	 *            function used as a replacement of <code><E>.toString()</code> method
	 * @return this box
	 */
	IBox<E> inspect(String label, IUnaryFunction<? super E, String> toString);


	// Cardinality operations

	/**
	 * Returns a boxed integer giving the number of elements in this box.
	 * <p>
	 * The boxed number is changed whenever elements are added to and removed from this box.
	 * <p>
	 * The operation is unidirectional, meaning that this box size cannot be changed by changing the boxed number.
	 * <p>
	 * The operation is equivalent to OCL size() function.
	 * 
	 * @return a boxed integer giving the number of elements in this box
	 */
	// note that a bidirectional version could be provided by adding an element-provider function
	// IOne<Integer> size(IUnaryFunction<Integer, E> elementProvider)
	// where the integer argument represents the position within this box of the element to provide
	IOne<Integer> size();

	/**
	 * Returns a boxed boolean indicating whether this box is empty or not.
	 * <p>
	 * The boxed boolean is updated whenever elements are added to and removed from this box.
	 * <p>
	 * The operation is unidirectional, meaning that this box state cannot be altered by changing the boxed boolean.
	 * 
	 * The operation is equivalent to OCL isEmpty() function.
	 * 
	 * @return a boxed boolean indicating whether this box is empty or not
	 */
	// note that a bidirectional version could be provided if an elements provider function
	// is specified: IOne<Integer> isEmpty(IAction<Integer, Iterable<E>> elementsProvider)
	// writing false => this.clear() / writing true => this.assign(elementsProvider.apply())
	IOne<Boolean> isEmpty();

	/**
	 * Returns a boxed boolean indicating whether this box is not empty or empty.
	 * 
	 * The operation is equivalent to OCL notEmpty() function.
	 * 
	 * @return a boxed boolean indicating whether this box is not empty or empty
	 * @see #isEmpty()
	 */
	IOne<Boolean> notEmpty();


	// Collect operations

	/**
	 * Creates and returns a box that contains the elements of this box transformed by the specified collector function.
	 * <p>
	 * The result box has the same constraints than this box, except the uniqueness constraints: as the collector may
	 * introduce duplicate, the result box has a uniqueness constraints only if this box is a singleton.
	 * <p>
	 * This method is equivalent to OCL <code>collect</code> function, but with the following limitation: the collector
	 * function <b>must</b> not introduce mutations that cannot be captured by observing this box. Active operation
	 * {@link #collectMutable(IUnaryFunction)} encompass this limitation.
	 * <p>
	 * 
	 * The following example, based on class {@link java.awt.geom.Point2D}, illustrates a <b>bad</b> practice:
	 * 
	 * <pre>
	 * IFactory factory = AOFFactory.INSTANCE;
	 * ISequence&lt;Point2D&gt; points = factory.createSequence();
	 * IBox&lt;Double&gt; xs = points.collect(p -&gt; p.getX());
	 * </pre>
	 * 
	 * Mutating sequence <code>points</code> induces a consistent updating of <code>xs</code>. <b>However</b>, updating
	 * a point by writing <code>points.get(0).setLocation(...)</code> does <b>not</b> update <code>xs</code>.
	 * <p>
	 * The following example, based on Java classes representing immutable values, illustrates <b>good</b> practices:
	 * 
	 * <pre>
	 * ISequence&lt;Double&gt; values = factory.createSequence();
	 * IBox&lt;String&gt; strings = values.collect(d -&gt; d.toString());
	 * IBox&lt;Double&gt; squares = values.collect(d -&gt; d * d);
	 * </pre>
	 * 
	 * Since a double is an <b>immutable</b> value, the active operation result is always consistent.
	 * <p>
	 * However, the active operation remains consistent even when operating on mutable objects as soon as the collector
	 * function only uses methods whose effect does not vary when the object state changes. The following example is
	 * consistent:
	 * 
	 * <pre>
	 * ISequence&lt;Object&gt; objects = factory.createSequence();
	 * IBox&lt;Boolean&gt; arePoints = objects.collect(e -&gt; e instanceof Point2D);
	 * IBox&lt;Class&gt; classes = objects.collect(e -&gt; e.getClass());
	 * </pre>
	 * 
	 * This active operation is unidirectional. Use {@link #collect(IUnaryFunction, IUnaryFunction)} if bidirectionality
	 * is required.
	 * 
	 * @param collector
	 *            function used to transform elements of this box
	 * @param <R>
	 *            type of elements of the returned box
	 * @return
	 *         a box that contains the elements of this box transformed by the specified collector function
	 * @see #collect(IUnaryFunction, IUnaryFunction)
	 */
	<R> IBox<R> collect(IUnaryFunction<? super E, ? extends R> collector);

	/**
	 * Creates and returns a box that contains the elements of this box transformed by the specified collector function,
	 * providing bidirectionality through the specified inverse collector.
	 * <p>
	 * The active operation follows the same typing rules (the result box has the same constraints than this box), and
	 * consistency rules than {@link #collect(IUnaryFunction)}.
	 * <p>
	 * The following code illustrates that bidirectionality may be inconsistent:
	 * 
	 * <pre>
	 * ISequence&lt;Integer&gt; integers = factory.createSequence();
	 * IBox&lt;Integer&gt; multipliedByTwo = integers.collect(i -&gt; i * 2, i -&gt; i / 2);
	 * </pre>
	 * 
	 * Adding an integer into <code>multipliedByTwo</code> requires that this integer is even: if not, the
	 * bidirectionality is inconsistent since reapplying the operation gives a different result. For example, adding 3
	 * in <code>multipliedByTwo</code> results in adding 1 in <code>integers</code>, which is not consistent since 1*2
	 * differs from 3. If such a scenario arises, an illegal state exception is thrown.
	 * <p>
	 * This typical example shows that the collector function requires to be <b>bijective</b>. Changing from integers to
	 * doubles makes the previous example consistent:
	 * 
	 * <pre>
	 * ISequence&lt;Double&gt; doubles = factory.createSequence();
	 * IBox&lt;Double&gt; multipliedByTwo = doubles.collect(d -&gt; d * 2, d -&gt; d / 2);
	 * </pre>
	 * 
	 * @param collector
	 *            bijective function used to transform elements of this box in the forward direction
	 * @param reverseCollector
	 *            bijective function used to transform elements of this box in the reverse direction
	 * @param <R>
	 *            type of elements of the returned box
	 * @return
	 *         a box that contains elements of this box transformed by the specified collector function
	 * @throws IllegalStateException
	 *             if the element added or replaced in the result is not consistent regarding the collector and inverse
	 *             collector functions
	 * @see #collect(IUnaryFunction)
	 */
	<R> IBox<R> collect(IUnaryFunction<E, R> collector, IUnaryFunction<R, E> reverseCollector);

	<R, S> IBox<R> collectWithState(S defaultState, IUnaryFunction<? super E, IPair<R, S>> collector, IUnaryFunction<IPair<R, S>, ? extends E> reverseCollector);

	/**
	 * Creates and returns a box that contains the elements of this box transformed by the specified collector function,
	 * or retrieved using a cache for elements previously transformed by the same operation.
	 * <p>
	 * Consequently, the collector function must be <b>bijective</b>, thus the result box has exactly the same
	 * constraints than this box (no duplicates can be introduced by the collector function).
	 * <p>
	 * Contrary to {@link #collect(IUnaryFunction)}, this active operation is provided for collecting mutable objects,
	 * and defining mappings between objects. The collected objects can be retrieved by invoking active operation
	 * {@link #collectedFrom(IUnaryFunction)} that uses the cache.
	 * <p>
	 * The following example illustrates an unidirectional transformation of a set of persons into textual items (of a
	 * tree widget for instance). UML class <code>Person</code> has been introduced in {@link IFactory}, and class
	 * <code>Item</code> is defined similarly by properties: <code>text: String</code>, and
	 * <code>subItems: Set(Item)</code>.
	 * 
	 * The transformation can be written using an OCL function and shadow objects, as follows:
	 * 
	 * <pre>
	 * def: populationToItems(population : Set(Person)): Set(Item) =
	 *    population->collect(p | 
	 *       Item {
	 *          text = p.name,
	 *          subItems = populationToItems(p.children)
	 *       }
	 *    )
	 * </pre>
	 * 
	 * Making this transformation active is achieved by the following AOF code:
	 * 
	 * <pre>
	 * IUnaryFunction<Person, Item> personToItem = (p -> 
	 *    Item i = new Item();
	 *    i.getText().bind(p.getName());
	 *    i.getSubItems().bind(populationToItems.getChildren());
	 *    return i;
	 * )
	 * 
	 * IBox<Item> populationToItems(ISet<Person> population) {
	 *    return polulation.collectTo(personToItem);
	 * }
	 * </pre>
	 * 
	 * Note that the previous code is not platform-independent since it use direct access to property boxes (see
	 * {@link AOFFactory}). Instead of <code>i.getText()</code>, one can write
	 * <code>factory.createPropertyBox(i, "text")</code>.
	 * <p>
	 * A bidirectional version is provided by method {@link #collectTo(IUnaryFunction, IUnaryFunction)}.
	 * 
	 * @param toCollector
	 *            bijective function used to transform elements of this box
	 * @param <R>
	 *            type of elements of the returned box
	 * @return
	 *         a box that contains elements of this box transformed by the specified collector function
	 * @see #collectedFrom(IUnaryFunction)
	 * @see #collectTo(IUnaryFunction, IUnaryFunction)
	 */
	<R> IBox<R> collectTo(IUnaryFunction<? super E, ? extends R> toCollector);

	/**
	 * Creates and returns a box that contains the elements of this box transformed by the specified to-collector
	 * function, or retrieved using a cache for elements previously transformed by the same operation,
	 * providing bidirectionality through the specified from-collector.
	 * <p>
	 * The active operation follows the same typing rules and semantics than {@link #collectTo(IUnaryFunction)}.
	 * <p>
	 * The unidirectional mapping presented in {@link #collectTo(IUnaryFunction)} can be easily extended to a
	 * bidirectional mapping by "reverting" the code of the to-collector in the from-collector, as follows:
	 * 
	 * <pre>
	 * IUnaryFunction<Item, Person> itemToPerson = (i -> 
	 *    Person p = new Person();
	 *    p.getName().bind(i.getText());
	 *    populationToItems(p.getChildren()).bind(i.getSubItems());
	 *    return p;
	 * )
	 * 
	 * IBox<Item> populationToItems(ISet<Person> population) {
	 *    return polulation.collectTo(personToItem, itemToPerson)
	 * }
	 * </pre>
	 * 
	 * @param toCollector
	 *            bijective function used to transform elements of this box in the forward direction
	 * @param fromCollector
	 *            bijective function used to transform elements of this box in the reverse direction
	 * @param <R>
	 *            type of elements of the returned box
	 * @return
	 *         a box that contains elements of this box transformed by the specified collector function
	 * @see #collectedFrom(IUnaryFunction)
	 * @see #collectTo(IUnaryFunction)
	 */
	<R> IBox<R> collectTo(IUnaryFunction<E, R> toCollector, IUnaryFunction<R, E> fromCollector);

	/**
	 * Creates and returns a box that contains the elements of this box that have been previously collected
	 * by {@link #collectTo(IUnaryFunction)} or {@link #collectTo(IUnaryFunction, IUnaryFunction)}.
	 * <p>
	 * The result box has the same constraints than this box (uniqueness is notably preserve since the to-collector
	 * function requires to be bijective, see {@link #collectTo(IUnaryFunction)}.
	 * <p>
	 * The elements that this active operation collects correspond to the argument elements of the to-collector of
	 * {@link #collectTo(IUnaryFunction)} or {@link #collectTo(IUnaryFunction, IUnaryFunction)}, and the result elements
	 * of the from-collector of method {@link #collectTo(IUnaryFunction, IUnaryFunction)} in case of a bidirectional
	 * collect-to.
	 * <p>
	 * This operation only use the cache populated by {@link #collectTo(IUnaryFunction)} and
	 * {@link #collectTo(IUnaryFunction, IUnaryFunction)}, and thus <b>never</b> create new element instances.
	 * <p>
	 * The following example illustrates the use of this active operation along with {@link #collectTo(IUnaryFunction)}:
	 * 
	 * <pre>
	 * ISet<Person> population = factory.createSet();
	 * IBox<Item> items = populationToItems(population); // from {@link #collectTo(IUnaryFunction)}
	 * IBox<Person> persons = items.collectedFrom(personToitem);
	 * Person john = creatPerson("John", 25); // see {@link IFactory}
	 * population.add(john)
	 * assert(persons.sameAs(population));
	 * </pre>
	 * <p>
	 * This operation is unidirectional due to its deterministic semantics: elements must have been previously mapped
	 * using method {@link #collectTo(IUnaryFunction)} (or {@link #collectTo(IUnaryFunction, IUnaryFunction)}). The
	 * reverse direction of this operation is thus achieved one of these methods.
	 * <p>
	 * 
	 * @param toCollector
	 *            function used by {@link #collectTo(IUnaryFunction)} in case of a unidirectional collect-to,
	 *            or by {@link #collectTo(IUnaryFunction, IUnaryFunction)} in case of a a bidirectional collect-to
	 * @param <R>
	 *            type of elements of the returned box
	 * @return box that contains the elements of this box that have been previously collected
	 * @see #collectTo(IUnaryFunction)
	 * @see #collectTo(IUnaryFunction, IUnaryFunction)
	 */
	// not yet tested: useless operation for Facade, but useful for understanding the difference between collect
	// and collectTo - should be tested in AOF2
	<R> IBox<R> collectedFrom(IUnaryFunction<? super R, ? extends E> toCollector);


	/**
	 * Creates and returns a box that contains the elements of all boxes representing the specified property for each
	 * element of this box.
	 * <p>
	 * This active operation thus performs a flattening of the two interleaved boxes: this box, and the boxes
	 * representing the property of each element of this box.
	 * <p>
	 * The result box has a and'ed ordered, uniqueness and singleton constraints of this box and of the boxes
	 * representing the property, supplemented by a or'ed optional constraints.
	 * <p>
	 * A factory is required retrieve the type of the specified property, and thus setting the type of the returned box.
	 * <p>
	 * OCL has a simple syntax that shortcuts its collect function, which is itself a flattening version. For example,
	 * accessing all children of the person of a given population declared as follows:
	 * 
	 * <pre>
	 * def: allChildrenOf(population : Set(Person)): Bag(Person) =
	 *     population.children
	 *     // equivalent to: population->collect(p | p.children)
	 * </pre>
	 * 
	 * The equivalent AOF version of such a navigation is implemented as follows:
	 * 
	 * <pre>
	 * IBox&lt;Person&gt; allChildrenOf(ISet&lt;Person&gt; population) {
	 * 	population.collect(factory, Person.class, &quot;children&quot;);
	 * }
	 * </pre>
	 * 
	 * This example operates in the forward direction.
	 * <p>
	 * 
	 * This active operation is bidirectional but following a condition: this box must be a <b>singleton</b>. The
	 * following example illustrates the principle:
	 * 
	 * <pre>
	 * IBox&lt;Person&gt; childrenOf(IOption&lt;Person&gt; person) {
	 * 	person.collect(factory, Person.class, &quot;children&quot;);
	 * }
	 * </pre>
	 * 
	 * When a child <code>c</code> is added to the result of <code>childrenOf</code>, it is also added to the children
	 * of person <code>p</code> contained in box argument <code>person</code>. Moreover, this addition is performed
	 * <b>after</b> person <code>p</code> has been added to <code>person</code>.
	 * 
	 * <p>
	 * If such an addition is performed using the first version of <code>childrenOf</code> that takes a set of person as
	 * its argument, the reverse updating as no semantics: to which person of box <code>person</code> child
	 * <code>c</code> should be added?
	 * <p>
	 * As a consequence, the bidirectionality is restricted to this box with the singleton constraints. This restriction
	 * is checked whenever the result box is modified.
	 * 
	 * @param factory
	 *            factory managing the platform-dependent specified containing class and property
	 * @param containingClass
	 *            platform-dependent class that the elements contained in this box are instance of (formerly class <E>)
	 * @param property
	 *            property defined by the elements contained in this box
	 * @param <P>
	 *            type of the property
	 * @return a box that contains the elements of all boxes representing the specified property for each
	 *         element of this box
	 * @throws IllegalStateException
	 *             if the result is modified but is a not singleton box
	 * @see #collectMutable(IUnaryFunction)
	 */
	<P> IBox<P> collectMutable(IFactory factory, Object containingClass, Object property);

	/**
	 * Creates and returns a box that contains the elements of all boxes representing the specified property for each
	 * element of this box.
	 * <p>
	 * This active operation thus performs a flattening of the two interleaved boxes: this box, and the boxes
	 * representing the property of each element of this box.
	 * <p>
	 * The result box has a and'ed ordered, uniqueness and singleton constraints of this box and of the boxes
	 * representing the property, supplemented by a or'ed optional constraints.
	 * <p>
	 * A factory is required retrieve the type of the specified property, and thus setting the type of the returned box.
	 * <p>
	 * OCL has a simple syntax that shortcuts its collect function, which is itself a flattening version. For example,
	 * accessing all children of the person of a given population declared as follows:
	 * 
	 * <pre>
	 * def: allChildrenOf(population : Set(Person)): Bag(Person) =
	 *     population.children
	 *     // equivalent to: population->collect(p | p.children)
	 * </pre>
	 * 
	 * The equivalent AOF version of such a navigation is implemented as follows:
	 * 
	 * <pre>
	 * static IMetaClass&lt;Person&gt; PERSON = factory.getMetaClass(Person.class); // see {@link IFactory}
	 * 
	 * IBox&lt;Person&gt; allChildrenOf(ISet&lt;Person&gt; population) {
	 * 	population.collect(PERSON, &quot;children&quot;);
	 * }
	 * </pre>
	 * 
	 * This example operates in the forward direction.
	 * <p>
	 * 
	 * This active operation is bidirectional but following a condition: this box must be a <b>singleton</b>. The
	 * following example illustrates the principle:
	 * 
	 * <pre>
	 * IBox&lt;Person&gt; childrenOf(IOption&lt;Person&gt; person) {
	 * 	person.collect(PERSON, &quot;children&quot;);
	 * }
	 * </pre>
	 * 
	 * When a child <code>c</code> is added to the result of <code>childrenOf</code>, it is also added to the children
	 * of person <code>p</code> contained in box argument <code>person</code>. Moreover, this addition is performed
	 * <b>after</b> person <code>p</code> has been added to <code>person</code>.
	 * 
	 * <p>
	 * If such an addition is performed using the first version of <code>childrenOf</code> that takes a set of person as
	 * its argument, the reverse updating as no semantics: to which person of box <code>person</code> child
	 * <code>c</code> should be added?
	 * <p>
	 * As a consequence, the bidirectionality is restricted to this box with the singleton constraints. This restriction
	 * is checked whenever the result box is modified.
	 * 
	 * @param containingClass
	 *            platform-independent class that the elements contained in this box are instance of (formerly class
	 *            <E>)
	 * @param property
	 *            property defined by the elements contained in this box
	 * @param <P>
	 *            type of the property
	 * @return a box that contains the elements of all boxes representing the specified property for each
	 *         element of this box
	 * @throws IllegalStateException
	 *             if the result is modified but is a not singleton box
	 */
	<P> IBox<P> collectMutable(IMetaClass<E> containingClass, Object property);


	/**
	 * Creates and returns a box that contains the elements of all boxes returned by the specified collector function,
	 * thus performing a flattening of the interleaved boxes.
	 * <p>
	 * This active operation can be used instead of {@link #collectMutable(IMetaClass, Object)}, but is less readable.
	 * However, it is not restricted to collect a property of this box elements: it can collect anything belonging to
	 * these elements.
	 * <p>
	 * The result box type and the bidirectionality restriction are similar to those of
	 * {@link #collectMutable(IMetaClass, Object)}.
	 * <p>
	 * The collector function must return a default box when passing argument null. This allows an accurate typing of
	 * the returned box. If the collector does not handle such as case, it will probably throws a null pointer
	 * exception, which is caught then re-thrown as an {@link IllegalStateException} by this collect operation.
	 * 
	 * <p>
	 * The following example is equivalent to the first example given for {@link #collectMutable(IMetaClass, Object)}:
	 * 
	 * <pre>
	 * IBox&lt;Person&gt; allChildrenOf(ISet&lt;Person&gt; population) {
	 *     population.collect(p -&gt; (p == null) ? IBox.SET: p.getChildren());
	 * }
	 * </pre>
	 * 
	 * <p>
	 * As for {@link #collectMutable(IMetaClass, Object)}, this active operation is bidirectional but following a
	 * condition: this box must be a singleton.
	 * 
	 * @param collector
	 *            property accessor function that returns the property for for each element of this box
	 * @return a box that contains the elements of all boxes returned by the specified collector function
	 * @see #collectMutable(IMetaClass, Object)
	 */
	<R> IBox<R> collectMutable(IUnaryFunction<? super E, ? extends IBox<R>> collector);

	// Collect with conditional selection

	/**
	 * Creates and returns a box that contains the elements of this box transformed by a collector function that
	 * includes if and else conditions.
	 * <p>
	 * The following OCL example illustrates the aim of this active operation:
	 * 
	 * <pre>
	 * def: switchCollectExample(integers: Set(Integer)) : Set(Integer)
	 *    integers->collect(i | 
	 *       if i.mod(2) = 1 then 
	 *          -i
	 *       else if i.mod(3) = 0 then
	 *          i*i
	 *       else
	 *          i
	 *       endif endif
	 *    )
	 * </pre>
	 * 
	 * Translating this OCL example in AOF requires splitting the collector into elementary collectors associated with
	 * predicates representing the conditions, supplemented by a default collector, as follows:
	 * 
	 * <pre>
	 * IBox<Integer> switchCollectExample(ISet<Integer> integers) {
	 *    return integers.switchCollect(
	 *       newArray(i -> (i % 2) == 1, i -> (i % 3) == 0),
	 *       newArray(i -> -i, i -> i*i), 
	 *       i -> i
	 *    )
	 * }
	 * </pre>
	 * 
	 * This example use utility function <code>newArray</code>:
	 * 
	 * <pre>
	 * &lt;A&gt; A[] newArray(A... array) {
	 * 	return array;
	 * }
	 * </pre>
	 * 
	 * @param conditions
	 *            predicates representing the conditions
	 * @param collectors
	 *            collector functions providing the elements when its associated condition matches
	 * @param defaultCollector
	 *            collector function providing the elements when none of the conditions matches
	 * @return a box that contains the elements of this box transformed by a collector function that
	 *         includes if and else conditions
	 */
	public <R> IBox<R> switchCollect(IUnaryFunction<? super E, IOne<Boolean>>[] conditions, IUnaryFunction<? super E, ? extends R>[] collectors, IUnaryFunction<? super E, ? extends R> defaultCollector);

	/**
	 * Creates and returns a box that contains the elements of this box transformed by a collector function that
	 * includes if and else conditions, in both forward and reverse direction.
	 * <p>
	 * This active operation is the bidirectional version of
	 * {@link #switchCollect(IUnaryFunction[], IUnaryFunction[], IUnaryFunction)}.
	 * <p>
	 * The specified reverse collector computes the element in the reverse direction whenever the result box is
	 * modified. As for bidirectional collect {@link #collect(IUnaryFunction, IUnaryFunction)}, the overall collector
	 * composed of the elementary collectors and the default collector must be bijective.
	 * <p>
	 * Consequently, example provided in {@link #switchCollect(IUnaryFunction[], IUnaryFunction[], IUnaryFunction)}
	 * should not be used with this bidirectional collect. The following example that illustrates a if-the-else inside a
	 * collect can be used reversely:
	 * 
	 * <pre>
	 * IBox<Double> switchCollectExample(ISet<Double> doubles) {
	 *    return doubles.switchCollect(
	 *       newArray(x -> x > 0), 
	 *       newArray(x -> 2 * x),
	 *       x -> x,
	 *       x -> if x > 0 then x / 2 else x 
	 *    )
	 * }
	 * </pre>
	 * 
	 * @param conditions
	 *            predicates representing the conditions
	 * @param collectors
	 *            collector functions providing the elements when its associated condition matches
	 * @param defaultCollector
	 *            collector function providing the elements when none of the conditions matches
	 * @param reverseCollector
	 *            collector function providing the elements in reverse direction
	 * @return a box that contains the elements of this box transformed by a collector function that
	 *         includes if and else conditions
	 */
	public <R> IBox<R> switchCollect(IUnaryFunction<? super E, IOne<Boolean>>[] conditions, IUnaryFunction<? super E, ? extends R>[] collectors, IUnaryFunction<? super E, ? extends R> defaultCollector, IUnaryFunction<? super R, ? extends E> reverseCollector);


	// Select operations

	/**
	 * Creates and returns a box that contains the elements of this box satisfying the specified selector predicate.
	 * <p>
	 * This active operation is equivalent to OCL function <code>select</code>.
	 * <p>
	 * The result box has the same constraints than this box, except the optional constraints that is always true (the
	 * selection can be empty if no element matches the predicate).
	 * <p>
	 * As for {@link #collect(IUnaryFunction)}, it is <b>mandatory</b> that the selector function does not introduce
	 * mutations that cannot be captured by observing this box.
	 * <p>
	 * The following example, based on class {@link java.awt.geom.Point2D}, illustrates a <b>bad</b> practice:
	 * 
	 * <pre>
	 * IFactory factory = AOFFactory.INSTANCE;
	 * ISequence&lt;Point2D&gt; points = factory.createSequence();
	 * IBox&lt;Double&gt; pointsAtRight = points.select(p -&gt; p.getX() &gt; 0);
	 * </pre>
	 * 
	 * Mutating sequence <code>points</code> induces a consistent updating of <code>pointsAtRight</code>.
	 * <b>However</b>, updating a point by writing <code>points.get(0).setLocation(...)</code> does <b>not</b> update
	 * <code>pointsAtRight</code>.
	 * <p>
	 * The following examples, based on class {@link java.lang.Double}, illustrate <b>good</b> practices:
	 * 
	 * <pre>
	 * ISequence&lt;Double&gt; values = factory.createSequence();
	 * IBox&lt;Double&gt; positiveValues = values.select(d -&gt; d &gt; 0);
	 * IBox&lt;Double&gt; squaresAreAlwaysPositive = values.collect(d -&gt; d * d).select(d -&gt; d &gt; 0);
	 * </pre>
	 * 
	 * Since a double is an <b>immutable</b> value, the active operation result is always consistent.
	 * <p>
	 * However, the active operation remains consistent even when operating on mutable objects as soon as the selector
	 * function only uses methods whose effect does not vary when the object state changes. The following examples are
	 * consistent:
	 * 
	 * <pre>
	 * ISequence&lt;Object&gt; objects = factory.createSequence();
	 * IBox&lt;Object&gt; pointObjects = objects.select(e -&gt; e instanceof Point2D);
	 * IBox&lt;Point2D&gt; points = pointObjects.collect(e -&gt; (Point2D) e);
	 * IBox&lt;Object&gt; noNulls = objects.select(e -&gt; e != null);
	 * </pre>
	 * 
	 * This active operation is bidirectional unless modification performed on the result box is consistent with the
	 * predicate:
	 * <ul>
	 * <li>If an element is added into the result box and satisfies the predicate, it is added into this box.
	 * <li>If an element is added into the result box but does not satisfy the predicate, an
	 * {@link IllegalStateException} is thrown.
	 * <li>The two previous rules also apply if an element replace a previous one.
	 * <li>If an element is removed from the result box, it is removed from this box.
	 * <li>If an element is moved inside the result box, it is moved inside this box. However, the new position inside
	 * this box is computed from the predicate so that the semantics of the operation is preserved: this can lead in
	 * unexpected behavior when undoing the move on the result, because the element may not necessarily retrieve its
	 * original position within this box.
	 * </ul>
	 * 
	 * @param selector
	 *            predicate used to select elements from this box
	 * @return
	 *         a box that contains the elements of this box transformed by the specified collector function
	 * @see #collect(IUnaryFunction)
	 */
	IBox<E> select(IUnaryFunction<? super E, Boolean> selector);

	/**
	 * Creates and returns a box that contains the elements of this box which are instances of the specified
	 * platform-independent meta-class.
	 * <p>
	 * This active operation is a shortcut to <code>select(e -> metaClass.isInstance(e))</code> safely casted into a
	 * <code>IBox&lt;C&gt;</code>.
	 * <p>
	 * It is bidirectional, following the same consistency rules that {@link #select(IUnaryFunction)}.
	 * <p>
	 * This operation is equivalent to OCL function defined as follows:
	 * 
	 * <pre>
	 * def: select(box: Collection(T), metaClass: OclType): Collection(T)
	 *    box->select(e | e.oclIsKindOf(metaClass))
	 * </pre>
	 * 
	 * @param metaClass
	 *            meta-class used to select the elements of this box
	 * @return a box that contains the elements of this box which are instances of the specified meta-class
	 */
	<C extends E> IBox<C> select(IMetaClass<C> metaClass);

	/**
	 * Creates and returns a box that contains the elements of this box which are instances of the specified Java
	 * meta-class.
	 * <p>
	 * This active operation is similar to {@link #select(IMetaClass)} except that the specified meta-class is not
	 * platform-dependent. It is however useful since most of platform allows the generation of the Java code of the
	 * manipulated meta-model.
	 * 
	 * @param javaClass
	 *            a Java-platform meta-class (e.g., <code>MyClass.class</code>)
	 * @return a box that contains the elements of this box which are instances of the specified Java
	 *         meta-class.
	 */
	<C extends E> IBox<C> select(Class<C> javaClass);


	/**
	 * Creates and returns a box that contains the elements of this box satisfying the specified mutable selector
	 * predicate.
	 * <p>
	 * The result box has the same constraints than this box, except the optional constraints that is always true (the
	 * selection can be empty if no element matches the predicate).
	 * <p>
	 * Contrary to {@link #select(IUnaryFunction)}, the selector is mutable meaning that afterwards mutations of the one
	 * boxes it returns can be observed, complementary to this box observing. A joint use of
	 * {@link #select(IUnaryFunction)} and {@link #selectMutable(IUnaryFunction)} allows writing selection of any kind.
	 * <p>
	 * The implementation of this active operation follows a similar scheme than {@link #collectMutable(IUnaryFunction)}
	 * since they both observe the result of their respective selector and collector functions.
	 * <p>
	 * 
	 * The following example illustrates the use of a mutable select. Let us first consider the OCL expression that
	 * computes the minor persons of a given population:
	 * 
	 * <pre>
	 * def: minorsOf(population : Set(Person)) : Set(Person) =
	 * 		population->select(p | p.age < 18)
	 * </pre>
	 * 
	 * As OCL does not consider side-effects, predicate (p | p.age < 18) is correct.
	 * 
	 * Expression of variable <code>minor</code> should be rewritten in another OCL expression because property
	 * <code>age</code> is represented in AOF as a one box with an integer contents:
	 * 
	 * <pre>
	 * def: minorsOf(population : Set(Person)) : Set(Person) =
	 * 		population->select(p | p.age->collect(a | a < 18)->first())
	 * </pre>
	 * 
	 * This rewrote expression is written in AOF (assuming Java 8 is used) as follows:
	 * 
	 * <pre>
	 * IBox&lt;Person&gt; minorsOf(ISet&lt;Person&gt; population) {
	 *   IUnaryFunction&lt;Person, IBox&lt;Boolean&gt;&gt; selector =  p -&gt; (IOne&lt;Boolean&gt;) factory.createPropertyBox(p, &quot;age&quot;).collect(a -&gt; a &lt; 18);
	 *   return population.select(selector);
	 * }
	 * </pre>
	 * 
	 * As the functional part as been defined in AOF, side effects can now be performed on the population:
	 * 
	 * <pre>
	 * ISet&lt;Person&gt; population = factory.createSet();
	 * IBox&lt;Person&gt; minors = minorsOf(population);
	 * Person john = createPerson(&quot;John&quot;, 25); // createPerson: see {@link IFactory}
	 * Person joe = createPerson(&quot;Joe&quot;, 16);
	 * // forward modification
	 * population.add(john);
	 * population.add(joe);
	 * assert (!minors.contains(john));
	 * assert (minors.contains(joe));
	 * </pre>
	 * 
	 * Side effects can also be performed in the reverse direction, as follows:
	 * 
	 * <pre>
	 * Person jack = createPerson(&quot;Jack&quot;, 16);
	 * minors.add(jack);
	 * assert (population.contains(jack));
	 * minors.remove(john);
	 * assert (!population.contains(john));
	 * minors.add(createPerson(&quot;Jim&quot;, 20)); // throws an IllegalStateException
	 * </pre>
	 * 
	 * Last line is not consistent regarding the select predicate thus resulting in an exception throwing.
	 * 
	 * @param selector
	 *            mutable selector predicate used to select elements of this box
	 * @return a box that contains the elements of this box satisfying the specified mutable selector
	 *         predicate
	 * @throws IllegalStateException
	 *             if adding a new element, or replacing an old element to a new element, while the new element does not
	 *             satisfy the predicate
	 */
	IBox<E> selectMutable(IUnaryFunction<? super E, IOne<Boolean>> selector);

	/**
	 * Creates and returns a box that contains the elements of this box satisfying the specified selector box.
	 * <p>
	 * The result box has the same constraints than this box, except the optional constraints that is always true (the
	 * selection can be empty if no element matches the predicate).
	 * <p>
	 * Contrary to {@link #select(IUnaryFunction)}, the selector is a box of booleans acting as a presence vector: each
	 * element of this box is selected if the corresponding boolean of the selector box equals true. The correspondence
	 * between the element and the boolean is based in their respective positions within their owning boxes, which are
	 * maintained by all active operations (even for unordered boxes).
	 * <p>
	 * As for {@link #collectMutable(IUnaryFunction)}, this active operation allows the selection of elements of this
	 * box even if their state changes. This however implies that the selector box is computed from this box, and that
	 * this computation guarantees that the two boxes have the same cardinalities when the result box is updated.
	 * <p>
	 * The following example illustrates the use of a mutable select along with a collect:
	 * 
	 * <pre>
	 * IFactory factory = AOFFactory.INSTANCE;
	 * IMetaClass&lt;Person&gt; PERSON = factory.getMetaClass(Person.class); // see {@link IFactory}
	 * ISet&lt;Person&gt; population = factory.createSet();
	 * IBox&lt;Integer&gt; ages = population.collect(PERSON, &quot;age&quot;);
	 * IBox&lt;Boolean&gt; presence = ages.collect(a -&gt; a &lt; 18);
	 * IBox&lt;Person&gt; minors = population.select(presence);
	 * </pre>
	 * 
	 * Adding a new person in <code>population</code> results in the following successive mutations:
	 * <p>
	 * <ol>
	 * <li>His age is added in <code>ages</code>.
	 * <li>A boolean is added in <code>presence</code>.
	 * <li>Operation select observes <b>only</b> vector <code>presence</code> to avoid a double notification since both
	 * <code>population</code> and <code>presence</code>, which may lead to an inconsistent side effect performed by the
	 * operation.
	 * </ol>
	 * <p>
	 * Consequently to point 3, this active operation must only be used when the presence vector in computed from this
	 * box. However, selecting elements independently of their containing box sounds useless.
	 * <p>
	 * Although this select operation is bidirectional, this feature must be used carefully since the operation is
	 * always used jointly to collect operation, as the previous example illustrates. Adding a minor in box
	 * <code>minors</code> goes up to box <code>ages</code> that restricts its bidirectionaly to singleton box result,
	 * which is not the case here.
	 * 
	 * @param selector
	 *            predicate used to select elements from this box
	 * @return
	 *         a box that contains the elements of this box transformed by the specified collector function
	 * @see #collect(IUnaryFunction)
	 */
	IBox<E> selectMutable(IBox<Boolean> selector);



	// Zip operations

	/**
	 * Creates and return a box contains paired elements of this box and a specified box.
	 * <p>
	 * The following example gives the principle of operation zip:
	 * 
	 * <pre>
	 * ISequence&lt;Integer&gt; integers = factory.createSequence(1, 2, 3);
	 * ISequence&lt;Boolean&gt; odds = factory.createSequence(true, false, true);
	 * IBox&lt;IPair&lt;Integer, Boolean&gt;&gt; zipBox = leftBox.zip(rightBox);
	 * assert (zipBox.toString().equals(&quot;seq((1, true), (2, false), (3, true))&quot;));
	 * </pre>
	 * 
	 * As zip is a binary operation, temporal alignments of the paired elements made lead to temporal inconsistencies.
	 * Such inconsistencies are avoid by specifying whether this left box depends on that right box.
	 * <p>
	 * The operation is bidirectional, meaning that adding a pair of left and right elements adds the left element to
	 * this box, and the right element to that box.
	 * 
	 * @param that
	 *            right box to be zipped with this left box
	 * @param leftRightDependency
	 *            specifies whether this left box depends on that right box
	 * @return a box contains paired left and right elements of this left box and that right box
	 */
	<F> IBox<IPair<E, F>> zip(IBox<F> that, boolean leftRightDependency);

	/**
	 * Creates and returns a box that contains elements of this box and a specified box transformed by the specified
	 * zipper binary function.
	 * <p>
	 * The following example gives the principle of operation zip with:
	 * 
	 * <pre>
	 * ISequence&lt;Integer&gt; odds = factory.createSequence(1, 3, 5);
	 * ISequence&lt;Integer&gt; evens = factory.createSequence(2, 4, 6, 8);
	 * IBox&lt;Integer&gt; sums = odds.zipWith(evens, (i1, i2) -&gt; i1 + i2);
	 * assert (sums.sameAs(createSequence(3, 7, 11)));
	 * </pre>
	 * 
	 * @param that
	 *            box containing elements to be paired then transformed
	 * @param zipper
	 *            binary function used to transformed the paired elements of this box and that box
	 * @return a box that contains elements of this box and a specified box transformed by the specified
	 *         zipper binary function
	 */
	<F, R> IBox<R> zipWith(IBox<F> that, IBinaryFunction<E, F, R> zipper);

	/**
	 * Creates and returns a box that contains elements of this box and a specified box transformed by the specified
	 * binary zipper function, providing bidirectionality through the specified unzipper.
	 * <p>
	 * This operation is similar to {@link #zipWith(IBox, IBinaryFunction)} but provided bidirectionality capabilities
	 * based on the unzipper unary function that returns a pair of elements for an element of the result box.
	 * 
	 * @param that
	 *            box containing elements to be paired then transformed
	 * @param leftRightDependency
	 *            specifies whether this left box depends on that right box
	 * @param zipper
	 *            binary function used to transformed the paired elements of this box and that box
	 * @param unzipper
	 *            unary function that returns a pair of elements for an element of the result box
	 * 
	 * @return a box that contains elements of this box and a specified box transformed by the specified
	 *         binary zipper function
	 */
	<F, R> IBox<R> zipWith(IBox<F> that, boolean leftRightDependency, IBinaryFunction<E, F, R> zipper, IUnaryFunction<R, IPair<E, F>> unzipper);


	// Conversion operations

	/**
	 * Converts this box to a box containing all elements of this box excluding duplicates.
	 * <p>
	 * The returned box has the same constraints that this box, exception uniqueness (which is true).
	 * <p>
	 * This operation is equivalent to OCL operation <code>asSet</code> if this box is not ordered, or operation
	 * <code>asOrderedSet</code> otherwise.
	 * <p>
	 * If this box is already a unique box, the operation returns <code>this</code>, otherwise a new box is created.
	 * <p>
	 * This operation is bidirectional.
	 * 
	 * @return a box that contains all elements of this box excluding duplicates, or this this box is already a unique
	 *         box
	 */
	IBox<E> distinct();

	/**
	 * Converts this box to an option box containing the first element of this box if not empty.
	 * <p>
	 * This operation can be considered as equivalent to OCL expression <code>Set(first())</code>.
	 * <p>
	 * If this box is already an option box, the operation returns <code>this</code>, otherwise a new box is created.
	 * <p>
	 * This operation is bidirectional.
	 * 
	 * @return a box containing at the first element of this box if not empty
	 */
	IOption<E> asOption();

	/**
	 * Converts this box to a one box containing at the first element of this box if not empty, or a default value
	 * otherwise.
	 * <p>
	 * Since one box type is specific to AOF, it jas no equivalent in OCL.
	 * <p>
	 * If this box is already a one box, and if the default elements are equals, the operation returns <code>this</code>
	 * , otherwise a new box is created.
	 * <p>
	 * This operation is bidirectional.
	 * 
	 * @return a one box containing at the first element of this box if not empty, or a default value
	 *         otherwise
	 */
	IOne<E> asOne(E defaultElement);

	/**
	 * Converts this box to a sequence box containing all elements of this box respecting its internal order.
	 * <p>
	 * This operation is the same than OCL function <code>asSequence</code>.
	 * <p>
	 * If this box is already a sequence, the operation returns <code>this</code>, otherwise a new box is created.
	 * <p>
	 * This operation is bidirectional.
	 * 
	 * @return a sequence box containing all elements of this box respecting its internal order
	 */
	ISequence<E> asSequence();

	/**
	 * Converts this box to a bag box containing all elements of this box.
	 * <p>
	 * This operation is the same than OCL function <code>asBag</code>.
	 * <p>
	 * If this box is already a bag, the operation returns <code>this</code>, otherwise a new box is created.
	 * <p>
	 * This operation is bidirectional.
	 * 
	 * @return a bag box containing all elements of this box respecting its internal order
	 */
	IBag<E> asBag();

	/**
	 * Converts this box to an ordered set box containing all elements of this box except duplicates, and respecting its
	 * internal
	 * order.
	 * <p>
	 * This operation is the same than OCL function <code>asOrderedSet</code>.
	 * <p>
	 * If this box is already an ordered set, the operation returns <code>this</code>, otherwise a new box is created.
	 * <p>
	 * This operation is bidirectional.
	 * 
	 * @return an an ordered set box containing all elements of this box except duplicates, and respecting its internal
	 *         order
	 */
	IOrderedSet<E> asOrderedSet();

	/**
	 * Converts this box to an ordered set box containing all elements of this box except duplicates.
	 * <p>
	 * This operation is the same than OCL function <code>asOrderedSet</code>.
	 * <p>
	 * If this box is already an ordered set, the operation returns <code>this</code>, otherwise a new box is created.
	 * <p>
	 * This operation is bidirectional.
	 * 
	 * @return an ordered set box containing all elements of this box except duplicates
	 */
	ISet<E> asSet();

	/**
	 * Converts this box to a box satisfying the specified constraints and containing all elements of this box, except
	 * duplicates if the constraints implies uniqueness.
	 * <p>
	 * If this box already matches the specified constraints, the operation returns <code>this</code>, otherwise a new
	 * box is created.
	 * <p>
	 * This operation is bidirectional.
	 * 
	 * @return a box satisfying the specified constraints and containing all elements of this box, except
	 *         duplicates if the constraints implies uniqueness
	 */
	IBox<E> asBox(IConstraints constraints);

	// Math operations

	/**
	 * Creates and returns a box containing all elements of this box followed by all elements of the specified box.
	 * <p>
	 * This operations preserves ordered and allows duplicates, independently from this and that unique constraints.
	 * <p>
	 * Current version is unidirectional.
	 * 
	 * @param that
	 *            box to be concatenated with this box
	 * @return a box containing all elements of this box followed by all elements of the specified box
	 */
	IBox<E> concat(IBox<E> that);

	/**
	 * Creates and returns a box containing all elements of this box followed by all elements of the specified box, but
	 * without duplicates.
	 * <p>
	 * This operations is strictly equivalent to <code>concat(that).distinct()</code>.
	 * <p>
	 * It is analogous to OCL function <code>union</code> but has a different returned type, as the following
	 * equivalence illustrates.
	 * <p>
	 * Current version is unidirectional.
	 * 
	 * @param that
	 *            box to be concatenated with this box
	 * @return a box containing all elements of this box followed by all elements of the specified box
	 */
	IBox<E> union(IBox<E> that);


	// Default empty boxes

	/**
	 * Defines an empty option box.
	 * <p>
	 * It can can be used by collector function for providing the option type.
	 * 
	 * @see #collectMutable(IUnaryFunction)
	 */
	IOption<Object> OPTION = AOFFactory.INSTANCE.createOption();

	/**
	 * Defines a one box containing the default null value.
	 * <p>
	 * It can can be used by collector function for providing the one type.
	 * 
	 * @see #collectMutable(IUnaryFunction)
	 */
	IOne<Object> ONE = AOFFactory.INSTANCE.createOne(null);

	/**
	 * Defines an empty set box.
	 * <p>
	 * It can can be used by collector function for providing the set type.
	 * 
	 * @see #collectMutable(IUnaryFunction)
	 */
	ISet<Object> SET = AOFFactory.INSTANCE.createSet();

	/**
	 * Defines an empty ordered-set box.
	 * <p>
	 * It can can be used by collector function for providing the ordered-set type.
	 * 
	 * @see #collectMutable(IUnaryFunction)
	 */
	IOrderedSet<Object> ORDERED_SET = AOFFactory.INSTANCE.createOrderedSet();

	/**
	 * Defines an empty sequence box.
	 * <p>
	 * It can can be used by collector function for providing the sequence type.
	 * 
	 * @see #collectMutable(IUnaryFunction)
	 */
	ISequence<Object> SEQUENCE = AOFFactory.INSTANCE.createSequence();

	/**
	 * Defines an empty bag box.
	 * <p>
	 * It can can be used by collector function for providing the bag type.
	 * 
	 * @see #collectMutable(IUnaryFunction)
	 */
	IBag<Object> BAG = AOFFactory.INSTANCE.createBag();

}
