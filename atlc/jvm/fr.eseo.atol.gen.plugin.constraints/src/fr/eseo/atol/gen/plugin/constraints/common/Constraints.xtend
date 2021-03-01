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

package fr.eseo.atol.gen.plugin.constraints.common

import fr.eseo.aof.xtend.utils.AOFAccessors
import fr.eseo.atlc.constraints.CompositeExp
import fr.eseo.atlc.constraints.Constraint
import fr.eseo.atlc.constraints.ConstraintsPackage
import fr.eseo.atlc.constraints.DoubleExp
import fr.eseo.atlc.constraints.Expression
import fr.eseo.atlc.constraints.ExpressionGroup
import fr.eseo.atlc.constraints.IntExp
import fr.eseo.atlc.constraints.Strength
import fr.eseo.atlc.constraints.StrengthLevel
import fr.eseo.atlc.constraints.VariableRelationExp
import fr.eseo.atol.gen.ATOLGen
import fr.eseo.atol.gen.ATOLGen.CompilationHelper
import fr.eseo.atol.gen.AbstractRule
import fr.eseo.atol.gen.Metaclass
import java.util.function.Supplier
import javafx.scene.Node
import org.eclipse.emf.ecore.EObject
import org.eclipse.m2m.atl.common.ATL.Binding
import org.eclipse.m2m.atl.common.OCL.CollectionExp
import org.eclipse.m2m.atl.common.OCL.IntegerExp
import org.eclipse.m2m.atl.common.OCL.LetExp
import org.eclipse.m2m.atl.common.OCL.NavigationOrAttributeCallExp
import org.eclipse.m2m.atl.common.OCL.OclExpression
import org.eclipse.m2m.atl.common.OCL.OclModelElement
import org.eclipse.m2m.atl.common.OCL.OperationCallExp
import org.eclipse.m2m.atl.common.OCL.PropertyCallExp
import org.eclipse.m2m.atl.common.OCL.RealExp
import org.eclipse.m2m.atl.common.OCL.StringExp
import org.eclipse.m2m.atl.common.OCL.VariableExp
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.papyrus.aof.core.ISequence
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend2.lib.StringConcatenationClient

import static fr.eseo.atol.gen.MetamodelUtils.*
import java.rmi.UnexpectedException
import org.eclipse.m2m.atl.common.ATL.OutPatternElement
import fr.eseo.atlc.constraints.LocalSearch
import fr.eseo.atlc.constraints.OptimizationKind

@AOFAccessors(ConstraintsPackage)
class Constraints implements ATOLGen.Extension {

	// new "entrypoint"
	override compileBinding(Binding it, extension CompilationHelper compilationHelper) {
		val type = outPatternElement.type as OclModelElement
		val mmClass = type.model.name.mmClass
		val compilerMethodName = '''__«propertyName»Compiler'''.toString
		if(mmClass.declaredMethods.exists[m | m.simpleName == compilerMethodName]) {
			new ConstraintsCompiler(compilationHelper).compile(it)
		} else {
			null
		}
	}

	// old "entrypoint"
	// remark this project requires plugin ...atl.common because of this method
	def StringConcatenationClient __expressionsCompiler(Binding e, CompilationHelper compilationHelper) {
		new ConstraintsCompiler(compilationHelper).compile(e)
	}

	def StringConcatenationClient __expCompiler(Binding e, CompilationHelper compilationHelper) {
		new ConstraintsCompiler(compilationHelper).compile(e)
	}

	def StringConcatenationClient __valueCompiler(Binding e, CompilationHelper compilationHelper) {
		new ConstraintsCompiler(compilationHelper).compile(e)
	}

	def dispatch String prettyPrint(Expression it) {
		throw new UnsupportedOperationException('''Cannot pretty display «it»''')
	}
	
	def dispatch String prettyPrint(Constraint it) {
		if (arguments.size == 2) {
			'''«strength.prettyPrint» «arguments.get(0).prettyPrint» «operatorName» «arguments.get(1).prettyPrint»'''
		}
		else {
			'''«strength.prettyPrint» «operatorName»(«FOR a : arguments SEPARATOR ', '»«a.prettyPrint»«ENDFOR»)'''
		}
	}

