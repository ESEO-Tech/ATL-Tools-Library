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
package org.eclipse.papyrus.aof.core;

/**
 * Represents singleton boxes containing exactly one element.
 * <p>
 * It defines a default element that is used when clearing the box .
 */
public interface IOne<E> extends ISingleton<E> {

	/**
	 * Returns the default element of this one box.
	 * <p>
	 * For consistency reasons, the default element can only be changed when clearing the box (@see #clear(Object))
	 * 
	 * @return the default element of this one box
	 */
	E getDefaultElement();

	/**
	 * Clear this one box and redefines its new default element.
	 * 
	 * @param newDefaultElement
	 *            the new default element of this one box
	 */
	void clear(E newDefaultElement);

}
