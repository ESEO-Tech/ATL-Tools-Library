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

package fr.eseo.atlc2tcsvg

import com.beust.jcommander.Parameter
import java.util.ArrayList
import java.util.List

class Parameters {
	@Parameter(names = #['-i', '--input'], description = 'Input file name', required = true)
	public String inputPath

	@Parameter(names = #['-o', '--output'], description = 'Output file name')
	public String outputPath

	@Parameter(names = #['-I', '--include'], description = 'Include directories')
	public List<String> modulesPaths = new ArrayList<String>

	@Parameter(names = #['-M', '--metamodel'], description = 'Metamodel paths')
	public List<String> metamodels = new ArrayList<String>

	@Parameter(names = #['-S', '--styleURL'], description = 'URL of CSS stylesheet')
	public List<String> styleURL = new ArrayList<String>

	@Parameter(names = #['-E', '--embedStyle'], description = 'path to CSS file to include in the SVG file')
	public List<String> embededStylePath = new ArrayList<String>

	@Parameter(names = #['-s', '--embedSVG'], description = 'path to SVG fragments to include in final SVG final')
	public List<String> embededSVGPath = new ArrayList<String>

	@Parameter(names = #['-B', '--baseURL'], description = 'path to prepend to all relative URL')
	public String baseURL = ""

	@Parameter(names = #['-H', '--hostname'], description = 'hostname used for external resources, leave blank to use relative URL')
	public String hostname = ""

	@Parameter(names = #['-t', '--tcsvgPath'], description = 'path for TCSVG.min.js')
	public String tcsvgJSPath = "tcsvg/TCSVG.min.js"

	@Parameter(names = #['-c', '--cassowaryPath'], description = 'path for c.js')
	public String cassowaryJSPath = "tcsvg/c.js"

	@Parameter(names = #['-p', '--protocole'], description = 'protocol to use for URL')
	public String protocol = "https"

	@Parameter(names = #['-r', '--remoteScript'], description = 'scripts to load by src')
	public List<String> localStripts = new ArrayList<String>

	@Parameter(names = #['-js', '--embedJS'], description = 'scripts to inline')
	public List<String> embededScriptPath = new ArrayList<String>

	@Parameter(names = #['-n', '--lowercaseRuleId'], description = 'force lowercase on generate rule ids')
	public boolean lowercaseRules = false

	@Parameter(names = #['--directConstraints'], description = 'add constraints at the end of each constraint block, not compatible with incremental TCSVG')
	public boolean legacyTCSVGConstraints = false

	@Parameter(names = #['-v', '--verbose'])
	public boolean verbose = false;

	@Parameter(names = #['-g', '--debug'], description = "add debug symbols to generated constraints")
	public boolean debug = false

	@Parameter(names = "--help", help = true)
	public boolean help;
}
