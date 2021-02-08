/****************************************************************
 *  Copyright (C) 2020 ESEO, Université d'Angers 
 *
 *  This program and the accompanying materials are made
 *  available under the terms of the Eclipse Public License 2.0
 *  which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 *  Contributors:
 *    - Frédéric Jouault
 *    - Théo Le Calvar
 *
 *  version 1.0
 *
 *  SPDX-License-Identifier: EPL-2.0
 ****************************************************************/

package fr.eseo.aof.extensions;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.emf.common.notify.Adapter;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IOne;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.eclipse.papyrus.aof.core.impl.operation.Operation;
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver;
import org.eclipse.papyrus.aof.core.impl.utils.Equality;

// WARNING: result order not deterministic (result box & nestedBoxes)
// actually first run keeps order, but propagation does not do it yet
public class SelectBy<E, K> extends Operation<E> {

	private final IOne<K> keyBox;
	private final IUnaryFunction<E, IOne<K>> collector;

	private final Map<K, List<E>> cache = new HashMap<K, List<E>>();

	public SelectBy(IBox<E> sourceBox, IOne<K> keyBox, IUnaryFunction<E, IOne<K>> collector) {
		this.keyBox = keyBox;
		this.collector = collector;

		for(E e : sourceBox) {
			processElement(e);
		}

		registerObservation(sourceBox, new SourceObserver());
		registerObservation(keyBox, new KeyBoxObserver());
	}

	private List<E> getGroup(K key) {
		List<E> group = cache.get(key);
		if(group == null) {
			group = new ArrayList<E>();
			cache.put(key, group);
		}
		return group;
	}

	// rename to show it is an add
	private void processElement(E element) {
		if(element != null) {	// TODO: use a select before to avoid this check?
			IOne<K> elementKeyBox = collector.apply(element);
			K elementKey = elementKeyBox.get();
			getGroup(elementKey).add(element);
			if(Equality.optionalEquals(keyBox.get(), elementKey)) {
				getResult().add(element);
			}
			registerObservation(elementKeyBox, new InnerBoxObserver(element));
		}
	}

	@Override
	public boolean isOptional() {
		return true;
	}

	@Override
	public boolean isSingleton() {
		return false;
	}

	@Override
	public boolean isOrdered() {
		return false;
	}

	@Override
	public boolean isUnique() {
		return true;	// TODO: sourceBox.isUnique?
	}

	@Override
	public E getResultDefautElement() {
		return null;
	}

	private class SourceObserver extends DefaultObserver<E> {
		@Override
		public void added(int index, E element) {
			processElement(element);
		}

		@Override
		public void removed(int index, E element) {
			if(element != null) {	// same comment as in processElement
				IOne<K> elementKeyBox = collector.apply(element);
				K elementKey = elementKeyBox.get();
				List<E> group = cache.get(elementKey);

				group.remove(element);
				// TODO: remove group if empty?
				if(Equality.optionalEquals(keyBox.get(), elementKey)) {
					getResult().remove(element);
				}
			}
		}

		@Override
		public void replaced(int index, E newElement, E oldElement) {
			// could be optimized if same group (or if same element)
			removed(index, oldElement);
			added(index, newElement);
		}

		@Override
		public void moved(int newIndex, int oldIndex, E element) {
			// nothing to do
		}
	}

	private class InnerBoxObserver extends DefaultObserver<K> {
		private final E element;

		public InnerBoxObserver(E element) {
			this.element = element;
		}

		@Override
		public void added(int index, K element) {
			throw new IllegalStateException();
		}

		@Override
		public void removed(int index, K element) {
			throw new IllegalStateException();
		}

		@Override
		public void replaced(int index, K newKey, K oldKey) {
			if(!Equality.optionalEquals(newKey, oldKey)) {
				cache.get(oldKey).remove(element);
				getGroup(newKey).add(element);
				if(Equality.optionalEquals(keyBox.get(), oldKey)) {
					getResult().remove(element);
					// TODO: remove empty groups
				} else if(Equality.optionalEquals(keyBox.get(), newKey)) {
					getResult().add(element);
				}
			}
		}

		@Override
		public void moved(int newIndex, int oldIndex, K element) {
			// TODO: do nothing instead of throwing?
			throw new IllegalStateException();
		}
	}

	private class KeyBoxObserver extends DefaultObserver<K> {
		@Override
		public void added(int index, K element) {
			throw new IllegalStateException();
		}

		@Override
		public void removed(int index, K element) {
			throw new IllegalStateException();
		}

		@Override
		public void replaced(int index, K newKey, K oldKey) {
			if(!Equality.optionalEquals(newKey, oldKey)) {
				getResult().clear();
				List<E> group = cache.get(newKey);
				if(group != null) {
					for(E element : group) {
						getResult().add(element);
					}
				}
			}
		}

		@Override
		public void moved(int newIndex, int oldIndex, K element) {
			// TODO: do nothing instead of throwing?
			throw new IllegalStateException();
		}
	}
}
