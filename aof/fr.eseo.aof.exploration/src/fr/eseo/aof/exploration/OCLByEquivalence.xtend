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

package fr.eseo.aof.exploration

import fr.eseo.aof.exploration.helperboxes.Naturals
import java.util.HashMap
import java.util.Map
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.IOne
import org.eclipse.papyrus.aof.core.IOption
import org.eclipse.papyrus.aof.core.IPair
import org.eclipse.papyrus.aof.core.ISequence
import org.eclipse.papyrus.aof.core.ISingleton

// TODO: test
// TODO: use non-zero Naturals instead of Naturals to get correct 1-based indices?
/*
 * TODO:
 * - classify operations wrt. whether they need a native implementation (NeedNative) or not (NoNeedNative)
 * 		- some operations cannot be kept as is, but may not need a native implementation, only a better way to express them
 * 			- possibly in terms of a missing native operation (not necessarily defined in OCL spec)
 * 			- e.g., this might be the case for index-based operations like indexOf, at, subSequence, ...
 * 		- sometimes this is conditional
 * 		- sometimes it is not decided yet
 * TODO[Complexity]:
 * - fully annotate time complexity for init, prop (all kinds), as well as space complexity (notably in terms of number of boxes)
 * - determinate which operations (among those present or not) should be directly implemented in order to reduce complexities of as
 * many operations as possible
 * 
 * Remark: some operations depending on "indexed" are O(n) on insertion, whereas they could be O(1) (e.g., at)
 * 
 * 
 * A dispatch (or partition) operation could be interesting:
 * - its lambda would return an index of the target box in which to put the result
 * - could be used to split...
 */
class OCLByEquivalence {

	private static val factory = AOFFactory.INSTANCE

	def static serialize(String label, (ISequence<Integer>)=>IBox<?> action) {
		label.serializeConditionally(true, action)
	}
	def static serializeNot(String label, (ISequence<Integer>)=>IBox<?> action) {
		label.serializeConditionally(false, action)
	}

	def static serializeConditionally(String label, boolean serialize, (ISequence<Integer>)=>IBox<?> action) {
		val ser = if(serialize) new PipesSerializer else null

		// create it anew each time, to make sure it is part of the serialization
		val a = factory.createSequence(1, 2, 3, 100, 123, 101, 120, 103)

		action.apply(a).inspect('''	«label»: ''')

		if(ser != null as Object)
			ser.serialize('''«label».plantuml''')

		println("Appending 4 to source box")		
		a.add(4)

		println("Prepending 5 to source box")		
		a.add(0, 5)
	}

	def static void main(String[] args) {

		println("Initialization")
		"first".serialize[
			it.first
		]
		"indexed".serialize[
			it.indexed
		]
		"tail".serialize[
			it.tail
		]
		"at".serialize[
			it.at(2)
		]
		"atM".serialize[
			it.at(factory.createOne(2))
		]
		"last".serialize[
			it.last
		]

		"forAll".serialize[
			it.forAll[it > 2]
		]

		"iterateString".serializeNot[
			it.iterate("")[e, acc |
//*
				if(acc.empty) {
					e.toString
				} else {
					acc + ", " + e
				}
/*/
				acc + e
/**/
			]
		]

		"reverse".serializeNot[
			it.reverse
		]

		"sum".serialize[
			it.sum
		]

		"max".serialize[
			it.max
		]

		"equals".serialize[
			(it == factory.createSequence(1, 2, 3, 4))
		]

		"product".serialize[
			it.product(factory.createSequence("a", "b"))
		]

		"insertAt".serialize[
			it.insertAt(2, 10)
		]
		"prepend".serialize[
			it.prepend(10)
		]
		"append".serialize[
			it.append(10)
		]
		"excluding".serialize[
			it.excluding(4)
		]
		"flatten1".serialize[
			it.flatten
		]
		"flatten2".serialize[
			#[#[1, 2, 3].toSeq, it, #[4, 5, 6].toSeq].toSeq.flatten
		]
		"flatten3".serialize[
			#[#[#[1, 2, 3].toSeq, it, #[4, 5, 6].toSeq].toSeq].toSeq.flatten
		]
		"sortedBy".serialize[
			it.sortedBy[it]
		]
	}

	def static <E> IOne<Boolean> operator_equals(IBox<E> box, IBox<E> other) {
		box.size.zipWith(other.size)[$0 == $1].zipWith(
			box.zipWith(other)[
				$0 == $1
			].iterate(true)[
				$0 && $1
			]
		)[
			$0 && $1
		].asOne(false)
	}

