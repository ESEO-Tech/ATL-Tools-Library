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

import java.util.Iterator;

import org.eclipse.papyrus.aof.core.AOFFactory;
import org.eclipse.papyrus.aof.core.IBag;
import org.eclipse.papyrus.aof.core.IBinaryFunction;
import org.eclipse.papyrus.aof.core.IBinding;
import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.eclipse.papyrus.aof.core.IFactory;
import org.eclipse.papyrus.aof.core.IMetaClass;
import org.eclipse.papyrus.aof.core.IObserver;
import org.eclipse.papyrus.aof.core.IOne;
import org.eclipse.papyrus.aof.core.IOption;
import org.eclipse.papyrus.aof.core.IOrderedSet;
import org.eclipse.papyrus.aof.core.IPair;
import org.eclipse.papyrus.aof.core.ISequence;
import org.eclipse.papyrus.aof.core.ISet;
import org.eclipse.papyrus.aof.core.ISingleton;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.eclipse.papyrus.aof.core.impl.operation.Bind;
import org.eclipse.papyrus.aof.core.impl.operation.CollectBijective;
import org.eclipse.papyrus.aof.core.impl.operation.CollectBox;
import org.eclipse.papyrus.aof.core.impl.operation.CollectSurjective;
import org.eclipse.papyrus.aof.core.impl.operation.CollectTo;
import org.eclipse.papyrus.aof.core.impl.operation.CollectWithState;
import org.eclipse.papyrus.aof.core.impl.operation.Concat;
import org.eclipse.papyrus.aof.core.impl.operation.Copy;
import org.eclipse.papyrus.aof.core.impl.operation.Distinct;
import org.eclipse.papyrus.aof.core.impl.operation.First;
import org.eclipse.papyrus.aof.core.impl.operation.Inspect;
import org.eclipse.papyrus.aof.core.impl.operation.SelectWithMutablePredicate;
import org.eclipse.papyrus.aof.core.impl.operation.SelectWithPredicate;
import org.eclipse.papyrus.aof.core.impl.operation.SelectWithPresence;
import org.eclipse.papyrus.aof.core.impl.operation.Size;
import org.eclipse.papyrus.aof.core.impl.operation.SwitchCollect;
import org.eclipse.papyrus.aof.core.impl.operation.Zip;
import org.eclipse.papyrus.aof.core.impl.operation.ZipWith;
import org.eclipse.papyrus.aof.core.impl.utils.Equality;
import org.eclipse.papyrus.aof.core.utils.Functions;

public abstract class Box<E> implements IBox<E> {

	public static IObserver<IBox<?>> factoryObserver;

	public Box() {
		if (factoryObserver != null) {
			factoryObserver.added(0, this);
		}
	}

	private BaseDelegate<E> delegate;

	protected BaseDelegate<E> getDelegate() {
		return delegate;
	}

	protected void setDelegate(BaseDelegate<E> delegate) {
		this.delegate = delegate;
		this.delegate.setDelegator(this);
	}

	// IConstraints (implemented for facility purpose only: shortcuts to getConstraint().<method>())

	@Override
	public boolean isOptional() {
		return getConstraints().isOptional();
	}

	@Override
	public boolean isSingleton() {
		return getConstraints().isSingleton();
	}

	@Override
	public boolean isOrdered() {
		return getConstraints().isOrdered();
	}

	@Override
	public boolean isUnique() {
		return getConstraints().isUnique();
	}

	@Override
	public boolean isLegal() {
		return getConstraints().isLegal();
	}

	@Override
	public boolean matches(IConstraints that) {
		return getConstraints().matches(that);
	}

	// IReadable

	@Override
	public Iterator<E> iterator() {
		return delegate.iterator();
	}

	@Override
	public E get(int index) {
		assert checkExistingIndex(index);

		return delegate.get(index);
	}

	@Override
	public int length() {
		return delegate.length();
	}

	@Override
	public int indexOf(E element) {
		return delegate.indexOf(element);
	}

	@Override
	public boolean contains(E element) {
		return delegate.contains(element);
	}

	// IWritable

	private boolean checkAddIndex(int index) {
		return (index >= 0) && (index <= length());
	}

