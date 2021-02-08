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

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.eclipse.emf.common.notify.Adapter;
import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.common.notify.impl.AdapterImpl;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.papyrus.aof.core.IObserver;

public class GetSetFeatureDelegate<E> extends FeatureDelegate<E> {

	public GetSetFeatureDelegate(EObject object, EStructuralFeature feature) {
		super(object, feature);
	}

	// Iterable

	@Override
	public Iterator<E> iterator() {
		List<E> singleton = new ArrayList<E>();
		if (length() == 1) {
			singleton.add((E) getObject().eGet(getFeature()));
		}
		return singleton.iterator();
	}

	// IReadable

	@Override
	public E get(int index) {
		return (E) getObject().eGet(getFeature());
	}

	// All EMF singleton features behave as Ones with possible null value
	// @see FeatureDelagate.isOptional
	@Override
	public int length() {
		return 1; // (object.eIsSet(feature) || feature.isRequired()) ? 1 : 0;
	}

	@Override
	public int indexOf(E element) {
		Object v = getObject().eGet(getFeature());
		if (v == null) {
			return element == null ? 0 : -1;
		} else {
			return v.equals(element) ? 0 : -1;
		}
	}

	// IWritable

	@Override
	public void add(int index, E element) {
		getObject().eSet(getFeature(), element);
	}

	@Override
	public void removeAt(int index) {
		getObject().eUnset(getFeature());
	}

	@Override
	public void remove(E element) {
		getObject().eUnset(getFeature());
	}

	@Override
	public void set(int index, E element) {
		add(index, element);
	}

	@Override
	public void move(int newIndex, int oldIndex) {
		// do nothing since moving inside a singleton is a nonsense
	}

	// IObservable

	private Adapter adapter;

	@Override
	public void addObserver(IObserver<E> observer) {
		super.addObserver(observer);
		if (adapter == null) {
			adapter = new NotificationAdapter();
			getObject().eAdapters().add(adapter);
		}
	}

	@Override
	public void removeObserver(IObserver<E> observer) {
		super.removeObserver(observer);
		if (!isObserved()) {
			getObject().eAdapters().remove(adapter);
			adapter = null;
		}
	}

	private class NotificationAdapter extends AdapterImpl {

		@Override
		public void notifyChanged(Notification notification) {
			for (IObserver<E> observer : getObservers()) {
				if (!observer.isDisabled() && (getFeature() == notification.getFeature())) {
					switch (notification.getEventType()) {
					case Notification.ADD:
						observer.added(notification.getPosition(), (E) notification.getNewValue());
						break;
					case Notification.REMOVE:
						observer.removed(notification.getPosition(), (E) notification.getOldValue());
						break;
					case Notification.SET:
						if (notification.wasSet() || !isOptional()) {
							observer.replaced(0, (E) notification.getNewValue(), (E) notification.getOldValue());
						} else {
							observer.added(0, (E) notification.getNewValue());
						}
						break;
					case Notification.UNSET:
						observer.removed(0, (E) notification.getOldValue());
						break;
					case Notification.ADD_MANY:
					case Notification.REMOVE_MANY:
					case Notification.MOVE:
						throw new UnsupportedOperationException("EMF notification " + notification + " can never occur on a list-based feature");
					default: // REMOVING_ADAPTER | RESOLVE
					}
				}
			}
		}

	}

}
