<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:letex="http://www.le-tex.de/namespace"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:edu="http://www.le-tex.de/namespace/edu"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  version="2.0">

  <xsl:output method="xhtml"
    encoding="UTF-8"
    doctype-public="-//W3C//DTD XHTML 1.0//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    />

  <xsl:variable name="non-table-content" select="('hru-infobox')" as="xs:string+" />
  <xsl:variable name="heading-spans-two-cols" select="('section')" as="xs:string+" />
  <xsl:variable name="content-as-tr" select="('hru-phase', 'Tips', 'hru-vocab', 'section')" as="xs:string+" />

  <xsl:variable name="light-gray" as="xs:string" select="'#eee'"/>
  <xsl:variable name="shadow-gray" as="xs:string" select="'#bbb'"/>
  <xsl:variable name="dark-blue" as="xs:string" select="'#039'"/>
  <xsl:variable name="bg-blue" as="xs:string" select="'#89f'"/>

  <xsl:template match="/*/@xml:base" mode="tei2html">
    <xsl:attribute name="xml:base" select="replace(., '\.tei\.xml$', '.html')" />
  </xsl:template>

  <xsl:template match="/" mode="tei2html">
    <html>
      <xsl:apply-templates select="TEI/@xml:base" mode="#current"/>
      <head>
        <title>
	  <xsl:value-of select="replace(tokenize(/*/@xml:base, '/')[last()], '\.tei\.xml', '')"/>
	</title>
        <style type="text/css">
          body {
            width: 21cm;
            font-family: Minion,sans-serif;
            font-size: 10pt;
            line-height:1.3em;
            hyphens: auto;
            font-weight: 400;
          }
          h1 {
            color: <xsl:value-of select="$dark-blue"/>;
            font-weight: bold;
            margin-left: 2cm;
            margin-bottom: 1em;
            font-size:14pt;
          }
          p, ul, li, h2, h3, h4 {
            margin-top: 0;
            margin-bottom: 2mm;
          }
          h2, h3, h4 {
            font-weight: 600;
            font-stretch: condensed;
          }
          h2 {
            font-size: 16pt;
            color: <xsl:value-of select="$dark-blue"/>;
            margin-left: 2cm;
            margin-top: 6mm;
            page-break-before: always;
          }
          h3 {
            font-size: 14pt;
            color: <xsl:value-of select="$dark-blue"/>;
            margin-left: 2cm;
            margin-top: 6mm;
          }
          h4 {
            font-size: 10pt;
          }
          table { 
            border-collapse: separate;
            border: none;
          }
          table.two-column-main {
            width: 188mm;
            margin-left: 1.6cm;
          }
          td, th {
            padding: 2mm;
            border: 1pt solid black;
            vertical-align: top;
          }
          table.overview-section { 
            border-collapse: collapse;
            border: 1pt solid <xsl:value-of select="$light-gray"/>;
            margin-left: 1.8cm;
            margin-bottom: 3mm;
          }
          table.overview-section p.empty.section { 
            margin-top: 6mm;
          }
          th {
            text-align:left;
            vertical-align:top;
            font-weight: 600;
          }
          th.hru-overview {
            width: 39mm;
            border: 1pt solid <xsl:value-of select="$light-gray"/>;
            background-color: <xsl:value-of select="$light-gray"/>;
            -webkit-print-color-adjust: exact;
          }
          td.hru-overview {
            width: 130mm;
            border: 1pt solid <xsl:value-of select="$light-gray"/>;
          }
          div.hru-lead-in {
            width: 182mm;
            border: 1pt solid <xsl:value-of select="$light-gray"/>;
            background-color: <xsl:value-of select="$light-gray"/>;
            -webkit-print-color-adjust: exact;
            box-shadow: 0 0 <xsl:value-of select="$shadow-gray"/>, 0 2mm <xsl:value-of select="$shadow-gray"/>, 2mm 0 <xsl:value-of select="$shadow-gray"/>, 0 0 <xsl:value-of select="$shadow-gray"/>;
            margin: 5mm 0 5mm 1.7cm;
          }
          h4.hru-infobox,
          h4.hru-vocab,
          h4.hru-phase {
            text-transform: uppercase;
          }
          h4.hru-phase,
          h4.hru-vocab,
          h4.supplementary {
            margin-bottom: 0.5mm;
          }
          div.hru-lead-in h4 {
            margin: 2mm 0 0 2mm;
            text-transform: uppercase;
          }
          div.hru-lead-in p {
            margin-left: 2mm;
          }
          table.hru-lead-in { 
            border-collapse: collapse;
            border: none;
            margin-top: 0;
          }
          table.hru-lead-in p {
            margin-bottom: 0px;
          }
          table.hru-lead-in +h4.section {
            margin-top: 5mm;
          }
          table.hru-lead-in th, table.hru-lead-in td {
            border: none;
            padding: 0;
          }
          table.hru-lead-in th {
            width: 24mm;
          }
          table.hru-lead-in td {
            width: 142mm;
          }
          h3.hru-pageref {
            width: 178mm;
            border: 1pt solid <xsl:value-of select="$dark-blue"/>;
            margin: 10mm 0 3mm 1.8cm;
            padding: 0.5mm 2mm;
            color: <xsl:value-of select="$dark-blue"/>;
            font-weight: 600;
            font-size: 10pt;
          }
          table.hru-pageref {
            margin-left: 0;
          }
          td.hru-pageref {
            width: 170mm;
            border: none;
            padding: 0;
          }
          td.hru-exercise {
            border: none;
          }
          td.hru-exercise h3 {
            margin-top: 2mm;
            margin-left: 1.8cm;
          }
          td h3 {
            font-weight: 600;
            margin:0;
            color: <xsl:value-of select="$dark-blue"/>;
          }
          td.hru-pageref h3 {
            font-size: 10pt;
          }
          td.post-pageref-vspace, td.pre-pageref-vspace {
            line-height:1ex;
            font-size: 10pt;
            border:none;
            width: 170mm;
          }
          td.pre-pageref-vspace {
            height:1ex;
          }
          td.post-pageref-vspace {
            height:1ex;
          }
          h3.hru-pageref span.link {
            color: <xsl:value-of select="$dark-blue"/>;
          }
          div.hru-pageref p {
          }
          table.two-column-main {
            border-spacing: 2mm;
            -webkit-border-horizontal-spacing: 2mm;
            -webkit-border-vertical-spacing: 0;
          }
          td.main, td.margin {
            border-top: 1pt solid <xsl:value-of select="$dark-blue"/>;
            border-bottom: none;
            border-left: none;
            border-right: none;
            padding-bottom: 0;
            margin-bottom: 0;
          }
          td.main {
            width: 112mm;
          }
          td.margin {
            width: 54mm;
          }
          td.spacer {
            width: 4mm;
            margin: 0;
            padding:0;
            border:none;
          }
          div.hru-infobox {
            width: 188mm;
            background-color: <xsl:value-of select="$light-gray"/>;
            -webkit-print-color-adjust: exact;
            box-shadow: 0 0 <xsl:value-of select="$shadow-gray"/>, 0 2mm <xsl:value-of select="$shadow-gray"/>, 2mm 0 <xsl:value-of select="$shadow-gray"/>, 0 0 <xsl:value-of select="$shadow-gray"/>;
            margin: 4mm 0 3mm 1.2cm;
          }
          div.hru-infobox-content {
            margin-left: 8mm;
            padding-bottom: 1mm;
            padding-right: 1mm;
          }
          span.hru-infobox-icon {
            position: absolute;
            left: 13mm;
            font-size: 22pt;
            color: <xsl:value-of select="$dark-blue"/>;
            background-color:white;
            padding:1mm 0 0 0;
          }
          h4.hru-infobox {
            color: <xsl:value-of select="$dark-blue"/>;
            padding-top: 2mm;
            margin-bottom: 1mm;
          }
          .no-space-after {
            margin-bottom: 0;
          }
          .last-in-phase {
            margin-bottom: 1.5mm;
          }
          .edu-opt {
            color: <xsl:value-of select="$dark-blue"/>;
          }
          table.tafelbild {
            color: white;
          }
          table.tafelbild {
            background-color: <xsl:value-of select="$shadow-gray"/>;
            -webkit-print-color-adjust: exact;
          }
          table.heftbild {
            background-color: <xsl:value-of select="$light-gray"/>;
            -webkit-print-color-adjust: exact;
          }
          table.tafelbild.edu-opt {
            background-color: <xsl:value-of select="$bg-blue"/>;
            -webkit-print-color-adjust: exact;
          }
          table.edu-opt td, table.edu-opt th {
            color: white;
          }
          table.heftbild  {
            border: 3pt solid <xsl:value-of select="$light-gray"/>;
          }
          table.tafelbild td, table.tafelbild th {
            padding: 1mm;
            border: none;
          }
          table.tafelbild th, table.heftbild th, table.other th {
            text-align:center;
          }
          table.tafelbild, table.heftbild, table.other {
            border-collapse:collapse;
            font-family: cursive;
            margin: 2mm 0;
          }
          table.float-right {
            float: right;
            margin-top: 0;
            margin-left: 3mm;
          }
          span.link {
            color: #999;
          }
          span.run-in {
            font-weight: 600;
          }
          span.non-bold {
            font-weight: 400;
          }
          span.extra {
            background-color: <xsl:value-of select="$dark-blue"/>;
            -webkit-print-color-adjust: exact;
            color: white;
            font-weight: bold;
            padding: 0.6mm 1mm;
          }
          span.term {
            border-bottom: 1pt dotted <xsl:value-of select="$shadow-gray"/>;
          }
          span.Glossref {
            color:#a30;
            border-bottom: 1pt solid #a30;
          }
          ol {
            margin: 1em;
            padding: 0;
          }
          ol.decimal {
            list-style-type: decimal;
          }
          ul.ndash {
            margin-left: 0.5em; 
            margin-top: 0.5em;
            padding-left: 1em;
            list-style-type: none;
            text-indent: -1.7em;
            overflow: visible;
          }
          ul.ndash li { 
            display: list-item;
          }
          ul.ndash li:before { 
            content: '\2013\a0';
            width: 1em;
            margin-right: 1em;
          }
          img {
            border: 1px solid red;
          }
          .icon {
            background-color:  <xsl:value-of select="$shadow-gray"/>;
          }
          .textbook-series {
            border-bottom: 1pt dotted <xsl:value-of select="$shadow-gray"/>;
          }
          .underline {
            text-decoration:underline;
          }
          :lang(en) {
            border-bottom: 2pt dashed #dd4;
          }
        </style>
      </head>
      <body>
        <xsl:apply-templates select="TEI/text" mode="#current"/>
      </body>
    </html>
  </xsl:template>

  <!-- Identity template for the preprocessing mode -->
  <xsl:template match="@* | *" mode="pull-up-non-table">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="html:*" mode="tei2html">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*" />
      <xsl:apply-templates select="node()" mode="#current" />
    </xsl:copy>
  </xsl:template>

  <xsl:function name="letex:non-table-content" as="xs:boolean">
    <xsl:param name="node" as="node()"/>
    <xsl:sequence select="boolean(
                               $node/self::div[@type = $non-table-content]
                            or $node/self::head[parent::div[@type = ('hru-exercise', 'hru-pageref')]]
                            or $node/self::div[@type = 'Tips']
                          )" />
  </xsl:function>

  <xsl:template match="div[@type = 'hru-pageref']" mode="pull-up-non-table">
    <xsl:variable name="context" select="." as="element(div)"/>
    <xsl:for-each-group select=".//node()[not(node()) or letex:non-table-content(.)]
                                         [not(ancestor::*[letex:non-table-content(.)])]"
      group-starting-with="*[letex:non-table-content(.)]">
      <xsl:if test="letex:non-table-content(.)">
        <xsl:apply-templates select="." mode="tei2html"/>
      </xsl:if>
      <xsl:variable name="rest-of-group" select="current-group()[not(ancestor-or-self::node()[letex:non-table-content(.)])]" as="node()*"/>
      <xsl:if test="$rest-of-group">
        <xsl:apply-templates select="$context" mode="slice">
          <xsl:with-param name="restricted-to" select="$rest-of-group/ancestor-or-self::node()" tunnel="yes"/>
          <xsl:with-param name="leaves" select="$rest-of-group" tunnel="yes"/>
          <xsl:with-param name="ancestors" select="$rest-of-group/ancestor::*" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:if>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:template match="node()" mode="slice">
    <xsl:param name="restricted-to" as="node()+" tunnel="yes"/>
    <xsl:param name="leaves" as="node()+" tunnel="yes"/>
    <xsl:param name="ancestors" as="node()+" tunnel="yes"/>
    <xsl:if test="exists(. intersect $restricted-to)">
      <xsl:choose>
        <xsl:when test="self::div[@type = $non-table-content]" />
        <xsl:otherwise>
          <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
          </xsl:copy>
        </xsl:otherwise>
      </xsl:choose>     
    </xsl:if>
  </xsl:template>


  <xsl:template match="*" mode="tei2html" priority="-1">
    <xsl:message>Unhandled: <xsl:apply-templates select="." mode="unhandled"/>
    </xsl:message>
    <xsl:apply-templates select="@* | node()" mode="#current" />
  </xsl:template>

  <xsl:template match="@*" mode="tei2html" priority="-1.5">
    <xsl:message>Unhandled attr: <xsl:apply-templates select="." mode="unhandled"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="@*" mode="tei2html-tableatts" priority="-1">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="@xml:lang" mode="tei2html">
    <xsl:attribute name="{local-name()}" select="." />
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="@edu:opt" mode="tei2html" />

    
  <xsl:template match="*" mode="unhandled" priority="0">
    <xsl:message select="concat(name(), '  ', substring(normalize-space(.),1,40))" /> 
    <xsl:apply-templates select="@*" mode="#current" />
  </xsl:template>

  <xsl:template match="@*" mode="unhandled" priority="0">
    <xsl:message select="concat('  ', name(), '=', .)" /> 
  </xsl:template>

  <xsl:template match="text | body | front | div[@type = ('hru-comment', 'preface')]" mode="tei2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
    
  <xsl:template match="div[@type = 'hru-comment']/head"  mode="tei2html"/>

  <xsl:template match="div[@type = 'hru-unit']" mode="tei2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>



  <xsl:template match="div[@type = 'hru-pageref'][.//text()]" mode="tei2html">
    <table class="two-column-main">
      <xsl:apply-templates select="node() except head" mode="#current" />
    </table>
  </xsl:template>

  <xsl:template match="div[@type = 'hru-unit']/head" mode="tei2html">
    <h1>
      <xsl:apply-templates select="../@n" mode="#current" />
      <span class="unit-title">
        <xsl:apply-templates mode="#current" />
      </span>
    </h1>
  </xsl:template>

  <xsl:template match="div[@type = 'hru-unit']/@n" mode="tei2html">
    <span class="unit-number">
      <xsl:value-of select="../@n"/>
    </span>
    <xsl:text>&#x2003;</xsl:text>
  </xsl:template>

  <xsl:template match="div[@type = $heading-spans-two-cols][not(@type = $content-as-tr)]" mode="tei2html">
    <xsl:apply-templates mode="#current" />
  </xsl:template>

  <xsl:template match="div[@type = $heading-spans-two-cols]/head" mode="tei2html">
    <tr>
      <td colspan="3">
        <xsl:element name="h{letex:heading-level(.)}">
          <xsl:sequence select="letex:class-attr((.., .))" />
          <xsl:apply-templates mode="#current" />
        </xsl:element>
      </td>
    </tr>
  </xsl:template>


  <xsl:template match="div[@type = $content-as-tr][not(parent::div[@type = ('hru-lead-in', 'hru-part')])]" mode="tei2html">
    <xsl:variable name="pass1" as="element(*)*">
      <xsl:for-each-group select="*" group-adjacent="boolean(self::div[@type = 'supplementary'])">
        <xsl:choose>
          <xsl:when test="current-grouping-key()">
            <td class="spacer"></td>
            <td class="margin">
              <xsl:apply-templates select="current-group()" mode="#current" />
            </td>
          </xsl:when>
          <xsl:otherwise>
            <td class="main">
              <xsl:apply-templates select="current-group()" mode="#current" />
            </td>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:variable>
    <xsl:for-each-group select="$pass1" group-starting-with="html:td[@class eq 'main']">
      <tr>
        <xsl:sequence select="current-group()" />
        <xsl:if test="not(current-group()/self::html:td[@class eq 'margin'])">
          <td class="spacer"></td>
          <td class="margin">&#xa0;</td>
        </xsl:if>
      </tr>
    </xsl:for-each-group>
  </xsl:template>


