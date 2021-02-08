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

public class WeakKeysWeakValuesBinaryCache<K1, K2, V> implements IBinaryCache<K1, K2, V> {
	private Map<K1, Map<K2, WeakReference<V>>> cache = new WeakHashMap<K1, Map<K2,WeakReference<V>>>();

	@Override
	public V get(K1 key1, K2 key2) {
		Map<K2, WeakReference<V>> cache2 = cache.get(key1);
		if(cache2 == null) {
			return null;
		} else {
			WeakReference<V> ret = cache2.get(key2);
			return ret == null ? null : ret.get();
		}
	}

	@Override
	public void put(K1 key1, K2 key2, V value) {
		Map<K2, WeakReference<V>> cache2 = cache.get(key1);
		if(cache2 == null) {
			cache2 = new WeakHashMap<K2, WeakReference<V>>();
			cache.put(key1, cache2);
		}
		cache2.put(key2, new WeakReference<V>(value));
	}
}