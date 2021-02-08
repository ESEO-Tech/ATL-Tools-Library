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
package org.eclipse.papyrus.aof.core.impl.operation;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IObserver;
import org.eclipse.papyrus.aof.core.IOne;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver;

/**
 * Based on Select{WithPresence,WithPredicate} by Olivier Beaudoux
 * Rationale: should be consistent, which is not the case of its "logical" equivalent expression:
 * 		sourceBox.select(sourceBox.collect(<factory>, <default>, selector))
 * @author Frédéric Jouault
 *
 * @param <E>
 */
// deal with silent observers... too bad unregisterObservation does not take the wrapped Observer
// instead of the wrapping SilentObserver... could be done with a Map
public class SelectWithMutablePredicate<E> extends Operation<E> {

	private IBox<E> sourceBox;
	// we keep references to the IOne<Boolean>, not just the Boolean value
	// this way we do not have to ask the selector over and over again AND
	// we may perform correct work even if the selector return value is not cached (TO BE TESTED)
	private List<IOne<Boolean>> presence = new ArrayList<IOne<Boolean>>();
	private List<IObserver<Boolean>> innerObservers = new ArrayList<IObserver<Boolean>>();

	private IUnaryFunction<? super E, IOne<Boolean>> selector;

	public SelectWithMutablePredicate(IBox<E> sourceBox, IUnaryFunction<? super E, IOne<Boolean>> selector) {
		this.sourceBox = sourceBox;
		this.selector = selector;
		for (E element : sourceBox) {
			IOne<Boolean> elementPresence = selector.apply(element);
			innerObservers.add(registerObservation(elementPresence, new InnerBoxObserver(element)));
			presence.add(elementPresence);
			if (elementPresence.get(0)) {
				getResult().add(element);
			}
		}
		registerObservation(sourceBox, new SourceObserver());
		registerObservation(getResult(), new ResultObserver());
	}

	@Override
	public boolean isOptional() {
		return true;
	}

	@Override
	public boolean isSingleton() {
		return sourceBox.isSingleton();
	}

	@Override
	public boolean isOrdered() {
		return sourceBox.isOrdered();
	}

	@Override
	public boolean isUnique() {
		return sourceBox.isUnique();
	}

	@Override
	public E getResultDefautElement() {
		IOne<E> sourceOne = (IOne<E>) sourceBox;
		return sourceOne.getDefaultElement();
	}

	private class SourceObserver extends DefaultObserver<E> {
		@Override
		public void added(int sourceIndex, E element) {
			debugCheckConsistencyOfPresenceWithInnerObservers();
			IOne<Boolean> elementPresence = selector.apply(element);
			if (elementPresence.get(0)) {
				getResult().add(countTrue(sourceIndex), element);
			}
			innerObservers.add(sourceIndex, registerObservation(elementPresence, new InnerBoxObserver(element)));
			presence.add(sourceIndex, elementPresence);
			debugCheckConsistencyOfPresenceWithInnerObservers();
			debugCheckAlignmentOfSourceWithPresence();
		}

		@Override
		public void removed(int sourceIndex, E element) {
			debugCheckConsistencyOfPresenceWithInnerObservers();
			IOne<Boolean> elementPresence = presence.remove(sourceIndex);
			if (elementPresence.get(0)) {
				getResult().removeAt(countTrue(sourceIndex));
			}
			unregisterObservation(elementPresence, innerObservers.remove(sourceIndex));
			debugCheckConsistencyOfPresenceWithInnerObservers();
			debugCheckAlignmentOfSourceWithPresence();
		}