	def dispatch String prettyPrint(ExpressionGroup it) {
		'''
			{	solver : «solver»
			«FOR e : expressions BEFORE '\t' SEPARATOR ',\n\t'»«e.prettyPrint»«ENDFOR»
			}
		'''
	}
	
	def dispatch String prettyPrint(CompositeExp it) {
		switch arguments.size {
			case 1:
				'''«operatorName» «arguments.get(0).prettyPrint»'''
			case 2:
				'''«arguments.get(0).prettyPrint» «operatorName» «arguments.get(1).prettyPrint»'''
			default: {
				'''«operatorName»«FOR a : arguments BEFORE '(' SEPARATOR ", " AFTER ')'»«a.prettyPrint»«ENDFOR»'''
			}
		}
	}

	def dispatch String prettyPrint(DoubleExp it) {
		'''«value»'''
	}

	def dispatch String prettyPrint(IntExp it) {
		'''«value»'''
	}

	def dispatch String prettyPrint(fr.eseo.atlc.constraints.VariableExp it) {
		val src = source
		var prefix = ""
		var suffix = ""
		var body = ""
		if (isConstant) {
			prefix = "["
			suffix = "]"
		}
		else if (isVector) {
			prefix = "{"
			suffix = "}"
		}
		
		if (src instanceof Node) {
			body = '''«src.id».«propertyName»'''
		}
		else if (src instanceof IBox<?>){
			body = '''box.«propertyName»'''
		}
		else if (src instanceof EObject) {
			body = '''«src.eResource.getURIFragment(src)».«propertyName»'''
		}
		else {
			body = '''«src.class.simpleName».«propertyName»'''
		}
		'''«prefix»«body»«suffix»'''
	}

	def dispatch String prettyPrint(VariableRelationExp it) {
		val src = source
		var prefix = ""
		var suffix = ""
		if (isConstant) {
			prefix = "["
			suffix = "]"
		}
		else if (isVector) {
			prefix = "{"
			suffix = "}"
		}
		var id = switch (src) {
			Node:
				src.id
			IBox<?>:
				'box'
			EObject:
				src.eResource.getURIFragment(src)
			default:
				src.class.simpleName
		}
		'''«prefix»«id».{«relationName»}«IF !propertyName.empty».«propertyName»«ENDIF»«suffix»'''
	}

	def dispatch String prettyPrint(Strength it) {
		'''«strength.prettyPrint» «IF weight != 1.0»{«weight»}«ENDIF»'''
	}

	def dispatch String prettyPrint(StrengthLevel it) {
		switch (it) {
			case REQUIRED : '''REQUIRED'''
			case STRONG : '''STRONG'''
			case MEDIUM : '''MEDIUM'''
			case WEAK : '''WEAK'''
		}
	}

	// "Block" metaclass for SimplifyConstraints.atl
	public static val Metaclass<ISequence<Expression>> ExpressionVector = [AOFFactory.INSTANCE.createSequence]

	public val __contents = [ISequence<Expression> it |
		it
	]
	
	public val __doubleValue = <DoubleExp, Double>oneDefault(0.0)[
		_value
	]

	public val __intValue = <IntExp, Integer>oneDefault(0)[
		_value
	]

	public val __weight = <Strength, Double>oneDefault(0.0)[
		_weight
	]

	public val __optimization = <LocalSearch, OptimizationKind>enumConverterBuilder([_optimization], OptimizationKind, "")
}

@Data
class ConstraintsCompiler {
	extension CompilationHelper compilationHelper

