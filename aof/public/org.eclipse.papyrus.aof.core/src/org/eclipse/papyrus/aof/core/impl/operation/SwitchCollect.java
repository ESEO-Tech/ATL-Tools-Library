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

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IObserver;
import org.eclipse.papyrus.aof.core.IOne;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver;
import org.eclipse.papyrus.aof.core.impl.utils.Equality;

/**
 * Rationale: should be consistent, which is not the case of its "logical" equivalent expressions when conditions.length
 * > 0:
 * if conditions.length == 0: collect(defaultCollector)
 * if conditions.length == 1, this is equivalent to an "if-else" operation
 * if conditions.length > 1, this is equivalent to an "if-elseif-elseif-...-else" operation
 * 
 * @author Frédéric Jouault
 *
 * @param <E>
 */
public class SwitchCollect<E, R> extends Operation<R> {

	private IBox<E> sourceBox;

	// we keep references to the IOne<Boolean>, not just the Boolean value
	// this way we do not have to ask the conditions over and over again AND
	// we may perform correct work even if the selector return value is not cached (TO BE TESTED)
	private List<IOne<Boolean>> allElementConditions[];
	private List<IObserver<Boolean>> allInnerObservers[];

	private IUnaryFunction<? super E, IOne<Boolean>> conditions[];
	private IUnaryFunction<? super E, ? extends R> collectors[];
	private IUnaryFunction<? super E, ? extends R> defaultCollector;
	private IUnaryFunction<? super R, ? extends E> reverseCollector;

	public SwitchCollect(IBox<E> sourceBox, IUnaryFunction<? super E, IOne<Boolean>> conditions[], IUnaryFunction<? super E, ? extends R> collectors[], IUnaryFunction<? super E, ? extends R> defaultCollector) {
		this(sourceBox, conditions, collectors, defaultCollector, null);
	}

	public SwitchCollect(IBox<E> sourceBox, IUnaryFunction<? super E, IOne<Boolean>> conditions[], IUnaryFunction<? super E, ? extends R> collectors[], IUnaryFunction<? super E, ? extends R> defaultCollector,
			IUnaryFunction<? super R, ? extends E> reverseCollector) {
		this.sourceBox = sourceBox;

		if (conditions.length != collectors.length) {
			throw new IllegalArgumentException("there must be the same number of conditions and collectors");
		}
		this.conditions = conditions;
		this.collectors = collectors;
		this.allElementConditions = new ArrayList[conditions.length];
		this.allInnerObservers = new ArrayList[conditions.length];

		this.defaultCollector = defaultCollector;
		this.reverseCollector = reverseCollector;

		for (int conditionIndex = 0; conditionIndex < conditions.length; conditionIndex++) {
			allElementConditions[conditionIndex] = new ArrayList<IOne<Boolean>>();
			allInnerObservers[conditionIndex] = new ArrayList<IObserver<Boolean>>();
			for (E element : sourceBox) {
				// [optimize?]: only observe (and obtain) the elementConditions until (and including) the first one that
				// is true
				IOne<Boolean> elementCondition = conditions[conditionIndex].apply(element);
				allInnerObservers[conditionIndex].add(registerObservation(elementCondition, new InnerBoxObserver(conditionIndex, element)));
				allElementConditions[conditionIndex].add(elementCondition);
			}
		}
		for (int boxIndex = 0; boxIndex < sourceBox.length(); boxIndex++) {
			boolean matchedACondition = false;
			for (int conditionIndex = 0; conditionIndex < allElementConditions.length; conditionIndex++) {
				if (allElementConditions[conditionIndex].get(boxIndex).get(0)) {
					getResult().add(collectors[conditionIndex].apply(sourceBox.get(boxIndex)));
					matchedACondition = true;
					break;
				}
			}
			if (!matchedACondition) {
				getResult().add(defaultCollector.apply(sourceBox.get(boxIndex)));
			}
		}
		registerObservation(sourceBox, new SourceObserver());

		if (reverseCollector != null) {
			registerObservation(getResult(), new ResultObserver());
		}
	}

	@Override
	public boolean isOptional() {
		return sourceBox.isOptional();
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
		return sourceBox.isSingleton();
	}

	@Override
	public R getResultDefautElement() {
		IOne<E> sourceOne = (IOne<E>) sourceBox;
		return defaultCollector.apply(sourceOne.getDefaultElement());
	}

	private class SourceObserver extends DefaultObserver<E> {
		@Override
		public void added(int index, E element) {
			debugCheckConsistency(false);
			IUnaryFunction<? super E, ? extends R> collector = null;
			for (int conditionIndex = 0; conditionIndex < conditions.length; conditionIndex++) {
				IOne<Boolean> elementCondition = conditions[conditionIndex].apply(element);
				allInnerObservers[conditionIndex].add(index, registerObservation(elementCondition, new InnerBoxObserver(conditionIndex, element)));
				allElementConditions[conditionIndex].add(index, elementCondition);
				if (elementCondition.get(0) && collector == null) {
					collector = collectors[conditionIndex];
				}
			}
			if (collector == null) {
				collector = defaultCollector;
			}
			getResult().add(index, collector.apply(element));
			debugCheckConsistency(true);
		}

