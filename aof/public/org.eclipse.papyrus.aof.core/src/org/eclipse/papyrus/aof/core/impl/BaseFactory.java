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

import java.util.Arrays;

import org.eclipse.papyrus.aof.core.IBag;
import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.eclipse.papyrus.aof.core.IFactory;
import org.eclipse.papyrus.aof.core.IOne;
import org.eclipse.papyrus.aof.core.IOption;
import org.eclipse.papyrus.aof.core.IOrderedSet;
import org.eclipse.papyrus.aof.core.IPair;
import org.eclipse.papyrus.aof.core.ISequence;
import org.eclipse.papyrus.aof.core.ISet;

public abstract class BaseFactory implements IFactory {


	public <E> IBox<E> createBox(IConstraints constraints, BaseDelegate<E> delegate) {
		if (!constraints.isLegal()) {
			throw new IllegalStateException("Invalid constraints " + constraints);
		} else {
			Box<E> box;
			if (constraints.matches(IConstraints.OPTION)) {
				box = new Option<E>();
			} else if (constraints.matches(IConstraints.ONE)) {
				box = new One<E>();
			} else if (constraints.matches(IConstraints.ORDERED_SET)) {
				box = new OrderedSet<E>();
			} else if (constraints.matches(IConstraints.SEQUENCE)) {
				box = new Sequence<E>();
			} else if (constraints.matches(IConstraints.SET)) {
				box = new Set<E>();
			} else if (constraints.matches(IConstraints.BAG)) {
				box = new Bag<E>();
			} else {
				throw new IllegalStateException("Invalid constraints " + constraints);
			}
			box.setDelegate(delegate);
			return box;
		}
	}

	@Override
	public <E> IBox<E> createBox(IConstraints constraints, E... elements) {
		IBox<E> box = createBox(constraints, new ListDelegate<E>());
		if (box.matches(IConstraints.ONE)) {
			// if elements is empty => null default value
			// else: default value = the first of the list
			IOne<E> one = (IOne<E>) box;
			E defaultElement = (elements.length > 0) ? elements[0] : null;
			one.clear(defaultElement);
		}
		box.assign(Arrays.asList(elements));
		return box;
	}

	@Override
	public <E> IOption<E> createOption() {
		return (IOption<E>) createBox(IConstraints.OPTION);
	}

	@Override
	public <E> IOption<E> createOption(E element) {
		return (IOption<E>) createBox(IConstraints.OPTION, element);
	}

	@Override
	public <E> IOne<E> createOne(E defaultElement) {
		return (IOne<E>) createBox(IConstraints.ONE, defaultElement);
	}

	@Override
	public <E> IOne<E> createOne(E defaultElement, E initialAlement) {
		return (IOne<E>) createBox(IConstraints.ONE, defaultElement, initialAlement);
	}

	@Override
	public <E> ISet<E> createSet(E... elements) {
		return (ISet<E>) createBox(IConstraints.SET, elements);
	}

	@Override
	public <E> IOrderedSet<E> createOrderedSet(E... elements) {
		return (IOrderedSet<E>) createBox(IConstraints.ORDERED_SET, elements);
	}

	@Override
	public <E> ISequence<E> createSequence(E... elements) {
		return (ISequence<E>) createBox(IConstraints.SEQUENCE, elements);
	}

	@Override
	public <E> IBag<E> createBag(E... elements) {
		return (IBag<E>) createBox(IConstraints.BAG, elements);
	}

	@Override
	public <L, R> IPair<L, R> createPair(L left, R right) {
		return new Pair<L, R>(left, right);
	}

}