		// we propagate even if oldElement == newElement, but do not change our internal stuff if unnecessary
		@Override
		public void replaced(int sourceIndex, E newElement, E oldElement) {
			debugCheckConsistencyOfPresenceWithInnerObservers();
			IOne<Boolean> oldElementPresence = presence.get(sourceIndex);
			IOne<Boolean> newElementPresence = (newElement == oldElement ? presence.get(sourceIndex) : selector.apply(newElement));

			if (newElementPresence.get(0)) {
				if (oldElementPresence.get(0)) {
					getResult().set(countTrue(sourceIndex), newElement);
				} else {
					getResult().add(countTrue(sourceIndex), newElement);
				}
			} else if (oldElementPresence.get(0)) {
				getResult().removeAt(countTrue(sourceIndex));
			}

			if(newElement != oldElement) {
				presence.remove(sourceIndex);
				unregisterObservation(oldElementPresence, innerObservers.remove(sourceIndex));

				innerObservers.add(sourceIndex, registerObservation(newElementPresence, new InnerBoxObserver(newElement)));
				presence.add(sourceIndex, newElementPresence);
			}
			debugCheckConsistencyOfPresenceWithInnerObservers();
			debugCheckAlignmentOfSourceWithPresence();
		}

		@Override
		public void moved(int newSourceIndex, int oldSourceIndex, E element) {
			debugCheckConsistencyOfPresenceWithInnerObservers();
			IOne<Boolean> elementPresence = presence.remove(oldSourceIndex);
			// we must move presence first because this is how the algorithm works (as in SelectWith{Predicate,Presence})
			// check other events
			presence.add(newSourceIndex, elementPresence);
			if (elementPresence.get(0)) {
				getResult().move(countTrue(newSourceIndex), countTrue(oldSourceIndex, newSourceIndex));
			}
			innerObservers.add(newSourceIndex, innerObservers.remove(oldSourceIndex));
			debugCheckConsistencyOfPresenceWithInnerObservers();
			debugCheckAlignmentOfSourceWithPresence();
		}
	}

	private int countTrue(int untilIndex) {
		return countTrue(untilIndex, untilIndex);
	}

	private int countTrue(int untilIndex, int changeIndex) {
		int count = 0;
		for (int n = 0; n < untilIndex; n++) {
			int index = (n < changeIndex) ? n : n + 1;
			if (presence.get(index).get(0)) {
				count++;
			}
		}
		return count;
	}

	private class InnerBoxObserver extends DefaultObserver<Boolean> {
		private E sourceElement;

		public InnerBoxObserver(E sourceIndex) {
			this.sourceElement = sourceIndex;
		}

		@Override
		public void added(int index, Boolean element) {
			// inner box is singleton, add makes no sense
			throw new IllegalStateException();
		}

		@Override
		public void removed(int index, Boolean element) {
			// inner box is singleton, removed makes no sense
			throw new IllegalStateException();
		}

		@Override
		public void replaced(int index, Boolean newElement, Boolean oldElement) {
			if(!newElement.equals(oldElement)) {
				int sourceIndex = sourceBox.indexOf(sourceElement);
				if(newElement) {
					getResult().add(countTrue(sourceIndex), sourceBox.get(sourceIndex));
				} else {
					getResult().removeAt(countTrue(sourceIndex));
				}
			}
		}

		@Override
		public void moved(int newIndex, int oldIndex, Boolean element) {
			// inner box is singleton, move makes no sense
			throw new IllegalStateException();
		}

	}

	// uncomment body for testing, comment for release
	private void debugCheckConsistencyOfPresenceWithInnerObservers() {
/*
		if(innerObservers.size() != presence.size()) {
			throw new IllegalStateException("innerObservers and presence have different sizes");
		}
		for(int i = 0 ; i < presence.size() ; i++) {
			IBox<Boolean> elementPresence = presence.get(i);
			IObserver<Boolean> innerObserver = innerObservers.get(i);
			if(!((Collection<IObserver<Boolean>>)elementPresence.getObservers()).contains(innerObserver)) {
				throw new IllegalStateException("At index " + i + " innerObserver not registered to elementPresence box");
			}
		}
/**/
	}

	// only to be called after an event has been processed
	// uncomment body for testing, comment for release
	private void debugCheckAlignmentOfSourceWithPresence() {
/*
		if(presence.size() != sourceBox.length()) {
			throw new IllegalStateException("innerObservers and sourceBox have different sizes");
		}
		// the following only works if the selector has a cache! (this Operation should work without selector cache)
//		for(int i = 0 ; i < presence.size() ; i++) {
//			IBox<Boolean> elementPresence = selector.apply(sourceBox.get(i));
//			if(elementPresence != presence.get(i)) {
//				throw new IllegalStateException("elementPresence not aligned with sourceBox at " + i);
//			}
//		}
/**/
	}

