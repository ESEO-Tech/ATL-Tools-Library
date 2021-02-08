/****************************************************************
 *  Copyright (C) 2020 ESEO, Université d'Angers 
 *
 *  This program and the accompanying materials are made
 *  available under the terms of the Eclipse Public License 2.0
 *  which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 *  Contributors:
 *    - Frédéric Jouault
 *    - Théo Le Calvar
 *
 *  version 1.0
 *
 *  SPDX-License-Identifier: EPL-2.0
 ****************************************************************/

package fr.eseo.atlc.example.scheduling.transfo

import fr.eseo.aof.extensions.AOFExtensions
import fr.eseo.atol.gen.ATOLGen
import fr.eseo.atol.gen.ATOLGen.Metamodel
import fr.eseo.atol.gen.plugin.constraints.common.Constraints
import java.util.HashMap
import java.util.Map

@ATOLGen(transformation="src/fr/eseo/atlc/example/scheduling/transfo/SchedulingConstraints.atl", metamodels = #[
	@Metamodel(name = "Scheduling", impl = Scheduling),
	@Metamodel(name="Constraints", impl=Constraints)
]
//, extensions = #[
//	@Extension(impl = Constraints, args = #[
//		@VariableRelation(type = Task, referenceName = "slot")
//	])
//]
, extensions = #[Constraints])
class SchedulingConstraints implements AOFExtensions {

	public val trace = new HashMap<Object, Map<String, Object>>
/*
	def manualRefine(Resource r) {
		val allTimeSlots = allContents(r, Scheduling.TimeSlot)

		// collectTo does not work with virtual result box (i.e., lazy computation)
//		TupleRule.collectTo(
//			allTimeSlots.collect[
//				new SourceTupleTimeSlot(it)
//			],
//			TimeSlot
//		)

		onceForEach(allTimeSlots, [refineTimeSlot null], [], [])
	}

	def manualRefineTimeSlot(TimeSlot s) {
		SchedulingMM.__totalCost.apply(s).bind(
			new Sum(SchedulingMM.cost(SchedulingMM._tasks(s)), 0.0f, [$0+$1], [$0-$1]).result
		)
	}

	// using specific tuples might be necessary to support multiple source|target elements
  public static class SourceTupleTimeSlot {
    new(TimeSlot s) {
      super()
      this.s = s
    }
    
    public final TimeSlot s;
    
    override equals(Object o) {
      if(o instanceof SourceTupleTimeSlot) {
    	Objects.equals(this.s, o.s)
      } else {
      	false
      }
      
    }
    
    override hashCode() {
      Objects.hash(s);
    }
  }
  
  public static class TargetTupleTimeSlot {
    new() {
      super()
    }
  }
	val TimeSlot = new TupleRule(SourceTupleTimeSlot, TargetTupleTimeSlot)[s, t |
		refineTimeSlot(s.s)
	]
*/
}