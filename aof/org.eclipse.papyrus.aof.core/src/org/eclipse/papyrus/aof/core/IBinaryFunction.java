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
 * Represents binary functions wrapped into objects that can be passed as arguments to methods.
 * <p>
 * It is equivalent to the Java 8 interface <code>BiFunction</code>, and is provided so that AOF API can be used with
 * Java version lesser that 8.
 *
 * @param <F>
 *            type of first parameter of this binary function
 * @param <S>
 *            type of second parameter of this binary function
 * @param <R>
 *            type of returned object of this binary function
 */
public interface IBinaryFunction<F, S, R> {

	/**
	 * Applies the binary function with two arguments represented by the given parameters
	 * 
	 * @param firstParameter
	 *            parameter representing the first argument pass to the function
	 * @param secondParameter
	 *            parameter representing the second argument pass to the function
	 * @return
	 *         the result of the function application
	 */
	R apply(F firstParameter, S secondParameter);

}
