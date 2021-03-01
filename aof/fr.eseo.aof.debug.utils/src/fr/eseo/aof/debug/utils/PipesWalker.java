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

package fr.eseo.aof.debug.utils;


import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IObserver;
import org.eclipse.papyrus.aof.core.impl.BaseDelegate;
import org.eclipse.papyrus.aof.core.impl.Box;
import org.eclipse.papyrus.aof.core.impl.operation.Bind;
import org.eclipse.papyrus.aof.core.impl.operation.Collect;
import org.eclipse.papyrus.aof.core.impl.operation.CollectBox;
import org.eclipse.papyrus.aof.core.impl.operation.Concat;
import org.eclipse.papyrus.aof.core.impl.operation.Distinct;
import org.eclipse.papyrus.aof.core.impl.operation.First;
import org.eclipse.papyrus.aof.core.impl.operation.Inspect;
import org.eclipse.papyrus.aof.core.impl.operation.Operation;
import org.eclipse.papyrus.aof.core.impl.operation.SelectWithMutablePredicate;
import org.eclipse.papyrus.aof.core.impl.operation.SelectWithPredicate;
import org.eclipse.papyrus.aof.core.impl.operation.SwitchCollect;
import org.eclipse.papyrus.aof.core.impl.operation.ZipWith;
import org.eclipse.papyrus.aof.emf.impl.FeatureDelegate;

import com.google.common.collect.HashBasedTable;
import com.google.common.collect.Table;

//import ttc2018.ConnectedComponents;

public class PipesWalker {

	private static Map<Class<?>, String> simpleNameCache = new HashMap<>();
	protected static String getSimpleName(Class<?> c) {
		return simpleNameCache.computeIfAbsent(c, Class::getSimpleName);
	}

	protected static <A, C> A javaGet(C o, String fieldName) {
		return javaGet(o, (Class<C>)o.getClass(), fieldName);
	}

