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

public interface IBinaryCache<K1, K2, V> {
	V get(K1 key1, K2 key2);

	void put(K1 key1, K2 key2, V value);
}