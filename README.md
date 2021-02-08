# Installation

- Eclipse for Java Developpers
- Xtend: http://download.eclipse.org/modeling/tmf/xtext/updates/composite/releases/ 
    - Xtext:
        - Xtend IDE	2.15.0 or later
- ATL: http://download.eclipse.org/mmt/atl/updates/releases
    - ATL:
        - ATL EMFTVM    4.2.0 or later
- Main repo:
    - Modeling
        - EMF - Eclipse Modeling Framework SDK
        - EMF - Eclipse Modeling Framework Xcore SDK 
        - UML2 Extender SDK

Solvers used by project `atol/fr.eseo.atol.gen.plugin.constraints` must be downloaded separatly and placed in the `atol/fr.eseo.atol.gen.plugin.constraints/lib` folder.
The classpath of project `atol/fr.eseo.atol.gen.plugin.constraints` may need to be updated.
These solvers can be downloaded here:
- [Cassowary](https://github.com/pybee/cassowary-java)
- [Choco](https://github.com/chocoteam/choco-solver)
- [MiniCP](https://bitbucket.org/minicp/minicp/src/master/)
- [XCSP3](https://github.com/xcsp3team/XCSP3-Java-Tools)

