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
package org.eclipse.papyrus.aof.core.tests.operation;

import static org.eclipse.papyrus.aof.core.utils.Functions.identity;

import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IConstraints;
import org.eclipse.papyrus.aof.core.IOne;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.eclipse.papyrus.aof.core.tests.BaseTest;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;


/**
 * 
 * @author Frédéric Jouault
 *
 */
@RunWith(Parameterized.class)
public class SwitchCollectTest extends BaseTest {

	@Parameters
	public static Collection<Object[]> data() {
		return Arrays.<Object[]> asList(
				newArray(IConstraints.BAG),
				newArray(IConstraints.ONE),
				newArray(IConstraints.OPTION),
				newArray(IConstraints.SEQUENCE),
				newArray(IConstraints.ORDERED_SET),
				newArray(IConstraints.SET)
				);
	}

	private IConstraints constraints;

	public SwitchCollectTest(IConstraints constraints) {
		this.constraints = constraints;
	}

	@Test
	public void testIf() {
		System.out.println(constraints);
		IBox<Integer> a = factory.createBox(constraints, 1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6);
		a.inspect("\ta: ");
		IBox<Integer> b = a.switchCollect(newArray(isOdd), newArray(negate), identity);
		b.inspect("\tb: ");
		a.add(0, 10);
		a.add(0, 11);
		if (!a.isUnique()) {
			a.add(0, 5);
		}
		if (!a.isSingleton()) {
			a.add(a.length(), 12);
			a.add(a.length(), 13);
			a.add(a.length() / 2, 14);
			a.add(a.length() / 2, 15);
		}
		IBox<Integer> c = a.switchCollect(newArray(isOdd), newArray(negate), identity);
		assertEquals(c, b);
	}

	public static IUnaryFunction<Integer, Integer> ifReverseCollector = new IUnaryFunction<Integer, Integer>() {
		@Override
		public Integer apply(Integer parameter) {
			if (parameter % 2 != 0) {
				return -parameter;
			} else {
				return parameter;
			}
		}
	};

	@Test
	public void testIfReverse() {
		System.out.println(constraints);
		IBox<Integer> a = factory.createBox(constraints, 1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6);
		a.inspect("\ta: ");
		IBox<Integer> b = a.switchCollect(newArray(isOdd), newArray(negate), identity, ifReverseCollector);
		b.inspect("\tb: ");
		b.add(0, 10);
		b.add(0, -11);
		if (!a.isUnique()) {
			b.add(0, -5);
		}
		if (!b.isSingleton()) {
			b.add(b.length(), 12);
			b.add(b.length(), -13);
			b.add(b.length() / 2, 14);
			b.add(b.length() / 2, -15);
		}
		IBox<Integer> c = a.switchCollect(newArray(isOdd), newArray(negate), identity);
		assertEquals(c, b);
	}

	@Test
	public void testSwitch() {
		System.out.println(constraints);
		IBox<Integer> a = factory.createBox(constraints, 1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6);
		a.inspect("\ta: ");
		IBox<Integer> b = a.switchCollect(newArray(isOdd, isMultipleOf(3)), newArray(negate, square), identity);
		b.inspect("\tb: ");
		a.add(0, 10);
		a.add(0, 11);
		if (!a.isUnique()) {
			a.add(0, 5);
		}
		if (!a.isSingleton()) {
			a.add(a.length(), 12);
			a.add(a.length(), 13);
			a.add(a.length() / 2, 14);
			a.add(a.length() / 2, 15);
		}
		IBox<Integer> c = a.switchCollect(newArray(isOdd, isMultipleOf(3)), newArray(negate, square), identity);
		assertEquals(c, b);
	}

	public static IUnaryFunction<Integer, Integer> switchReverseCollector = new IUnaryFunction<Integer, Integer>() {
		@Override
		public Integer apply(Integer parameter) {
			if (parameter % 2 == 0) {
				return -parameter;
			}
			int sqrt = (int) Math.sqrt(parameter);
			if (sqrt * sqrt == parameter && sqrt % 2 != 0 && sqrt % 3 == 0) {
				return sqrt;
			} else {
				return parameter;
			}
		}
	};

	@Test
	public void testSwitchReverse() {
		System.out.println(constraints);
		IBox<Integer> a = factory.createBox(constraints, 1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6);
		a.inspect("\ta: ");
		IBox<Integer> b = a.switchCollect(newArray(isEven, isMultipleOf(3)), newArray(negate, square), identity, switchReverseCollector);
		b.inspect("\tb: ");
		b.add(0, -10);
		b.add(0, 11);
		if (!a.isUnique()) {
			b.add(0, 5);
		}
		if (!b.isSingleton()) {
			b.add(b.length(), -12);
			b.add(b.length(), 13);
			b.add(b.length() / 2, -14);
			b.add(b.length() / 2, 225); // 15 squared
		}
		IBox<Integer> c = a.switchCollect(newArray(isEven, isMultipleOf(3)), newArray(negate, square), identity, switchReverseCollector);
		assertEquals(c, b);
	}

	// does not work for negative numbers
	public static IUnaryFunction<Integer, IOne<Boolean>> isOdd =
			new IUnaryFunction<Integer, IOne<Boolean>>() {
				private Map<Integer, IOne<Boolean>> cache = new HashMap<Integer, IOne<Boolean>>();

				@Override
				public IOne<Boolean> apply(Integer parameter) {
					IOne<Boolean> ret = cache.get(parameter);
					if (ret == null) {
						ret = factory.createOne(AbstractSelectTest.isOdd.apply(parameter));
						cache.put(parameter, ret);
					}
					return ret;
				}
			};

	// works for negative numbers
	public static IUnaryFunction<Integer, IOne<Boolean>> isEven =
			new IUnaryFunction<Integer, IOne<Boolean>>() {
				private Map<Integer, IOne<Boolean>> cache = new HashMap<Integer, IOne<Boolean>>();

				@Override
				public IOne<Boolean> apply(Integer parameter) {
					IOne<Boolean> ret = cache.get(parameter);
					if (ret == null) {
						ret = factory.createOne(parameter % 2 == 0);
						cache.put(parameter, ret);
					}
					return ret;
				}
			};

	public static IUnaryFunction<Integer, IOne<Boolean>> isMultipleOf(final int n) {
		return new IUnaryFunction<Integer, IOne<Boolean>>() {
			private Map<Integer, IOne<Boolean>> cache = new HashMap<Integer, IOne<Boolean>>();

			@Override
			public IOne<Boolean> apply(Integer parameter) {
				IOne<Boolean> ret = cache.get(parameter);
				if (ret == null) {
					ret = factory.createOne(parameter % n == 0);
					cache.put(parameter, ret);
				}
				return ret;
			}
		};
	}

	public static IUnaryFunction<Integer, Integer> negate = new IUnaryFunction<Integer, Integer>() {
		@Override
		public Integer apply(Integer parameter) {
			return -parameter;
		}
	};

	public static IUnaryFunction<Integer, Integer> square = new IUnaryFunction<Integer, Integer>() {
		@Override
		public Integer apply(Integer parameter) {
			return parameter * parameter;
		}
	};

	public static IUnaryFunction<Integer, Integer> identity = identity();

	public static <A> A[] newArray(A... array) {
		return array;
	}
}