	protected static <A, C> A javaGet(C o, Class<? super C> c, String fieldName) {
		try {
			Field f = getField(c, fieldName);//c.getDeclaredField(fieldName);
			f.setAccessible(true);
			return (A)f.get(o);
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	private static Table<Class<?>, String, Field> getFieldCache = HashBasedTable.create();
	protected static Field getField(Class<?> c, String fieldName) throws Exception {
		Field ret = getFieldCache.get(c, fieldName);
		if(ret == null) {
			try {
				ret = c.getDeclaredField(fieldName);
			} catch(Exception e) {}
			if(ret == null && c.getSuperclass() != null) {
				ret = getField(c.getSuperclass(), fieldName);
			}
			if(ret != null) {
				getFieldCache.put(c,  fieldName, ret);
			}
		}
//		System.out.println("getField(" + c.getSimpleName() + ", " + fieldName + ")");
		return ret;
	}

	protected static IObserver<?> unwrap(IObserver<?> observer) {
		String observerClassName = observer.getClass().getName();
		if(observerClassName.endsWith(".Operation$SilentObserver")) {	// necessary because SilentObserver is private
			observer = javaGet(observer, "wrappedObserver");
		}
		return observer;
	}

	public PipesWalker() {
		
	}

	public void accept(Object o, PipesVisitor visitor) {
		accept(o, visitor, true);
	}

	public void accept(Object o, PipesVisitor visitor, boolean forward) {
		if(forward) {
			traverse(o, visitor);
		} else {
			reverseTraverse(o, visitor);
		}
	}

	private void traverse(Object o, PipesVisitor visitor) {
		if(o instanceof Operation) {
			traverseOperation((Operation<?>)o, visitor);
		} else if(o instanceof IObserver<?>){
			IObserver<?> observer = unwrap((IObserver<?>)o);
			Object op = javaGet(observer, "this$0");	// remark: Bind does not extend Operation
			if(op instanceof Bind) {
				String observerClassName = getSimpleName(observer.getClass());
				IBox<?> comingFrom = javaGet(op, (observerClassName.startsWith("Left") ? "left" : "right") + "Box");
				traverseBind((Bind<?>)op, visitor, comingFrom);
			} else {
				traverse(op, visitor);
			}
		} else if(o instanceof Bind) {
			IBox<?> comingFrom = javaGet(o, "leftBox");
			traverseBind((Bind<?>)o, visitor, comingFrom);
		} else if(o instanceof IBox) {
			traverseBox((IBox<?>)o, visitor, null);
		} else if(o instanceof BaseDelegate){
			traverse(javaGet(o, "delegator"), visitor);
		} else {
			System.out.println("UNSUPPORTED by PipesWalker: " + o);
			new Exception().printStackTrace();
		}
	}

	// @param operation Operation of which this box is the result, if available
	private void traverseBox(IBox<?> box, PipesVisitor visitor, Operation<?> operation) {
		visitor.visit(box);
		BaseDelegate<?> delegate = javaGet((Box)box, Box.class, "delegate");
		if(delegate instanceof FeatureDelegate) {
			FeatureDelegate<?> featureDelegate = (FeatureDelegate<?>)delegate;
			EObject object = javaGet(featureDelegate, FeatureDelegate.class, "object");
			EStructuralFeature feature = javaGet(featureDelegate, FeatureDelegate.class, "feature");
			visitor.propertyBox(box, object, feature);
		}
		boolean first = true;
		for(IObserver<?> observer : box.getObservers()) {
			observer = unwrap(observer);
			String observerClassName = getSimpleName(observer.getClass());
			String observerToIgnore = "Result";
			if(operation instanceof Distinct<?>) {
				if(operation.getResult() != box) {
					observerToIgnore = "NonUniqueBox";
				} else {
					observerToIgnore = "UniqueBox";
				}
			}

//			if(!observer.getClass().getName().startsWith("org.eclipse.papyrus.")) {
//				continue;
//			}
			Object op = javaGet(observer, "this$0");
			if(op instanceof First) {
				boolean reversed = javaGet(op, "reversed");
				if(reversed) {
					observerToIgnore = "Source";
				}
			}
			if(observerClassName.startsWith(observerToIgnore)) {
				// ignore
			} else if(observerClassName.equals("ReverseAdapter")) {
				// ignore
			} else if(observerClassName.equals("InnerBoxObserver")) {
				// ignore, for DuplicateBoxesAnalyzer
				// TODO: add a parameter to PipesWalker to make this optional, or notify visitor differently for inner observers
			} else {
				if(first) {
					first = false;
				} else {
					visitor.next();
				}
				if(op instanceof Operation) {
					if(op instanceof First) {
						traverse(op, visitor);	// handled separately from Operation because it may be reversed and getResult() != box
					} else if(op instanceof Distinct<?>) {
//						if(oper.getResult() != result) {
//							traverseOperation(oper, result, visitor);
//						} else {
//							traverseOperation(oper, (IBox<?>)javaGet(op, "nonUniqueBox"), visitor);
//						}
						traverseDistinct((Distinct<?>)op, box, visitor);
					} else if(((Operation<?>)op).getResult() != box) {	// Self operations like inspect would introduce infinite recursion
						traverse(op, visitor);
					} else if(op instanceof Inspect<?>) {
						visitor.inspect((String)javaGet(op, "label"));
					} else {
						throw new UnsupportedOperationException(op.toString());
					}
				} else if(op instanceof Bind) {
					traverseBind((Bind<?>)op, visitor, box);
				} else {
//					throw new UnsupportedOperationException();
				}
			}
		}
	}

	private List<Object> getArguments(final Operation<?> operation) {
		List<Object> arguments = new ArrayList<Object>();
		if(operation instanceof SelectWithMutablePredicate || operation instanceof SelectWithPredicate) {
			arguments.add(javaGet(operation, "selector"));
		} else if(operation instanceof SwitchCollect) {
			arguments.add(javaGet(operation, "conditions"));
			arguments.add(javaGet(operation, "collectors"));
			arguments.add(javaGet(operation, "defaultCollector"));
			arguments.add(javaGet(operation, "reverseCollector"));
		} else if(operation instanceof Collect) {
			arguments.add(javaGet((Collect<?, ?>)operation, Collect.class, "collector"));
			Object reverseCollector = javaGet((Collect<?, ?>)operation, Collect.class, "inverseCollector");
			if(reverseCollector != null) {
				arguments.add(reverseCollector);
			}
		} else if(operation instanceof CollectBox) {
			arguments.add(javaGet(operation, "collector"));
		} else if(operation instanceof ZipWith) {
			arguments.add(javaGet(operation, "rightBox"));
			arguments.add(javaGet(operation, "zipper"));
			Object reverseCollector = javaGet(operation, "unzipper");
			if(reverseCollector != null) {
				arguments.add(reverseCollector);
			}
		} else if(operation instanceof Concat) {
			arguments.add(javaGet(operation, "rightBox"));
		} else if(operation instanceof Distinct) {
			// no argument
		} else {
			// TODO: take into account superclass fields + ignore first source box, and target boxes
			for(Field f : operation.getClass().getDeclaredFields()) {
				f.setAccessible(true);
				try {
					arguments.add(f.get(operation));
				} catch (IllegalArgumentException e) {
					e.printStackTrace();
				} catch (IllegalAccessException e) {
					e.printStackTrace();
				}
			}
		}
		return arguments;
	}

	private void traverseOperation(Operation<?> operation, PipesVisitor visitor) {
		List<Object> arguments = getArguments(operation);
		String operationName = getSimpleName(operation.getClass());
		visitor.enterOperation(operation, operationName, arguments.toArray());

		IBox<?> result = operation.getResult();
		if(operation instanceof First) {
			boolean reversed = javaGet(operation, "reversed");
			if(reversed) {
				result = javaGet(operation, "sourceBox");
			}
/*
		} else if(operation instanceof ConnectedComponents) {
//			Map cache = javaGet(operation, "setsCache");
			int i = 0;
			for(IBox<?> b : (IBox<IBox<?>>)result) {
				String opName = "ConnectedComponents[" + i + "]";
				visitor.enterOperation(operation, opName, new Object[] {i});
				traverseBox(b, visitor, operation);
				visitor.leaveOperation(operation, opName, new Object[] {i});
				i++;
			}
*/
		}
		traverseBox(result, visitor, operation);
		visitor.leaveOperation(operation, operationName, arguments.toArray());
	}

	private void traverseDistinct(Distinct<?> distinct, IBox<?> result, PipesVisitor visitor) {
		if(distinct.getResult() == result) {
//			throw new UnsupportedOperationException("swapped Distinct");
			System.out.println("swapped Distinct");
			traverseOperation(distinct, visitor);
		} else {
			traverseOperation(distinct, visitor);
		}
	}

	private void traverseBind(Bind<?> bind, PipesVisitor visitor, IBox<?> comingFrom) {
		Box<?> leftBox = javaGet(bind, "leftBox");
		Box<?> rightBox = javaGet(bind, "rightBox");
		if(comingFrom == leftBox) {
			visitor.bindTo(bind, rightBox);
		} else {
			visitor.bindTo(bind, leftBox);
		}
	}

	public static interface PipesVisitor {
		void enterOperation(Operation<?> operation, String operationName, Object...arguments);
		void leaveOperation(Operation<?> operation, String operationName, Object...arguments);
		void visit(IBox<?> box);
		void inspect(String label);
		void bindTo(Bind<?> bind, Box<?> otherBox);
		void next();	// next element in list
		void propertyBox(IBox<?> box, EObject object, EStructuralFeature feature);
		public void rootBox(IBox<?> box);	// boxes that are computed from nothing and that are not propertyBoxes
	}

	public static class PipesVisitorAdapter implements PipesVisitor {
		@Override
		public void enterOperation(Operation<?> operation, String operationName, Object...arguments) {
			// TODO Auto-generated method stub
		}

		@Override
		public void leaveOperation(Operation<?> operation, String operationName, Object...arguments) {
			// TODO Auto-generated method stub
		}

		@Override
		public void visit(IBox<?> box) {

		}

		@Override
		public void inspect(String label) {
			// TODO Auto-generated method stub
		}

		@Override
		public void bindTo(Bind<?> bind, Box<?> otherBox) {
			// TODO Auto-generated method stub
		}

		@Override
		public void next() {
			// TODO Auto-generated method stub
		}

		@Override
		public void propertyBox(IBox<?> box, EObject object, EStructuralFeature feature) {
			// TODO Auto-generated method stub
		}

		@Override
		public void rootBox(IBox<?> box) {
			// TODO Auto-generated method stub
		}
	}

	private void reverseTraverse(Object o, PipesVisitor visitor) {
		if(o instanceof Box) {
			Box<?> box = (Box<?>)o;
			visitor.visit(box);
			BaseDelegate<?> delegate = javaGet(box, Box.class, "delegate");
			if(delegate instanceof FeatureDelegate) {
				FeatureDelegate<?> featureDelegate = (FeatureDelegate<?>)delegate;
				EObject object = javaGet(featureDelegate, FeatureDelegate.class, "object");
				EStructuralFeature feature = javaGet(featureDelegate, FeatureDelegate.class, "feature");
				visitor.propertyBox(box, object, feature);
			} else {
				reverseTraverse(delegate, visitor);
			}
		} else if(o instanceof BaseDelegate){
			boolean traversed = false;
			for(IObserver<?> observer : ((BaseDelegate<?>) o).getObservers()) {
				observer = unwrap(observer);
				String observerClassName = getSimpleName(observer.getClass());
				String observerToKeep = "Result";
				String nextBox = "sourceBox";
				if(!observer.getClass().getName().startsWith("org.eclipse.papyrus.")) {
					System.out.println("Could not handle observer: " + observer);
					continue;
				}
				Object op = javaGet(observer, "this$0");
				if(op instanceof First) {
					boolean reversed = javaGet(op, "reversed");
					if(reversed) {
						observerToKeep = "Source";
						nextBox = "resultBox";
					}
				} else if(op instanceof ZipWith || op instanceof Concat) {
//					observerToKeep = "Left";	// no: we want the result because we are reverse-traversing
					nextBox = "leftBox";
				} else if(op instanceof Distinct && !traversed) {	// since we can only know the direction by looking at which box is the current one, then we must ignore if already traversed 
					nextBox = "nonUniqueBox";
					observerToKeep = "UniqueBox";
					Object nonUniqueBox = javaGet(op, nextBox);
					if(javaGet(nonUniqueBox, "delegate") == o) {
						// reversed
						nextBox = "resultBox";
						observerToKeep = "NonUniqueBox";
					}
				}
				if(observerClassName.startsWith(observerToKeep)) {

					if(op instanceof Operation) {
						Operation<?> operation = (Operation<?>)op;

						List<Object> arguments = getArguments(operation);
						String operationName = getSimpleName(operation.getClass());
						visitor.enterOperation(operation, operationName, arguments.toArray());

						System.out.println(op + "." + nextBox);
						Object sourceBox = javaGet(op, nextBox);
						reverseTraverse(sourceBox, visitor);
						visitor.leaveOperation(operation, operationName, arguments.toArray());

						traversed = true;
					} else {
						throw new UnsupportedOperationException("cannot reverse traverse " + op + " yet");
					}
				}
			}
			if(!traversed) {
				visitor.rootBox((IBox<?>)javaGet(o, "delegator"));
			}
		} else {
			throw new UnsupportedOperationException("cannot reverse traverse " + o + " yet");
		}
	}

//	for(box : boxes) {
//		for(obs : box.observers) {
//			var ocn = obs.class.name
//			var observer = obs
//			if(ocn.endsWith(".Operation$SilentObserver")) {
//				observer = observer.get("wrappedObserver")
//				ocn = observer.class.name
//			}
//			switch ocn.replaceFirst("^.*\\.", "") {
//				case "Bind$LeftObserver",
//				case "Bind$RightObserver": {
//					// bind
//				}
//				case "ListFeatureDelegate$ReverseAdapter": {
//					// "root" box
//				}
//				case "SelectWithPredicate$ResultObserver",
//				case "SelectWithMutablePredicate$ResultObserver",
//				case "First$ResultObserver",
//				case "ZipWith$ResultObserver",
//				case "Collect$ResultObserver",
//				case "CollectBox$ResultObserver",
//				case "SelectMutable$ResultObserver": {
//					// downstream
//				}
//				case "SelectWithMutablePredicate$InnerBoxObserver",
//				case "SelectWithMutablePredicate$SourceObserver",
//				case "SelectWithPredicate$SourceObserver",
//				case "ZipWith$LeftObserver",
//				case "ZipWith$RightObserver",
//				case "Concat$LeftObserver",
//				case "oncat$RightObserver",
//				case "Collect$SourceObserver",
//				case "First$SourceObserver",
//				case "CollectBox$InnerBoxObserver",
//				case "CollectBox$SourceObserver": {
//					// upstream
//				}
//				case "Distinct$UniqueBoxObserver",
//				case "Distinct$NonUniqueBoxObserver": {
//					// distinct... which one is upstream?
//				}
//				default: {
//					println(ocn)
//				}
//			}
//		}
//	}
}
