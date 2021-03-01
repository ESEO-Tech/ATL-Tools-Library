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
package org.eclipse.papyrus.aof.core.impl.utils;

import org.eclipse.papyrus.aof.core.impl.utils.cache.IBinaryCache;
import org.eclipse.papyrus.aof.core.impl.utils.cache.IUnaryCache;
import org.eclipse.papyrus.aof.core.impl.utils.cache.WeakKeysWeakValuesBinaryCache;
import org.eclipse.papyrus.aof.core.impl.utils.cache.WeakKeysWeakValuesUnaryCache;

public class Cache {
	private IUnaryCache sourceByTarget = new WeakKeysWeakValuesUnaryCache();
	// many sources per link, few (typically 1) links by source
	private IBinaryCache targetByLinkAndSource = new WeakKeysWeakValuesBinaryCache();

	public Object getTarget(Object source, Object link) {
		return targetByLinkAndSource.get(link, source);
	}

	public Object getSource(Object target) {
		return sourceByTarget.get(target);
	}

	public void addLink(Object source, Object link, Object target) {
		sourceByTarget.put(target, source);
		targetByLinkAndSource.put(link, source, target);
	}
}