<!-- §§§ [not(ancestor::div[@type = ('hru-lead-in', 'hru-part')])] -->
  <xsl:template match="div[@type = 'pg']" mode="tei2html">
    <xsl:apply-templates mode="#current" />
  </xsl:template>

  <xsl:template match="div[@type = 'supplementary']" mode="tei2html">
    <xsl:apply-templates mode="#current" />
  </xsl:template>

  <xsl:template match="p[not(ancestor::tr)]" mode="tei2html">
    <p>
      <xsl:sequence select="letex:class-attr((ancestor::div[@edu:*][1], .., .))" />
      <xsl:sequence select="letex:style-overrides(.)" />
      <xsl:apply-templates select="@rend" mode="tei2html-rend-pre" />
      <xsl:apply-templates mode="#current" />
    </p>
  </xsl:template>

  <xsl:template match="div/head[letex:contains(@rend, 'run-in')]" mode="tei2html tei2html-rend-pre tei2html-rend-post" />

  <!-- everything that is not in a lead-in overview table, I'd guess (that table will be filled ~300 lines below): -->
  <xsl:template match=" *[not(self::div[@type = ('hru-lead-in', 'hru-part')])]
                       /*[not(self::div[@type = ('section')])]
                       /div[head[letex:contains(@rend, 'run-in')]]/p[1]" mode="tei2html" priority="2">
    <p>
      <xsl:sequence select="letex:class-attr((ancestor::div[@edu:*][1], .))" />
      <span>
        <xsl:apply-templates select="@*" mode="#current" />
        <xsl:sequence select="letex:class-attr(../head)" />
        <xsl:apply-templates select="../head/@rend" mode="tei2html-rend-pre" />
        <xsl:apply-templates select="../head/node()" mode="tei2html" />
        <xsl:apply-templates select="../head/@rend" mode="tei2html-rend-post" />
      </span>
      <xsl:text>&#x2002;</xsl:text>
      <xsl:apply-templates mode="#current" />
    </p>
  </xsl:template>

  <xsl:template match="head[emph[not(@*)]]/text()" mode="tei2html">
    <span class="non-bold">
      <xsl:next-match/>
    </span>
  </xsl:template>

  <xsl:template match="text()" mode="tei2html">
    <xsl:analyze-string select="." regex="[&#x2190;&#x2192;]">
      <xsl:matching-substring>
        <!-- todo: rename class -->
        <span class="Glosspfeil">
          <xsl:value-of select="." />
        </span>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="." />
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>

  <xsl:template match="head[emph[not(@*)]]/emph[not(@*)]" mode="tei2html">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="div[not(ancestor::div[@type = ('hru-lead-in', 'hru-part')])]
                         /head[letex:contains(@rend, 'run-in')][not(following-sibling::p)]" mode="tei2html" priority="2">
    <p>
      <span>
        <xsl:sequence select="letex:class-attr(.)" />
        <xsl:apply-templates select="node()" mode="tei2html" />
        <xsl:apply-templates select="@rend" mode="tei2html-rend-post" />
      </span>
    </p>
  </xsl:template>

  <xsl:template match="@rend" mode="tei2html-rend-pre" as="node()*">
    <xsl:for-each select="tokenize(., '\s+', 's')">
      <xsl:sort select="letex:rendsort(.)"/>
      <xsl:choose>
        <xsl:when test=". eq 'link'">
          <span class="icon">&#x27a1;</span>
          <xsl:text>&#xa0;</xsl:text>
          <span class="tab-indent-to-here"/>
        </xsl:when>
        <xsl:when test=". eq 'extra'">
          <span class="extra">Extra</span>
          <xsl:text>&#xa0;</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="seg/@type" mode="tei2html-rend-pre" as="node()*">
    <xsl:for-each select="tokenize(., '\s+', 's')">
      <xsl:sort select="letex:rendsort(.)"/>
      <xsl:if test=". eq 'Glossref'">
<!--         <span class="icon">Glosspfeil</span> -->
        <span class="Glosspfeil">&#x25b6;</span>
        <xsl:text>&#xa0;</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="p[@type = 'KV']" mode="tei2html" priority="2">
    <p class="KV">
      <xsl:sequence select="letex:class-attr((ancestor::div[@edu:*][1], .., .))" />
      <xsl:sequence select="letex:style-overrides(.)" />
      <xsl:apply-templates select="@rend" mode="tei2html-rend-pre" />
      <span class="icon">KV</span>
      <xsl:text>&#xa0;</xsl:text>
      <span class="tab-indent-to-here"/>
      <xsl:apply-templates mode="#current" />
    </p>
  </xsl:template>


  <xsl:template match="@rend" mode="tei2html-rend-replace" as="node()*">
    <xsl:variable name="context" select="." as="attribute(rend)" />
    <xsl:for-each select="tokenize(., '\s+', 's')">
      <xsl:sort select="letex:rendsort(.)"/>
      <xsl:choose>
        <xsl:when test=". eq 'icon'">
          <img src="icons/{$context/..}.png" alt="((icon:{$context/..}))"/>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="@rend" mode="tei2html-rend-post" as="node()*">
    <xsl:for-each select="tokenize(., '\s+', 's')">
      <xsl:sort select="letex:rendsort(.)"/>
      <xsl:choose>
        <xsl:when test=". eq 'colon'">
          <xsl:if test="matches(., ':\s*$')">
            <xsl:message>WRN 1
            </xsl:message>
          </xsl:if>
          <xsl:text>:</xsl:text>
        </xsl:when>
        <xsl:when test=". eq 'full-stop'">
          <xsl:if test="matches(., '\.\s*$')">
            <xsl:message>WRN 2
            </xsl:message>
          </xsl:if>
          <xsl:text>.</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:function name="letex:rendsort" as="xs:integer">
    <xsl:param name="token" as="xs:string" />
    <xsl:choose>
      <xsl:when test="$token eq 'link'">
        <xsl:sequence select="-5" />
      </xsl:when>
      <xsl:when test="$token eq 'extra'">
        <xsl:sequence select="0" />
      </xsl:when>
      <xsl:when test="$token = ('colon', 'full-stop')">
        <xsl:sequence select="5" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="2" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="letex:class-attr" as="attribute(class)?">
    <xsl:param name="input" as="element(*)*" />
    <xsl:variable name="space-sep-values" as="xs:string*">
      <xsl:apply-templates select="$input, $input/@*" mode="tei2html-class" />
    </xsl:variable>
    <xsl:if test="exists($space-sep-values)">
      <xsl:attribute name="class" select="distinct-values($space-sep-values)" />
    </xsl:if>
  </xsl:function>

  <xsl:function name="letex:style-overrides" as="attribute(style)?">
    <xsl:param name="input" as="element(*)" />
    <xsl:variable name="css-atts" as="attribute(*)*" select="$input/@css:*"/>
    <xsl:if test="exists($css-atts)">
      <xsl:attribute name="style" select="string-join(
                                            for $a in $css-atts 
                                            return concat(local-name($a), ': ', $a),
                                            '; '
                                          )" />
    </xsl:if>
  </xsl:function>

  <xsl:function name="letex:heading-level" as="xs:integer">
    <xsl:param name="context" as="element(*)*" />
    <xsl:choose>
      <xsl:when test="$context/parent::div/@type = ('hru-exercise', 'hru-pageref')">
        <xsl:sequence select="3" />
      </xsl:when>
      <xsl:when test="$context/parent::div/@type = ('section', 'hru-vocab', 'hru-phase', 'Tips', 'hru-infobox', 'supplementary')">
        <xsl:sequence select="4" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Please give heading level for <xsl:value-of select="string-join((name($context/..), $context/../@type), '/@type=')"/>
        </xsl:message>
        <xsl:sequence select="0" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template match="* | @*" mode="tei2html-class" priority="-1" />

  <xsl:template match="@rend" mode="tei2html" />

  <xsl:template match="@type[. eq 'hub2tei:shortcut']" mode="tei2html" priority="2">
    <xsl:attribute name="class" select="'icon'" />
  </xsl:template>
    

  <xsl:template match="div[@type eq 'pg']/p[following-sibling::*]" mode="tei2html-class" as="xs:string">
    <xsl:sequence select="'no-space-after'" />
  </xsl:template>

  <xsl:template match="p[. is (
                                ancestor::div[@type = ('hru-phase')]
                                  //p[not(ancestor::div[@type = ('supplementary')])]
                              )[last()]
                        ]" mode="tei2html-class" as="xs:string" priority="2">
    <xsl:sequence select="'last-in-phase'" />
  </xsl:template>

  <xsl:template match="p[ancestor::div[@type = ('supplementary')]]
                        [. is (
                           ancestor::div[@type = ('hru-phase')]//p
                              )[last()]
                        ]" mode="tei2html-class" as="xs:string" priority="2">
    <xsl:sequence select="'last-in-phase'" />
  </xsl:template>

  <xsl:template match="p[not(node())]" mode="tei2html-class" as="xs:string">
    <xsl:sequence select="'empty'"/>
  </xsl:template>
    
  <xsl:template match="@rend" mode="tei2html-class" as="xs:string*">
    <xsl:for-each select="tokenize(., '\s+', 's')">
      <xsl:choose>
        <xsl:when test=". = ('colon', 'full-stop', 'extra', 'link')" />
        <xsl:when test=". = ('reception', 'non-bold', 'run-in', 'underline')">
          <xsl:sequence select="." />
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>Unhandled @rend token: <xsl:sequence select="." />
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="div[@type eq 'hru-overview']" mode="tei2html">
    <xsl:apply-templates mode="#current" />
  </xsl:template>

  <xsl:template match="div[@type eq 'hru-overview']/div[@type eq 'section']" mode="tei2html" priority="2">
    <table class="overview-section">
      <tr>
        <th class="{../@type}">
          <xsl:apply-templates select="head" mode="#current" />
        </th>
        <td class="{../@type}">
          <xsl:apply-templates select="* except head" mode="#current" />
        </td>
      </tr>
    </table>
  </xsl:template>

  <xsl:template match="div[@type eq 'hru-overview']/div[@type eq 'section']/head" mode="tei2html" priority="2">
    <xsl:element name="h{letex:heading-level(.)}">
      <xsl:attribute name="class" select="overview-section" />
      <xsl:apply-templates mode="#current" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="div[@type = $content-as-tr]/head" mode="tei2html" priority="1.5">
    <xsl:element name="h{letex:heading-level(.)}">
      <xsl:sequence select="letex:class-attr((ancestor::div[@edu:*][1], .., .))" />
      <xsl:apply-templates mode="#current" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="div[@type eq 'supplementary']/head[not(letex:contains(@rend, 'run-in'))]" mode="tei2html">
    <xsl:element name="h{letex:heading-level(.)}">
      <xsl:sequence select="letex:class-attr((ancestor::div[@edu:*][1], .., .))" />
      <xsl:apply-templates select="@rend" mode="tei2html-rend-pre" />
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>


  <!-- LEAD-IN / Part -->

  <xsl:template match="div[@type = ('hru-lead-in', 'hru-part')]" mode="tei2html">
    <xsl:apply-templates select="head" mode="#current" />
    <xsl:if test="exists(div[@type eq 'section'])">
      <div class="hru-lead-in">
        <xsl:apply-templates select="div[@type eq 'section']" mode="#current" />
      </div>
    </xsl:if>
    <xsl:apply-templates select="*[not(self::div[@type eq 'section'] or self::head)]" mode="#current" />
  </xsl:template>

  <xsl:template match="div[@type = ('hru-part')]/head" mode="tei2html">
    <h2>
      <xsl:apply-templates mode="#current" />
    </h2>
  </xsl:template>

  <xsl:template match="div[@type = ('hru-lead-in', 'hru-part')]/div[@type = 'section']" mode="tei2html">
    <xsl:for-each-group select="*" group-adjacent="boolean(self::div[@type eq 'pg'])">
      <xsl:choose>
        <xsl:when test="current-grouping-key()">
          <table class="hru-lead-in">
            <xsl:apply-templates select="current-group()" mode="#current" />
          </table>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="current-group()" mode="#current" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:template match="div[@type = ('hru-lead-in', 'hru-part')]/div[@type eq 'section']/div[@type eq 'pg']" mode="tei2html" priority="2">
    <tr>
      <th>
        <p>
          <xsl:apply-templates select="head/node()" mode="#current" />
          <xsl:apply-templates select="head/@*" mode="tei2html-rend-post"/>
        </p>
      </th>
      <td>
        <xsl:apply-templates select="* except head" mode="#current" />
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="div[@type = ('hru-lead-in', 'hru-part')]/div[@type eq 'section']/*[not(self::head or self::div[@type eq 'pg'])]" 
    priority="2" mode="tei2html_DISABLED"><!-- prio: otherwise interference with lists -->
    <tr>
      <td colspan="3">
        <xsl:next-match/>
      </td>
    </tr>
  </xsl:template>

  <!-- Tips -->
  <xsl:template match="div[@type = 'Tips']" mode="tei2html" priority="2">
    <table class="Tips two-column-main">
      <tr>
        <td class="main">
          <xsl:apply-templates mode="#current"/>
        </td>
        <td class="spacer"></td>
        <td class="margin"></td>
      </tr>
    </table>
  </xsl:template>

  <xsl:template match="div[@type = 'Tips_']/head" mode="tei2html">
    <xsl:element name="h3">
      <xsl:sequence select="letex:class-attr((.., .))" />
      <xsl:apply-templates mode="#current" />
    </xsl:element>
  </xsl:template>

  <!-- PAGEREF, EXERCISE heads -->

  <xsl:template match="div[@type = ('hru-pageref', 'hru-exercise')]/head" mode="tei2html">
    <table>
      <xsl:sequence select="letex:class-attr((.., .))" />
      <tr>
        <td>
          <xsl:sequence select="letex:class-attr((.., .))" />
          <xsl:element name="h{letex:heading-level(.)}">
            <xsl:sequence select="letex:class-attr((.., .))" />
            <xsl:if test="../@n">
              <span class="numbering">
                <xsl:value-of select="../@n"/>
              </span>
              <xsl:text>&#x2002;</xsl:text>
            </xsl:if>
            <xsl:apply-templates mode="#current" />
          </xsl:element>
        </td>
      </tr>
    </table>
  </xsl:template>


  <!-- INFOBOX -->

  <xsl:template match="div[@type = 'hru-infobox']" mode="tei2html">
    <div class="{@type}-container">
      <span class="{@type}-icon">&#x25e2;</span>
      <div class="{@type}">
        <div class="{@type}-content">
          <xsl:apply-templates mode="#current" />
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="div[@type = 'hru-infobox']/head" mode="tei2html">
    <xsl:element name="h{letex:heading-level(.)}">
      <xsl:sequence select="letex:class-attr((.., .))" />
      <xsl:apply-templates mode="#current" />
    </xsl:element>
  </xsl:template>




  <!-- LISTS -->

  <xsl:template match="list[letex:contains(@rend, 'inline')]" mode="tei2html">
    <xsl:variable name="sep-name" as="xs:string">
      <xsl:choose>
        <xsl:when test="letex:contains(@rend, 'bullet')">
          <xsl:sequence select="'bullet'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="'comma'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="sep" as="xs:string">
      <xsl:choose>
        <xsl:when test="$sep-name eq 'bullet'">
          <xsl:sequence select="'&#xa0;&#x2022; '" />
        </xsl:when>
        <xsl:when test="$sep-name eq 'comma'">
          <xsl:sequence select="', '" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="' '" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="rendered" as="element(html:span)">
      <span class="inline-list {$sep-name}">
        <xsl:apply-templates mode="#current">
          <xsl:with-param name="sep" select="$sep" />
        </xsl:apply-templates>
      </span>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="ancestor::p">
        <xsl:sequence select="$rendered" />
      </xsl:when>
      <xsl:otherwise>
        <p>
          <xsl:sequence select="letex:class-attr((ancestor::div[@edu:*][1], .., .))" />
          <xsl:sequence select="$rendered" />
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="list[letex:contains(@rend, 'inline')]/item" mode="tei2html">
    <xsl:param name="sep" as="xs:string" />
    <span class="list-item">
      <xsl:apply-templates mode="#current"/>
    </span>
    <xsl:if test="following-sibling::item">
      <xsl:value-of select="$sep" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="table | th | td | tr | cols | col | td/p | th/p" mode="tei2html">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*" mode="tei2html-tableatts"/>
      <xsl:sequence select="letex:style-overrides(.)" />
      <xsl:sequence select="letex:class-attr((ancestor::div[@edu:*][1], .., .))" />
      <xsl:apply-templates mode="#current"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="table/@width[. = '50%']" mode="tei2html-class" as="xs:string">
    <xsl:sequence select="'float-right'"/>
  </xsl:template>

  <xsl:template match="p/@type[. = 'KV']" mode="tei2html-class" as="xs:string">
    <xsl:sequence select="'KV'"/>
  </xsl:template>
  

  <xsl:template match="@type" mode="tei2html-tableatts" />

  <xsl:template match="@css:*" mode="tei2html-tableatts" />
  
  <xsl:template match="@type" mode="tei2html-class" as="xs:string">
    <xsl:sequence select="string(.)"/>
  </xsl:template>

  <xsl:template match="@type" mode="tei2html"/>

  <xsl:template match="@edu:opt[. eq 'true']" mode="tei2html-class" as="xs:string">
    <xsl:sequence select="'edu-opt'"/>
  </xsl:template>



  <xsl:template match="ptr[@cRef]" mode="tei2html">
    <xsl:if test="@type eq 'page'">
      <xsl:value-of select="if (@subtype = 'abbrev') 
                            then 'S.&#xa0;' 
                            else
                              if (contains(@cRef, ','))
                              then 'Seiten '
                              else 'Seite '"/>
    </xsl:if>
    <span class="link">
      <xsl:value-of select="@cRef"/>
    </span>
    <xsl:if test="@type eq 'page-and-number'">
      <xsl:value-of select="if (@subtype = 'abbrev') 
                            then ' auf S.&#xa0;' 
                            else
                              if (contains(@cRef, ','))
                              then ' auf Seiten ??'
                              else ' auf Seite ??'"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="ref" mode="tei2html">
    <span class="link">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>


  <xsl:template match="lg[@type eq 'pg']" mode="tei2html">
    <div>
      <xsl:sequence select="letex:class-attr((ancestor::div[@edu:*][1], .))" />
      <xsl:apply-templates mode="#current" />
    </div>
  </xsl:template>

  <xsl:template match="lg/l | lg[@type eq 'pg']/head" mode="tei2html">
    <p>
      <xsl:sequence select="letex:class-attr((ancestor::div[@edu:*][1], ., ..))" />
      <xsl:apply-templates mode="#current" />
    </p>
  </xsl:template>

  <xsl:template match="lg" mode="tei2html-class" as="xs:string">
    <xsl:sequence select="name()" />
  </xsl:template>

  <xsl:template match="lg/*[following-sibling::*]" mode="tei2html-class" as="xs:string">
    <xsl:sequence select="'no-space-after'" />
  </xsl:template>

  <xsl:template match="foreign" mode="tei2html">
    <xsl:choose>
      <xsl:when test="letex:contains(@rend, 'icon')">
        <xsl:apply-templates select="@rend" mode="tei2html-rend-replace" />
      </xsl:when>
      <xsl:otherwise>
        <i>
          <xsl:sequence select="letex:style-overrides(.)" />
          <xsl:apply-templates select="@* except @css:*" mode="#current"/>
          <xsl:apply-templates select="@rend" mode="tei2html-rend-pre" />
          <xsl:apply-templates select="node()" mode="#current"/>
        </i>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="emph" mode="tei2html">
    <b>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="@rend" mode="tei2html-rend-pre" />
      <xsl:apply-templates select="node()" mode="#current"/>
    </b>
  </xsl:template>

  <xsl:template match="name[@type eq 'textbook-series']" mode="tei2html">
    <i>
      <xsl:sequence select="letex:class-attr(.)" />
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="@rend" mode="tei2html-rend-pre" />
      <xsl:apply-templates select="node()" mode="#current"/>
    </i>
  </xsl:template>

  

  <xsl:template match="seg" mode="tei2html">
    <xsl:if test="@type eq 'Glossref'">
      <xsl:apply-templates select="@type" mode="tei2html-rend-pre" />
    </xsl:if>
    <span>
      <xsl:sequence select="letex:class-attr(.)" />
      <xsl:sequence select="letex:style-overrides(.)" />
      <xsl:apply-templates select="@* except @css:*" mode="#current"/>
      <xsl:apply-templates select="@rend" mode="tei2html-rend-pre" />
      <xsl:apply-templates select="node()" mode="#current"/>
    </span>
  </xsl:template>

  <xsl:template match="term" mode="tei2html">
    <span class="term-group">
      <xsl:if test="not(letex:contains(../@rend, 'link'))">
        <span class="decoration">
          <xsl:text>&#x25ba;&#xa0;</xsl:text>
        </span>
      </xsl:if>
      <span class="term">
        <xsl:apply-templates mode="#current"/>
      </span>
    </span>
  </xsl:template>

  <xsl:template match="list[@type='ordered']" mode="tei2html">
    <xsl:variable name="type" select="if (every $i in item/@n satisfies matches($i,'^[0-9]+')) then 'decimal' else 'default'"/>
    <ol>
      <xsl:attribute name="class" select="$type"/>
      <xsl:for-each select="item">
        <li>
          <xsl:apply-templates select="." mode="#current"/>
        </li>
      </xsl:for-each>
    </ol>
  </xsl:template>

  <xsl:template match="list[@type='unordered']" mode="tei2html">
    <xsl:variable name="type" select="if (every $i in item/@n satisfies matches($i,'^\-$')) then 'ndash' else 'default'"/>
    <ul>
      <xsl:attribute name="class" select="$type"/>
      <xsl:for-each select="item">
        <li>
          <xsl:apply-templates select="." mode="#current"/>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template match="graphic" mode="tei2html">
    <img>
      <xsl:attribute name="src" select="@url"/>
      <xsl:attribute name="alt" select="@url"/>
      <xsl:copy-of select="@width|@height"/>
    </img>
  </xsl:template>

  <xsl:function name="letex:contains" as="xs:boolean">
    <xsl:param name="space-sep-list" as="xs:string?" />
    <xsl:param name="item" as="xs:string+" />
    <xsl:sequence select="$item = tokenize($space-sep-list, '\s+', 's')" />
  </xsl:function>

</xsl:stylesheet>
