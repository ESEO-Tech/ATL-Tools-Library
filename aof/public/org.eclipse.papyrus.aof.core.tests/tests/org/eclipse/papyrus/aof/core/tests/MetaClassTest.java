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
package org.eclipse.papyrus.aof.core.tests;

import java.util.Arrays;

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IMetaClass;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.junit.Test;

public abstract class MetaClassTest extends BaseTest {

	// Fixture

	public static class Base {
	}

	public static class Derived extends Base {
	}

	public static class Sample {
		public Sample(Object arg) {
		}
	}

	public static abstract class Abstract {
	}

	public static class Concrete extends Abstract {
	}

	// Is instance of

	@Test
	public void testIntegerIsInstanceOfInteger() {
		testIsInstanceOfMetaClass(new Integer(0), Integer.class, true);
	}

	@Test
	public void testIntegerIsInstanceOfObject() {
		testIsInstanceOfMetaClass(new Integer(0), Object.class, true);
	}

	@Test
	public void testLongIsNotInstanceOfInteger() {
		testIsInstanceOfMetaClass(new Long(0), Integer.class, false);
	}

	@Test
	public void testObjectIsNotInstanceOfInteger() {
		testIsInstanceOfMetaClass(new Object(), Integer.class, false);
	}

	@Test
	public void testBooleanIsInstanceOfBoolean() {
		testIsInstanceOfMetaClass(new Boolean(false), Boolean.class, true);
	}

	@Test
	public void testIntegerIsNotInstanceOfBoolean() {
		testIsInstanceOfMetaClass(new Integer(0), Boolean.class, false);
	}

	@Test
	public void testBaseIsInstanceOfBase() {
		testIsInstanceOfMetaClass(new Base(), Base.class, true);
	}

	@Test
	public void testDerivedIsInstanceOfBase() {
		testIsInstanceOfMetaClass(new Derived(), Base.class, true);
	}

	@Test
	public void testBaseIsNotInstanceOfDerived() {
		testIsInstanceOfMetaClass(new Base(), Derived.class, false);
	}

	public void testIsInstanceOfMetaClass(Object object, Object platformClass, boolean expectedResult) {
		IMetaClass<Object> metaClass = factory.getMetaClass(platformClass);
		assertEquals(expectedResult, metaClass.isInstance(object));
	}

	// Get default instance

	@Test
	public void testGetDefaultInstanceOfString() {
		testGetDefaultInstanceOfMetaClass(String.class);
	}

	@Test
	public void testGetDefaultInstanceOfDouble() {
		testGetDefaultInstanceOfMetaClass(Double.class);
	}

	@Test
	public void testGetDefaultInstanceOfInteger() {
		testGetDefaultInstanceOfMetaClass(Integer.class);
	}

	@Test
	public void testGetDefaultInstanceOfBoolean() {
		testGetDefaultInstanceOfMetaClass(Integer.class);
	}

	@Test
	public void testGetDefaultInstanceOfBase() {
		testGetDefaultInstanceOfMetaClass(Base.class);
	}

	@Test
	public void testGetDefaultInstanceOfClassWithoutDefaultConstructor() {
		thrown.expect(IllegalStateException.class);
		testGetDefaultInstanceOfMetaClass(Sample.class);
	}

	@Test
	public void testGetDefaultInstanceOfAbstractClass() {
		thrown.expect(IllegalStateException.class);
		testGetDefaultInstanceOfMetaClass(Abstract.class);
	}

	public void testGetDefaultInstanceOfMetaClass(Object platformClass) {
		IMetaClass<Object> metaClass = factory.getMetaClass(platformClass);
		metaClass.getDefaultInstance();
	}

	// Default instance values

	@Test
	public void testDefaultInstanceOfInteger() {
		testDefaultInstanceOfMetaClass(Integer.class, new Integer(0));
	}

	@Test
	public void testDefaultInstanceOfDouble() {
		testDefaultInstanceOfMetaClass(Double.class, new Double(0));
	}

	@Test
	public void testDefaultInstanceOfBoolean() {
		testDefaultInstanceOfMetaClass(Boolean.class, new Boolean(false));
	}

	@Test
	public void testDefaultInstanceOfString() {
		testDefaultInstanceOfMetaClass(String.class, new String(""));
	}

	public <C> void testDefaultInstanceOfMetaClass(Class<C> platformClass, Object expectedDefault) {
		IMetaClass<C> metaClass = factory.getMetaClass(platformClass);
		assertEquals(expectedDefault, metaClass.getDefaultInstance());
	}

	// Set default instance

	@Test
	public void testSetDefaultInstanceOfAbstractClass() {
		testSetDefaultInstanceOfMetaClass(Abstract.class, new Concrete());
	}

	@Test
	public void testSetDefaultInstanceOfConcreteClass() {
		testSetDefaultInstanceOfMetaClass(Concrete.class, new Concrete());
	}

	@Test
	public void testReSetDefaultInstanceOfBoolean() {
		thrown.expect(IllegalStateException.class);
		testSetDefaultInstanceOfMetaClass(Boolean.class, new Boolean(true));
	}

	@Test
	public void testSetDefaultInstanceOfMetaClassToNull() {
		thrown.expect(IllegalArgumentException.class);
		testSetDefaultInstanceOfMetaClass(Sample.class, null);
	}

	public void testSetDefaultInstanceOfMetaClass(Object platformClass, Object defaultInstance) {
		IMetaClass<Object> metaClass = factory.getMetaClass(platformClass);
		metaClass.setDefaultInstance(defaultInstance);
		assertEquals(defaultInstance, metaClass.getDefaultInstance());
	}

	// Property accessor

	@Test
	public void testGetPropertyAccessorForInvalidPropertyName() {
		thrown.expect(IllegalArgumentException.class);
		testGetPropertyAccessorOfMetaClass(Sample.class, "prop", null);
	}

	public void testGetPropertyAccessorOfMetaClass(Object platformClass, Object propertyName, Object instance, Object... exceptedPropertyElements) {
		IMetaClass<Object> metaClass = factory.getMetaClass(platformClass);
		IUnaryFunction<Object, IBox<Object>> accessor = metaClass.getPropertyAccessor(propertyName);
		assertEquals(Arrays.asList(exceptedPropertyElements), accessor.apply(instance));
	}


}