	private boolean checkExistingIndex(int index) {
		return (index >= 0) && (index < length());
	}

	private boolean checkNoDuplicatesIfUnique(E element) {
		return !(isUnique() && contains(element));
	}

	@Override
	public void add(int index, E element) {
		assert checkAddIndex(index);
		assert checkNoDuplicatesIfUnique(element);

		delegate.add(index, element);
	}

	@Override
	public void add(E element) {
		assert checkNoDuplicatesIfUnique(element);

		delegate.add(element);
	}

	@Override
	public void removeAt(int index) {
		assert checkExistingIndex(index);

		delegate.removeAt(index);
	}

	@Override
	public void remove(E element) {
		assert contains(element);

		delegate.remove(element);
	}

	@Override
	public void set(int index, E element) {
		assert checkExistingIndex(index);
		assert !(isUnique() && (!Equality.optionalEquals(get(index), element)) && contains(element));

		delegate.set(index, element);
	}

	@Override
	public void move(int newIndex, int oldIndex) {
		assert checkExistingIndex(newIndex);
		assert checkExistingIndex(oldIndex);

		delegate.move(newIndex, oldIndex);
	}

	@Override
	public void clear() {
		delegate.clear();
	}

	// IObservable

	@Override
	public void addObserver(IObserver<E> observer) {
		delegate.addObserver(observer);
	}

	@Override
	public void removeObserver(IObserver<E> observer) {
		delegate.removeObserver(observer);
	}

	@Override
	public Iterable<IObserver<E>> getObservers() {
		return delegate.getObservers();
	}

	@Override
	public boolean isObserved() {
		return delegate.isObserved();
	}

	// IBox

	@Override
	public boolean sameAs(IBox<E> other) {
		if (other instanceof Box<?>) {
			Box<E> that = (Box<E>) other;
			if (!this.getConstraints().equals(that)) {
				return false;
			} else if (isOrdered()) {
				return this.delegate.sameAs(that.delegate);
			} else {
				return this.delegate.similarTo(that.delegate);
			}
		} else {
			return false;
		}
	}

	@Override
	public IBox<E> snapshot() {
		IBox<E> box = AOFFactory.INSTANCE.createBox(this);
		box.assign(this);
		return box;
	}

	@Override
	public void assignNoCheck(Iterable<E> iterable) {
		if (iterable == null) {
			throw new IllegalArgumentException("Cannot assign a box from a null iterator");
		}
		delegate.assignNoCheck(iterable);
	}

	@Override
	public void assign(Iterable<E> iterable) {
		if (iterable == null) {
			throw new IllegalArgumentException("Cannot assign a box from a null iterator");
		}
		delegate.assign(iterable);
	}

	@Override
	public void assign(E... elements) {
		delegate.assign(elements);
	}

	@Override
	public IBinding<E> bind(IBox<E> that) {
		return new Bind<E>(this, that).getBinding();
	}

	@Override
	public IBox<E> inspect(String label) {
		return new Inspect<E>(this, label).getResult();
	}

	@Override
	public IBox<E> inspect(String label, IUnaryFunction<? super E, String> toString) {
		return new Inspect<E>(this, label, toString).getResult();
	}

	@Override
	public IOne<Integer> size() {
		return new Size<E>(this).getResult();
	}

	@Override
	public IOne<Boolean> isEmpty() {
		return (IOne<Boolean>) size().collect(new IUnaryFunction<Integer, Boolean>() {
			@Override
			public Boolean apply(Integer element) {
				return element == 0;
			}
		});
	}

	@Override
	public IOne<Boolean> notEmpty() {
		return (IOne<Boolean>) size().collect(new IUnaryFunction<Integer, Boolean>() {
			@Override
			public Boolean apply(Integer element) {
				return element > 0;
			}
		});
	}

	@Override
	public <R> IBox<R> collect(IUnaryFunction<? super E, ? extends R> collector) {
		return new CollectSurjective<E, R>(this, collector).getResult();
	}

	@Override
	public <R> IBox<R> collect(IUnaryFunction<E, R> collector, IUnaryFunction<R, E> inverseCollector) {
		return new CollectBijective<E, R>(this, collector, inverseCollector).getResult();
	}

