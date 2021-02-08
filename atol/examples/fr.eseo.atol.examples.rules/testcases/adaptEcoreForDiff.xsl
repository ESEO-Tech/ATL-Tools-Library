<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xmi="http://www.omg.org/spec/XMI/20131001"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore"
>
	<xsl:strip-space elements="*"/>
 	<xsl:output indent="yes"/>

	<xsl:template match="ecore:EPackage">
		<xsl:element name="{name(.)}">
			<xsl:copy-of select="namespace::*"/>
			<xsl:copy-of select="@*"/>

			<xsl:apply-templates select="*">
				<xsl:sort select="name()" order="ascending"/>
				<xsl:sort select="@xsi:type" order="ascending"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<!-- things to drop -->
	<xsl:template match="eAnnotations"/>

	<xsl:template match="node()">
		<xsl:element name="{name(.)}">
			<xsl:copy-of select="namespace::*"/>
			<xsl:if test="@xmi:id">
				<xsl:value-of select="@xmi:id"/>
			</xsl:if>
			<xsl:copy-of select="@*[name() != 'resolveProxies' and name() != 'xmi:id' and name() != 'instanceClassName' and name() != 'serializable']"/>

			<xsl:apply-templates select="*"/>
			<xsl:copy-of select="text()"/>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
