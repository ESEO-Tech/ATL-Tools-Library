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

import org.eclipse.papyrus.aof.core.impl.Constraints;

/**
 * Defines a set of four constraints that characterizes a constrained
 * contents (see {@link org.eclipse.papyrus.aof.core.IConstrained}.
 * <p>
 * The number of legal combinations of the four constraints is limited to six, each combination representing a specific
 * box type. The following table summarizes the constraints defined for these six box types:
 * <p>
 * <table>
 * <tr>
 * <th>Optional</th>
 * <th>Singleton</th>
 * <th>Ordered</th>
 * <th>Unique</th>
 * </tr>
 * <tr>
 * <td>Option</td>
 * <td>true</td>
 * <td>true</td>
 * <td>true</td>
 * <td>true</td>
 * </tr>
 * <tr>
 * <td>One</td>
 * <td>false</td>
 * <td>true</td>
 * <td>true</td>
 * <td>true</td>
 * </tr>
 * <tr>
 * <td>Set</td>
 * <td>true</td>
 * <td>false</td>
 * <td>false</td>
 * <td>true</td>
 * </tr>
 * <tr>
 * <td>Ordered Set</td>
 * <td>true</td>
 * <td>false</td>
 * <td>true</td>
 * <td>true</td>
 * </tr>
 * <tr>
 * <td>Sequence</td>
 * <td>true</td>
 * <td>false</td>
 * <td>true</td>
 * <td>false</td>
 * </tr>
 * <tr>
 * <td>Bag</td>
 * <td>true</td>
 * <td>false</td>
 * <td>false</td>
 * <td>false</td>
 * </tr>
 * </table>
 * <p>
 * All other combinations are considered as <b>illegal</b> ones.
 */
public interface IConstraints {

	/**
	 * Represents the option box type with the constraints optional, singleton, ordered, and unique.
	 */
	IConstraints OPTION = new Constraints(true, true, true, true);

	/**
	 * Represents the one box type with the constraints singleton, ordered, and unique.
	 */
	IConstraints ONE = new Constraints(false, true, true, true);

	/**
	 * Represents the set box type with the constraints optional, and unique.
	 */
	IConstraints SET = new Constraints(true, false, false, true);

	/**
	 * Represents the ordered set box type with the constraints optional, ordered, and unique.
	 */
	IConstraints ORDERED_SET = new Constraints(true, false, true, true);

	/**
	 * Represents the sequence box type with the constraints optional, and ordered.
	 */
	IConstraints SEQUENCE = new Constraints(true, false, true, false);

	/**
	 * Represents the set box type with the constraint optional.
	 */
	IConstraints BAG = new Constraints(true, false, false, false);

	/**
	 * Constraint optional specifies whether the box can be empty or not.
	 * It represents the minimal cardinality of a box which is 0 if optional is false, 1 if optional is true.
	 * 
	 * @return the optional constraint value
	 */
	boolean isOptional();

	/**
	 * Constraint singleton specifies whether the box can have more that one element or not.
	 * It represents the maximal cardinality of a box which is * if singleton is false, 1 if singleton is true.
	 * 
	 * @return the singleton constraint value
	 */
	boolean isSingleton();

	/**
	 * Constraint ordered specifies whether the box is ordered or not.
	 * 
	 * @return the ordered constraint value
	 */
	boolean isOrdered();

	/**
	 * Constraint unique specifies whether the box guarantees the uniqueness of its elements or not.
	 * 
	 * @return the unique constraint value
	 */
	boolean isUnique();

	/**
	 * Returns the legality of the constraints.
	 * A constraints is legal only if it is equal to one of the six constraints that represent
	 * the six box types.
	 * 
	 * @return legality of the constraints
	 */
	boolean isLegal();

	/**
	 * Returns whether two constraints are equal or not.
	 * Two constraints are equal if their six respective constraints are equal.
	 * 
	 * @param that
	 *            the constraints to compare with <code>this</code>
	 * @return the exact equality of <code>this</code> and <code>that</code> constraints
	 */
	boolean matches(IConstraints that);

}
