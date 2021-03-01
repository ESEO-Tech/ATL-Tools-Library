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

import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;

import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver;

public class Inspect<E> extends Self<E> {

	public static boolean enable = true;

	private static Map<Class<?>, IUnaryFunction<?, String>> toStringFunctions = new HashMap<Class<?>, IUnaryFunction<?, String>>();

	public static <T> void registerToString(Class<T> clazz, IUnaryFunction<? super T, String> toString) {
		if (toString == null) {
			toStringFunctions.remove(clazz);
		} else {
			toStringFunctions.put(clazz, toString);
		}
	}

	public static <T> String toString(T object) {
		return toString(object, null);
	}

	public static <T> String toString(T object, IUnaryFunction<? super T, String> toString) {
		if (object == null) {
			return "null";
		} else if (toString != null) {
			return toString.apply(object);
		} else if (toStringFunctions.containsKey(object.getClass())) {
			IUnaryFunction<T, String> toString2 = (IUnaryFunction<T, String>) toStringFunctions.get(object.getClass());
			return toString2.apply(object);
		} else {
			// Note: the first matching function will be used, therefore registration order matters
			for(Entry<Class<?>, IUnaryFunction<?, String>> entry : toStringFunctions.entrySet()) {
				if(entry.getKey().isAssignableFrom(object.getClass())) {
					// the mapping object.getClass()->entry.getValue() could be cached, but would need to be properly invalidated in registerToString
					return ((IUnaryFunction<Object, String>) entry.getValue()).apply(object);
				}
			}
			return object.toString();
		}
	}

	private String label;
	private IUnaryFunction<? super E, String> toString;

	public Inspect(IBox<E> sourceBox, String label) {
		this(sourceBox, label, null);
	}

	public Inspect(IBox<E> sourceBox, String label, IUnaryFunction<? super E, String> toString) {
		super(sourceBox);
		this.label = label;
		this.toString = toString;
		sourceBox.addObserver(new SourceObserver()); // registerObservation is useless
		display(null, 0, null);
	}

	public static <A> String toString(IBox<A> box, IUnaryFunction<? super A, String> toString) {
		StringBuffer buffer = new StringBuffer();
		buffer.append(box.getConstraints());
		buffer.append("(");
		boolean first = true;
		for (A element : box) {
			if (first) {
				first = false;
			} else {
				buffer.append(", ");
			}
			buffer.append(toString(element, toString));
		}
		buffer.append(")");
		return buffer.toString();
	}

	private void display(String event, int i, E e) {
		if (enable) {
			System.out.println(label + Inspect.toString(getResult(), toString));
			if (event != null) {
				System.out.println(tab(label, i) + "^ " + event + "(" + i + ", " + Inspect.toString(e, toString) + ")");
			}
		}
	}

	/**
	 * Builds a tab from the size of the whole inspect string. This tab
	 * enhances displaying operations on the observable 'a'
	 * 
	 * @param label
	 *            a string to display
	 * @param index
	 *            the index of the element to tabulate
	 * @return a tab
	 */
	private String tab(String label, int index) {
		String spaces = "";
		for (int i = 0; i < label.length(); i++) {
			char c = label.charAt(i);
			if (Character.isWhitespace(c)) {
				spaces += c;
			} else {
				spaces += " ";
			}
		}
		int length = getResult().toString().indexOf("(") + 1;
		for (int i = 0; i < index; i++) {
			length += Inspect.toString(getResult().get(i), toString).length() + ", ".length();
		}
		for (int i = 0; i < length; i++) {
			spaces += " ";
		}

		return spaces;
	}

	protected class SourceObserver extends DefaultObserver<E> {

		@Override
		public void added(int index, E element) {
			display("added", index, element);
		}

		@Override
		public void removed(int index, E element) {
			display("removed", index, element);
		}

		@Override
		public void replaced(int index, E newElement, E oldElement) {
			display("replaced", index, newElement);
		}

		@Override
		public void moved(int newIndex, int oldIndex, E newElement) {
			display("moved", newIndex, newElement);
		}

	}

}
