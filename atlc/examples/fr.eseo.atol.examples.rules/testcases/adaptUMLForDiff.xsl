<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xmi="http://www.omg.org/spec/XMI/20131001"
	xmlns:standard="http://www.eclipse.org/uml2/5.0.0/UML/Profile/Standard"
	xmlns:Ecore="http://www.eclipse.org/uml2/schemas/Ecore/5"
	xmlns:uml="http://www.eclipse.org/uml2/5.0.0/UML"
	xmlns:java="xalan://fr.eseo.atol.rules.RunEcore2UML$StringExt"
>
<!--
	To see how xalan resolves Java methods, see:
		com.sun.org.apache.xalan.internal.xsltc.compiler.FunctionCall.typeCheckExternal
-->

	<xsl:strip-space elements="*"/>
 	<xsl:output indent="yes"/>

	<xsl:template match="uml:Model|uml:Package|packagedElement">
		<xsl:element name="{name(.)}">
			<xsl:copy-of select="namespace::*"/>
			<xsl:copy-of select="@*"/>

			<xsl:apply-templates select="*">
				<xsl:sort select="name()" order="ascending"/>
				<xsl:sort select="@xmi:id" order="ascending"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<!-- things to drop -->
	<xsl:template match="eAnnotations|ownedComment|ownedRule"/>

	<xsl:template match="node()">
		<xsl:element name="{name(.)}">
			<xsl:copy-of select="namespace::*"/>
			<xsl:if test="@xmi:id">
				<xsl:attribute name="xmi:id">
<!--
					With XSLT 2.0 (and XPath 2.0), one could use the built-in replace function. But Java XSLT transformer (xalan) only supports XSLT 1.0.
					<xsl:value-of select="fn:replace(@xmi:id, '(-[^_][^-.]*)\.[0-9]+', '$1')"/>

					Remark: our Java code now actually adds the .1. It is necessary when several class member (attributes and/or operations) have the same name
					<xsl:value-of select="java:replace(@xmi:id, '(-[^_][^-.]*)\.[0-9]+', '$1')"/>
-->
					<xsl:value-of select="@xmi:id"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:copy-of select="@*[(name() = 'visibility' and . != 'public') or (name() != 'visibility' and name() != 'subsettedProperty' and name() != 'xmi:id')]"/>

			<xsl:apply-templates select="*"/>
			<xsl:copy-of select="text()"/>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