	@Override
	public <R, S> IBox<R> collectWithState(S defaultState, IUnaryFunction<? super E, IPair<R, S>> collector, IUnaryFunction<IPair<R, S>, ? extends E> reverseCollector) {
		return new CollectWithState<E, R, S>(this, defaultState, collector, reverseCollector).getResult();
	}

	@Override
	public <R> IBox<R> switchCollect(IUnaryFunction<? super E, IOne<Boolean>>[] conditions, IUnaryFunction<? super E, ? extends R>[] collectors, IUnaryFunction<? super E, ? extends R> defaultCollector, IUnaryFunction<? super R, ? extends E> reverseCollector) {
		return new SwitchCollect<E, R>(this, conditions, collectors, defaultCollector, reverseCollector).getResult();
	}

	@Override
	public <R> IBox<R> switchCollect(IUnaryFunction<? super E, IOne<Boolean>>[] conditions, IUnaryFunction<? super E, ? extends R>[] collectors, IUnaryFunction<? super E, ? extends R> defaultCollector) {
		return new SwitchCollect<E, R>(this, conditions, collectors, defaultCollector).getResult();
	}

	@Override
	public <R> IBox<R> collectTo(IUnaryFunction<? super E, ? extends R> collector) {
		return new CollectTo<E, R>(this, collector).getResult();
	}

	@Override
	public <R> IBox<R> collectTo(IUnaryFunction<E, R> collector, IUnaryFunction<R, E> inverseCollector) {
		return new CollectTo<E, R>(this, collector, inverseCollector).getResult();
	}

	@Override
	public <R> IBox<R> collectedFrom(IUnaryFunction<? super R, ? extends E> toCollector) {
		return new CollectBijective(this, new IUnaryFunction<R, E>() {
			@Override
			public E apply(R a) {
				return (E) CollectTo.getCache().getSource(a);
			}
		}).getResult();
	}

	@Override
	public <R> IBox<R> collectMutable(IFactory factory, Object containingClass, Object property) {
		IMetaClass<E> metaClass = factory.getMetaClass(containingClass);
		return collectMutable(metaClass, property);
	}

	@Override
	public <R> IBox<R> collectMutable(IMetaClass<E> containingClass, Object property) {
		E sourceDefault = containingClass.getDefaultInstance();
		IUnaryFunction<E, IBox<R>> accessor = containingClass.getPropertyAccessor(property);
		return new CollectBox<E, R>(this, sourceDefault, accessor).getResult();
	}

	@Override
	public <R> IBox<R> collectMutable(IUnaryFunction<? super E, ? extends IBox<R>> collector) {
		return new CollectBox<E, R>(this, null, collector).getResult();
	}

	@Override
	public IBox<E> select(IUnaryFunction<? super E, Boolean> selector) {
		return new SelectWithPredicate<E>(this, selector).getResult();
	}

	@Override
	public <C extends E> IBox<C> select(Class<C> javaClass) {
		return (IBox<C>) select(Functions.instanceOf(javaClass));
	}

	@Override
	public <C extends E> IBox<C> select(IMetaClass<C> metaClass) {
		return (IBox<C>) select(Functions.instanceOf(metaClass));
	}

	@Override
	public IBox<E> selectMutable(IBox<Boolean> selector) {
		return new SelectWithPresence<E>(this.zip(selector, true)).getResult();
	}

	@Override
	public IBox<E> selectMutable(IUnaryFunction<? super E, IOne<Boolean>> selector) {
		return new SelectWithMutablePredicate<E>(this, selector).getResult();
	}

	@Override
	public IBox<E> concat(IBox<E> that) {
		return this.concat(that, null);
	}

	public IBox<E> concat(IBox<E> that, IUnaryFunction<E, Boolean> leftSelector) {
		return new Concat<E>(this, that, leftSelector).getResult();
	}

	@Override
	public <F> IBox<IPair<E, F>> zip(IBox<F> that, boolean leftRightDependency) {
		return new Zip<E, F>(this, that, leftRightDependency).getResult();
	}