		@Override
		public void removed(int index, E element) {
			debugCheckConsistency(false);
			for (int conditionIndex = 0; conditionIndex < conditions.length; conditionIndex++) {
				unregisterObservation(allElementConditions[conditionIndex].remove(index), allInnerObservers[conditionIndex].remove(index));
			}
			getResult().removeAt(index);
			debugCheckConsistency(true);
		}

		@Override
		public void replaced(int index, E newSourceElement, E oldSourceElement) {
			debugCheckConsistency(false);
			if (newSourceElement == oldSourceElement) {
				// propagate a non-modifying replace
				getResult().set(index, getResult().get(index));
			} else {
				for (int conditionIndex = 0; conditionIndex < conditions.length; conditionIndex++) {
					unregisterObservation(allElementConditions[conditionIndex].remove(index), allInnerObservers[conditionIndex].remove(index));
				}
				IUnaryFunction<? super E, ? extends R> collector = null;
				for (int conditionIndex = 0; conditionIndex < conditions.length; conditionIndex++) {
					IOne<Boolean> elementCondition = conditions[conditionIndex].apply(newSourceElement);
					allInnerObservers[conditionIndex].add(index, registerObservation(elementCondition, new InnerBoxObserver(conditionIndex, newSourceElement)));
					allElementConditions[conditionIndex].add(index, elementCondition);
					if (elementCondition.get(0) && collector == null) {
						collector = collectors[conditionIndex];
					}
				}
				if (collector == null) {
					collector = defaultCollector;
				}
				getResult().set(index, collector.apply(newSourceElement));
			}


			debugCheckConsistency(true);
		}

		@Override
		public void moved(int newIndex, int oldIndex, E element) {
			debugCheckConsistency(false);
			for (int conditionIndex = 0; conditionIndex < conditions.length; conditionIndex++) {
				allElementConditions[conditionIndex].add(newIndex, allElementConditions[conditionIndex].remove(oldIndex));
				allInnerObservers[conditionIndex].add(newIndex, allInnerObservers[conditionIndex].remove(oldIndex));
			}
			getResult().move(newIndex, oldIndex);
			debugCheckConsistency(true);
		}
	}