	// O(n)
	// But also O(n) boxes
	def static <E, R> IBox<R> iterate(IBox<E> box, R init, (E, R)=>R loopExpr) {
		box.first.collectMutable[
			if(it == null as E) {
				IBox.SEQUENCE as IBox<R>
			} else {
				box.tail.iterate(
					loopExpr.apply(it, init),
					loopExpr
				)
			}
		].append(init).first
	}

	def static <E, R> IBox<R> iterate(IBox<E> box, IOne<R> init, (E, R)=>R loopExpr) {
		box.first.collectMutable[
			if(it == null as E) {
				IBox.SEQUENCE as IBox<R>
			} else {
				box.tail.iterate(
					init.collect[b | loopExpr.apply(it, b)].asOne(null),
					loopExpr
				)
			}
		].append(init).first
	}

	// reverse: should be based on a generic operation that implements permutations
	def static <E> IBox<E> reverse(IBox<E> box) {
		box.iterate(IBox.SEQUENCE as IBox<E>)[
			$1.prepend($0)
		].collectMutable[
			if(null as Object== it) {
				IBox.SEQUENCE as IBox<E>
			} else {
				it
			}
		]
	}

	/*
	 * helper context <E, R> Sequence(E) def: iterate(init : R, (E, R)=>R loopExpr) : R =
	 * 		if self.isEmpty then
	 * 			init
	 * 		else
	 * 			self.tail.iterate(loopExpr(self.first, init), loopExpr)
	 * 		endif
	 */


	// TODO: sum & max would be better if based on a directly implemented reduce, or even better if directly implemented (notably for sum) 

	def static IOne<Integer> max(IBox<Integer> box) {
		box.iterate(Integer.MIN_VALUE)[e, acc |
			if(e > acc) {
				e
			} else {
				acc
			}
		].asOne(Integer.MIN_VALUE)
	}

	// TODO: make it work for any type having a + operator?
	def static IOne<Integer> sum(IBox<Integer> box) {
		box.iterate(0)[
			$0 + $1
		].asOne(0)
	}

	// TODO: make it work for any type having a + operator?
	def static IOne<Double> sumDouble(IBox<Double> box) {
		box.iterate(0.0)[
			$0 + $1
		].asOne(0.0)
	}

	// O(n)
	// NoNeedNative
	def static <E> IOne<Boolean> includes(IBox<E> box, E element) {
		box.select[
			element == it
		].notEmpty
	}

	// O(n)
	// NoNeedNative if AOF2 avoids the many ones.
	def static <E> IOne<Boolean> includes(IBox<E> box, IOne<E> element) {
		box.select[
			element == it
		].notEmpty
	}

	// O(n.m)
	def static <E> IOne<Boolean> includesAll(IBox<E> box, IBox<E> element) {
		element.select[
			!box.includes(it)
		].isEmpty
	}

	// O(n)
	// NoNeedNative
	def static <E> IOne<Boolean> excludes(IBox<E> box, E element) {
		box.select[
			element == it
		].isEmpty
	}

	// O(n)
	// NoNeedNative if AOF2 avoids the many ones.
	def static <E> IOne<Boolean> excludes(IBox<E> box, IOne<E> element) {
		box.select[
			element == it
		].isEmpty
	}

	// O(n.m)
	def static <E> IOne<Boolean> excludesAll(IBox<E> box, IBox<E> element) {
		element.select[
			box.includes(it)
		].isEmpty
	}

	// O(n)
	// NoNeedNative
	def static <E> IOne<Integer> count(IBox<E> box, E element) {
		box.select[
			element == it
		].size
	}

	// O(n)
	// NoNeedNative if AOF2 avoids the many ones.
	def static <E> IOne<Integer> count(IBox<E> box, IOne<E> element) {
		box.select[
			element == it
		].size
	}

	// O(n²)
	def static <L, R> IBox<IPair<L, R>> product(IBox<L> box, IBox<R> other) {
		box.collectMutable[e1 |
			other.collect[e2 |
				factory.createPair(e1, e2)
			]
		]
	}

//	def static <E, C extends E> IBox<C> selectByKind(IBox<E> box, Class<C> type) {
//		box.select(type)
//	}

	def static <E, C extends E> IBox<C> selectByType(IBox<E> box, Class<C> type) {
		box.select[type == it.class] as IBox<C>
//		box.select(type)	?
	}

	// TODO: get rid of the IOnes, or make them constant
	def static <E> IBox<E> flatten(IBox<?> box) {
		box.collectMutable[
			switch it {
				case null: IBox.SEQUENCE as IBox<E>
				IBox<?>: it.flatten
				default: factory.createOne(it)
			} as IBox<Object>
		] as IBox<E>
	}

