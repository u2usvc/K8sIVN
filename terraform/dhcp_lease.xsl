<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <xsl:template match="node()|@*">
     <xsl:copy>
       <xsl:apply-templates select="node()|@*"/>
     </xsl:copy>
  </xsl:template>

  <xsl:template match="/network/ip/dhcp">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="node()"/>
      <host mac='50:73:0F:31:81:E1' ip='192.168.122.101'/>
      <host mac='50:73:0F:31:81:E2' ip='192.168.122.102'/>
      <host mac='50:73:0F:31:81:F1' ip='192.168.122.103'/>
      <host mac='50:73:0F:31:81:F2' ip='192.168.122.104'/>
      <!-- <host mac='50:73:0F:31:81:F3' ip='192.168.122.105'/> -->
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

