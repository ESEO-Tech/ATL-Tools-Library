import org.eclipse.papyrus.aof.core.AOFFactory;
import org.eclipse.papyrus.aof.core.IBox;
import org.eclipse.papyrus.aof.core.IUnaryFunction;
import org.junit.Test;

public class TestCollectBoxBug {

	private static class O {
		public final IBox<Integer> elements;
		public O(Integer...elements) {
			this.elements = AOFFactory.INSTANCE.createSequence(elements);
		}
	}

	// crashes when CollectBox uses a Weak...Cache2 because the Pair is collected before the second call to collectMutable
	@Test
	public void test() throws Exception {
		O a1 = new O(1, 2, 3);
		O a2 = new O(1, 2, 3);
		O a3 = new O(1, 2, 3);
		IBox<O> a = AOFFactory.INSTANCE.createSequence(a1, a2, a3);
		a.inspect("a: ");

		IUnaryFunction<O, IBox<Integer>> f = new IUnaryFunction<O, IBox<Integer>>() {
			@Override
			public IBox<Integer> apply(O parameter) {
				if(parameter == null) {
					return (IBox<Integer>)(IBox<?>)IBox.SEQUENCE;
				} else {
					return parameter.elements;
				}
			}
		};

		IBox<Integer> b = a.collectMutable(f);
		b.inspect("b: ");

		System.gc();	// essential to trigger the bug

		IBox<Integer> c = a.collectMutable(f);
		c.inspect("c: ");

		a2.elements.add(4);
	}
}