	val enableVariableReference = true
	val variableReferences = #{ //TODO : map is not a good structure, it cannot store more than 1 variable reference per class
		'c.period',
		'c.corequisites.target1.period',
		'c.requisites.target.period',
		's.isEncapsulatedBy'
	}

	def StringConcatenationClient compile(Binding it) {
		value.compileEntry(it)
	}

	dispatch def StringConcatenationClient compileEntry(OclExpression e, Binding it) {
		'''
			«e.compileCons(outPatternElement.varName, false)»
		'''
	}

	dispatch def isRuleCall(OclExpression it) {
		false
	}

	dispatch def isRuleCall(OperationCallExp it) {
		calledRule !== null
	}

	dispatch def StringConcatenationClient compileEntry(LetExp e, Binding it) {
		val initExpression = e.variable.initExpression
		val isConstraintExp = initExpression.isTarget && !initExpression.isRuleCall
		'''
			«AbstractRule».letStat(
				«IF isConstraintExp»
				«AbstractRule».wrap(() -> {
					«initExpression.compileExp(initExpression.variableName, true)»
					return «initExpression.variableName»;
				})
				«ELSE»
					«initExpression.compile»
				«ENDIF»
				,
				(«if(isConstraintExp) e.variable.varName else e.variable.mangledVarName») -> {
					«e.in_.compileEntry(it)»
				}
			);
		'''
	}

	dispatch def StringConcatenationClient compileEntry(CollectionExp e, Binding it) {
		//TODO : correctly handle strengths
		'''
			«FOR c : e.elements»
				// compiling expression at «c.location»
				«c.compileCons(c.variableName, true)»
				«outPatternElement.varName».getExpressions().add(«c.variableName»);
			«ENDFOR»
		'''
	}

	def isStrength(String s) {
		val pattern = "--\\s*(WEAK|MEDIUM|STRONG|REQUIRED)(\\s+\\d+(\\.\\d+)?)?.*"
		s.toUpperCase.matches(pattern)
	}

	def StringConcatenationClient extractStrength(String s) {
		val pattern = "(--\\s*)(WEAK|MEDIUM|STRONG|REQUIRED).*"
		'''«StrengthLevel».«s.toUpperCase.replaceAll(pattern, "$2")»'''
	}

	def extractWeight(String s) {
		val pattern = "(--\\s*[^0-9]*)(\\d+(\\.\\d+)?)?.*" // not 100% certain about this regex, it need proper testing I guess
		val res = s.toUpperCase.replaceAll(pattern, "$2")
		if (res.empty) {
			"1.0"
		}
		else {
			res
		}
	}

// @begin compileCons
	dispatch def compileCons(OclExpression it, String vn, boolean createVar) {
		compileExp(vn, createVar)
	}

	dispatch def StringConcatenationClient compileCons(OperationCallExp it, String vn, boolean createVar) {
		switch operationName {
			// Compile SimpleConstraint
			case "<",
			case ".<",
			case ">",
			case ".>",
			case ">=",
			case ".>=",
			case "<=",
			case ".<=",
			case "=",
			case ".=",
			case "!=",
			case ".!=",
			case "<>",
			case ".<>",
			case "includes",
			case "binPacking",
			case "allDifferent": {
				compileConstraint(vn, createVar)
			}
			case "and": {
				compileAnd(vn, createVar)
			}
			case 'stay': {
				compileStay(vn, createVar)
			}
			case 'suggest': {
				compileSuggest(vn, createVar)
			}
			//Compile RelExp
			default: {
				compileExp(vn, createVar)
			}
		}
	}
// @end compileCons



