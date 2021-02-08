/****************************************************************
 *  Copyright (C) 2020 ESEO
 *
 *  This program and the accompanying materials are made
 *  available under the terms of the Eclipse Public License 2.0
 *  which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 *  Contributors:
 *    - Frédéric Jouault
 *
 *  version 1.0
 *
 *  SPDX-License-Identifier: EPL-2.0
 ****************************************************************/

package fr.eseo.aof.exploration.helperboxes

import java.util.stream.IntStream
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBinaryFunction
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.IConstraints
import org.eclipse.papyrus.aof.core.IFactory
import org.eclipse.papyrus.aof.core.IMetaClass
import org.eclipse.papyrus.aof.core.IOne
import org.eclipse.papyrus.aof.core.IPair
import org.eclipse.papyrus.aof.core.IUnaryFunction

// Designed only for use as right box of zipWith
class Naturals implements Constant<Integer>, ReadOnly<Integer>, IBox<Integer> {
	public static val INSTANCE = new Naturals

	override snapshot() {
		this	// since this box is readonly
	}
	
	override asBag() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override asBox(IConstraints constraints) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override asOne(Integer defaultElement) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override asOption() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override asOrderedSet() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override asSequence() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override asSet() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override distinct() {
		this
	}
	
	override sameAs(IBox<Integer> that) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
		
	static val factory = AOFFactory.INSTANCE
	static val length = Integer.MAX_VALUE
	public static val size = factory.createOne(length)

	override size() {
		size
	}
	
	override getConstraints() {
		this
	}
	
	override isLegal() {
		true
	}
	
	override isOptional() {
		true
	}
	
	override isOrdered() {
		true
	}
	
	override isSingleton() {
		false
	}
	
	override isUnique() {
		true
	}
	
	override matches(IConstraints that) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override contains(Integer element) {
		element >= 0
	}
	
	override get(int index) {
		index
	}
	
	override indexOf(Integer element) {
		if(element < 0) {
			-1
		} else {
			element
		}
	}
	
	override length() {
		length
	}
	
	override iterator() {
		IntStream.range(0, length).iterator
	}

	// IBox
	
	override <C extends Integer> select(IMetaClass<C> metaClass) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override <C extends Integer> select(Class<C> javaClass) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override bind(IBox<Integer> that) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override <R> collect(IUnaryFunction<? super Integer, ? extends R> collector) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override <R> collect(IUnaryFunction<Integer, R> collector, IUnaryFunction<R, Integer> reverseCollector) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override <P> collectMutable(IFactory factory, Object containingClass, Object property) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override <P> collectMutable(IMetaClass<Integer> containingClass, Object property) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override <R> collectMutable(IUnaryFunction<? super Integer, ? extends IBox<R>> collector) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override <R> collectTo(IUnaryFunction<? super Integer, ? extends R> toCollector) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override <R> collectTo(IUnaryFunction<Integer, R> toCollector, IUnaryFunction<R, Integer> fromCollector) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override <R,S> collectWithState(S defaultState, IUnaryFunction<? super Integer, IPair<R, S>> collector, IUnaryFunction<IPair<R, S>, ? extends Integer> reverseCollector) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override <R> collectedFrom(IUnaryFunction<? super R, ? extends Integer> toCollector) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override concat(IBox<Integer> that) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override inspect(String label) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override inspect(String label, IUnaryFunction<? super Integer, String> toString) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override isEmpty() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override notEmpty() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override select(IUnaryFunction<? super Integer, Boolean> selector) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override selectMutable(IUnaryFunction<? super Integer, IOne<Boolean>> selector) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override selectMutable(IBox<Boolean> selector) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override <R> switchCollect(IUnaryFunction<? super Integer, IOne<Boolean>>[] conditions, IUnaryFunction<? super Integer, ? extends R>[] collectors, IUnaryFunction<? super Integer, ? extends R> defaultCollector) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override <R> switchCollect(IUnaryFunction<? super Integer, IOne<Boolean>>[] conditions, IUnaryFunction<? super Integer, ? extends R>[] collectors, IUnaryFunction<? super Integer, ? extends R> defaultCollector, IUnaryFunction<? super R, ? extends Integer> reverseCollector) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override union(IBox<Integer> that) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override <F> zip(IBox<F> that, boolean leftRightDependency) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override <F,R> zipWith(IBox<F> that, IBinaryFunction<Integer, F, R> zipper) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override <F,R> zipWith(IBox<F> that, boolean leftRightDependency, IBinaryFunction<Integer, F, R> zipper, IUnaryFunction<R, IPair<Integer, F>> unzipper) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}