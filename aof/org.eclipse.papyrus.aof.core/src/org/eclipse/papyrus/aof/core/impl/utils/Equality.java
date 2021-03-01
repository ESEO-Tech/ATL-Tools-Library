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
package org.eclipse.papyrus.aof.core.impl.utils;

public class Equality {
	public static boolean optionalEquals(Object a, Object b) {
		if (a != null) {
			return a.equals(b);
		} else {
			return b == null;
		}
	}
}
