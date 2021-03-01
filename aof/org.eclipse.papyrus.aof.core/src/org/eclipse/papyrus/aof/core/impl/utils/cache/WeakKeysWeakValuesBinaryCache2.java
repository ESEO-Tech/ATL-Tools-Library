/*******************************************************************************
 *  Copyright (c) 2015 ESEO.
 *  All rights reserved. This program and the accompanying materials
 *  are made available under the terms of the Eclipse Public License v1.0
 *  which accompanies this distribution, and is available at
 *  http://www.eclipse.org/legal/epl-v10.html
 *
 *  Contributors:
 *     Frederic Jouault - initial API and implementation
 *******************************************************************************/
package org.eclipse.papyrus.aof.core.impl.utils.cache;

import java.lang.ref.WeakReference;
import java.util.Map;
import java.util.WeakHashMap;

import org.eclipse.papyrus.aof.core.AOFFactory;
import org.eclipse.papyrus.aof.core.IPair;

public class WeakKeysWeakValuesBinaryCache2<K1, K2, V> implements IBinaryCache<K1, K2, V> {
	private Map<IPair<K1, K2>, WeakReference<V>> cache = new WeakHashMap<IPair<K1, K2>, WeakReference<V>>();

	public WeakKeysWeakValuesBinaryCache2() {
		throw new RuntimeException("should not be used because the Pair may be collected before the keys are collectable (i.e., while they are still used)");
	}

	@Override
	public V get(K1 key1, K2 key2) {
		WeakReference<V> ret = cache.get(AOFFactory.INSTANCE.createPair(key1, key2));
		return ret == null ? null : ret.get();
	}

	@Override
	public void put(K1 key1, K2 key2, V value) {
		cache.put(AOFFactory.INSTANCE.createPair(key1, key2), new WeakReference<V>(value));
	}
}