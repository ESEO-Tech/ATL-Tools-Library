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
 * Represents predicates wrapped into objects that can be passed as arguments to methods.
 * <p>
 * A predicate returns an immutable boolean.
 *
 * @param <P>
 *            type of the parameter of this predicate
 */
public interface IPredicate<P> extends IUnaryFunction<P, Boolean> {

}
