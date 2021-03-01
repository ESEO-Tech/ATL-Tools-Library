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
 * Represents pairs of elements.
 * <p>
 * The first element of the pair is considered at left, and the second element is considered at right.
 * <p>
 * It is notably used by function {@link org.eclipse.papyrus.aof.core.IBox#zip(IBox, boolean)}.
 * 
 * @param <L>
 *            type of the element at left
 * @param <R>
 *            type of the element at right
 */
public interface IPair<L, R> {

	/**
	 * Returns the element at left on this pair
	 * 
	 * @return the element at left on this pair
	 */
	L getLeft();

	/**
	 * Returns the element at right on this pair
	 * 
	 * @return the element at right on this pair
	 */
	R getRight();

}