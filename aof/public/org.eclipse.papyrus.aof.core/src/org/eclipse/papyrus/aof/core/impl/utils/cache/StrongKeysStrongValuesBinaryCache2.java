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

import java.util.HashMap;
import java.util.Map;

import org.eclipse.papyrus.aof.core.AOFFactory;
import org.eclipse.papyrus.aof.core.IPair;

public class StrongKeysStrongValuesBinaryCache2<K1, K2, V> implements IBinaryCache<K1, K2, V> {
	private Map<IPair<K1, K2>, V> cache = new HashMap<IPair<K1, K2>, V>();

	@Override
	public V get(K1 key1, K2 key2) {
		return cache.get(AOFFactory.INSTANCE.createPair(key1, key2));
	}

	@Override
	public void put(K1 key1, K2 key2, V value) {
		IPair<K1, K2> key = AOFFactory.INSTANCE.createPair(key1, key2);
		cache.put(key, value);
	}
}