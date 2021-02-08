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
package org.eclipse.papyrus.aof.core.impl.operation;

import org.eclipse.papyrus.aof.core.IBinaryFunction;
import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IOne;
import org.eclipse.papyrus.aof.core.IPair;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver;

public class ZipWith<L, R, LR> extends Operation<LR> {

	protected IBox<L> leftBox;

	protected IBox<R> rightBox;

	private boolean leftRightDependency;

	private IBinaryFunction<L, R, LR> zipper;

	private IUnaryFunction<LR, IPair<L, R>> unzipper;

	public ZipWith(IBox<L> leftBox, IBox<R> rightBox, boolean leftRightDependency, IBinaryFunction<L, R, LR> zipper, IUnaryFunction<LR, IPair<L, R>> unzipper) {
		this.leftBox = leftBox;
		this.rightBox = rightBox;
		this.leftRightDependency = leftRightDependency;
		this.zipper = zipper;
		this.unzipper = unzipper;
		for (int i = 0; i < minSize(); i++) {
			getResult().add(applyZipperAt(i));
		}
		// left box mutations are ALWAYS received first, we observe only the right box thus
		// avoiding a potentially inconsistent state of the result box
		if (!leftRightDependency) {
			registerObservation(leftBox, new LeftObserver());
		}
		registerObservation(rightBox, new RightObserver());
		if (unzipper != null) {
			registerObservation(getResult(), new ResultObserver());
		}
	}

	@Override
	public boolean isOptional() {
		return leftBox.isOptional() || rightBox.isOptional();
	}

	@Override
	public boolean isSingleton() {
		return leftBox.isSingleton() || rightBox.isSingleton();
	}

	@Override
	public boolean isOrdered() {
		return isSingleton() || (leftBox.isOrdered() && rightBox.isOrdered());
	}

	@Override
	public boolean isUnique() {
		return isSingleton(); // zipper function may introduce duplicates
	}

	@Override
	public LR getResultDefautElement() {
		IOne<L> leftOne = (IOne<L>) leftBox;
		IOne<R> rightOne = (IOne<R>) rightBox;
		L leftDefault = leftOne.getDefaultElement();
		R rightDefault = rightOne.getDefaultElement();
		return zipper.apply(leftDefault, rightDefault);
	}

	private LR applyZipperAt(int i) {
		return zipper.apply(leftBox.get(i), rightBox.get(i));
	}

	private int minSize() {
		return Math.min(leftBox.length(), rightBox.length());
	}

	private void safeReplace(int j, LR zippedValue) {
		// safe replace in case of unique result box
		if (getResult().isUnique() && getResult().contains(zippedValue)) {
			getResult().remove(zippedValue);
			getResult().add(j, zippedValue);
		}
		// standard replace for non unique result box
		else {
			getResult().set(j, zippedValue);
		}
	}

	private class LeftObserver extends DefaultObserver<L> {

		@Override
		public void added(int index, L element) {
			if (index < minSize()) {
				if (leftBox.length() <= rightBox.length()) {
					for (int j = index; j < minSize() - 1; j++) {
						safeReplace(j, applyZipperAt(j));
					}
					if (getResult().length() < minSize()) {
						getResult().add(applyZipperAt(minSize() - 1));
					}
				} else {
					for (int j = index; j < minSize(); j++) {
						safeReplace(j, applyZipperAt(j));
					}
				}
			}
		}

		@Override
		public void removed(int index, L element) {
			for (int j = index; j < minSize(); j++) {
				safeReplace(j, applyZipperAt(j));
			}
			if ((leftBox.length() < rightBox.length()) || (getResult().length() > minSize())) {
				getResult().removeAt(getResult().length() - 1);
			}
		}

		@Override
		public void replaced(int index, L newElement, L oldElement) {
			if (index < minSize()) {
				safeReplace(index, applyZipperAt(index));
			}
		}

		@Override
		public void moved(int newIndex, int oldIndex, L element) {
			if (!isSingleton()) {// useless for singleton, and generate a null element within one boxes
				removed(oldIndex, element);
			}
			added(newIndex, element);
			// should be optimized...
		}

	}

	private class RightObserver extends DefaultObserver<R> {

		@Override
		public void added(int index, R element) {
			if (index < minSize()) {
				if (rightBox.length() <= leftBox.length()) {
					for (int j = index; j < minSize() - 1; j++) {
						safeReplace(j, applyZipperAt(j));
					}
					if (getResult().length() < minSize()) {
						getResult().add(applyZipperAt(minSize() - 1));
					}
				} else {
					for (int j = index; j < minSize(); j++) {
						safeReplace(j, applyZipperAt(j));
					}
				}
			}
		}

		@Override
		public void removed(int index, R element) {
			for (int j = index; j < minSize(); j++) {
				safeReplace(j, applyZipperAt(j));
			}
			if ((rightBox.length() < leftBox.length()) || (getResult().length() > minSize())) {
				getResult().removeAt(getResult().length() - 1);
			}
		}

		@Override
		public void replaced(int index, R newElement, R oldElement) {
			if (index < minSize()) {
				safeReplace(index, applyZipperAt(index));
			}
		}

		@Override
		public void moved(int newIndex, int oldIndex, R element) {
			if (!isSingleton()) { // useless for singleton, and generate a null element within one boxes
				removed(oldIndex, element);
			}
			added(newIndex, element);
			// should be optimized...
		}

	}

	private class ResultObserver extends DefaultObserver<LR> {

		@Override
		public void added(int index, LR element) {
			IPair<L, R> pair = unzipper.apply(element);
			leftBox.add(index, pair.getLeft());
			// the dependency between the left and right boxes ensures that mutating the left box results in
			// a right box mutation so that the right box is up-to-date.
			if (!leftRightDependency) {
				rightBox.add(index, pair.getRight());
			}
		}

		@Override
		public void removed(int index, LR pair) {
			if ((leftBox.matches(ONE) && !rightBox.isSingleton()) ||
					(rightBox.matches(ONE) && !leftBox.isSingleton())) {
				throw new IllegalStateException("Removing the first element of the zip result is inconsistent when the zip operates a one box");
			}
			leftBox.removeAt(index);
			if (!leftRightDependency) {
				rightBox.removeAt(index);
			}
		}

		@Override
		public void replaced(int index, LR newElement, LR oldElement) {
			IPair<L, R> newPair = unzipper.apply(newElement);
			leftBox.set(index, newPair.getLeft());
			if (!leftRightDependency) {
				rightBox.set(index, newPair.getRight());
			}
		}

		@Override
		public void moved(int newIndex, int oldIndex, LR element) {
			leftBox.move(newIndex, oldIndex);
			if (!leftRightDependency) {
				rightBox.move(newIndex, oldIndex);
			}
		}

	}

}