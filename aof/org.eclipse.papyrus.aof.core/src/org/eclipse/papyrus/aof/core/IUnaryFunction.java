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
 * Represents unary functions wrapped into objects that can be passed as arguments to methods.
 * <p>
 * It is equivalent to Java 8 interface <code>Function</code>, and is provided so that AOF API can be used with Java
 * version lesser that 8.
 *
 * @param <P>
 *            type of the parameter of this unary function
 * @param <R>
 *            type of the returned object of this unary function
 */
public interface IUnaryFunction<P, R> {

	/**
	 * Applies the unary function with an argument represented by the given parameter
	 * 
	 * @param parameter
	 *            parameter representing the argument pass to the function
	 * @return
	 *         the result of the function application
	 */
	R apply(P parameter);

}