//	def StringConcatenationClient compileExp(OperationCallExp it) {
//		'''
//		«AbstractRule».wrap((«Supplier»<«CompositeExp»>) () -> {
//			«CompositeExp» «vn» = «Constraints».CompositeExp.newInstance();
//			«vn».setOperatorName("«operationName»");
//			«vn».getArguments().add(«source.compileCons»);
//			«FOR s : arguments»
//				«vn».getArguments().add(«s.compileCons»);
//			«ENDFOR»
//			return «vn»;
//		})'''
//	}

	def StringConcatenationClient compileConstraint(OperationCallExp it, String vn, boolean createVar) {
		'''
			«IF createVar»
				«Constraint» «vn» = «Constraints».Constraint.newInstance();
			«ENDIF»
			«vn».setOperatorName("«operationName»");

				«source.compileExp(source.variableName, true)»
			«vn».getArguments().add(«source.variableName»);
			«FOR a : arguments»
					
					«a.compileExp(a.variableName, true)»
				«vn».getArguments().add(«a.variableName»);
			«ENDFOR»

			«IF commentsAfter.size > 0 && commentsAfter.get(0).isStrength»
				«vn.compileStrength(commentsAfter.get(0).extractStrength, commentsAfter.get(0).extractWeight)»
			«ELSE»
				if («vn».getStrength() == null) {
					«vn.compileStrength('''«StrengthLevel».REQUIRED''', "1.0")»
				}
			«ENDIF»
		'''
	}


	def StringConcatenationClient compileAnd(OperationCallExp it, String vn, boolean createVar) {
		'''
			«IF createVar»
				«Constraint» «vn» = «Constraints».Constraint.newInstance();
			«ENDIF»
			«vn».setOperatorName("«operationName»");

				«source.compileCons(source.variableName, true)»
			«vn».getArguments().add(«source.variableName»);
			«FOR a : arguments»

					«a.compileCons(a.variableName, true)»
				«vn».getArguments().add(«a.variableName»);
			«ENDFOR»

			«IF commentsAfter.size > 0 && commentsAfter.get(0).isStrength»
				«vn.compileStrength(commentsAfter.get(0).extractStrength, commentsAfter.get(0).extractWeight)»
			«ELSE»
				if («vn».getStrength() == null) {
					«vn.compileStrength('''«StrengthLevel».REQUIRED''', "1.0")»
				}
			«ENDIF»
		'''
	}

	def StringConcatenationClient compileStay(OperationCallExp it, String vn, boolean createVar) {
		// stay(Strength, weight = 1.0)
		val StringConcatenationClient s = if (arguments.size == 0)
			'''«StrengthLevel».MEDIUM'''
		else if (arguments.get(0) instanceof StringExp)
			'''«StrengthLevel».«arguments.get(0).compileValue.toUpperCase»'''
		else
			'''
			«AbstractRule».wrap((«Supplier»<«StrengthLevel»>) () -> {
				switch («arguments.get(0).compile».get(0).toUpperCase()) {
					case "REQUIRED": return «StrengthLevel».REQUIRED;
					case "STRONG": return «StrengthLevel».STRONG;
					case "MEDIUM": return «StrengthLevel».MEDIUM;
					case "WEAK": return «StrengthLevel».WEAK;
					default: return «StrengthLevel».MEDIUM;
				}
			})
			'''	//TODO: does this need to be active ?
		val w = if (arguments.size >= 2)
			arguments.get(1).compileValue
		else "1.0"
		'''
			«IF createVar»
				«Constraint» «vn» = «Constraints».Constraint.newInstance();
			«ENDIF»
			«vn».setOperatorName("«operationName»");
			«vn.compileStrength(s, w)»
				«source.compileExp(source.variableName, true)»
			«vn».getArguments().add(«source.variableName»);
		'''
	}

	def StringConcatenationClient compileSuggest(OperationCallExp it, String vn, boolean createVar) {
		'''
			«IF createVar»
				«Constraint» «vn» = «Constraints».Constraint.newInstance();
			«ENDIF»
			«vn».setOperatorName("«operationName»");
			«vn.compileStrength('''«StrengthLevel».WEAK''','1.0')»
				«source.compileExp(source.variableName, true)»
			«vn».getArguments().add(«source.variableName»);
				«arguments.get(0).compileExp(arguments.get(0).variableName, true)»
			«vn».getArguments().add(«arguments.get(0).variableName»);
		'''
	}

	def StringConcatenationClient compileStrength(String vn, StringConcatenationClient s, String w) {
		'''
			«vn».setStrength(«AbstractRule».wrap((«Supplier»<«Strength»>) () -> {
				«Strength» s_«vn» = «Constraints».Strength.newInstance();
				s_«vn».setStrength(«s»);
				s_«vn».setWeight(«w»);
				return s_«vn»;
			}));
		'''
	}