	@Override
	public <F, R> IBox<R> zipWith(IBox<F> that, IBinaryFunction<E, F, R> zipper) {
		return this.zipWith(that, false, zipper, null);
	}

	@Override
	public <F, R> IBox<R> zipWith(IBox<F> that, boolean leftRightDependency, IBinaryFunction<E, F, R> zipper, IUnaryFunction<R, IPair<E, F>> unzipper) {
		return new ZipWith<E, F, R>(this, that, leftRightDependency, zipper, unzipper).getResult();
	}

	@Override
	public IBox<E> distinct() {
		if (this.isUnique()) {
			return this;
		} else {
			return new Distinct<E>(this).getResult();
		}
	}

	@Override
	public IBox<E> union(IBox<E> that) {
		return this.concat(that).distinct();
	}

	@Override
	public IOption<E> asOption() {
		if (this instanceof IOption<?>) {
			return (IOption<E>) this;
		} else {
			IOption<E> option = AOFFactory.INSTANCE.createOption();
			new First<E>(this, option, false);
			return option;
		}
	}

	@Override
	public IOne<E> asOne(E defaultElement) {
		if (this instanceof IOne<?>) {
			IOne<E> one = (IOne<E>) this;
			if (Equality.optionalEquals(one.getDefaultElement(), defaultElement)) {
				return (IOne<E>) this;
			}
		}
		IOne<E> one = AOFFactory.INSTANCE.createOne(defaultElement);
		new First<E>(this, one, false);
		return one;
	}

	@Override
	public ISequence<E> asSequence() {
		if (this instanceof ISequence<?>) {
			return (ISequence<E>) this;
		} else {
			ISequence<E> that = AOFFactory.INSTANCE.createSequence();
			if (this.isSingleton()) {
				new First<E>(that, (ISingleton<E>) this, true);
			} else if (this.isUnique()) {
				new Distinct<E>(that, this, true);
			} else {
				new Copy<E>(this, that);
			}
			return that;
		}
	}

	@Override
	public IBag<E> asBag() {
		if (this instanceof IBag<?>) {
			return (IBag<E>) this;
		} else {
			IBag<E> that = AOFFactory.INSTANCE.createBag();
			if (this.isSingleton()) {
				new First<E>(that, (ISingleton<E>) this, true);
			} else if (this.isUnique()) {
				new Distinct<E>(that, this, true);
			} else {
				new Copy<E>(this, that);
			}
			return that;
		}
	}

	@Override
	public IOrderedSet<E> asOrderedSet() {
		if (this instanceof IOrderedSet<?>) {
			return (IOrderedSet<E>) this;
		} else {
			IOrderedSet<E> that = AOFFactory.INSTANCE.createOrderedSet();
			if (this.isSingleton()) {
				new First<E>(that, (ISingleton<E>) this, true);
			} else if (this.isUnique()) {
				new Copy<E>(this, that);
			} else {
				new Distinct<E>(this, that, false);
			}
			return that;
		}
	}

	@Override
	public ISet<E> asSet() {
		if (this instanceof ISet<?>) {
			return (ISet<E>) this;
		} else {
			ISet<E> that = AOFFactory.INSTANCE.createSet();
			if (this.isSingleton()) {
				new First<E>(that, (ISingleton<E>) this, true);
			} else if (this.isUnique()) {
				new Copy<E>(this, that);
			} else {
				new Distinct<E>(this, that, false);
			}
			return that;
		}
	}

	// warning: in case of a ONE constraints, the default element of the
	// returned one box is null
	@Override
	public IBox<E> asBox(IConstraints constraints) {
		if (!constraints.isLegal()) {
			throw new IllegalStateException("Illegal constraints " + constraints);
		}
		if (constraints.matches(OPTION)) {
			return asOption();
		} else if (constraints.matches(ONE)) {
			return asOne(null);
		} else if (constraints.matches(ORDERED_SET)) {
			return asOrderedSet();
		} else if (constraints.matches(SET)) {
			return asSet();
		} else if (constraints.matches(SEQUENCE)) {
			return asSequence();
		} else { // constraints.matches(BAG)
			return asBag();
		}
	}

	// Object

	@Override
	public String toString() {
		return Inspect.toString(this, null);
	}

}
