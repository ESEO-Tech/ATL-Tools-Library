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
 * Represents constraints relative to the contents of boxes.
 * <p>
 * It extends {@link org.eclipse.papyrus.aof.core.IConstraints} for facility purpose only: each method defined in
 * {@link org.eclipse.papyrus.aof.core.IConstraints} can be invoked without invoking {@link #getConstraints()}.
 */
public interface IConstrained extends IConstraints {

	/**
	 * Returns the constraints associated to this constrained contents.
	 * 
	 * @return the constraints of this constrained contents
	 */
	IConstraints getConstraints();

}