	private class ResultObserver extends DefaultObserver<E> {

		@Override
		public void added(int resultIndex, E element) {
			debugCheckConsistencyOfPresenceWithInnerObservers();
			int sourceIndex = indexOfTrue(resultIndex);
			IOne<Boolean> elementPresence = selector.apply(element);
			if (elementPresence.get(0)) {
				sourceBox.add(sourceIndex, element);
				if (sourceBox instanceof IOne<?>) {
					// innerObservers and presence do not need updating
				} else {
					innerObservers.add(sourceIndex, registerObservation(elementPresence, new InnerBoxObserver(element)));
					presence.add(sourceIndex, elementPresence);
				}
			}
			// should throw an exception
			debugCheckConsistencyOfPresenceWithInnerObservers();
			debugCheckAlignmentOfSourceWithPresence();
		}

		@Override
		public void removed(int resultIndex, E element) {
			debugCheckConsistencyOfPresenceWithInnerObservers();
			if (sourceBox instanceof IOne<?>) {
				E sourceDefault = ((IOne<E>)sourceBox).getDefaultElement();
				if(selector.apply(sourceDefault).get(0)) {
					throw new IllegalStateException("Emptying the result " + getResult() + " of a select while the source box " + sourceBox + " is a one box which a default value that satisfies the selector is forbidden");
				} else {
					sourceBox.clear();
				}
			} else {
				int sourceIndex = indexOfTrue(resultIndex + 1) - 1;
				sourceBox.removeAt(sourceIndex);
				IOne<Boolean> elementPresence = presence.remove(sourceIndex);
				unregisterObservation(elementPresence, innerObservers.remove(sourceIndex));
			}
			debugCheckConsistencyOfPresenceWithInnerObservers();
			debugCheckAlignmentOfSourceWithPresence();
		}

		// we propagate even if oldElement == newElement, but do not change our internal stuff if unnecessary
		@Override
		public void replaced(int resultIndex, E newElement, E oldElement) {
			debugCheckConsistencyOfPresenceWithInnerObservers();
			int sourceIndex = indexOfTrue(resultIndex + 1) - 1;
			IOne<Boolean> newElementPresence = (newElement == oldElement ? presence.get(sourceIndex) : selector.apply(newElement));
			if (newElementPresence.get(0)) {
				sourceBox.set(sourceIndex, newElement);
			} else {
				throw new IllegalStateException("Trying to replace element " + oldElement + " by element " + newElement + " that does not satisify predicate");
			}

			if(newElement != oldElement) {
				unregisterObservation(presence.remove(sourceIndex), innerObservers.remove(sourceIndex));

				innerObservers.add(sourceIndex, registerObservation(newElementPresence, new InnerBoxObserver(newElement)));
				presence.add(sourceIndex, newElementPresence);
			}
			debugCheckConsistencyOfPresenceWithInnerObservers();
			debugCheckAlignmentOfSourceWithPresence();
		}

		@Override
		public void moved(int newResultIndex, int oldResultIndex, E element) {
			debugCheckConsistencyOfPresenceWithInnerObservers();
			int newSourceIndex = indexOfTrue(newResultIndex + 1) - 1;
			int oldSourceIndex = indexOfTrue(oldResultIndex + 1) - 1;
			sourceBox.move(newSourceIndex, oldSourceIndex);

			innerObservers.add(newSourceIndex, innerObservers.remove(oldSourceIndex));
			presence.add(newSourceIndex, presence.remove(oldSourceIndex));
			debugCheckConsistencyOfPresenceWithInnerObservers();
			debugCheckAlignmentOfSourceWithPresence();
		}

		// it is in fact the reversed version of countTrue...?
		private int indexOfTrue(int untilCount) {
			int index = 0;
			int count = 0;
			while (count < untilCount) {
				if (presence.get(index).get(0)) {
					count++;
				}
				index++;
			}
			return index;
		}
	}
}