	// O(n²)
	// Only for sets?*
	def static <E> IBox<E> intersection(IBox<E> box, IBox<E> other) {
		box.select[
			other.includes(it)
		]
	}

	// O(n²)
	// Only for sets?
	def static <E> IBox<E> operator_minus(IBox<E> box, IBox<E> other) {
		box.select[
			other.excludes(it)
		]
	}

	// Only for sets?
	def static <E> IBox<E> operator_symmetricDifference(IBox<E> box, IBox<E> other) {
		(box - other).union(other - box)
	}

	// O(n)
	def static <E> IBox<E> append(IBox<E> box, E element) {
		box.append(factory.createOne(element))
	}

	// O(n)
	// unidir (because of Concat implementation, but could easily be bidir when one of the arguments is an IOne)
	def static <E> IBox<E> append(IBox<E> box, IOne<E> element) {
		box.concat(element)
	}

	// O(n)
	def static <E> IBox<E> prepend(IBox<E> box, E element) {
		box.prepend(factory.createOne(element))
	}

	// O(n)
	// unidir (because of Concat implementation, but could easily be bidir when one of the arguments is an IOne)
	def static <E> IBox<E> prepend(IBox<E> box, IOne<E> element) {
		element.concat(box)
	}

	// O(n)
	def static <E> IBox<E> including(IBox<E> box, E element) {
		box.append(element)
	}

	// O(n)
	// unidir (because of Concat implementation, but could easily be bidir when one of the arguments is an IOne)
	def static <E> IBox<E> including(IBox<E> box, IOne<E> element) {
		box.append(element)
	}

	// O(n)
	// NoNeedNative
	def static <E> IBox<E> excluding(IBox<E> box, E element) {
		box.select[
			element != it
		]
	}

	// O(n)
	// NoNeedNative if AOF2 avoids the many ones.
	def static <E> IBox<E> excluding(IBox<E> box, IOne<E> element) {
		box.select[
			element != it
		]
	}

	// O(n)
	def static <E> IOption<E> at(IBox<E> box, int index) {
		box.indexed.select[
			it.right == index - 1
		].left.first
	}

	// O(n)
	def static <E> IOption<E> at(IBox<E> box, IOne<Integer> index) {
		box.indexed.select[e |
//			e.right == index - 1
			// optimization to reduce the number of intermediate collects
			index.collect[i | i - 1 == e.right] as IOne<Boolean>
		].left.asOption
	}

	// TODO: duplicate for subOrderedSet
	def static <E> ISequence<E> subSequence(ISequence<E> box, int lower, int upper) {
		box.indexed.select[
			it.right >= lower - 1 && it.right <= upper - 1
		].left.asSequence
	}

	def static <E> ISequence<E> subSequence(ISequence<E> box, IOne<Integer> lower, IOne<Integer> upper) {
		box.indexed.select[
			it.right >= lower - 1 && it.right <= upper - 1
		].left.asSequence
	}

	def static <E> ISequence<E> subSequence(ISequence<E> box, int lower, IOne<Integer> upper) {
		box.indexed.select[
			it.right >= lower - 1 && it.right <= upper - 1
		].left.asSequence
	}

	def static <E> ISequence<E> subSequence(ISequence<E> box, IOne<Integer> lower, int upper) {
		box.indexed.select[
			it.right >= lower - 1 && it.right <= upper - 1
		].left.asSequence
	}

	// TODO: duplicate for subOrderedSet
	def static <E> ISequence<E> insertAt(ISequence<E> box, int index, E element) {
			(
				box.subSequence(1, index - 1)
			).append(element).concat(
				box.subSequence(index, Integer.MAX_VALUE)
			).asSequence
	}

	def static <E> ISequence<E> insertAt(ISequence<E> box, IOne<Integer> index, E element) {
			(
				box.subSequence(1, index - 1)
			).append(element).concat(
				box.subSequence(index, Integer.MAX_VALUE)
			).asSequence
	}

	def static <E> ISequence<E> insertAt(ISequence<E> box, IOne<Integer> index, IOne<E> element) {
			(
				box.subSequence(1, index - 1)
			).append(element).concat(
				box.subSequence(index, Integer.MAX_VALUE)
			).asSequence
	}

	def static <E> ISequence<E> insertAt(ISequence<E> box, int index, IOne<E> element) {
			(
				box.subSequence(1, index - 1)
			).append(element).concat(
				box.subSequence(index, Integer.MAX_VALUE)
			).asSequence
	}

