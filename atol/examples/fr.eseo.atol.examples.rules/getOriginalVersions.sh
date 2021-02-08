#!/bin/sh

unzip -p ~/.p2/pool/plugins/org.eclipse.emf.ecore_2.12.0.v20160420-0247.jar model/Ecore.ecore > testcases/ecore/ecore-out-original.ecore
unzip -p ~/.p2/pool/plugins/org.eclipse.uml2.uml_5.2.3.v20170227-0935.jar model/UML.ecore > testcases/uml/uml-out-original.ecore
unzip -p ~/.p2/pool/plugins/org.eclipse.papyrus.uml.alf_2.0.0.201703080851.jar model/alf.ecore > testcases/alf/alf-out-original.ecore

# xbase, built from the following metamodels:
#unzip -p ~/.p2/pool/plugins/org.eclipse.xtext.xbase_2.10.0.v201605250459.jar model/Xbase.ecore
#unzip -p ~/.p2/pool/plugins/org.eclipse.xtext.common.types_2.10.0.v201605250459.jar model/JavaVMTypes.ecore
# but the original file we use is actually built and saved by RunEcore2UML

# xtend, built from the following metamodels:
#unzip -p /home/fjouault/.p2/pool/plugins/org.eclipse.xtend.core_2.10.0.v201605250459.jar model/Xtend.ecore
#unzip -p ~/.p2/pool/plugins/org.eclipse.xtext.xbase_2.10.0.v201605250459.jar model/Xtype.ecore
#unzip -p ~/.p2/pool/plugins/org.eclipse.xtext.xbase_2.10.0.v201605250459.jar model/XAnnotations.ecore
#unzip -p ~/.p2/pool/plugins/org.eclipse.xtext.xbase_2.10.0.v201605250459.jar model/Xbase.ecore
#unzip -p ~/.p2/pool/plugins/org.eclipse.xtext.common.types_2.10.0.v201605250459.jar model/JavaVMTypes.ecore
# but the original file we use is actually built and saved by RunEcore2UML

