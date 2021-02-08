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
package org.eclipse.papyrus.aof.emf.impl;

import java.util.Iterator;
import java.util.List;

import org.eclipse.emf.common.notify.Adapter;
import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.common.notify.impl.AdapterImpl;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.papyrus.aof.core.AOFFactory;
import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IObserver;
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver;

public class ListFeatureDelegate<E> extends FeatureDelegate<E> {

	private EList<E> list;

	// Proxy between this EMF delegate and an AOF delegate
	// - this delegate captures EMF mutation events through the NoticationAdapter inner class, and updates the AOF delegate
	// thus emulating a copy of this EMF delegate => it is thus a double delegation
	// - the AOF delegate is observed by registered observers while this EMF delegate is not directly observered
	// end of javadoc
	// note: cannot use aof.ListDelegate since it requires a box delegator that cannot be provided during construction
	private IBox<E> proxyBox;

	public ListFeatureDelegate(EObject object, EStructuralFeature feature) {
		super(object, feature);
		list = (EList<E>) object.eGet(feature);
		proxyBox = AOFFactory.INSTANCE.createBox(this);
		proxyBox.assignNoCheck(list);
		proxyBox.addObserver(new ReverseAdapter());
	}

	// Iterable

	@Override
	public Iterator<E> iterator() {
		return proxyBox.iterator();
	}

	// IReadable

	@Override
	public E get(int index) {
		return proxyBox.get(index);
	}

	@Override
	public int length() {
		return proxyBox.length();
	}

	@Override
	public int indexOf(E element) {
		return proxyBox.indexOf(element);
	}

	@Override
	public boolean contains(E element) {
		return proxyBox.contains(element);
	}

	// IWritable

	@Override
	public void add(E element) {
		proxyBox.add(element);
	}

	@Override
	public void add(int index, E element) {
		proxyBox.add(index, element);
	}

	@Override
	public void remove(E element) {
		proxyBox.remove(element);
	}

	@Override
	public void removeAt(int index) {
		proxyBox.removeAt(index);
	}

	@Override
	public void clear() {
		proxyBox.clear();
	}

	@Override
	public void set(int index, E element) {
		proxyBox.set(index, element);
	}

	@Override
	public void move(int newIndex, int oldIndex) {
		proxyBox.move(newIndex, oldIndex);
	}

	// IObservable

	private Adapter adapter;

	@Override
	public void addObserver(IObserver<E> observer) {
		proxyBox.addObserver(observer);
		if (adapter == null) {
			adapter = new ForwardAdapter();
			getObject().eAdapters().add(adapter);
		}
	}

	@Override
	public void removeObserver(IObserver<E> observer) {
		proxyBox.removeObserver(observer);
		if (!proxyBox.isObserved()) {
			getObject().eAdapters().remove(adapter);
		}
	}

	@Override
	public Iterable<IObserver<E>> getObservers() {
		return proxyBox.getObservers();
	}

	@Override
	public boolean isObserved() {
		return proxyBox.isObserved();
	}

	private boolean silentForward;

	private boolean silentReverse;

	private class ForwardAdapter extends AdapterImpl {
		@Override
		public void notifyChanged(Notification notification) {
			if (getFeature() != notification.getFeature()) {
				return;
			}

			if (silentForward) {
				return;
			}
			silentReverse = true;
			switch (notification.getEventType()) {
			case Notification.ADD:
				proxyBox.add(notification.getPosition(), (E) notification.getNewValue());
				break;
			case Notification.ADD_MANY: {
				// to be tested
				int i = notification.getPosition();
				for (E element : (List<E>) notification.getNewValue()) {
					proxyBox.add(i++, element);
				}
				break;
			}
			case Notification.REMOVE:
				proxyBox.removeAt(notification.getPosition());
				break;
			case Notification.REMOVE_MANY: {
				int[] indices = (int[]) notification.getNewValue();
				if (indices == null) {
					proxyBox.clear();
				} else {
					// to be tested
					for (int index : indices) {
						proxyBox.removeAt(index);
					}
				}
				break;
			}
			case Notification.MOVE:
				proxyBox.move(notification.getPosition(), (Integer) notification.getOldValue());
				break;
			case Notification.SET:
				if (getFeature().isMany()) {
					proxyBox.set(notification.getPosition(), (E) notification.getNewValue());
				}
				break;
			case Notification.UNSET:
				throw new UnsupportedOperationException("EMF notification " + notification + " can never occur on a list-based feature");
			default: // REMOVING_ADAPTER | RESOLVE
			}
			silentReverse = false;
		}
	}

	private class ReverseAdapter extends DefaultObserver<E> {

		@Override
		public void added(int index, E element) {
			if (silentReverse) {
				return;
			}
			silentForward = true;
			list.add(index, element);
			silentForward = false;
		}

		@Override
		public void removed(int index, E element) {
			if (silentReverse) {
				return;
			}
			silentForward = true;
			list.remove(index);
			silentForward = false;
		}

		@Override
		public void replaced(int index, E newElement, E oldElement) {
			if (silentReverse) {
				return;
			}
			silentForward = true;
			list.set(index, newElement);
			silentForward = false;
		}

		@Override
		public void moved(int newIndex, int oldIndex, E element) {
			if (silentReverse) {
				return;
			}
			silentForward = true;
			list.move(newIndex, oldIndex);
			silentForward = false;
		}
	}
}
