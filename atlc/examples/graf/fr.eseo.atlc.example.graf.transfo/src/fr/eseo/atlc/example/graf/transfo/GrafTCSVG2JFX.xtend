package fr.eseo.atlc.example.graf.transfo

import fr.eseo.atol.gen.ATOLGen
import fr.eseo.atol.gen.ATOLGen.Metamodel
import fr.eseo.atol.gen.plugin.constraints.common.Constraints
import fr.eseo.atol.javafx.JFX

@ATOLGen(transformation="src/fr/eseo/atlc/example/graf/transfo/Graf2TCSVG-noXML.atl", metamodels=#[
	@Metamodel(name="Graf", impl=Graf),
	@Metamodel(name="SVG", impl=JFX),
	@Metamodel(name="Constraints", impl=Constraints)
], extensions = #[Constraints])
class GrafTCSVG2JFX {
	
}