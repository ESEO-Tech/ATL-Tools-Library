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

package org.eclipse.papyrus.aof.core;

/**
 * Represents bidirectional bindings between boxes.
 * <p>
 * The binding is a pair containing the two boxes, as the following code illustrates:
 * 
 * <pre>
 * IBox<E> leftBox = ...
 * IBox<E> rightBox = ...
 * IBinding<E> binding = leftBox.bind(rightBox);
 * assert(binding.getLeft() == leftBox);
 * assert(binding.getRight() == rightBox);
 * </pre>
 * 
 * The binding is established by invoking {@link org.eclipse.papyrus.aof.core.IBox#bind(IBox)} on the left box.
 * <p>
 * It can be then disabled and enabled at any time to pause and resume the bonding.
 *
 * @param <E>
 *            type of the elements of the two bound boxed
 */
public interface IBinding<E> extends IPair<IBox<E>, IBox<E>> {

	/**
	 * Enables the binding, which consists of assigning the right box contents to the left box, then of
	 * resuming the synchronization between the two boxes.
	 */
	void enable();

	/**
	 * Disables the binding, which consists of pausing the synchronization between the two boxes.
	 */
	void disable();

}
