/*******************************************************************************
 *  Copyright (c) 2015 ESEO.
 *  All rights reserved. This program and the accompanying materials
 *  are made available under the terms of the Eclipse Public License v1.0
 *  which accompanies this distribution, and is available at
 *  http://www.eclipse.org/legal/epl-v10.html
 *
 *  Contributors:
 *     Olivier Beaudoux - initial API and implementation
 *     Frédéric Jouault - API and implementation improvements 
 *******************************************************************************/
package org.eclipse.papyrus.aof.emf.impl;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.eclipse.papyrus.aof.core.impl.BaseDelegate;
import org.eclipse.papyrus.aof.core.impl.Constraints;

/**
 * A delegate bound to an EMF object property.
 * 
 * @author obeaudoux
 * 
 * @param <E>
 */

public abstract class FeatureDelegate<E> extends BaseDelegate<E> implements IConstraints {

	private EObject object;

	private EStructuralFeature feature;

	protected FeatureDelegate(EObject object, EStructuralFeature feature) {
		this.object = object;
		this.feature = feature;
	}

	protected EObject getObject() {
		return object;
	}


	protected EStructuralFeature getFeature() {
		return feature;
	}


	// IConstraints

	// All EMF singleton features behave as Ones with possible null value
	// @see GetSetFeatureDelagate.size
	@Override
	public boolean isOptional() {
		return feature.isMany();// || !feature.isRequired();
	}

	@Override
	public boolean isSingleton() {
		return !feature.isMany();
	}

	@Override
	public boolean isOrdered() {
		return true;// feature.isOrdered() || isSingleton(); // FIXME mandatory to have all EMF features ordered ??
	}

	@Override
	public boolean isUnique() {
		return feature.isUnique() || isSingleton();
	}

	// the constraints are computed form the EMF feature, so we need to check for their consistency
	@Override
	public boolean isLegal() {
		IConstraints delegate = new Constraints(this);
		return delegate.isLegal();
	}

	@Override
	public boolean matches(IConstraints that) {
		IConstraints delegate = new Constraints(this);
		return delegate.matches(that);
	}

}
