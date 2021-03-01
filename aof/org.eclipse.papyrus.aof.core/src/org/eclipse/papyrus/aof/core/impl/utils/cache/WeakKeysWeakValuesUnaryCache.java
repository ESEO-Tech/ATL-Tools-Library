/*******************************************************************************
 *  Copyright (c) 2015 ESEO.
 *  All rights reserved. This program and the accompanying materials
 *  are made available under the terms of the Eclipse Public License v1.0
 *  which accompanies this distribution, and is available at
 *  http://www.eclipse.org/legal/epl-v10.html
 *
 *  Contributors:
 *     Frédéric Jouault - initial API and implementation
 *******************************************************************************/
package org.eclipse.papyrus.aof.core.impl.utils.cache;

import java.lang.ref.WeakReference;
import java.util.Map;
import java.util.WeakHashMap;

public class WeakKeysWeakValuesUnaryCache<K, V> implements IUnaryCache<K, V> {
	private Map<K, WeakReference<V>> cache = new WeakHashMap<K, WeakReference<V>>();

	@Override
	public V get(K key) {
		WeakReference<V> ret = cache.get(key);
		return ret == null ? null : ret.get();
	}

	@Override
	public void put(K key, V value) {
		cache.put(key, new WeakReference<V>(value));
	}
}