// @begin compileExp
	dispatch def compileExp(OclExpression it, String vn, boolean createVar) {
		throw new UnsupportedOperationException('''Cannot compile expression «it»''')
	}

	dispatch def StringConcatenationClient compileExp(NavigationOrAttributeCallExp it, String vn, boolean createVar) {
		//TODO: look for variable references and compile differently
		val path = propertyPath
		// TODO: isThisModule with mutable helper
		'''
			«IF source.isThisModule && !name.findAttributeHelper.initExpression.isMutable»
				«IF createVar»
					«DoubleExp» «vn» = «Constraints».DoubleExp.newInstance();
				«ENDIF»
				«vn».setValue(«name»);
			«ELSEIF path.hasVariableReference»
				«IF createVar»
					«VariableRelationExp» «vn» = «Constraints».VariableRelationExp.newInstance();
				«ENDIF»
				«IF it.sourceExpression instanceof VariableExp»
					«vn».setIsVector(false);
				«ELSE»
					«vn».setIsVector(true);
				«ENDIF»
				«vn».setIsConstant(false);
				«vn».setSource(«sourceExpression.compile»);
				«vn».setPropertyName("«path.split('\\.').dropWhile[path.variableRelation != it].drop(1).join('.')»");
				«vn».setRelationName("«path.variableRelation»");
			«ELSE»
				«IF createVar»
					«fr.eseo.atlc.constraints.VariableExp» «vn» = «Constraints».VariableExp.newInstance();
				«ENDIF»
				«IF it.source instanceof VariableExp && !source.isMutable»
					«vn».setIsVector(false);
				«ELSE»
					«vn».setIsVector(true);
				«ENDIF»
				«vn».setIsConstant(false);
				«vn».setSource(«it.source.compile»);
				«vn».setPropertyName("«it.name»");
			«ENDIF»
			'''
	}

	def OclExpression getSourceExpression(NavigationOrAttributeCallExp it) {
		val path = propertyPath
		val match = path.variableRelationMatch
		val distance = path.split('\\.').size - match.split('\\.').size
		var ret = source
		for (var i=0; i < distance; i++) {
			switch (ret) {
				PropertyCallExp: {
					ret = ret.source
				}
				default: {
					throw new UnsupportedOperationException('''Unexpected type of navigation in «it».''')
				}
			}
		}
		ret
	}

	def String getPropertyPath(NavigationOrAttributeCallExp it) {
		//TODO: does not work when there are OperationCallExp inside the path, in this case what is the path anyway ?
		val s = source
		switch (s) {
			VariableExp: {
				'''«s.referredVariable.varName».«name»'''
			}
			NavigationOrAttributeCallExp: {
				'''«s.propertyPath».«name»'''
			}
		}
	}

	def boolean hasVariableReference(String path) {
		return enableVariableReference && (path !== null) &&
			variableReferences.filter[
				path.startsWith(it)
			].size > 0
	}

	def String getVariableRelation(String path) {
		path.getVariableRelationMatch.split('\\.').last
	}

	def String getVariableRelationMatch(String path) {
		variableReferences.filter[
				path.startsWith(it)
			].last
	}

	dispatch def StringConcatenationClient compileExp(VariableExp it, String vn, boolean createVar) {
//		'''
//		«AbstractRule».wrap((«Supplier»<«fr.eseo.atlc.constraints.VariableExp»>) () -> {
//			«fr.eseo.atlc.constraints.VariableExp» «vn» = «Constraints».VariableExp.newInstance();
//			«vn».setSource(«referredVariable.varName»);
//			return «vn»;
//		})'''
		if(referredVariable.letExp === null) {
			'''
				«IF createVar»
					«DoubleExp» «vn» = «Constraints».DoubleExp.newInstance();
				«ENDIF»
				«vn».setValue(«referredVariable.varName»);
			'''
		} else {
			'''
				«IF createVar»
					«Expression» «vn»;
				«ENDIF»
				«vn» = «referredVariable.varName»;
			'''
		}
	}

	dispatch def StringConcatenationClient compileExp(StringExp it, String vn, boolean createVar) {
		'''"«stringSymbol»"'''
	}

	def String variableName(EObject it) {
		'''c_«it.hashCode»''' // TODO: use something like nextInt in a non§static context
	}

	dispatch def StringConcatenationClient compileExp(IntegerExp it, String vn, boolean createVar) {
		vn.compileConstant(integerSymbol.toString, createVar)
	}

	dispatch def StringConcatenationClient compileExp(RealExp it, String vn, boolean createVar) {
		vn.compileConstant(realSymbol.toString, createVar)
	}

	dispatch def StringConcatenationClient compileExp(OperationCallExp it, String vn, boolean createVar) {
		switch (operationName) {
			case 'toConstant' : {
				if (source instanceof NavigationOrAttributeCallExp) {
					val s = source as NavigationOrAttributeCallExp
					'''
						«IF createVar»
							«fr.eseo.atlc.constraints.VariableExp» «vn» = «Constraints».VariableExp.newInstance();
						«ENDIF»
						«IF s.source instanceof VariableExp»
							«vn».setIsVector(false);
						«ELSE»
							«vn».setIsVector(true);
						«ENDIF»
						«vn».setIsConstant(true);
						«vn».setSource(«s.source.compile»);
						«vn».setPropertyName("«s.name»");
					'''
				}
				else {
					val s = source as VariableExp
					'''
						«IF createVar»
							«fr.eseo.atlc.constraints.VariableExp» «vn» = «Constraints».VariableExp.newInstance();
						«ENDIF»
						«vn».setSource(«s.compile»);
						«vn».setPropertyName(null);
						«vn».setIsConstant(true);
						«vn».setIsVector(false);
					'''
				}
			}
			case 'asExp',
			case 'asExpression',
			case 'toExp', //used to indicate that the source of the operation is an Expression generated by another rule
			case 'toExpression' : {
				switch source {
					NavigationOrAttributeCallExp: {
						val s = source as NavigationOrAttributeCallExp
						//TODO : can the result box be empty ? if so what to do ?
						'''
						«IF createVar»
							«Expression» «vn»;
						«ENDIF»
						«vn» = «s.source.compile».get(0).«s.name»;'''
					}
					VariableExp: {
						// source is a target element of the rule
						val s = source as VariableExp
						'''
						«IF createVar»
							«Expression» «vn»;
						«ENDIF»
						«vn» = «s.compile»;
						'''
					}
					default: {
						throw new UnexpectedException('''Unexpected source type «source»''')
					}
				}
			}
			case 'and': {
				'''
					«IF createVar»
						«Constraint» «vn» = «Constraints».Constraint.newInstance();
					«ENDIF»
					«vn».setOperatorName("«operationName»");
					
						«source.compileCons(source.variableName, true)»
					«vn».getArguments().add(«source.variableName»);
					
					«FOR a : arguments»
							«a.compileCons(a.variableName, true)»
						«vn».getArguments().add(«a.variableName»);
					«ENDFOR»
				'''
			}
			default: {
				'''
					«IF createVar»
						«CompositeExp» «vn» = «Constraints».CompositeExp.newInstance();
					«ENDIF»
					«vn».setOperatorName("«operationName»");
					
					«IF operationName == "reify"»
							«source.compileCons(source.variableName, true)»
						«vn».getArguments().add(«source.variableName»);
					«ELSE»
							«source.compileExp(source.variableName, true)»
						«vn».getArguments().add(«source.variableName»);
						
						«FOR a : arguments»
								«a.compileExp(a.variableName, true)»
							«vn».getArguments().add(«a.variableName»);
							
						«ENDFOR»
					«ENDIF»
				'''
			}
		}
	}
// @end compileExp

// @begin compileValue
	dispatch def compileValue(OclExpression it) {
		throw new UnsupportedOperationException('''Cannot compile value «it»''')
	}

	dispatch def String compileValue(StringExp it) {
		stringSymbol
	}

	dispatch def String compileValue(IntegerExp it) {
		integerSymbol.toString
	}

	dispatch def String compileValue(RealExp it) {
		realSymbol.toString
	}
// @end compileValue

	def StringConcatenationClient compileConstant(String vn, String v, boolean createVar) {
		try {
			Integer.parseInt(v)
			'''
				«IF createVar»
					«IntExp» «vn» = «Constraints».IntExp.newInstance();
				«ENDIF»
				«vn».setValue(«v»);
			'''
		} catch(NumberFormatException e) {
			Double.parseDouble(v)
			'''
				«IF createVar»
					«DoubleExp» «vn» = «Constraints».DoubleExp.newInstance();
				«ENDIF»
				«vn».setValue(«v»);
			'''
		}
	}
}