	// NoNeedNative
	def static <E> IOption<E> first(IBox<E> box) {
		box.asOption
	}

	// last
	def static <E> IOption<E> last(IBox<E> box) {
		box.at(box.size)
	}

	def static <E> IOne<Integer> indexOf(IBox<E> box, E element) {
		box.indexed.select[
			it.left == element
		].right.asOne(-1)
	}

	def static <E> IOne<Integer> indexOf(IBox<E> box, IOne<E> element) {
		box.indexed.select[
			it.left == element
		].right.asOne(-1)
	}

	// NoNeedNative
	def static <E> IOption<E> any(IBox<E> box, (E)=>Boolean selector) {
		box.select(selector).first
	}

//	def static <E> IOption<E> any(IBox<E> box, (E)=>IOne<Boolean> selector) {
	// why uncommenting breaks xtend?
//	def static <E> IOption<E> any(IBox<E> box, IUnaryFunction<E, IOne<Boolean>> selector) {
//		box.select(selector).first
//	} 

	def static <E> IBox<E> closure(IBox<E> box, (E)=>IBox<E> loopExpr) {
		Closure.closure(box, loopExpr)
	}

	// NoNeedNative
	def static <E> IOne<Boolean> exists(IBox<E> box, (E)=>Boolean loopExpr) {
//		box.collect(loopExpr).iterate(false)[$0 || $1].asOne(false)
		box.select(loopExpr).notEmpty
	}

	// TODO: for this and other similar operations: implement the Mutable version (with an (E)=>IOne<Boolean> loopExpr argument)
	def static <E> IOne<Boolean> forAll(IBox<E> box, (E)=>Boolean loopExpr) {
//		box.collect(loopExpr).iterate(true)[$0 && $1].asOne(false)
//		box.select(loopExpr).size == box.size
		box.select(loopExpr).size.zipWith(box.size)[$0 == $1] as IOne<Boolean>
	}

	// optimization: if distinct was based on a HashSet
	def static <E, R> IOne<Boolean> isUnique(IBox<E> box, (E)=>R loopExpr) {
		box.collect(loopExpr).distinct.size == box.size
	}

	// NoNeedNative
	def static <E, R> IOne<Boolean> one(IBox<E> box, (E)=>Boolean loopExpr) {
		box.select(loopExpr).size == 1
	}

	def static <E, R> IBox<E> reject(IBox<E> box, (E)=>Boolean loopExpr) {
		box.select[!loopExpr.apply(it)]
	}

	def static <E, R> IBox<E> rejectMutable(IBox<E> box, (E)=>IOne<Boolean> loopExpr) {
		box.select[!loopExpr.apply(it)]
	}

	// TODO: sortedBy
	def static <E, R extends Comparable<R>> sortedBy(IBox<E> box, (E)=>R loopExpr) {
		sortedByRight(
			box.collect[
				factory.createPair(it, loopExpr.apply(it))
			], ""
		).left
	}

	// TODO: resolve problem that the selectMutable inside the collectMutable are notified via their InnerBoxObserver BEFORE being notified via their SourceObserver
	// AOF2 may resolve the problem by proper graph analysis... but this would require considering this collectMutable to be an n-ary operation:
	// one source box, but multiple other boxes referenced in its lambda
	private def static <E, R extends Comparable<R>> IBox<IPair<E, R>> sortedByRight(IBox<IPair<E, R>> box, String depth) {
		val pivot = box.at(
			box
				.size
				.collect[it / 2 + 1]
				as IOne<Integer>
		).inspect('''pivot«depth»: ''') as ISingleton<IPair<E, R>>
		val cache = newArrayOfSize(1)
		pivot
			.collect[0]	// make sure we have a constant
			.collectMutable[
				if(it as Object == null as Object) {
					IBox.SEQUENCE as IBox<?> as IBox<IPair<E, R>>
				} else if(cache.get(0) as Object != null as Object) {
					cache.get(0)
				} else {
					println('''pivot«depth»: «pivot»''')
					val lower = box.select[it.right < pivot.right]
						.inspect('''lower«depth»: ''')
					val equal = box.select[it.right == pivot.right]
						.inspect('''equal«depth»: ''')
					val upper = box.select[it.right > pivot.right]
						.inspect('''upper«depth»: ''')
					val ret = sortedByRight(lower, depth + "L").concat(equal).concat(sortedByRight(upper, depth + "U"))
					cache.set(0, ret)
					ret
				}
			]
	}

	// helpers