	private Object javaGet(Object o, String fieldName) {
		try {
			Field field = o.getClass().getDeclaredField(fieldName);
			field.setAccessible(true);
			return field.get(o);
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	// uncomment body for testing, comment for release
	private void debugCheckConsistency(boolean synchronizedWithSourceBox) {
		/*
		 * for(int conditionIndex = 0 ; conditionIndex < conditions.length ; conditionIndex++) {
		 * if(synchronizedWithSourceBox) {
		 * if(allElementConditions[conditionIndex].size() != sourceBox.length()) {
		 * throw new IllegalStateException("not right number of elementConditions for condition " + conditionIndex);
		 * }
		 * if(allInnerObservers[conditionIndex].size() != sourceBox.length()) {
		 * throw new IllegalStateException("not right number of innerObservers for condition " + conditionIndex);
		 * }
		 * } else {
		 * if(allInnerObservers[conditionIndex].size() != allElementConditions[conditionIndex].size()) {
		 * throw new IllegalStateException("not same number of innerObservers and elementConditions condition " +
		 * conditionIndex);
		 * }
		 * }
		 * for(int elementIndex = 0 ; elementIndex < allElementConditions[conditionIndex].size() ; elementIndex++) {
		 * IOne<Boolean> elementCondition = allElementConditions[conditionIndex].get(elementIndex);
		 * IObserver<Boolean> innerObserver = allInnerObservers[conditionIndex].get(elementIndex);
		 * // warning, this check only works if ConstantOnes remember their observers
		 * if(synchronizedWithSourceBox) {
		 * // check if innerObserver.sourceElement == sourceBox.get(j)
		 * if(javaGet(javaGet(innerObserver, "wrappedObserver"), "sourceElement") != sourceBox.get(elementIndex)) {
		 * throw new IllegalStateException("observer at " + elementIndex +
		 * " does not correspond to sourceElement for condition " + conditionIndex);
		 * }
		 * } else {
		 * // do not access sourceBox because it has not been updated yet
		 * }
		 * // WARNING: only if cache is fully enabled (including in ConstantOne by making {remove,add}Observer actually
		 * work)
		 * // if(((List<IObserver<Boolean>>)elementCondition.getObservers()).contains(innerObserver)) {
		 * // // no problem
		 * // } else {
		 * // throw new IllegalStateException("observer at " + elementIndex +
		 * " does not match registered observer for condition " + conditionIndex);
		 * // }
		 * }
		 * }
		 * /*
		 */
	}

	private class InnerBoxObserver extends DefaultObserver<Boolean> {
		private int conditionIndex;
		private E sourceElement;

		public InnerBoxObserver(int conditionIndex, E sourceElement) {
			this.conditionIndex = conditionIndex;
			this.sourceElement = sourceElement;
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
			debugCheckConsistency(true);
			if (!newElement.equals(oldElement)) {
				int boxIndex = sourceBox.indexOf(sourceElement);
				IUnaryFunction<? super E, ? extends R> collector = null;
				for (int conditionIndex = 0; conditionIndex < conditions.length; conditionIndex++) {
					if (allElementConditions[conditionIndex].get(boxIndex).get(0)) {
						collector = collectors[conditionIndex];
						break;
					}
				}
				if (collector == null) {
					collector = defaultCollector;
				}
				getResult().set(boxIndex, collector.apply(sourceBox.get(boxIndex)));
			}
			debugCheckConsistency(true);
		}

		@Override
		public void moved(int newIndex, int oldIndex, Boolean element) {
			// inner box is singleton, move makes no sense
			throw new IllegalStateException();
		}

	}

	private class ResultObserver extends DefaultObserver<R> {
		@Override
		public void added(int index, R targetElement) {
			debugCheckConsistency(false);
			E sourceElement = reverseCollector.apply(targetElement);

			IUnaryFunction<? super E, ? extends R> collector = null;
			for (int conditionIndex = 0; conditionIndex < conditions.length; conditionIndex++) {
				IOne<Boolean> elementCondition = conditions[conditionIndex].apply(sourceElement);
				allInnerObservers[conditionIndex].add(index, registerObservation(elementCondition, new InnerBoxObserver(conditionIndex, sourceElement)));
				allElementConditions[conditionIndex].add(index, elementCondition);
				if (elementCondition.get(0) && collector == null) {
					collector = collectors[conditionIndex];
				}
			}
			if (collector == null) {
				collector = defaultCollector;
			}
			R recomputedTargetElement = collector.apply(sourceElement);
			if (!Equality.optionalEquals(recomputedTargetElement, targetElement)) {
				throw new IllegalArgumentException("inconsistency: added target element " + targetElement + " should be the same as " + recomputedTargetElement + " recomputed from source element " + sourceElement);
			}
			sourceBox.add(index, sourceElement);
			debugCheckConsistency(true);
		}

		@Override
		public void removed(int index, R element) {
			debugCheckConsistency(false);
			for (int conditionIndex = 0; conditionIndex < conditions.length; conditionIndex++) {
				unregisterObservation(allElementConditions[conditionIndex].remove(index), allInnerObservers[conditionIndex].remove(index));
			}
			sourceBox.removeAt(index);
			debugCheckConsistency(true);
		}

		@Override
		public void replaced(int index, R newTargetElement, R oldTargetElement) {
			debugCheckConsistency(false);
			// factorize with added?

			if (newTargetElement == oldTargetElement) {
				// propagate a non-modifying replace
				sourceBox.set(index, sourceBox.get(index));
			} else {
				for (int conditionIndex = 0; conditionIndex < conditions.length; conditionIndex++) {
					unregisterObservation(allElementConditions[conditionIndex].remove(index), allInnerObservers[conditionIndex].remove(index));
				}
				E newSourceElement = reverseCollector.apply(newTargetElement);

				IUnaryFunction<? super E, ? extends R> collector = null;
				for (int conditionIndex = 0; conditionIndex < conditions.length; conditionIndex++) {
					IOne<Boolean> elementCondition = conditions[conditionIndex].apply(newSourceElement);
					allInnerObservers[conditionIndex].add(index, registerObservation(elementCondition, new InnerBoxObserver(conditionIndex, newSourceElement)));
					allElementConditions[conditionIndex].add(index, elementCondition);
					if (elementCondition.get(0) && collector == null) {
						collector = collectors[conditionIndex];
					}
				}
				if (collector == null) {
					collector = defaultCollector;
				}
				R recomputedTargetElement = collector.apply(newSourceElement);
				if (!Equality.optionalEquals(recomputedTargetElement, newTargetElement)) {
					throw new IllegalArgumentException("inconsistency: replaced target element " + newTargetElement + " should be the same as " + recomputedTargetElement + " recomputed from source element " + newSourceElement);
				}
				sourceBox.set(index, newSourceElement);
			}
			debugCheckConsistency(true);
		}

		@Override
		public void moved(int newIndex, int oldIndex, R element) {
			debugCheckConsistency(false);
			for (int conditionIndex = 0; conditionIndex < conditions.length; conditionIndex++) {
				allElementConditions[conditionIndex].add(newIndex, allElementConditions[conditionIndex].remove(oldIndex));
				allInnerObservers[conditionIndex].add(newIndex, allInnerObservers[conditionIndex].remove(oldIndex));
			}
			sourceBox.move(newIndex, oldIndex);
			debugCheckConsistency(true);
		}
	}
}