	static val indexedCache = new HashMap
	def static <E> IBox<IPair<E, Integer>> indexed(IBox<E> box) {
		indexedCache.cached(box)[
			box.zip(Naturals.INSTANCE, false)
		]
	}

	def static <E> IBox<E> tail(IBox<E> box) {
		box.asSequence.subSequence(2, Integer.MAX_VALUE)
	}

	// Lifted methods

	def static <L, R> IBox<L> left(IBox<IPair<L, R>> box) {
		box.collect[it.left]
	}

	private def static <K, V> V cached(Map<?, ?> cache, K box, ()=>V compute) {
		val existing = cache.get(box)
		if(existing != null as Object) {
			existing as V
		} else {
			val ret = compute.apply()
			(cache as Map<K, V>).put(box, ret)
			ret
		}
	}

	static val rightCacheBox = new HashMap<IBox<?>, IBox<?>>
	def static <L, R> IBox<R> right(IBox<IPair<L, R>> box) {
		rightCacheBox.cached(box)[
			box.collect[it.right]
		]
	}

	static val rightCacheSingle = new HashMap<IBox<?>, IBox<?>>
	def static <L, R> ISingleton<R> right(ISingleton<IPair<L, R>> box) {
		rightCacheSingle.cached(box)[
			box.collect[it.right] as ISingleton<R>
		]
	}

	// Lifted operators

	def static IOne<Boolean> operator_not(IOne<Boolean> box) {
		box.collect[!it].asOne(false)
	}

	def static <E> IOne<Boolean> operator_equals(ISingleton<E> box, E element) {
		box.collect[it == element].asOne(false)
	}

	def static <E> IOne<Boolean> operator_equals(E element, ISingleton<E> box) {
		box == element
	}

	def static <E> IOne<Boolean> operator_notEquals(IOne<E> box, E element) {
		box.collect[it != element].asOne(false)
	}

	def static <E> IOne<Boolean> operator_notEquals(E element, IOne<E> box) {
		box != element
	}

	def static IOne<Integer> operator_minus(IOne<Integer> left, int right) {
		left.collect[it - right].asOne(0)
	}

	def static <E extends Comparable<E>> IOne<Boolean> operator_greaterEqualsThan(E left, IOne<E> right) {
		right.collect[left >= it].asOne(false)
	}

	static val greaterThanRightCache = new HashMap
	def static <E extends Comparable<E>> IOne<Boolean> operator_greaterThan(E left, ISingleton<E> right) {
		greaterThanRightCache.cached(left -> right)[
			right.collect[left > it].asOne(false)
		]
	}

	def static <E extends Comparable<E>> IOne<Boolean> operator_lessEqualsThan(E left, IOne<E> right) {
		right.collect[left <= it].asOne(false)
	}

	static val lessRightThanCache = new HashMap
	def static <E extends Comparable<E>> IOne<Boolean> operator_lessThan(E left, ISingleton<E> right) {
		lessRightThanCache.cached(left -> right)[
			right.collect[left < it].asOne(false)
		]
	}

	def static <E extends Comparable<E>> IOne<Boolean> operator_lessThan(IOne<E> left, E right) {
		left.collect[it < right].asOne(false)
	}

	def static IOne<Boolean> operator_and(IOne<Boolean> left, IOne<Boolean> right) {
		left.zipWith(right)[$0 && $1].asOne(false)
	}

	def static IOne<Boolean> operator_and(IOne<Boolean> left, boolean right) {
		left.collect[it && right].asOne(false)
	}

	def static IOne<Boolean> operator_and(boolean left, IOne<Boolean> right) {
		right.collect[left && it].asOne(false)
	}

	def static IOne<Integer> operator_divide(IOne<Integer> left, int right) {
		left.collect[it / right].asOne(0)
	}

	// mutability hiders... is this really a good idea?
	//	anyway we cannot do it for to locally defined operations because of erasure (even if xtends type system can find the right one)
	// To hide the Mutable suffix from {collect,select}Mutable
	// TODO: add co- and contra-variance
 
	def static <E, R> IBox<R> collect(IBox<E> box, (E)=>IBox<R> collector) {
		box.collectMutable(collector)
	}

	def static <E> IBox<E> select(IBox<E> box, (E)=>IOne<Boolean> selector) {
		box.selectMutable(selector)
	}

	// Other operations

	def static <E> toSeq(Iterable<E> iterable) {
		val ret = factory.createSequence()
		ret.assign(iterable)
		ret
	}

	def static <E> IOne<E> choose(IOne<E> left, IOne<E> right, IOne<Boolean> condition) {
		left.select[condition].concat(right).asOne(null)
	}
}
