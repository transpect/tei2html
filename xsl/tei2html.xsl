<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:hub2htm="http://transpect.io/hub2htm" 
  xmlns:tei2html="http://transpect.io/tei2html"
  xmlns:l10n="http://transpect.io/l10n" 
  xmlns:tr="http://transpect.io"
  xmlns:epub="http://www.idpf.org/2007/ops" 
  xmlns:aria="http://www.w3.org/ns/wai-aria/" 
  xmlns:htmltable="http://transpect.io/htmltable"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns="http://www.w3.org/1999/xhtml" 
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all" 
  version="2.0">

  <xsl:import href="http://transpect.io/hub2html/xsl/css-rules.xsl"/>
  <xsl:import href="http://transpect.io/hub2html/xsl/css-atts2wrap.xsl"/>
  <xsl:import href="http://transpect.io/htmltables/xsl/html-tables-normalize.xsl"/>
  <xsl:import href="http://transpect.io/xslt-util/lengths/xsl/lengths.xsl"/>
  <xsl:import href="http://transpect.io/xslt-util/num/xsl/num.xsl"/>
  <xsl:import href="http://transpect.io/xslt-util/flat-list-to-tree/xsl/flat-list-to-tree.xsl"/>

  <xsl:param name="debug" select="'yes'"/>
  <xsl:param name="debug-dir-uri" select="'debug'"/>
  <xsl:param name="verbose" select="'yes'"/>

  <xsl:param name="s9y1-path" as="xs:string?"/>
  <xsl:param name="s9y2-path" as="xs:string?"/>
  <xsl:param name="s9y3-path" as="xs:string?"/>
  <xsl:param name="s9y4-path" as="xs:string?"/>
  <xsl:param name="s9y5-path" as="xs:string?"/>
  <xsl:param name="s9y6-path" as="xs:string?"/>
  <xsl:param name="s9y7-path" as="xs:string?"/>
  <xsl:param name="s9y8-path" as="xs:string?"/>
  <xsl:param name="s9y9-path" as="xs:string?"/>
  <xsl:param name="s9y1-role" as="xs:string?"/>
  <xsl:param name="s9y2-role" as="xs:string?"/>
  <xsl:param name="s9y3-role" as="xs:string?"/>
  <xsl:param name="s9y4-role" as="xs:string?"/>
  <xsl:param name="s9y5-role" as="xs:string?"/>
  <xsl:param name="s9y6-role" as="xs:string?"/>
  <xsl:param name="s9y7-role" as="xs:string?"/>
  <xsl:param name="s9y8-role" as="xs:string?"/>
  <xsl:param name="s9y9-role" as="xs:string?"/>
  
  <xsl:param name="epub-version" select="'EPUB2'" as="xs:string"/>
  <xsl:param name="xhtml-version" select="'1.0'" as="xs:string">
    <!-- supported values: '1.0', '5.0' -->
  </xsl:param>
  
  <xsl:param name="tei2html:copy-dt-class-from-dd" select="false()" as="xs:boolean"/>
  <xsl:param name="generate-note-link-title" select="false()" as="xs:boolean"/>
  <xsl:param name="tei2html:initial-letter-prop-handling" as="xs:string" select="'unchanged'">
     <!-- expected values: 
        - 'remove': discards the drop-cap properties
        - 'unchanged': preserve the porperty as style attribute
        - string-value: create a class with the given name, discard the CSS propertiy. e.g. drop-cap. can be styled via CSS -->
  </xsl:param>
  <xsl:param name="tei2html:table2figure" as="xs:boolean" select="false()">
    <!-- if set true() tables will be put in figure elements instead of divs -->
  </xsl:param>

  <!-- override this in your adaptions with 3, then epub-types are created -->
  <xsl:variable name="tei2html:epub-type" as="xs:string" select="if ($epub-version) then replace($epub-version, '^EPUB', '') else '2'"/>

  <xsl:variable name="paths" as="xs:string*"
    select="($s9y1-path, $s9y2-path, $s9y3-path, $s9y4-path, $s9y5-path, $s9y6-path, $s9y7-path, $s9y8-path, $s9y9-path)"/>
  <xsl:variable name="s" as="xs:string*"
    select="($s9y1-role, $s9y2-role, $s9y3-role, $s9y4-role, $s9y5-role, $s9y6-role, $s9y7-role, $s9y8-role, $s9y9-role)"/>
  <xsl:variable name="common-path" as="xs:string?"
    select="$paths[position() = index-of($s, 'common')]"/>

  <xsl:param name="divify-sections" select="'no'"/>
  <xsl:param name="calculate-table-width" as="xs:boolean" select="true()">
    <!-- If this parameter is set true, table width is calculated based on percentage of page width (not type area width) --> </xsl:param>
  <xsl:param name="css-location" select="concat($common-path, 'css/stylesheet.css')"/>

  <!-- for calculating whether a table covers the whole width or only part of it: -->
  <xsl:param name="page-width" select="'180mm'"/>
  <xsl:param name="page-width-twips" select="tr:length-to-unitless-twip($page-width)" as="xs:double"/>
  <xsl:param name="srcpaths" select="'no'"/>
  <xsl:variable name="tei2html:set-bodymatter-epub-type" select="false()"/>
  <xsl:variable name="tei2html:set-backmatter-epub-type" select="false()"/>

  <xsl:variable name="tei2html:allow-floats-in-para" select="('inline-marginal')" as="xs:string+">
    <!-- value 'inline-marginal' is not defined only as placeholder. if you want to exclude marginals or other floatingTexts from splittin paras, insert its type here as sting list. example ('marginal') -->
  </xsl:variable>
  <xsl:variable name="box-to-image-via-rendition" select="true()"/>

  <xsl:output method="xhtml" indent="no"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0//EN"
    saxon:suppress-indentation="p li h1 h2 h3 h4 h5 h6 th td dd dt"/>

  <xsl:param name="lang" select="(/*/@xml:lang, 'en')[1]" as="xs:string"/>

  <xsl:param name="apply-cstyles-in-indexterms" select="false()" as="xs:boolean"/>
  <xsl:param name="tei2html:add-blockquote-to-epigraph"  select="false()" as="xs:boolean"/>
  <xsl:variable name="l10n" select="document(concat('l10n.', ($lang, 'en')[1], '.xml'))" as="document-node(element(l10n:l10n))"/>
  
  <xsl:key name="tei2html:content-styled-by-rule" match="*[@class]" use="tokenize(@class, '\s+')"/>
  
  <!-- table style name for  auxiliary tables (without borders) -->
  <xsl:variable name="tei2html:auxiliary-table-style-regex" select="'letex_aux-table'" as="xs:string"/>
  <xsl:variable name="tei2html:add-toc-headline-to-toc" select="false()" as="xs:boolean"/>
  
  <!-- separate the endnotes list by section headlines
       e.g. '0' ... no section headlines
            '1' ... sections from the 1st level are included
            '2' ... sections from 1st and 2nd level are included
  -->
  <xsl:variable name="tei2html:endnote-heading-level" select="0" as="xs:integer"/>
  
  <xsl:key name="l10n-string" match="l10n:string" use="@id"/>
  <xsl:key name="rule-by-name" match="css:rule" use="@name"/>
  <xsl:key name="by-id" match="*[@id | @xml:id]" use="@id | @xml:id"/>
  <xsl:key name="link-by-anchor" match="*:ref" use="@target"/>

  <!-- identity template -->
  <xsl:template match="* | @*" mode="expand-css clean-up table-widths epub-alternatives join-segs"
    priority="-0.5">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="tei2html:main-sec-name" as="xs:string">
    <xsl:param name="context" as="element()"/>
    <xsl:sequence select="if (xs:double($xhtml-version) ge 5 
                              and $context[self::div[@type = $default-structural-containers]|self::divGen|self::text|self::back|self::front]) then 'section' else 'div'"/>
  </xsl:function>

  <xsl:template match="*" mode="tei2html" priority="-1">
    <xsl:if test="$verbose eq 'yes'">
      <xsl:message>tei2html: unhandled: <xsl:apply-templates select="." mode="css:unhandled"/></xsl:message>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*" mode="tei2html" priority="-1.5">
    <xsl:if test="$verbose eq 'yes'">
      <xsl:message>tei2html: unhandled attr: <xsl:apply-templates select="." mode="css:unhandled"/></xsl:message>
    </xsl:if>
  </xsl:template>

  <!-- collateral. Otherwise the generated IDs might differ due to temporary trees / variables 
    when transforming the content -->
  <xsl:template match="index | note[not(@xml:id)]" mode="epub-alternatives">
    <xsl:copy copy-namespaces="no">
      <xsl:attribute name="xml:id" select="generate-id()"/>
      <xsl:apply-templates select="@* except @xml:id, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!-- handle conditional texts -->
  <xsl:template match="*[@rendition = 'PrintOnly']" mode="epub-alternatives"/>
  <!-- no longer needed here -->
  <xsl:template match="*[@rendition[. = 'EOnly']][count(@*) eq 2][@srcpath]"
    mode="epub-alternatives">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>

  <xsl:template match="@rendition[. = 'EOnly']" mode="epub-alternatives"/>

  <xsl:template match="*[p[ancestor-or-self::*[@rendition eq 'EpubAlternative']]]"
    mode="epub-alternatives" priority="2">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates
        select="@*, head | info | p[descendant-or-self::*[@rendition eq 'EpubAlternative']]"
        mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template
    match="*[preceding-sibling::p[descendant-or-self::*[@rendition eq 'EpubAlternative']]]"
    mode="epub-alternatives" priority="2"/>

  <!-- if cells have a percentage width, then this mode can append classes like 'cellwidth-39' to a cell. Those generated classes are added as css:rules as well.-->

  <xsl:template match="/" mode="col-widths">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>

  <xsl:template match="*:TEI" mode="col-widths">
    <xsl:variable name="text">
      <xsl:apply-templates select="*:text" mode="#current"/>
    </xsl:variable>
    <xsl:copy>
      <xsl:apply-templates select="@*, *:teiHeader" mode="#current">
        <xsl:with-param name="table-classes"
          select="
            distinct-values(for $class in $text//@rend[matches(., 'cellwidth-')]
            return
              replace($class, '^.+(cellwidth-.+)$', '$1'))"
          as="xs:string*" tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:sequence select="$text"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="css:rules" mode="col-widths">
    <xsl:param name="table-classes" as="xs:string*" tunnel="yes"/>
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:for-each select="$table-classes">
        <xsl:element name="css:rule" xmlns="">
          <xsl:attribute name="native-name" select="."/>
          <xsl:attribute name="name" select="replace(., '\.', '_')"/>
          <xsl:attribute name="layout-type" select="'cell'"/>
          <xsl:attribute name="css:width" select="concat(replace(., '^cellwidth-', ''), '%')"/>
        </xsl:element>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <!--  <xsl:template match="*:table[exists(descendant::*:tr[count(*) ge 5])]" mode="col-widths">
    <!-\- adding the cellwidth classes on cells of tables with more than 4 cells causes ADE in most cases to render the table much too wide -\->
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:copy-of select="node()"/>
      </xsl:copy>
  </xsl:template>-->

  <xsl:template match="*[*:tr]" mode="col-widths">
    <xsl:variable name="table">
      <xsl:sequence select="htmltable:normalize(.)"/>
    </xsl:variable>
    <xsl:apply-templates select="$table" mode="create-table-width-classes"/>
  </xsl:template>

  <xsl:template match="@* | node()" mode="col-widths create-table-width-classes">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template
    match="*[local-name() = ('td', 'th')][@data-twips-width]/@*[name() = (/*/@css:rule-selection-attribute, 'rend')[1]]"
    mode="create-table-width-classes">
    <xsl:variable name="percent"
      select="concat('cellwidth-', xs:string(floor((../@data-twips-width) * 100 div ../../@data-twips-width)))"
      as="xs:string?"/>
    <xsl:attribute name="{name()}" select="string-join((., $percent), ' ')"/>
  </xsl:template>

  <xsl:template match="*[local-name() = ('td')][../..[*:colgroup]]
                        [parent::*:tr[*[xs:integer(@colspan) gt 1]]]
                        [@data-twips-width]/@*[name() = (/*/@css:rule-selection-attribute, 'rend')[1]]
                      |*[local-name() = ('th')][../../..[*:colgroup] 
                       or ../../../..[*:colgroup]][parent::*:tr[*[xs:integer(@colspan) gt 1]]]
             [@data-twips-width]/@*[name() = (/*/@css:rule-selection-attribute, 'rend')[1]]"
      mode="create-table-width-classes" priority="2">
    <xsl:variable name="elt" select=".." as="element(*)"/>
    <xsl:variable name="pos" select="xs:integer(replace($elt/@data-colnum, '^.+?-(\d)+', '$1'))"/>
    <xsl:variable name="cell-with-correct-width" as="element(*)+"
      select="
        if ($elt[xs:integer(@colspan) gt 1]) then
          ancestor::*[*:colgroup][1]/*:colgroup/*:col[(position() ge $pos) and (position() le ($pos + xs:integer($elt/@colspan - 1)))]
        else
          .."/>
    <xsl:variable name="row-with-correct-width" as="element(*)*"
      select="ancestor::*[*:colgroup][1]/*:colgroup/*:col"/>
    <!--  <xsl:if test="ancestor::*[self::*:table][1][@xml:id = 'Tab33']">
      <xsl:message select="'###### row: ', $row-with-correct-width, '##### cell: ', $cell-with-correct-width"/>
      <xsl:message select="'###### ', ../../../*:colgroup"/>
    </xsl:if>-->
    <xsl:variable name="percent" as="xs:string?"
      select="concat('cellwidth-', xs:string(floor((sum($cell-with-correct-width/@data-twips-width) * 100) div sum($row-with-correct-width/@data-twips-width))))"/>
    <xsl:attribute name="{name()}" select="string-join((., $percent), ' ')"/>
  </xsl:template>

  <xsl:template
    match="@data-twips-width | @data-rownum | *:colgroup[*:col[not(@*) or @data-twips-width]]"
    mode="create-table-width-classes"/>

  <xsl:template
    match="*:td[@data-rowspan-part &gt; 1] | *:td[@data-colspan-part &gt; 1] | *:th[@data-colspan-part &gt; 1] | *:th[@data-rowspan-part &gt; 1]"
    mode="create-table-width-classes" priority="3"/>

  <xsl:template match="/*/@*[name() = ('source-dir-uri', 'xml:base')]" mode="tei2html">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="@xml:lang" mode="epub-alternatives hub2htm:css-style-overrides" priority="2">
    <xsl:attribute name="lang" select="."/>
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="@xml:lang | @lang" mode="tei2html">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="@xml:lang[. = ../ancestor::*[@xml:lang][1]/@xml:lang]" mode="tei2html"
    priority="3"/>

  <xsl:template match="@lang[. = ../ancestor::*[@lang][1]/@lang]" mode="tei2html" priority="3"/>

  <xsl:template match="/*/@*[name() = ('version')]" mode="tei2html"/>

  <xsl:template match="/TEI" mode="tei2html">
    <html>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="$tei2html:epub-type eq '3'">
        <!-- Extended semantics for EPUB Structural Semantics Vocabulary 
             https://idpf.github.io/a11y-guidelines/content/semantics/epub-type.html#sem005-desc-custom
        -->
        <xsl:attribute name="epub:prefix" select="'tr: http://transpect.io'"/>
      </xsl:if>
      <head>
        <xsl:call-template name="stylesheet-links"/>
        <title>
          <xsl:apply-templates
            select="(//titlePart[@type = 'main'], teiHeader/fileDesc/titleStmt/title)[1]//text()[not(ancestor::*[self::note]) and not(ancestor::*[self::index])]"
            mode="#current">
            <!-- suppress replicated target with id: -->
            <xsl:with-param name="in-toc" select="true()" tunnel="yes"/>
          </xsl:apply-templates>
        </title>
        <xsl:call-template name="meta"/>
        <xsl:apply-templates select="teiHeader/encodingDesc/css:rules" mode="#current"/>
      </head>
      <body>
        <xsl:call-template name="html-body"/>
      </body>
    </html>
  </xsl:template>

  <xsl:variable name="suppress-docProps" as="xs:boolean" select="true()"/>
  
  <xsl:template match="textClass/keywords[@rendition = 'docProps']" mode="tei2html" priority="5">
    <xsl:if test="not($suppress-docProps)">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="textClass/keywords[@rendition]" mode="tei2html">
    <xsl:variable name="keywords" select="string-join(term/text(), ', ')"/>
    <xsl:variable name="zahl" select="5" as="xs:integer"/>
    <div class="keywords">
      <p class="{local-name()}">
        <b>
          <xsl:value-of select="tr:unescape-uri(@rendition)"/>
        </b>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$keywords"/>
      </p>
    </div>
  </xsl:template>

  <xsl:template name="stylesheet-links">
    <link href="{$css-location}" type="text/css" rel="stylesheet"/>
    <xsl:for-each select="reverse($paths)[not(. = $common-path)]">
      <xsl:if test="unparsed-text-available(concat(., 'css/overrides.css'))">
        <link href="{.}css/overrides.css" type="text/css" rel="stylesheet"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="titlePage" mode="tei2html"/>

  <xsl:template match="css:rule" mode="tei2html">
    <xsl:call-template name="css:move-to-attic">
      <xsl:with-param name="atts" select="@*[css:map-att-to-elt(., current())]"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="css:rules" mode="tei2html">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*, node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="css:rule[css:attic[@css:display = 'list-item']]" mode="epub-alternatives">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:copy-of select="css:attic/@css:list-style-type"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="html-body">
    <xsl:apply-templates select="text" mode="#current"/>
  </xsl:template>

  <xsl:variable name="tei2html:abstract-and-keyword-rendering" as="xs:boolean" select="false()"/>
  <xsl:variable name="tei2html:chapterwise-footnote" as="xs:boolean" select="false()"/>

  <xsl:template match="text" mode="tei2html">
    <xsl:if test="$tei2html:abstract-and-keyword-rendering">
      <xsl:apply-templates select="/*/teiHeader/profileDesc/abstract" mode="#current"/>
      <xsl:apply-templates select="/*/teiHeader/profileDesc/textClass/keywords[@rendition]"
        mode="#current"/>
    </xsl:if>
    <xsl:apply-templates select="node()" mode="#current">
        <xsl:with-param name="fn-ids" select="$footnote-ids" as="xs:string*" tunnel="yes"/>
    </xsl:apply-templates>
    <xsl:if test="not($tei2html:chapterwise-footnote) and (every $h in descendant::head satisfies $h[not(tei2html:is-global-note-heading(.))])">
      <xsl:call-template name="tei2html:footnotes">
        <xsl:with-param name="chapterwise" as="xs:boolean" select="false()" tunnel="yes"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:variable name="tei2html:global-note-heading-style" select="'transpect_global-endnote-style'" as="xs:string"/>

  <xsl:function name="tei2html:is-global-note-heading" as="xs:boolean">
    <xsl:param name="context" as="element()"/>
    <xsl:sequence select="exists($context[self::*:head[@type = 'main']
                                             [matches(@rend, $tei2html:global-note-heading-style)]
                                             [count(../*) le 3]
                                   ]
                                )"/>
  </xsl:function>


  <xsl:template match="*:head[tei2html:is-global-note-heading(.)]" mode="tei2html" priority="25">
    <xsl:next-match/>
    <xsl:if test="not($tei2html:chapterwise-footnote)">
    <xsl:variable name="footnotes" select="//note[@type = 'footnote']" as="element(note)*"/>
        <xsl:if test="$footnotes">
          <xsl:element name="{tei2html:main-sec-name(.)}">
            <xsl:attribute name="class" select="'notes'"/>
            <xsl:attribute name="epub:type" select="'footnotes'"/>
            <xsl:apply-templates select="//note[@type = 'footnote']" mode="notes">
              <xsl:with-param name="fn-ids" select="//note[@type = 'footnote']/@xml:id" as="xs:string*" tunnel="yes"/>
            </xsl:apply-templates>
          </xsl:element>
        </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:variable name="footnote-ids" as="xs:string*" select="/TEI/text//note[@type = 'footnote']/@xml:id"/>
  
  <xsl:template
    match="
      body | front | div[$divify-sections = 'no'][not(@type = ('imprint', 'dedication', 'preface', 'marginal', 'motto'))] |
      div1 | div2 | div3 | div4 | div5 | div6 | div7 | div8 | div9 | back | listBibl"
    mode="tei2html">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>

  <xsl:template match="/TEI/text/body[count(*) eq 1][p]/p[not(node()) and (every $att in @* satisfies ($att/name() = 'srcpath'))]" mode="tei2html"/>
    
  <xsl:variable name="tei2html:create-lox" as="xs:boolean" select="true()"/>

  <xsl:template match="/TEI/text/body" mode="tei2html">
    <xsl:if test="$tei2html:create-lox">
      <xsl:call-template name="lof"/>
      <xsl:call-template name="lot"/>
    </xsl:if>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <!-- List of Figures, List of Tables 
    It is expected that the location in the document, the headings, and classes will be adapted
    by another XSLT (e.g., htmltemplates)
  -->

  <xsl:template name="lof">
    <xsl:if test="//figure[normalize-space(head)]">
      <xsl:element name="{tei2html:main-sec-name(.)}">
        <xsl:attribute name="epub:type" select="'loi'"/>
        <xsl:attribute name="class" select="'lox loi'"/>
        <h2>List of Figures</h2>
        <xsl:apply-templates select="//figure[normalize-space(string-join(head, ' '))]" mode="lox"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="figure" mode="lox">
    <p>
      <a href="#{@xml:id}">
        <xsl:apply-templates select="(head[@type = 'titleabbrev'], head[not(@type)])[1]/label" mode="lox"/>
        <xsl:apply-templates select="(head[@type = 'titleabbrev'], head[not(@type)])[1]/node()[not(self::label)]"
          mode="strip-indexterms-etc"/>
      </a>
    </p>
  </xsl:template>

  <xsl:template match="(table|figure)/head//label" mode="lox">
    <xsl:apply-templates select="node()" mode="strip-indexterms-etc"/>
    <xsl:if test="following::node()[1][ancestor::head is current()/ancestor::head][not(matches(., '^\p{Zs}'))]">
      <xsl:apply-templates select="." mode="label-sep"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="lot">
    <xsl:if test="//table/head[normalize-space()]">
      <xsl:element name="{tei2html:main-sec-name(.)}">
        <xsl:attribute name="epub:type" select="'lot'"/>
        <xsl:attribute name="class" select="'lox lot'"/>
        <h2>List of Tables</h2>
        <xsl:apply-templates select="//table[head[normalize-space()]]" mode="lox"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="table" mode="lox">
    <p>
      <a href="#{@xml:id}">
        <xsl:apply-templates select="(head[@type = 'titleabbrev'], head[not(@type)])[1]/label" mode="lox"/>
        <xsl:apply-templates select="(head[@type = 'titleabbrev'], 
                                      head[not(@type)],
                                      head)[1]/node()[not(self::label)]"
          mode="strip-indexterms-etc"/>
      </a>
    </p>
  </xsl:template>

  <xsl:template match="div[@type = ('chapter', 'article', 'appendix', 'preface', 'bibliography')]
                          [not(..[@type = 'appendix'])]" mode="tei2html" priority="10">
    <xsl:param name="avoid-footnote-creation" select="false()" as="xs:boolean" tunnel="yes"/>
    <!-- also consider introductory text in parts -->
    <xsl:variable name="previous-text" as="element()*">
        <xsl:sequence select="if (.[..[self::div[@type = 'part']]]
                                   [. is ../div[1]]
                                   [not(@type = ('bibliography', 'appendix'))])
                              then preceding-sibling::*
                              else ()"/>
    </xsl:variable>
    <xsl:variable name="fn-ids" select="if ($tei2html:chapterwise-footnote) 
                                        then ($previous-text//note[@type = 'footnote']/@xml:id,.//note[@type = 'footnote']/@xml:id) 
                                        else $footnote-ids" as="xs:string*"/>
    <xsl:next-match>
      <xsl:with-param name="fn-ids" select="$fn-ids" as="xs:string*" tunnel="yes"/>
    </xsl:next-match>
    <xsl:if test="$tei2html:chapterwise-footnote and not($avoid-footnote-creation) ">
      <xsl:call-template name="tei2html:footnotes">
        <xsl:with-param name="chapterwise" as="xs:boolean" select="true()" tunnel="yes"/>
        <xsl:with-param name="context" as="node()*" select="$previous-text, ." tunnel="yes"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

 <xsl:template match="div[@type]" mode="tei2html" priority="3">
    <xsl:element name="{tei2html:main-sec-name(.)}">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:message select="'----', @type, @rend, $tei2html:epub-type, tr:create-epub-type-attribute($tei2html:epub-type, .)"/>
      <xsl:sequence select="tr:create-epub-type-attribute($tei2html:epub-type, .)"/>
      <xsl:apply-templates select="." mode="class-att"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="div[@type]" mode="class-att" priority="3">
    <xsl:attribute name="class"
      select="
        if (@rend) then
          concat(@rend, ' ', @type)
        else
          @type"/>
  </xsl:template>

  <!--  <xsl:template match="div[@type = ('imprint', 'dedication', 'preface', 'marginal')]" mode="tei2html" priority="2">
    <div>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </div>
  </xsl:template>-->

  <xsl:template match="*:div" mode="tei2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template name="meta">
    <!-- warum matcht langUsage nicht? -->
    <xsl:apply-templates select="teiHeader/profileDesc/langUsage" mode="#current"/>
    <xsl:apply-templates select="teiHeader/profileDesc/textClass/keywords[not(@rendition)]"
      mode="#current"/>
  </xsl:template>

  <xsl:template match="keywords" mode="tei2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="langUsage" mode="tei2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="keywords/term" mode="tei2html"/>

  <xsl:template match="keywords/term[@key = ('source-dir-uri', 'source-basename', 'source-type')]"
    mode="tei2html" priority="2">
    <meta name="{@key}" content="{.}"/>
  </xsl:template>

  <xsl:template match="langUsage/language" mode="tei2html" priority="2">
    <meta name="lang" content="{@ident}"/>
  </xsl:template>

  <xsl:template match="/TEI/teiHeader/fileDesc/publicationStmt/date" mode="tei2html" priority="5">
    <meta name="date" content="{.}"/>
  </xsl:template>

  <!-- Default handler for the content of para-like and phrase-like elements,
    invoked by an xsl:next-match for the same matching elements. Don't forget 
    to include the names of the elements that you want to handle here. Otherwise
    they'll be reported as unhandled.
    And don’t ever change the priority unless you’ve made sure that no other template
    relies on this value to be 0.25.
    -->
  <xsl:template
    match="
      head | quote | seg | p | table | caption | note | italic | bold | unclear | idno |
      underline | sub | sup | l | lg | hi | argument | emph | add | settlement | orig | date | name | persName | roleName | surname | Name | forename | spGrp | sp | speaker | stage"
    mode="tei2html" priority="-0.25">
    <xsl:call-template name="css:content"/>
  </xsl:template>

  <xsl:template name="css:other-atts">
    <xsl:variable name="class" as="attribute(class)?">
      <xsl:apply-templates select="." mode="class-att"/>
    </xsl:variable>
    <!-- avoid to return class attribute in css:other-atts twice -->
    <xsl:call-template name="css:remaining-atts">
      <xsl:with-param name="remaining-atts"
        select="@*[not(css:map-att-to-elt(., ..))][not(. is $class)]"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="epigraph" mode="tei2html">
    <xsl:choose>
      <xsl:when test="parent::*[self::div[@type = 'motto']]">
        <xsl:apply-templates select="node()" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <div class="motto">
          <xsl:apply-templates select="node()" mode="#current"/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="postscript" mode="tei2html">
    <div>
      <xsl:call-template name="css:content"/>
    </div>
  </xsl:template>

  <xsl:template match="postscript" mode="class-att">
    <xsl:attribute name="class" separator=" "
      select="distinct-values(tokenize(string-join((local-name(), @type, @rend), ' '), '\s+'))"/>
  </xsl:template>

  <xsl:template match="floatingText" mode="class-att" priority="2">
    <xsl:if test="@rend or @type or @rendition">
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="@rendition and @rendition[matches(., '\.(png|jpe?g)$', 'i')]">
            <xsl:value-of select="'alt-image'"/>
          </xsl:when>
          <xsl:when test="not(@rend)">
            <xsl:value-of
              select="
              if (@type) then
              @type
              else
              ''"/>
          </xsl:when>
          <xsl:when test="@rendition and @rendition[matches(., '\.(png|jpe?g)$', 'i')]">
            <xsl:value-of
              select="
              if (@type) then
              @type
              else
              ''"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of
              select="
              if (@rend = @type) 
              then @rend 
              else
              concat(@type, ' ', @rend)"
            />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template match="floatingText" mode="tei2html" name="default-floatingText">
    <div>
      <xsl:apply-templates select="." mode="class-att"/>
      <xsl:choose>
        <xsl:when test="@rendition and $box-to-image-via-rendition">
          <xsl:for-each select="tokenize(@rendition, ' ')">
            <xsl:element name="img" exclude-result-prefixes="#all">
              <xsl:attribute name="src" select="."/>
              <xsl:attribute name="class" select="'alt-image'"/>
              <xsl:attribute name="alt"
                select="concat('This is an alternative image named »', replace(., '^.+/(.+?)$', '$1'), '« of the original box. Due to displaying constraints of ePub readers it is delivered as an image only.')"
              />
            </xsl:element>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="@* except (@rend, @type, @rendition), node()" mode="#current">
            <xsl:with-param name="default-floatingText" as="xs:boolean" tunnel="yes" select="true()"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <!-- changeable order of figure elements-->
  <xsl:template match="table[@rendition[matches(., '\.(png|jpe?g)$', 'i')]][not(parent::p)]"
    mode="tei2html" priority="5">
    <xsl:element name="{if ($tei2html:table2figure and xs:double($xhtml-version) ge 5) then 'figure' else 'div'}">
      <xsl:attribute name="class" select="'table-wrapper alt-image'"/>
      <xsl:if test="matches(@xml:id, '^(cell)?page_')">
        <a id="{@xml:id}"/>
      </xsl:if>
      <xsl:if test="$tei2html:table-head-before-table">
        <xsl:call-template name="table-heading"/>
      </xsl:if>
      <xsl:for-each select="tokenize(@rendition, ' ')">
        <xsl:element name="img" exclude-result-prefixes="#all">
          <xsl:attribute name="src" select="."/>
          <xsl:attribute name="class" select="'alt-image'"/>
          <xsl:attribute name="alt"
            select="concat('This is an alternative image named »', replace(., '^.+/(.+?)$', '$1'), '« of the original table. Due to constraints of ePub readers it is delivered as an image only.')"
          />
        </xsl:element>
      </xsl:for-each>
      <xsl:if test="not($tei2html:table-head-before-table)">
        <xsl:call-template name="table-heading"/>
      </xsl:if>
      <xsl:apply-templates select="postscript | bibl | p" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <!-- changeable order of figure elements-->
  <xsl:template match="table[@rendition[matches(., '\.(png|jpe?g)$', 'i')]][parent::p]"
    mode="tei2html" priority="5">
    <xsl:if test="matches(@xml:id, '^(cell)?page_')">
      <a id="{@xml:id}"/>
    </xsl:if>
    <xsl:for-each select="tokenize(@rendition, ' ')">
      <xsl:element name="img" exclude-result-prefixes="#all">
        <xsl:attribute name="src" select="."/>
        <xsl:attribute name="class" select="'alt-image'"/>
        <xsl:attribute name="alt"
          select="concat('This is an alternative image named »', replace(., '^.+/(.+?)$', '$1'), '« of the original table. Due to constraints of ePub readers it is delivered as an image only.')"
        />
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <xsl:variable name="tei2html:table-head-before-table" as="xs:boolean" select="true()"/>

  <xsl:template name="table-heading">
    <xsl:param name="include-postscript-in-figcaption" as="xs:boolean?"/>
    <xsl:choose>
      <xsl:when test="$tei2html:table2figure and xs:double($xhtml-version) ge 5"> 
        <figcaption>
          <xsl:apply-templates select="head" mode="#current">
            <xsl:with-param name="not-discard-table-head" as="xs:boolean" tunnel="yes" select="true()"/>
          </xsl:apply-templates>
          <xsl:if test="$include-postscript-in-figcaption">
            <xsl:apply-templates select="postscript" mode="#current"/>
          </xsl:if>
        </figcaption>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="head" mode="#current">
          <xsl:with-param name="not-discard-table-head" as="xs:boolean" tunnel="yes" select="true()"/>
        </xsl:apply-templates>
        <xsl:if test="$include-postscript-in-figcaption">
          <xsl:apply-templates select="postscript" mode="#current"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="tei2html:strip-combining" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:sequence select="replace(normalize-unicode($input, 'NFKD'), '\p{Mn}', '')"/>
  </xsl:function>

  <!--  <xsl:template match="verse-line[@content-type | @style-type]" mode="class-att" priority="2">
    <xsl:variable name="att" as="attribute(class)?">
      <xsl:next-match/>
    </xsl:variable>
    <xsl:if test="$att">
      <xsl:attribute name="class" select="string-join(('verse-line', $att), ' ')"/>
    </xsl:if>
  </xsl:template>-->

  <xsl:variable name="tei2html:ignore-style-name-regex-x"
    select="'^(NormalParagraphStyle|Hyperlink)$'" as="xs:string"/>

  <!-- Is this needed? class-att is a mode that is meant to match elements. -->
  <!--<xsl:template match="@rend" mode="class-att">
    <xsl:if test="not(matches(., $tei2html:ignore-style-name-regex-x, 'x'))">
      <xsl:attribute name="class" select="replace(., ':', '_')"/>  
    </xsl:if>
  </xsl:template>-->

  <xsl:template match="table[@class = 'hub:right-tab']" mode="class-att" priority="2">
    <xsl:attribute name="class" select="'right-tab'"/>
  </xsl:template>

  <xsl:template match="@srcpath" mode="tei2html">
    <xsl:copy copy-namespaces="no"/>
  </xsl:template>

  <xsl:template match="@css:version | @css:rule-selection-attribute" mode="tei2html"/>

  <xsl:template match="table[@xml:id = ../@xml:id]/@xml:id" mode="tei2html"/>

  <xsl:template match="@css:*" mode="tei2html_DISABLED">
    <xsl:copy/>
  </xsl:template>

  <xsl:variable name="default-structural-containers" as="xs:string+"
    select="('part', 'chapter', 'virtual-part', 'virtual-chapter', 'front-matter-part', 'section', 'appendix', 'acknowledgements', 'dedication', 'preface')"/>

  <!-- everything that goes into a div (except footnote-like content): -->
  <xsl:template
    match="
            *[name() = $default-structural-containers][$divify-sections = 'yes']
            | caption | abstract | lg | spGrp"
    mode="tei2html" priority="2">
    <xsl:element name="{tei2html:main-sec-name(.)}">
      <xsl:call-template name="css:content"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="figure | figure/caption" mode="tei2html" priority="3">
    <xsl:element name="{if (xs:double($xhtml-version) ge 5) 
                        then 
                          if (self::figure) 
                          then 'figure' 
                          else 'figcaption' 
                        else 'div'}">
      <xsl:call-template name="css:content"/>
   </xsl:element>
  </xsl:template>

  <xsl:template match="*[name() = $default-structural-containers][not($divify-sections = 'yes')]"
    mode="tei2html" priority="2">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="docTitle" mode="tei2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="anchor[@xml:id]" mode="tei2html">
    <a id="{@xml:id}"/>
  </xsl:template>

  <!-- This was in mode clean-up which led to complaints about unhandled @xml:id attributes in mode tei2html -->
  <xsl:template match="@xml:id" mode="tei2html">
    <xsl:attribute name="id" select="."/>
  </xsl:template>

  <!-- Formerly label classes were created when a label had a srcpath. This was done to handle lables that were a para once (chapter numbers e.g.). 
    When converting tei2epub or after joining segs this information can be wrong. Therefore the template is changed. -->
  <xsl:template match="label[not(parent::item)]" mode="tei2html" priority="0.5">
    <span>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="." mode="class-att"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </span>
  </xsl:template>

  <xsl:template match="label[not(parent::item | parent::list)]" mode="class-att" priority="2">
    <xsl:attribute name="class"
      select="
        if (@rend) then
          concat(@rend, ' label block')
        else
          'label'"/>
  </xsl:template>

  <xsl:template match="*:label[ancestor::*:note]" mode="tei2html" priority="3"/>

  <xsl:template match="*[note[@type = 'footnote']]" mode="tei2html">
    <xsl:next-match/>
  </xsl:template>

  <xsl:template match="note[not(@type = 'footnote')]" mode="tei2html">
    <xsl:choose>
      <xsl:when test="text()[normalize-space()]">   
        <p><!-- only create p if text is contained (avoid creatin p around lists or paras) -->
          <xsl:next-match/>
        </p>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="docAuthor" mode="tei2html">
    <p>
      <xsl:call-template name="css:content"/>
    </p>
  </xsl:template>

  <xsl:template match="spGrp" mode="class-att">
    <xsl:attribute name="class" select="'speech-group'"/>
  </xsl:template>

  <xsl:template match="persName | surname | forename | name | abstract | byline | label | unclear | settlement | roleName"
    mode="class-att">
    <xsl:attribute name="class" select="local-name()"/>
  </xsl:template>

  <xsl:template match="Name" mode="class-att">
    <xsl:attribute name="class" select="'prefix'"/>
  </xsl:template>

  <xsl:template match="byline" mode="tei2html">
    <p>
      <xsl:call-template name="css:content"/>
    </p>
  </xsl:template>

  <!-- Footnotes -->

  <xsl:variable name="tei2html:after-footnote-marker-space" select="'&#xa0;'" as="xs:string"/>

  <xsl:template match="note" mode="notes">
    <xsl:param name="fn-ids" as="xs:string*" tunnel="yes"/>
    <xsl:variable name="note-marker-width" as="xs:string?"
                  select="if (string-length(xs:string(index-of($fn-ids, @xml:id)[1])) gt 2) 
                          then 'large'
                          else 'narrow'"/>
    <p class="{name()} footnote" id="fn_{@xml:id}" epub:type="endnote">
      <a href="#fna_{@xml:id}" class="fn-m {$note-marker-width}">
        <xsl:value-of select="index-of($fn-ids, @xml:id)"/>
        <xsl:value-of select="$tei2html:after-footnote-marker-space"/>
      </a>
      <span class="fn-t">
        <xsl:apply-templates mode="tei2html">
          <xsl:with-param name="in-notes" tunnel="yes" select="true()"/>
        </xsl:apply-templates>
      </span>
    </p>
  </xsl:template>

  <xsl:template match="note/*[local-name() = ('p', 'l')]" mode="tei2html">
    <!-- prevent invalid markup, use css to display breaks -->
    <span class="fn-p">
      <xsl:apply-templates mode="#current"/>
    </span>
  </xsl:template>

  <xsl:template
    match="
      *:seg[@type = 'tab'][ancestor::*[self::note]][not(preceding-sibling::*)][. is parent::*[self::*:p]/*[1]]
      | *:p/*:label[ancestor::*[self::note]][not(preceding-sibling::*)][. is parent::*[self::*:p]/*[1]]
      | *:seg[matches(string-join(.//text(), ''), '^\p{Zs}*$')][ancestor::*[self::note]][not(preceding-sibling::*)][. is parent::*[self::*:p]/*[1]]
      | text()[ancestor::*[self::note]]
              [preceding-sibling::*[1][self::*:seg[@type = 'footnotemarker']]]
              [matches(., '^\p{Zs}*$')]
      | *:index"
    mode="notes"/>

  <xsl:template match="*:note/@xml:id" mode="tei2html"/>

  <xsl:template
    match="*:seg[@type = 'tab'][preceding-sibling::*[1][self::*:label]][ancestor::*:note]"
    mode="tei2html"/>
  
  <xsl:variable name="chapterwise-footnotes-div-type" select="('article','chapter','part','appendix', 'bibliography')"/>

  <xsl:template match="note[@type = 'footnote']" mode="tei2html">
   <xsl:param name="in-toc" tunnel="yes" as="xs:boolean?"/>
   <xsl:param name="fn-ids" as="xs:string*" tunnel="yes"/>
   <xsl:variable name="previous-text" as="element()*">
        <xsl:sequence select="if (ancestor::div[@type=$chapterwise-footnotes-div-type][1]
                                               [..[self::div[@type = 'part']]]
                                               [. is ../div[1]])
                              then ancestor::div[@type=$chapterwise-footnotes-div-type][1]/preceding-sibling::*
                              else ()"/><!-- consider introductory text in parts -->
    </xsl:variable>
    <xsl:if test="not($in-toc)">
      <span class="note-anchor" id="fna_{@xml:id}">
        <a href="#fn_{@xml:id}">
          <xsl:if test="$tei2html:epub-type eq '3'">
            <xsl:attribute name="epub:type" select="'noteref'"/>
          </xsl:if>
          <xsl:call-template name="note-link-title"/>
          <xsl:variable name="footnote-number" 
                        select="if ($tei2html:chapterwise-footnote and ancestor::div[@type=$chapterwise-footnotes-div-type][not(..[@type = 'appendix'])]) 
                                then index-of(($previous-text,ancestor::div[@type=$chapterwise-footnotes-div-type][1])/descendant::note[@type='footnote']/@xml:id, @xml:id) 
                                else index-of($fn-ids, @xml:id)">
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="exists(ancestor::*[local-name() = ('hi', 'sup')]
                                              [not(@rend = ('strong', 'em'))]
                                   )">
              <xsl:value-of select="$footnote-number"/>
            </xsl:when>
            <xsl:otherwise>
              <sup>
                <xsl:value-of select="$footnote-number"/>
              </sup>
            </xsl:otherwise>
          </xsl:choose>
        </a>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template name="note-link-title" as="attribute(title)?">
    <!-- optional template to be overwritten in customer a9s -->
    <xsl:if test="$generate-note-link-title">
      <xsl:attribute name="title">
        <xsl:apply-templates select="node()" mode="notes"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template match="gloss" mode="tei2html">
    <xsl:choose>
      <xsl:when test="preceding-sibling::*[1][local-name() = 'term']">
        <span>
          <xsl:apply-templates select="@*, node()" mode="#current"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <p>
          <xsl:apply-templates select="@*, node()" mode="#current"/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="list[@type eq 'gloss']" mode="tei2html">
    <dl>
      <xsl:call-template name="css:content"/>
    </dl>
  </xsl:template>

  <xsl:template match="item/@n" mode="tei2html"/>

  <xsl:function name="tei2html:is-varlistentry" as="xs:boolean">
    <xsl:param name="item" as="element(item)?"/>
    <xsl:sequence select="$item/parent::list[@type eq 'gloss'] or $item/@rend = 'varlistentry'"/>
  </xsl:function>

  <xsl:template match="label[tei2html:is-varlistentry(following-sibling::*[1][self::item])]"
    mode="tei2html" priority="1">
    <xsl:variable name="wide-label" as="xs:string?" select="if (string-length(string-join(descendant::text(), '')) ge 3) then 'wide' else ()"/>
    <xsl:variable as="xs:string?" name="class">
      <xsl:if test="$tei2html:copy-class-from-item-to-dt">
        <xsl:apply-templates select="following-sibling::*[1][self::item]/gloss[1]/@rend" mode="#current"/>
      </xsl:if>
    </xsl:variable>
      <dt>
        <xsl:apply-templates select="@*" mode="#current"/>
        <xsl:if test="$tei2html:copy-dt-class-from-dd or $wide-label = 'wide' or @rend">
          <xsl:attribute name="class" select="string-join((@rend, $class, $wide-label), ' ')"/>
        </xsl:if>
        <xsl:apply-templates select="node()" mode="#current"/>
      </dt>
  </xsl:template>

  <xsl:template match="item[tei2html:is-varlistentry(.)]" mode="tei2html">
    <dd>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </dd>
  </xsl:template>
  

  <xsl:template match="list[@type = ('bulleted', 'simple', 'indexlist')]" mode="tei2html">
    <ul>
      <xsl:call-template name="css:content"/>
    </ul>
  </xsl:template>

  <xsl:template match="list[@type = ('bulleted', 'simple', 'indexlist')]" mode="class-att" priority="2">
    <xsl:attribute name="class" select="(descendant::p[1]/@rend, @type)[1]"/>
  </xsl:template>

  <xsl:template match="list[@type eq 'ordered']" mode="tei2html">
    <ol>
     <xsl:if test="$epub-version = 'EPUB3' 
                    and 
                   not(matches(string-join(./*:item[1]/@n, ''), $tei2html:ordered-to-def-list-regex))">
      <xsl:variable name="start-counter" select="replace(string-join(./*:item[1]/@n, ''), '[\(\[\.\)\]]','')" as="xs:string"/>
      <xsl:variable name="start-val" select="if (@style = ('loweralpha', 'upperalpha')) then tr:letters-to-number($start-counter, string-length($start-counter)) else
                                          if (@style = ('lowerroman', 'upperroman' )) then tr:roman-to-int($start-counter) else $start-counter"/>
      <xsl:if test="$start-val[. castable as xs:integer]"><xsl:attribute name="start" select="$start-val"/></xsl:if>
       
     </xsl:if>
      <xsl:call-template name="css:content"/>
    </ol>
  </xsl:template>

  <xsl:template match="list[@type eq 'ordered']" mode="class-att" priority="2">
    <xsl:attribute name="class" select="@style"/>
    <xsl:if test="$tei2html:generate-ol-type and 
                  not($epub-version = 'EPUB2')">
      <xsl:attribute name="type" select="if (@style = 'loweralpha') then 'a' else
                                         if (@style = 'upperalpha') then 'A' else 
                                         if (@style = 'lowerroman') then 'i' else
                                         if (@style = 'upperroman') then 'I' else '1'"/>
    </xsl:if>
<!--    <xsl:if test="$epub-version = 'EPUB3' 
                    and 
                    item[1]/@n[not(matches(., '^[1aAiI][\.]?$'))]">
      <xsl:variable name="start-counter" select="replace(item[1]/@n, '.\)\]','')"/>
      <xsl:attribute name="start" select="if (@style = ('loweralpha', 'upperalpha')) then tr:letters-to-number($start-counter, string-length($start-counter)) else
                                          if (@style = ('lowerroman', 'upperroman' )) then tr:roman-to-int($start-counter) else $start-counter"/>
      </xsl:if>-->
  </xsl:template>

 <xsl:param name="tei2html:change-ordered-to-deflist" as="xs:boolean" select="true()"/>
 <xsl:variable name="tei2html:ordered-to-def-list-regex" select="'^[1aA][\.\)]?$'" as="xs:string"/>
 <xsl:variable name="tei2html:generate-ol-type" select="false()" as="xs:boolean"/>

  <!-- ordered list whose first list item doesn't start with "1.", "1)", "a." or "a)" will be displayed as definition list then. 
       Only if the parameter change-orderer-to-deflist is set true.
        The regex to determine which ordered list items are changed is $ordered-to-def-list-regex. 
        For example if it is important that 1) is displayed as "1)" and not "1." in HTML you have to create a definition list.-->
  <xsl:template match="list[$tei2html:change-ordered-to-deflist]
                           [@type eq 'ordered']
                           [item[1][not(matches(@n, $tei2html:ordered-to-def-list-regex))]]"
    mode="tei2html" priority="3">
    <dl class="{@style}">
      <xsl:apply-templates mode="#current"/>
    </dl>
  </xsl:template>

  <xsl:param name="tei2html:copy-class-from-item-to-dt" as="xs:boolean" select="false()"/>

  <xsl:template  match="item[$tei2html:change-ordered-to-deflist]
                            [parent::list[@type eq 'ordered']
                                         [item[1][not(matches(@n, $tei2html:ordered-to-def-list-regex))]]]"
                 mode="tei2html" priority="3">
    <xsl:variable name="wide-label" as="xs:string?"
                select="if (string-length(@n) ge 3) 
                        then 'wide'
                        else ()"/>
    <dt>
      <xsl:if test="$tei2html:copy-class-from-item-to-dt or $wide-label = 'wide'">
        <xsl:variable name="class" as="attribute(class)?">
          <xsl:attribute name="class">
            <xsl:apply-templates select="*[1]/@rend" mode="#current"/>
          </xsl:attribute>
        </xsl:variable>
        <xsl:attribute name="class"
          select="if ($tei2html:copy-class-from-item-to-dt) 
                  then string-join(($class, $wide-label), ' ')
                  else $wide-label" />
      </xsl:if>
      <xsl:value-of select="@n"/>
    </dt>
    <dd>
      <xsl:if test="$wide-label = 'wide'">
        <xsl:attribute name="class" select="$wide-label"/>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </dd>
  </xsl:template>

  <xsl:template match="item[not(parent::list[@type eq 'gloss'])][not(tei2html:is-varlistentry(.))]"
    mode="tei2html">
    <li>
      <xsl:apply-templates select="." mode="class-att"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </li>
  </xsl:template>

  <xsl:template match="item" mode="tei2html">
    <li>
      <xsl:if test="@n">
        <xsl:attribute name="number" select="@n"/>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </li>
  </xsl:template>

  <xsl:template match="preformat" mode="tei2html">
    <pre>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </pre>
  </xsl:template>

  <xsl:template match="floatingText[@type = ('programlisting', 'code')]" mode="tei2html">
    <pre>
      <code>
        <xsl:apply-templates select="@*, node()" mode="#current"/>
      </code>
    </pre>
  </xsl:template>

  <xsl:template match="floatingText[@type = ('programlisting', 'code')]//p" mode="tei2html">
    <xsl:param name="default-floatingText" as="xs:boolean?" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="$default-floatingText">
        <xsl:next-match/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="preceding-sibling::*[1][self::p]">
          <br/>
        </xsl:if>
        <xsl:apply-templates select="node()" mode="#current" xml:space="preserve"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="floatingText[@type = ('programlisting', 'code')]/@rend" mode="tei2html">
    <xsl:attribute name="class" select="replace(., '^.+codeblock_?(.+)$', '$1')"/>
  </xsl:template>
  
  <xsl:template match="argument" mode="tei2html">
    <div class="introduction">
      <xsl:call-template name="css:content"/>
    </div>
  </xsl:template>

  <xsl:template match="argument/p[not(@*) and not(node())]" mode="tei2html" priority="2"/>
  
  <xsl:template match="quote" mode="tei2html">
    <blockquote>
      <xsl:call-template name="css:content"/>
    </blockquote>
  </xsl:template>

  <xsl:template match="quote[parent::p or @type = 'inline']" mode="tei2html">
    <cite>
      <xsl:call-template name="css:content"/>
    </cite>
  </xsl:template>

  <xsl:template match="figure | dateline | address | location" mode="tei2html">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>

  <xsl:template match="figure/head | lg/head | spGrp/head" mode="tei2html">
    <p>
      <xsl:call-template name="css:content"/>
    </p>
  </xsl:template>

  <xsl:template match="figure/head[tr:contains(@type, 'titleabbrev')]" mode="tei2html" priority="3"/>

  <xsl:template match="floatingText//head" mode="tei2html" priority="3">
    <p>
      <xsl:call-template name="css:content"/>
    </p>
  </xsl:template>

  <xsl:template match="@preformat-type" mode="tei2html">
    <xsl:attribute name="class" select="."/>
  </xsl:template>

  <xsl:template name="tei2html:footnotes">
    <xsl:param name="chapterwise" as="xs:boolean?" tunnel="yes"/>
    <xsl:param name="context" as="node()*" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="not($chapterwise)">
        <xsl:variable name="divs-with-footnotes" select="*[local-name() = ('front', 'body', 'back')]/*[self::div | self::div1][.//note[@type = 'footnote']]" as="element(div)*"/>
        <xsl:variable name="footnotes" select=".//note[@type = 'footnote']" as="element(note)*"/>
        <xsl:if test="$footnotes">
          <xsl:element name="{tei2html:main-sec-name(.)}">
            <xsl:attribute name="class" select="'notes'"/>
            <xsl:attribute name="epub:type" select="'footnotes'"/>
            <xsl:call-template name="footnote-heading"/>
            <xsl:sequence select="tei2html:create-endnotes(if($divs-with-footnotes) then $divs-with-footnotes else $footnotes, 
              0,
              $tei2html:endnote-heading-level)"/>
          </xsl:element>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="footnotes" select="if ($context[normalize-space()]) then $context//note[@type = 'footnote'] else .//note[@type = 'footnote']" as="element(note)*"/>
        <xsl:if test="$footnotes">
          <xsl:element name="{tei2html:main-sec-name(.)}">
            <xsl:attribute name="class" select="'notes'"/>
            <xsl:attribute name="epub:type" select="'footnotes'"/>
            <xsl:call-template name="footnote-heading"/>
            <xsl:apply-templates select="$footnotes" mode="notes">
              <xsl:with-param name="fn-ids" select="$footnotes/@xml:id" as="xs:string*" tunnel="yes"/>
            </xsl:apply-templates>
          </xsl:element>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- The function below creates an endnote section from regular footnotes. 
       You can include chapter-wise section headlines for any given headline 
       level. Therefore, you have to change the -->
  
  <xsl:function name="tei2html:create-endnotes" as="element()*">
    <xsl:param name="seq" as="element()*"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:param name="max" as="xs:integer"/>
     <xsl:choose>
      <xsl:when test="$index eq $max">
        <xsl:apply-templates select="$seq//note[@type = 'footnote']" mode="notes">
          <xsl:with-param name="fn-ids" select="$footnote-ids" as="xs:string*" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="$seq">
          <xsl:element name="{tei2html:main-sec-name(.)}">
            <xsl:attribute name="class" select="concat('notes-section level-',$index + 1)"/>
            <xsl:apply-templates select="head[not(@type = 'sub')]" mode="notes">
              <xsl:with-param name="index" select="$index + 1"/>
            </xsl:apply-templates>
            <xsl:apply-templates select=".//note[@type = 'footnote'][count(ancestor::div) eq ($index + 1)]" mode="notes">
              <xsl:with-param name="fn-ids" select="$footnote-ids" as="xs:string*" tunnel="yes"/>
            </xsl:apply-templates>
            <xsl:sequence select="tei2html:create-endnotes(./div[.//note[@type = 'footnote']], $index + 1, $max)"/>
          </xsl:element>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:template name="footnote-heading">
    <xsl:param name="chapterwise" select="false()" tunnel="yes" as="xs:boolean"/>
    <!-- if you do want to create a heading for endnotes: 
      overwrite this template using the param chapterwise -->
    <xsl:if test="$chapterwise">
      <xsl:element name="{if (/TEI/text/body/div[@type = 'chapter']) then 'h2' else 'h3'}">
        <xsl:attribute name="class" select="'notes-headline'"/>
        <xsl:value-of select="if (/TEI[@xml:lang eq 'de']) then 'Fußnoten' else 'Footnotes'"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="div/head[not(@type = 'sub')]" mode="notes">
    <xsl:param name="index"/>
    <xsl:element name="{concat('h', $index)}">
      <xsl:attribute name="class" select="'notes-headline'"/>
      <xsl:apply-templates mode="notes-head"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="div/head/lb" mode="notes-head">
    <span class="{local-name()}">&#x20;</span>
  </xsl:template>

  <!-- avoid footnote references or duplicate anchors in endnotes -->
  <xsl:template match="head//note|head//anchor" mode="notes-head"/>

  <xsl:variable name="frontmatter-parts" as="xs:string+"
    select="('title-page', 'copyright-page', 'about-contrib', 'about-book', 'series', 'additional-info', 'dedication', 'motto')"/>

  <xsl:template match="divGen[@type = 'toc']" mode="tei2html">
    <xsl:variable name="toc_level" as="xs:integer?" select="(@rendition, 10)[1]"/>
    <xsl:element name="{if ($tei2html:epub-type = '2') then 'div' else 'nav'}">
      <xsl:attribute name="class" select="'toc'"/>
      <xsl:attribute name="id" select="'tei2html_rendered_toc'"/>
      <!--<xsl:if test="$tei2html:epub-type = '3'"> This seems to be wrong. epub:prefix seems to be allowed on /html only
        <xsl:attribute name="epub:prefix" select="'tr: http://transpect.io'"/>
      </xsl:if>-->
      <!-- don’t create an epub:type attribute even for EPUB3 because the content of 
        the nav would have to be an ordered list (ol). Currently it’s only p elements
        with class attributes according to the to heading level, which is not permitted 
        (must be ol). -->
      <!-- The above comment is no longer true. The epubtools were changed, so now the attribute is needed -->
      <xsl:sequence select="tr:create-epub-type-attribute($tei2html:epub-type, .)"/>
      <xsl:choose>
        <xsl:when test="exists(* except head)">
          <!-- explicitly rendered toc -->
          <xsl:apply-templates mode="tei2html"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- toc headline -->
          <xsl:call-template name="generate-toc-headline"/>
          <!-- toc body -->
          <xsl:choose>
            <xsl:when test="matches($tei2html:epub-type, '3')">
              <ol class="toc">
                <xsl:call-template name="generate-toc-body">
                  <xsl:with-param name="toc_level" select="$toc_level"/>
                </xsl:call-template>
              </ol>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="generate-toc-body">
                <xsl:with-param name="toc_level" select="$toc_level"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template match="html:nav/html:ol/html:p" mode="clean-up">
    <!-- group toc entries -->
    <xsl:element name="li">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>


  <xsl:template name="generate-toc-headline">
    <xsl:apply-templates select="head" mode="#current"/>
  </xsl:template>

  <xsl:variable name="add-to-toc-style" as="xs:string" select="'_-_TOC[1-6]'"/>

  <xsl:template name="generate-toc-body">
    <xsl:param name="toc_level"/>
    <xsl:variable name="toc-headlines" as="element()*" 
                  select="//*[self::*[local-name() = ('seg', 'p', 'l', 'head')]][matches(@rend, $add-to-toc-style)]
                         |//head[parent::div[@type = ('section', 
                                                      'glossary', 
                                                      'acknowledgments',
                                                      'acknowledgements', 
                                                      'bibliography', 
                                                      'appendix', 
                                                      'article',
                                                      'chapter', 
                                                      'dedication', 
                                                      'part', 
                                                      'index', 
                                                      'listBibl')
                                            ]
                                            |parent::div[@type = 'preface'][not(@rend = $frontmatter-parts)]|
                                             parent::divGen[@type = 'index']|
                                             parent::listBibl|
                                             parent::divGen[@type = 'toc'][$tei2html:add-toc-headline-to-toc]
                                ]
                                [   (@type = 'main') 
                                 or (head[@type = 'sub'][not(preceding-sibling::*[1][self::head[@type = 'main']] 
                                     or following-sibling::*[1][self::head[@type = 'main']])])
                                ]
                                [not(ancestor::divGen[@type = 'toc']) or $tei2html:add-toc-headline-to-toc]
                                [tei2html:heading-level(.) le number(($toc_level, 100)[1]) + 1]"/>
    <!-- flat list of li elements with class representing level, e.g. "toc1, toc2, ..."-->
    <xsl:variable name="toc-headlines-by-level" as="element()*">
      <xsl:apply-templates select="$toc-headlines" mode="toc"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$tei2html:epub-type eq '3'">
        <xsl:variable name="start-heading-level" as="xs:integer"
                      select="(min($toc-headlines/tei2html:heading-level(.)), 0)[1]"/>
        <xsl:variable name="max-heading-level" as="xs:integer"
                      select="$start-heading-level + $toc_level - 1"/>
        <!-- a structured tree generated from a flat sequence of elements -->
        <xsl:variable name="toc-as-tree">
          <xsl:sequence select="tei2html:flat-toc-to-tree($toc-headlines-by-level, 
                                                          $start-heading-level, 
                                                          $max-heading-level)"/>
        </xsl:variable>
        <!-- we patch the tree in a separate mode for html-style lists -->

        <xsl:variable name="patched-toc">
          <xsl:apply-templates select="$toc-as-tree" mode="patch-toc-for-epub3"/>
        </xsl:variable>
        <xsl:sequence select="$patched-toc"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$toc-headlines-by-level"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="html:li[following-sibling::*[1][self::html:ol][html:li]]" mode="patch-toc-for-epub3">
    <xsl:variable name="next-ol" select="following-sibling::*[1][self::html:ol][html:li]" as="element(html:ol)"/>
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:if test="$next-ol">
        <ol>
          <xsl:apply-templates select="$next-ol/@*, $next-ol/html:*" mode="#current"/>
        </ol>  
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="html:ol" mode="patch-toc-for-epub3">
    <xsl:choose>
      <xsl:when test="count(*) eq 1 and html:ol">
        <xsl:apply-templates mode="#current"/>
      </xsl:when>
      <xsl:when test="not(preceding-sibling::*[1][self::html:li])">
        <xsl:copy>
          <xsl:apply-templates select="@*, node()" mode="#current"/>
        </xsl:copy>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="html:ol/html:ol" mode="clean-up">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="@*|*" mode="patch-toc-for-epub3">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@srcpath" mode="patch-toc-for-epub3">
    <!-- avoid duplication of sourcepaths-->
  </xsl:template>

  <xsl:function name="tei2html:flat-toc-to-tree" as="element()*">
    <xsl:param name="seq" as="element()*"/>
    <xsl:param name="level" as="xs:integer"/>
    <xsl:param name="max" as="xs:integer"/>
    <xsl:sequence select="tr:flat-list-to-tree($seq, 
                                               $level, 
                                               $max, 
                                               QName('http://www.w3.org/1999/xhtml', 'ol'), 
                                              'class', 
                                              '[A-Za-z_-]+')"/>
  </xsl:function>

  <xsl:template match="div[@type = 'imprint']" mode="tei2html">
    <xsl:element name="{tei2html:main-sec-name(.)}">
      <xsl:attribute name="class" select="'imprint'"/>
      <xsl:sequence select="tr:create-epub-type-attribute($tei2html:epub-type, .)"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*[self::*:seg or self::*:p or self::*:l or self::*:head[parent::*[self::*:figure | self::*:table | self::*:lg | self::listBibl]]]" 
                mode="toc" priority="6">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:element name="{if($tei2html:epub-type eq '3') then 'li' else 'p'}">
      <xsl:attribute name="class" select="replace(@rend, '^(.+)?_-_TOC(\d+)(_-_.+)?$', 'toc$2-nolabel')"/>
      <a href="#{(@xml:id, generate-id())[1]}">
        <xsl:value-of select="."/>
      </a>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="html:nav/html:ol/html:p" mode="clean-up" priority="0.6">
    <!-- override r4443 change in order to preserve flat para structure -->
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>


  <!-- no HTML toc entry for special headings-->
  <xsl:variable name="tei2html:no-toc-style-regex" as="xs:string" select="'_notoc'"/>
  
  <xsl:template match="head[matches(@rend, $tei2html:no-toc-style-regex)]" mode="toc" priority="4"/>
  
  <xsl:template match="head[not(@type = ('sub', 'titleabbrev'))][not(parent::*[self::figure | self::table | self::lg])]" 
                mode="toc" priority="3">
    <xsl:element name="{if(matches($tei2html:epub-type, '3')) then 'li' else 'p'}">
      <xsl:attribute name="class" select="concat('toc', tei2html:heading-level(.))"/>
      <xsl:element name="a">
        <xsl:attribute name="href" select="concat('#',(@xml:id, generate-id())[1])"/>
        <!--        <xsl:call-template name="heading-content"/>-->
        <xsl:if test="label">
          <xsl:apply-templates select="label/node()" mode="strip-indexterms-etc"/>
          <xsl:apply-templates select="label" mode="label-sep"/>
        </xsl:if>
        <xsl:apply-templates select="node() except label" mode="strip-indexterms-etc">
          <xsl:with-param name="in-toc" select="true()" as="xs:boolean" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <!-- @id or @xml:id? In mode tei2html it should be @xml:id since this mode processes TEI -->
  <xsl:template match="anchor[@xml:id]" mode="tei2html" priority="2">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="not($in-toc)">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="p[figure][count(text() | *) = 1]" mode="tei2html" priority="2">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="head[@type = 'sub'] | head[ancestor::*[self::floatingText]]" mode="tei2html"
    priority="2">
    <p>
      <xsl:if test="@type = 'sub' and ($epub-version = 'EPUB3' or $xhtml-version = '5.0')">
        <xsl:attribute name="role" select="'doc-subtitle'"/>
      </xsl:if>
      <xsl:call-template name="css:content"/>
    </p>
  </xsl:template>


  <xsl:template match="label[../head union ../caption/head]" mode="tei2html">
    <xsl:param name="actually-process-it" as="xs:boolean?"/>
    <xsl:if test="$actually-process-it">
      <span>
        <xsl:call-template name="css:content"/>
      </span>
      <xsl:apply-templates select="." mode="label-sep"/>
    </xsl:if>
  </xsl:template>

  <xsl:template
    match="
      head[not(@type = ('sub', 'titleabbrev'))]
      [not(ancestor::*[self::figure or self::table or self::floatingText or self::lg or self::spGrp])]"
    mode="tei2html" priority="2">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:variable name="heading-level" select="tei2html:heading-level(.)"/>
    <xsl:element name="{if ($heading-level) then concat('h', $heading-level) else 'p'}">
      <xsl:apply-templates select="@* except @rend" mode="#current"/>
      <xsl:attribute name="class"
        select="
          if (parent::div[@type] or parent::divGen[@type]) then
            (parent::div, parent::divGen)[1]/@type
          else
            local-name()"/>
      <xsl:attribute name="title" select="tei2html:heading-title(.)"/>
      <xsl:if test="not($in-toc)">
        <a id="{generate-id()}"/>
      </xsl:if>
      <xsl:call-template name="heading-content"/>
    </xsl:element>
  </xsl:template>


  <xsl:function name="tei2html:heading-title" as="xs:string?">
    <xsl:param name="context"/>
    <xsl:variable name="content">
      <xsl:for-each select="$context">
        <xsl:call-template name="heading-content">
          <xsl:with-param name="in-toc" select="true()" tunnel="yes"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="$content"/>
  </xsl:function>

  <xsl:template name="heading-content">
    <xsl:param name="in-toc" tunnel="yes" select="false()"/>
    <xsl:variable name="content" as="item()*">
      <xsl:apply-templates select="node() except label" mode="tei2html"/>
    </xsl:variable>
    <xsl:if test="label">
      <xsl:apply-templates select="label/node()" mode="strip-indexterms-etc"/>
      <xsl:if test="exists($content)">
        <xsl:apply-templates select="label" mode="label-sep"/>
      </xsl:if>
    </xsl:if>
    <xsl:sequence select="$content"/>
  </xsl:template>

  <xsl:variable name="tei:anonymous-chapter-regex" select="'p_h_anonym'" as="xs:string"/>
  <!--  <xsl:template match="head[matches(@rend, $tei:anonymous-chapter-regex)]" mode="tei2html">
    <xsl:copy>
      <xsl:apply-templates select="@* except @rend" mode="#current"/>
      <xsl:attribute name="title" select="."/>
    </xsl:copy>
  </xsl:template>
  -->
  <xsl:param name="tei2html:dissolve-br-in-toc-head" as="xs:boolean" select="false()"/>
  <xsl:variable name="tei2html:preserve-breaks-style-regex" select="'transpect-keep-br'"
    as="xs:string"/>

  <xsl:template match="*:head//*:lb" mode="strip-indexterms-etc">
    <xsl:param name="tei2html:dissolve-br-in-toc-head" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="$tei2html:dissolve-br-in-toc-head">
        <xsl:choose>
          <xsl:when test="parent::*[matches(@rend, $tei2html:preserve-breaks-style-regex)]">
            <br/>
          </xsl:when>
          <xsl:when
            test="
              preceding-sibling::node()[1]/(self::text()) and matches(preceding-sibling::node()[1], '\s$') or
              following-sibling::node()[1]/(self::text()) and matches(following-sibling::node()[1], '^\s')"/>
          <xsl:otherwise>
            <xsl:text>&#160;</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="index/term | note[matches(@type, '(foot|end)note')] | graphic/desc" mode="strip-indexterms-etc"/>
  
  <xsl:template match="seg[@rend='caption-numtext-separator']" mode="strip-indexterms-etc">
    <xsl:apply-templates mode="#current"/>
    <xsl:text>&#160;</xsl:text>
  </xsl:template>

  <!-- Discard certain css markup on titles that would otherwise survive on paras: -->
  <xsl:template match="title/@css:*[matches(local-name(), '^(margin-|text-align)')]" mode="tei2html"/>

  <xsl:template match="label" mode="label-sep">
    <xsl:text>&#160;</xsl:text>
  </xsl:template>

  <xsl:template match="label[node()[last()]/self::lb]" mode="label-sep">
    <xsl:param name="in-toc" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$in-toc">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="p" mode="tei2html">
    <p>
      <xsl:next-match/>
    </p>
  </xsl:template>

  <xsl:template match="verse-line" mode="tei2html">
    <p>
      <xsl:next-match/>
    </p>
  </xsl:template>

  <xsl:template
    match="hi[@rendition = ('subscript', 'superscript')] | hi[key('rule-by-name', @rend, $root)[@css:vertical-align = ('sub', 'super')]]"
    mode="tei2html" priority="2.5">
    <xsl:element
      name="{if (@rendition = 'superscript' or key('rule-by-name', @rend, $root)[@css:vertical-align = 'super']) then 'sup' else 'sub'}">
      <xsl:next-match/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@rendition[. = ('subscript', 'superscript')]" mode="tei2html"/>

  <xsl:template
    match="hi | seg | add |  orig | date | name | persName | surname | Name | forename | unclear | idno | settlement| roleName"
    mode="tei2html" priority="2">
    <span>
      <xsl:next-match/>
    </span>
  </xsl:template>

  <xsl:template match="emph" mode="tei2html" priority="3">
    <em>
      <xsl:next-match/>
    </em>
  </xsl:template>

  <xsl:template match="*:surname[not(../../../..[self::*:fileDesc])]" mode="epub-alternatives" priority="2">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="preceding-sibling::node()[1][self::*:forename]">
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*:name[not(../../../..[self::*:fileDesc])]" mode="epub-alternatives" priority="3">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:if test="following-sibling::node()[1][self::*:forename]">
        <xsl:text> </xsl:text>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="ref | ptr" mode="tei2html" priority="5">
    <a>
      <xsl:attribute name="class" select="local-name()"/>
      <xsl:sequence select="tr:create-epub-type-attribute($tei2html:epub-type, .)"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:if test="not(node())">
        <xsl:value-of select="(@xlink:href | @target)[1]"/>
      </xsl:if>
    </a>
  </xsl:template>

  <xsl:template match="ref/@target" mode="tei2html" priority="2">
    <xsl:attribute name="href" select="replace(., '^www\.', 'http://www.')"/>
  </xsl:template>

  <xsl:template match="formula" mode="tei2html">
    <xsl:choose>
      <xsl:when test="@rend = 'inline'">    <xsl:element name="{if (@rend = 'inline') then 'span' else 'p'}">
        <span> <xsl:apply-templates select="@*, node()" mode="#current"/></span>
      </xsl:element>
      </xsl:when>
      <xsl:when test="..[self::p] and not(@rend = 'inline')">   
        <xsl:apply-templates select="@*, node()" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <p>
          <xsl:apply-templates select="@*, node()" mode="#current"/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="state" mode="tei2html">
    <span class="{@type}">
      <xsl:apply-templates select="node()" mode="#current"/>
    </span>

  </xsl:template>

  <xsl:template match="state/label" mode="tei2html" priority="2">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>

  <xsl:template match="formula/@n" mode="tei2html"/>

  <!-- This is only meant for elements that don’t create their class attribute using mode="class-att".
       If @rend creates a class attribute und mode="tei2html", it may become next to impossible to
       suppress class attribute generation in certain contexts unless both the @rend based and the class-att
       templates return nothing. -->
  <xsl:template match="@rend" mode="tei2html">
    <xsl:apply-templates select=".." mode="class-att"/>
  </xsl:template>

  <xsl:template match="*[@rend][@rend != 'title-page']" mode="class-att" priority="0.75">
    <xsl:attribute name="class" select="replace(@rend, '^hub:', '')"/>
  </xsl:template>

  <xsl:template match="*" mode="class-att"/>

  <!-- Is this template needed? Report the occurrence of foobar="hurz" to Gerrit -->
  <xsl:template match="*[@rend][not(local-name() = 'head')]" mode="class-att" priority="0.2"
    xmlns:tei2html-uv-rend-not-head="tei2html-uv-rend-not-head">
    <!-- matching an attribute is non-standard for class-att. It is meant as a means
      to transform it to an eponymous class attribute -->
    <xsl:apply-templates select="@rend" mode="#current"/>
  </xsl:template>

  <!-- Is this a suitable replacement for line 316? -->
  <xsl:template match="head[@type = 'main'][@rend]" mode="class-att" priority="0.5001">
    <!-- priority is slightly higher than the identical calculated values, 0.5, for *[@rend] and head[@rend] --> </xsl:template>


  <xsl:template match="pb" mode="tei2html">
    <xsl:if test="parent::*[not(self::p | self::seg)]">
      <div class="{local-name()}">
        <xsl:sequence select="tr:create-epub-type-attribute($tei2html:epub-type, .)"/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:function name="tei2html:add-aria-role" as="attribute(role)?">
    <xsl:param name="rolename" as="xs:string"/>
    <xsl:if test="$tei2html:epub-type eq '3' or $xhtml-version = '5.0'">
      <xsl:attribute name="role" select="$rolename"/>
    </xsl:if>
  </xsl:function>

  
  <xsl:function name="tr:create-epub-type-attribute" as="attribute()*">
    <xsl:param name="tei2html:epub-type" as="xs:string"/>
    <xsl:param name="context" as="element(*)"/>
    <!-- always useful -->
    <!--    <xsl:if test="$tei2html:epub-type eq '3'">-->
    <xsl:choose>
      <xsl:when test="$context[self::*:pb]">
        <xsl:attribute name="epub:type" select="'pagebreak'"/>
        <xsl:sequence select="tei2html:add-aria-role('doc-pagebreak')"/>
      </xsl:when>
      <xsl:when test="$context[self::*:divGen[@type = 'index'] or self::*:div[@type = 'index']]">
        <xsl:attribute name="epub:type" select="$context/@type"/>
        <xsl:sequence select="tei2html:add-aria-role('doc-index')"/>
      </xsl:when>
      <xsl:when test="$context[self::*:divGen[@type = 'toc'] or self::*:div[@type = 'toc']]">
        <xsl:attribute name="epub:type" select="$context/@type"/>
        <xsl:sequence select="tei2html:add-aria-role('doc-toc')"/>
      </xsl:when>
      <xsl:when test="$context[self::*:div[@type = 'article']]">
        <xsl:attribute name="epub:type" select="'chapter'"/>
        <xsl:sequence select="tei2html:add-aria-role('doc-chapter')"/>
      </xsl:when>
      <xsl:when
        test="$context[self::*:div[@type = ('glossary', 'bibliography', 'chapter', 'foreword', 'part', 'dedication', 'appendix', 'acknowledgments')]]">
        <!-- subtype may be glossary for a chapter or appendix that serves also as a glossary. This is a hub2tei convention introduced on 2016-08-06 -->
        <xsl:variable name="type" select="if ($context[self::*:div[@type = ('appendix', 'chapter', 'part')]][tei2html:is-endnote-section(.)]) 
                                          then concat('endnotes ', $context/@type)
                                          else string-join(($context/@type, $context/@subtype[not(. = 'subhead')]), ' ')"/>
        <xsl:attribute name="epub:type" select="$type"/>
        <xsl:sequence select="tei2html:add-aria-role(if (starts-with($type, 'endnotes')) 
                                                     then 'doc-endnotes'
                                                     else concat('doc-', $context/@type)
                                                     )"/><!-- only one digital publishing role is allowed: https://idpf.github.io/epub-guides/epub-aria-authoring/-->
      </xsl:when>
      <xsl:when test="$context[self::*:div[@type = 'section'][tei2html:is-endnote-section(.)][not(..[self::*:div[@type = 'section'][tei2html:is-endnote-section(.)]])]]">
        <xsl:attribute name="epub:type" select="'endnotes'"/>
        <xsl:sequence select="tei2html:add-aria-role('doc-endnotes')"/>
        <!-- only one digital publishing role is allowed: https://idpf.github.io/epub-guides/epub-aria-authoring/-->
      </xsl:when>
      <xsl:when test="$context/self::div[self::*:div[@type = 'acknowledgements']]">
         <xsl:attribute name="epub:type" select="'acknowledgments'"/>
         <xsl:sequence select="tei2html:add-aria-role('doc-acknowledgments')"/>
      </xsl:when>
      <xsl:when test="$context/self::div[@type = ('virtual-part', 'virtual-chapter')]">
        <xsl:attribute name="epub:type" select="replace($context/@type, '^virtual-', '')"/>
        <xsl:sequence select="tei2html:add-aria-role(concat('doc-', replace($context/@type, '^virtual-', '')))"/>
      </xsl:when>
      <xsl:when
        test="
          $context[self::*:div[@type = 'preface'][not(@rend)
          or not(matches(@rend, string-join($frontmatter-parts, '|')))]]">
        <xsl:attribute name="epub:type" select="$context/@type"/>
        <xsl:sequence select="tei2html:add-aria-role('doc-preface')"/>
      </xsl:when>
      <xsl:when
        test="$context[self::*:div[@type = 'preface'][some $class in $frontmatter-parts satisfies matches(@rend, $class)]]">
        <xsl:choose>
          <xsl:when test="matches($context/@rend, 'title-page')">
            <xsl:attribute name="epub:type" select="'titlepage'"/>
          </xsl:when>
          <xsl:when test="matches($context/@rend, 'halftitle')">
            <xsl:attribute name="epub:type" select="'halftitle'"/>
          </xsl:when>
          <xsl:when test="matches($context/@rend, 'copyright-page')">
            <xsl:attribute name="epub:type" select="'copyright-page'"/>
          </xsl:when>
          <xsl:when test="matches($context/@rend, 'about-contrib')">
            <xsl:attribute name="epub:type" select="if ($tei2html:epub-type eq '3') then 'contributors' else 'tr:bio'"/>
  <!--        <xsl:if test="$tei2html:epub-type eq '3'"><xsl:attribute name="role" select="'doc-colophon'"/>
                                                    <xsl:attribute name="aria-label" select="'About the author'"/>-->
         <!--</xsl:if>-->
          </xsl:when>
          <xsl:when test="matches($context/@rend, 'acknowledge?ments')">
            <xsl:attribute name="epub:type" select="if ($tei2html:epub-type eq '3') then 'acknowledgments' else 'acknowledgements'"/>
            <xsl:sequence select="tei2html:add-aria-role('doc-acknowledgments')"/>
          </xsl:when>
          <!-- additional Info in title -->
          <xsl:when test="matches($context/@rend, 'additional-info')">
            <xsl:attribute name="epub:type" select="if ($tei2html:epub-type eq '3') then 'colophon' else 'tr:additional-info'"/>
            <xsl:sequence select="tei2html:add-aria-role('doc-colophon')"/>
          <xsl:if test="$tei2html:epub-type eq '3' or $xhtml-version = '5.0'">
             <xsl:attribute name="aria-label" select="'Additional information'"/>
         </xsl:if>
          </xsl:when>
          <xsl:when test="matches($context/@rend, 'series')">
            <xsl:attribute name="epub:type" select="if ($tei2html:epub-type eq '3') then 'colophon' else 'tr:additional-info'"/>
            <xsl:sequence select="tei2html:add-aria-role('doc-colophon')"/>
          <xsl:if test="$tei2html:epub-type eq '3' or $xhtml-version = '5.0'">
            <xsl:attribute name="aria-label" select="'About the series'"/>
          <!-- seriespage as draft-->
         </xsl:if>
          </xsl:when>
          <xsl:when test="matches($context/@rend, 'about-book')">
            <xsl:attribute name="epub:type" select="if ($tei2html:epub-type eq '3') then 'preamble' else 'tr:about-the-book'"/>
            <xsl:sequence select="tei2html:add-aria-role('doc-colophon')"/>
          <xsl:if test="$tei2html:epub-type eq '3' or $xhtml-version = '5.0'">
            <xsl:attribute name="aria-label" select="'About the book'"/>
         </xsl:if><!-- perhaps preamble as type? -->
          </xsl:when>
          <xsl:when test="matches($context/@rend, 'dedication')">
            <xsl:attribute name="epub:type" select="'dedication'"/>
            <xsl:sequence select="tei2html:add-aria-role('doc-dedication')"/>
          </xsl:when>
          <xsl:when test="matches($context/@rend, 'motto')">
            <xsl:attribute name="epub:type" select="'epigraph'"/>
            <xsl:sequence select="tei2html:add-aria-role('doc-epigraph')"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$context[self::*:div[@type = 'marginal']]">
        <xsl:attribute name="epub:type" select="'sidebar'"/>
      </xsl:when>
      <xsl:when test="$context[self::*:div[@type = 'motto']]">
        <xsl:attribute name="epub:type" select="'epigraph'"/>
        <xsl:sequence select="tei2html:add-aria-role('doc-epigraph')"/>
      </xsl:when>
      <xsl:when test="$context[self::*:divGen[@type = ('index')]]">
        <xsl:attribute name="epub:type" select="$context/@type"/>
        <xsl:sequence select="tei2html:add-aria-role(concat('doc-', $context/@type))"/>
        </xsl:when>
      <xsl:when test="$context[self::*:note[@type = ('footnote', 'endnote')]]">
        <xsl:attribute name="epub:type" namespace="http://www.idpf.org/2007/ops"
          select="$context/@type"/>
      </xsl:when>
      <xsl:when test="$context[self::*:ref[normalize-space()]
                                          [contains(@target, 'endnote')]
                                          [ancestor::*:p[matches(@rend, $tei:endnote-style-regex)]]
                              ]">
       <xsl:sequence select="tei2html:add-aria-role('doc-backlink')"/>
      </xsl:when>
    </xsl:choose>
    <!--</xsl:if>-->
  </xsl:function>

  <xsl:variable name="tei:endnote-style-regex" select="'tr_endnote-para'"/>
  <xsl:function name="tei2html:is-endnote-section" as="xs:boolean">
    <xsl:param name="section" as="element()"/>
    <xsl:sequence select="false()"/>
    <!-- overwrite this in your adaptations if wanted, for example use condition below -->
<!--    <xsl:sequence select="(some $p in $section/descendant::* satisfies $p[self::*:p]/@rend[matches(., $tei:endnote-style-regex)])
                            and
                          not($section/descendant::*[local-name() = ('listBibl', 'table') or self::*[@type = ('appendix', 'gloss', 'glossary', 'index')]])"/>-->
  </xsl:function>

  <xsl:template match="lb" mode="tei2html">
    <br/>
  </xsl:template>

  <xsl:template match="*[self::p|self::head]//bibl[@type = 'citation']" mode="tei2html" priority="2">
    <xsl:choose>
      <xsl:when test="exists(key('by-id', tokenize(translate(@corresp, '#', ''), '\s+'), $root)[@xml:id])">
        <a href="{tokenize(@corresp, '\s+')[1]}" class="citation">
          <xsl:apply-templates select="@* except @corresp, node()" mode="#current"/>
        </a>   
      </xsl:when>
      <xsl:otherwise>
        <span>
          <xsl:apply-templates select="@* except @corresp, node()" mode="#current"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@corresp" mode="hub2htm-default">
    <xsl:attribute name="href" select="if (contains(., '#')) then . else concat('#', .)"/>
  </xsl:template>
  
  <xsl:template match="bibl | biblFull" mode="tei2html">
    <p>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </p>
  </xsl:template>

  <xsl:template match="bibl[@type = 'source']" mode="tei2html" priority="2">
    <cite>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </cite>
  </xsl:template>
  
  <xsl:template match="divGen[@type = 'index'] | div[@type = 'index']" mode="class-att" priority="2">
    <xsl:attribute name="class" select="string-join((@type, @rend), ' ')"/>
  </xsl:template>

  <xsl:variable name="indexterm-cstyle-regex" as="xs:string" select="'#([ibth]|ti|hi|tb|hb)#'"/>
  <xsl:variable name="check-indexterm-for-cstyle-regex" as="xs:string"
    select="concat($indexterm-cstyle-regex, '([^#]*)', $indexterm-cstyle-regex)"/>

  <xsl:template match="divGen[@type = 'index']" mode="tei2html">
    <xsl:variable name="subtype" select="@subtype" as="xs:string?"/>
    <xsl:element name="{tei2html:main-sec-name(.)}">
      <xsl:apply-templates select="." mode="class-att"/>
      <xsl:sequence select="tr:create-epub-type-attribute($tei2html:epub-type, .)"/>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="id" select="string-join(((@id, @xml:id)[1], $subtype), '-')"/>
      <xsl:variable name="title-group">
        <xsl:call-template name="tei2html:title-group"/>
      </xsl:variable>
      <xsl:sequence select="$title-group"/>
      <xsl:for-each-group select="//index[not(parent::index)]
                                         [term](:broken indexterm:)
                                         [if ($subtype)
                                          then @indexName = $subtype
                                          else not(@indexName)]
                                          [if (empty(.//term[@type = ('see', 'seealso')])) 
                                           then not(tei2html:contains-token(@rend, 'hub:not-placed-on-page'))
                                           else true()]"
                          group-by="tei2html:index-grouping-key((term/@sortKey, term)[1])"
                          collation="http://saxon.sf.net/collation?lang={(/*/@xml:lang, 'de')[1]};strength=primary">
        <xsl:sort select="current-grouping-key()"
                  collation="http://saxon.sf.net/collation?lang={(/*/@xml:lang, 'de')[1]};strength=primary"/>
        <xsl:variable name="processed" as="element(*)*">
          <xsl:call-template name="index-heading">
            <xsl:with-param name="index-main-title" select="$title-group"/>
          </xsl:call-template>
          <xsl:call-template name="group-index-terms">
            <xsl:with-param name="level" select="1"/>
            <xsl:with-param name="index-terms" select="current-group()"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$divify-sections = 'yes'">
            <xsl:element name="{tei2html:main-sec-name(.)}">
              <xsl:attribute name="class" select="'ie1'"/>
              <xsl:sequence select="$processed"/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="$processed"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:element>
  </xsl:template>

  <xsl:template name="index-heading">
    <xsl:param name="index-main-title"/>
    
    <xsl:variable name="level" select="if ($index-main-title/descendant-or-self::*[matches(local-name(), '^h\d')]) 
                                       then xs:integer(substring($index-main-title/descendant-or-self::*[matches(local-name(), '^h\d')][1]/local-name(), 2, 1))
                                       else 0" as="xs:integer?"/>
    <xsl:element name="{if ($level = (1 to 5)) then concat('h', $level + 1) else 'p'}">
      <xsl:attribute name="class" select="'index-subject-heading'"/>
      <xsl:value-of select="current-grouping-key()"/>
    </xsl:element>
  </xsl:template>

  <!-- override this for actual grouping -->
  <xsl:template name="tei2html:title-group">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:function name="tei2html:index-grouping-key" as="xs:string">
    <xsl:param name="term" as="xs:string"/>
    <xsl:sequence select="substring(tei2html:normalize-for-index($term), 1, 1)"/>
  </xsl:function>

  <xsl:function name="tei2html:normalize-for-index" as="xs:string">
    <xsl:param name="term" as="xs:string"/>
    <xsl:sequence
      select="upper-case(replace(tei2html:strip-combining($term), concat('^(', $indexterm-cstyle-regex, ')'), ''))"
    />
  </xsl:function>

  <xsl:template name="group-index-terms">
    <xsl:param name="level" as="xs:integer"/>
    <xsl:param name="index-terms" as="element(index)*"/>
    <!-- §§§ We need to know a book’s main language! -->
    <xsl:for-each-group select="$index-terms" group-by="tei2html:normalize-for-index((term/@sortKey, term)[1])"
      collation="http://saxon.sf.net/collation?lang={(/*/@xml:lang, 'de')[1]};strength=identical">
      <xsl:sort
        collation="http://saxon.sf.net/collation?lang={(/*/@xml:lang, 'de')[1]};strength=primary" select="(current-grouping-key(), current())[1]"/>
      <xsl:sort
        collation="http://saxon.sf.net/collation?lang={(/*/@xml:lang, 'de')[1]};strength=identical" select="(current-grouping-key(), current())[1]"/>
      <xsl:call-template name="index-entry">
        <xsl:with-param name="level" select="$level"/>
      </xsl:call-template>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:variable name="tei2html:index-entry-sep" as="xs:string" select="'&#x2002;'"/>
  <xsl:variable name="tei2html:index-entry-see-string" as="xs:string" select="'see '"/>
  <xsl:variable name="tei2html:index-entry-seealso-string" as="xs:string" select="'see also'"/>

  <xsl:template name="index-entry">
    <!-- context: tei:index element -->
    <xsl:param name="level" as="xs:integer"/>
    <p class="ie ie{$level}">
      <span class="ie-term">
        <xsl:choose>
          <xsl:when test="$apply-cstyles-in-indexterms">
            <xsl:apply-templates select="term" mode="indexterms"/>
          </xsl:when>
          <xsl:when test="term[@type = 'seealso']">
            <span class="localize see-also">
              <xsl:apply-templates select="term[not(@type = ('see', 'seealso'))]/node()" mode="#current"/>
              <xsl:if test="term[@type = 'seealso']">
                <xsl:if test="term[@type = 'see']/preceding-sibling::*[1][self::term[not(@type = ('see', 'seealso'))]]">
                  <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:value-of select="$tei2html:index-entry-see-string"/>
                <xsl:apply-templates select="term[@type eq 'see']/node()" mode="#current"/>                
              </xsl:if>
              <xsl:if test="term[@type = 'seealso']/preceding-sibling::*[1][self::term[not(@type eq 'seealso')]]">
                <xsl:text>, </xsl:text>
              </xsl:if>
              <xsl:value-of select="$tei2html:index-entry-seealso-string"/>
              <xsl:apply-templates select="term/node()" mode="#current"/>
            </span>
          </xsl:when>
          <xsl:when test="term[@type = 'see']">
            <span class="localize see">
              <xsl:apply-templates select="term[not(@type = ('see', 'seealso'))]/node()" mode="#current"/>
              <xsl:if test="term[@type = 'see']/preceding-sibling::*[1][self::term[not(@type = ('see', 'seealso'))]]">
                <xsl:text>, </xsl:text>
              </xsl:if>
              <xsl:value-of select="$tei2html:index-entry-see-string"/>
              <xsl:apply-templates select="term[@type eq 'see']/node()" mode="#current"/>
            </span>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="term/node()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </span>
      <xsl:value-of select="$tei2html:index-entry-sep"/>
      <xsl:choose>
        <xsl:when test="descendant-or-self::*[term[@type = ('see', 'seealso')]]"/>
        <xsl:otherwise>
          <xsl:for-each select="current-group()[not(index)][not(@rend = 'hub:not-placed-on-page')]">
            <a href="#it_{@xml:id}" id="ie_{@xml:id}">
              <xsl:value-of select="position()"/>
            </a>
            <xsl:if test="position() ne last()">
              <xsl:text xml:space="preserve">, </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </p>
    <xsl:call-template name="group-index-terms">
      <xsl:with-param name="index-terms" select="current-group()/index"/>
      <xsl:with-param name="level" select="$level + 1"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="term[normalize-space()]" mode="indexterms">
    <xsl:analyze-string select="text()" regex="{$check-indexterm-for-cstyle-regex}">
      <xsl:matching-substring>
        <xsl:choose>
          <xsl:when test="regex-group(1) eq 'i'">
            <i>
              <xsl:value-of select="regex-group(2)"/>
            </i>
          </xsl:when>
          <xsl:when test="regex-group(1) eq 'b'">
            <b>
              <xsl:value-of select="regex-group(2)"/>
            </b>
          </xsl:when>
          <xsl:when test="matches(regex-group(1), 't')">
            <sub>
              <xsl:choose>
                <xsl:when test="matches(regex-group(1), 't[ib]')">
                  <xsl:element name="{replace(regex-group(1), 't', '')}">
                    <xsl:value-of select="regex-group(2)"/>
                  </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="regex-group(2)"/>
                </xsl:otherwise>
              </xsl:choose>
            </sub>
          </xsl:when>
          <xsl:when test="matches(regex-group(1), 'h')">
            <sup>
              <xsl:choose>
                <xsl:when test="matches(regex-group(1), 'h[ib]')">
                  <xsl:element name="{replace(regex-group(1), 'h', '')}">
                    <xsl:value-of select="regex-group(2)"/>
                  </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="regex-group(2)"/>
                </xsl:otherwise>
              </xsl:choose>
            </sup>
          </xsl:when>
        </xsl:choose>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>

  <xsl:variable name="tei2html:create-index-term-backlink" as="xs:boolean" select="true()"/>

  <xsl:variable name="tei2html:indexterm-backlink-class" select="'it'"/>

  <xsl:template match="index[not(parent::index)]" mode="tei2html">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="not($in-toc)">
      <span class="indexterm" id="it_{descendant-or-self::index[last()]/@xml:id}">
        <xsl:attribute name="title" select="replace(descendant-or-self::term[last()], $indexterm-cstyle-regex, '')"/>
        <xsl:if test="$tei2html:create-index-term-backlink">
          <a href="#ie_{descendant-or-self::index[last()]/@xml:id}"
            class="{$tei2html:indexterm-backlink-class}"/>
        </xsl:if>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="term" mode="tei2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="index[parent::index]" mode="tei2html">
    <xsl:text xml:space="preserve">, </xsl:text>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="see | term[@type = 'see']" mode="tei2html">
    <xsl:text xml:space="preserve"> see </xsl:text>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="see-also | term[@type = 'seealso']" mode="tei2html">
    <xsl:text xml:space="preserve"> see also </xsl:text>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="p[floatingText[not(@type = $tei2html:allow-floats-in-para)] | figure | table]" mode="tei2html" priority="1.2">
    <xsl:for-each-group select="node()"
      group-adjacent="boolean(self::floatingText | self::figure | self::table)">
      <xsl:choose>
        <xsl:when test="current-grouping-key()">
          <xsl:apply-templates select="current-group()" mode="#current"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="{name(..)}">
            <xsl:apply-templates select="../@*" mode="#current"/>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:template match="graphic" mode="tei2html">
    <img>
      <xsl:attribute name="alt" select="normalize-space((desc,../figDesc, ../desc)[1])"/>
      <xsl:attribute name="src" select="resolve-uri(translate(@url, '[]', '__'))"/>
      <xsl:apply-templates select="@rend, @type" mode="#current"/>
      <!--  <xsl:copy-of select="@* except (@url, @rend)">-->
      <!-- css:content AND copy duplicates attributes, so I commented it out (mp)-->
      <!--</xsl:copy-of>-->
      <xsl:call-template name="css:content"/>
    </img>
  </xsl:template>

  <xsl:template match="graphic[svg:svg]" mode="tei2html">
    <xsl:copy-of select="svg:svg"/>
  </xsl:template>

  <xsl:template match="graphic/@url | graphic/@rend | graphic/desc" mode="tei2html"/>

  <!--  <xsl:template match="@url | @type [. = 'tab']" mode="tei2html" priority="-0.5"/>-->

  <xsl:template match="graphic/@xlink:href" mode="tei2html">
    <xsl:attribute name="src" select="."/>
  </xsl:template>

  <xsl:template match="graphic/@type[. = 'artifact']" mode="tei2html" priority="3">
    <xsl:attribute name="role" select="'presentation'"/>
  </xsl:template>
  
  <xsl:template match="graphic/@css:*" mode="tei2html"/>

  <xsl:template
    match="css:rule/@css:*[matches(., 'pt$')] | @css:*[matches(local-name(), '-width')][matches(., 'pt$')][parent::*[local-name() = ('table', 'col', 'td', 'th')]]"
    mode="epub-alternatives">
    <xsl:attribute name="{name()}" select="hub2htm:pt2px(.)"/>
  </xsl:template>

  <xsl:function name="hub2htm:pt2px" as="xs:string">
    <xsl:param name="attribute-value" as="attribute()"/>
    <xsl:variable name="px-value"
      select="concat(round-half-to-even(number(replace($attribute-value, 'pt$', '')) * 1.33), 'px')"/>
    <xsl:choose>
      <xsl:when test="$attribute-value = '0pt'">
        <xsl:sequence select="'0px'"/>
      </xsl:when>
      <xsl:when test="$attribute-value != '0pt' and $px-value = '0px'">
        <xsl:sequence select="'1px'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$px-value"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <xsl:template
    match="*[name() = ('graphic', 'inline-graphic')]/@*[name() = ('css:width', 'css:height')]"
    mode="hub2htm:css-style-overrides"/>

  <xsl:template match="tbody | thead | tfoot | th | colgroup | col" mode="tei2html">
    <xsl:element name="{local-name()}" exclude-result-prefixes="#all">
      <xsl:call-template name="css:content"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="table[not(matches(@css:width, '(pt|mm)$'))] | table[matches(@css:width, '0(pt|mm)$')]" mode="tei2html">
    <xsl:variable name="atts" as="attribute(*)*">
      <xsl:call-template name="css:other-atts"/>
    </xsl:variable>
    <xsl:element name="{if (xs:double($xhtml-version) ge 5 and $tei2html:table2figure) then 'figure' else 'div'}">
      <xsl:attribute name="class" select="string-join(('table-wrapper', $atts[name() = 'class']), ' ')"/>
      <!-- We duplicate the class attribute on the wrapper since some classes belong to 
        the wrapper and some to the contained table -->
      <xsl:if test="$tei2html:table-head-before-table">
        <xsl:call-template name="table-heading"/>
      </xsl:if>
      <xsl:element name="{local-name()}" exclude-result-prefixes="#all">
        <xsl:sequence select="$atts"/>
        <xsl:apply-templates select="* except (head | postscript | *:tfoot), *:tfoot" mode="#current"/>
      </xsl:element>
      <xsl:if test="not($tei2html:table-head-before-table)">
        <!-- if captions are rendered after table and a figure is created: pull postscript into figcaption-->
        <xsl:call-template name="table-heading">
          <xsl:with-param name="include-postscript-in-figcaption" as="xs:boolean" select="$tei2html:table2figure"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="$tei2html:table-head-before-table or 
                    (not($tei2html:table-head-before-table) and not($tei2html:table2figure))">
        <!-- if a figure element is created and the caption is at the back: no element may come after-->
        <xsl:apply-templates select="postscript" mode="#current"/>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="td/@css:width | th/@css:width" mode="hub2htm:css-style-overrides" priority="3"/>

  <xsl:template
    match="table[@*[local-name() = 'width'][matches(., '(pt|mm)$')][not(matches(., '^0(pt|mm)$'))]][$calculate-table-width]"
    mode="tei2html" priority="3">
    <xsl:variable name="conditional-percent-widths" as="element(table)">
      <xsl:apply-templates select="." mode="table-widths"/>
    </xsl:variable>
    <xsl:apply-templates select="$conditional-percent-widths" mode="#current">
      <xsl:with-param name="root" select="$root" tunnel="yes" as="document-node()"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="*:table/head" mode="tei2html">
    <xsl:param name="not-discard-table-head" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="$not-discard-table-head">
      <xsl:element name="p" exclude-result-prefixes="#all">
        <xsl:call-template name="css:content"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <!-- For tables in HTML model -->
  <xsl:template match="table[.//tr]//*[local-name() = ('tr', 'td', 'colgroup')]" mode="tei2html">
    <xsl:element name="{local-name()}" exclude-result-prefixes="#all">
      <xsl:call-template name="css:content"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="row" mode="tei2html">
    <xsl:element name="tr" exclude-result-prefixes="#all">
      <xsl:call-template name="css:content"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="cell" mode="tei2html">
    <xsl:element name="{if (..[@* = 'label']) then 'th' else 'td'}"
      exclude-result-prefixes="#all">
      <xsl:call-template name="css:content"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="cell/@css:width | *:td/@css:width" mode="table-widths">
    <xsl:variable name="cell-width"
      select="
        if (matches(., '(pt|mm)$')) then
          tr:length-to-unitless-twip(.)
        else
          ."/>
    <xsl:variable name="table-width"
      select="
        if (ancestor::table[1]/@css:width) then
          tr:length-to-unitless-twip(ancestor::table[1]/@css:width)
        else
          '5000'"/>
    <xsl:attribute name="css:width"
      select="replace((xs:string((100 * $cell-width) div $table-width)), '(\d+)(\.?)(\d{2})?(\d*)', '$1$2$3%')"
    />
  </xsl:template>
  
  <xsl:template match="cell/@cols" mode="tei2html">
    <xsl:attribute name="colspan" select="."/>
  </xsl:template>
  
  <xsl:template match="cell/@rows" mode="tei2html">
    <xsl:attribute name="rowspan" select="."/>
  </xsl:template>

  <!-- There should always be @css:width. @width is only decorational (will be valuable just in case 
    all @css:* will be stripped -->
  <xsl:variable name="tei2html:max-table-width" select="100" as="xs:integer">
    <!-- you can define smaller values to avoid bugs concerning percentual body margins--> </xsl:variable>

  <xsl:template match="table[@css:width]" mode="table-widths">
    <xsl:variable name="twips" select="tr:length-to-unitless-twip(@css:width)" as="xs:double?"/>
    <xsl:variable name="page-width"
      select="
        if (xs:string(number(/TEI/teiHeader/profileDesc/textClass/keywords/term[@key = 'type-area-width'])) != 'NaN') then
          tr:length-to-unitless-twip(concat(/TEI/teiHeader/profileDesc/textClass/keywords/term[@key = 'type-area-width'], 'pt'))
        else
          $page-width-twips"
      as="xs:double?"/>
    <xsl:choose>
      <xsl:when test="$twips">
        <xsl:copy copy-namespaces="no">
          <xsl:apply-templates select="@*, node()" mode="#current">
            <xsl:with-param name="table-twips" select="$twips" tunnel="yes"/>
            <xsl:with-param name="table-percentage"
              select="
                if (tei2html:display-table-in-whole-width(.)) then
                  $tei2html:max-table-width
                else
                  tei2html:table-width-grid($twips, $page-width)"
              tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="table/@css:width" mode="table-widths">
    <xsl:param name="table-twips" as="xs:double?" tunnel="yes"/>
    <xsl:param name="table-percentage" as="xs:integer?" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="not($table-twips) or not($table-percentage)">
        <xsl:copy/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="css:width" select="concat($table-percentage, '%')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template
    match="
      table[not(col | colgroup)][@css:width]/*/row/*/@css:width
      | table[exists(col | colgroup)][@css:width]//col/@*[local-name() = 'width']"
    mode="table-widths">
    <xsl:param name="table-twips" as="xs:double?" tunnel="yes"/>
    <xsl:param name="table-percentage" as="xs:integer?" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="matches(., '[\d]+(\.\d+)?%$')">
        <xsl:attribute name="css:width" select="."/>
      </xsl:when>
      <xsl:when test="not($table-twips) or not($table-percentage)">
        <xsl:attribute name="css:width" select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="css:width"
          select="concat(string(xs:integer(1000 * (tr:length-to-unitless-twip(.) div $table-twips)) * 0.1), '%')"
        />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="table[exists(col | colgroup)]/*/row/*/@css:width" mode="table-widths"/>

  <xsl:template match="@data-colnum | @data-colspan-part" mode="tei2html"/>

  <xsl:template match="@colspan | @rowspan" mode="tei2html">
    <xsl:copy/>
  </xsl:template>

  <xsl:variable name="root" select="/" as="document-node()"/>

  <xsl:template match="title | alt-title[@alt-title-type eq 'xref']" mode="linked-item" xmlns="">
    <title>
      <xsl:apply-templates mode="render-xref"/>
    </title>
  </xsl:template>

  <xsl:template match="caption" mode="tei2html">
    <p>
      <xsl:attribute name="class" select="@rend"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </p>
  </xsl:template>

  <xsl:template match="sp" mode="tei2html">
    <div class="speech">
      <xsl:apply-templates select="node()" mode="#current"/>
    </div>
  </xsl:template>

  <xsl:template match="speaker | stage | opener[not(p)]" mode="tei2html">
    <p>
      <xsl:call-template name="css:content"/>
    </p>
  </xsl:template>

  <xsl:template match="p[preceding-sibling::*[1][self::speaker[@rendition = 'inline']]]" mode="tei2html" priority="2">
    <p>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="preceding-sibling::*[1][self::speaker[@rendition = 'inline']]" mode="#current">
        <xsl:with-param name="merge-speaker" as="xs:boolean?" tunnel="yes" select="true()"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="node()" mode="#current"/>
    </p>
  </xsl:template>

  <xsl:template match="speaker[@rendition = 'inline']" mode="tei2html" priority="2">
    <xsl:param name="merge-speaker" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="$merge-speaker">
      <span>
        <xsl:call-template name="css:content"/>
      </span>
      <xsl:if test="following-sibling::*[1][not(matches(., '^[:\p{Zs}]'))]">
        <xsl:text> </xsl:text>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="lg" mode="class-att" priority="2">
    <xsl:attribute name="class" select="(string-join((@type, @rend), ' '), local-name())[1]"/>
  </xsl:template>

  <xsl:template match="l" mode="tei2html">
    <p>
      <xsl:copy-of select="@srcpath"/>
      <xsl:attribute name="class" select="@rend"/>
      <xsl:apply-templates select="node()" mode="tei2html"/>
    </p>
  </xsl:template>
  
  <xsl:template match="*[ancestor::*/local-name()=('table','lg','spGrp','figure','floatingText')]" mode="tei2html_heading-level"/>
  
  <xsl:template match="*[parent::div/@type = ('part', 'appendix', 'imprint', 'acknowledgements', 'dedication', 'glossary', 'preface') or
                         parent::divGen/@type = ('index', 'toc') or
                         parent::listBibl]" mode="tei2html_heading-level">
    <xsl:sequence select="2"/>
  </xsl:template>
  
  <xsl:template match="*[parent::div/@type = ('chapter')]" mode="tei2html_heading-level">
    <xsl:sequence select="if (ancestor::div/@type = 'virtual-part') then 2 else 3"/>
  </xsl:template>
  
  <xsl:template match="*[parent::div[@type = ('section')]]" mode="tei2html_heading-level">
    <xsl:sequence select="count(ancestor::div[@type eq 'section']) + 3"/>
  </xsl:template>
  
  <xsl:template match="*[parent::div/@type = ('bibliography')]" mode="tei2html_heading-level">
    <xsl:sequence select=" if (ancestor::div/@type = 'chapter') then 3 else 3"/>
  </xsl:template>
  
  <xsl:template match="*[parent::*[matches(local-name(.), '^div\d')]]" mode="tei2html_heading-level">
    <xsl:sequence select="count(ancestor::*[matches(local-name(.), '^div')])"/>
  </xsl:template>

  <xsl:function name="tei2html:heading-level" as="xs:integer?">
    <xsl:param name="elt" as="element(*)"/>
    <xsl:variable name="level" as="xs:integer?">
      <xsl:apply-templates select="$elt" mode="tei2html_heading-level"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$level castable as xs:integer">
        <xsl:sequence select="if (xs:integer($level) gt 6)
                              then 6
                              else $level"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>(tei2html) No heading level for <xsl:copy-of select="$elt/.."/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template match="*" mode="tei2html_heading-level" as="xs:integer?"/>

  <xsl:function name="tei2html:table-width-grid" as="xs:integer">
    <!-- returns original width, 50, or 100. It should be interpreted and used as a width
      percentage, except when it’s 0. Then the original widths should be kept. -->
    <xsl:param name="object-width-twip" as="xs:double"/>
    <xsl:param name="page-width-twip" as="xs:double"/>
    <xsl:choose>
      <xsl:when test="($object-width-twip gt (0.75 * $page-width-twip))">
        <xsl:sequence select="100"/>
      </xsl:when>
      <xsl:when test="$object-width-twip gt (0.4 * $page-width-twip)">
        <xsl:sequence select="50"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="xs:integer(floor(($object-width-twip * 100) div $page-width-twip))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="tei2html:display-table-in-whole-width" as="xs:boolean">
    <!-- this function can be used to map special tables to 100% width. For example fake tables. (Instead of tabular tables, like timetables). Overwrite this in your adaptions.. -->
    <xsl:param name="table" as="element(table)"/>
    <xsl:choose>
      <xsl:when test="matches($table/@rend, $tei2html:auxiliary-table-style-regex)">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="tr:contains" as="xs:boolean">
    <xsl:param name="space-sep-list" as="xs:string?"/>
    <xsl:param name="item" as="xs:string+"/>
    <xsl:sequence select="$item = tokenize($space-sep-list, '\s+', 's')"/>
  </xsl:function>

  <xsl:function name="tei2html:label-width" as="xs:string">
    <xsl:param name="string" as="xs:string*"/>
    <xsl:variable name="length" as="xs:integer?">
      <xsl:sequence select="xs:integer(string-length($string))"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$length le 5">
        <xsl:value-of select="' width-5'"/>
      </xsl:when>
      <xsl:when test="$length le 10">
        <xsl:value-of select="' width-10'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="' width-15'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="tei2html:contains-token" as="xs:boolean">
    <xsl:param name="string" as="xs:string?"/>
    <xsl:param name="token" as="xs:string+"/>
    <xsl:sequence select="tokenize($string, '\s+') = $token"/>
  </xsl:function>

  <!-- MODE: JOIN-SEGS (analoguous in evolve-hub hub:join-phrases). Important when overrides are discarded earlier. -->

  <xsl:template match="@srcpath[not(tei:boolean-param($srcpaths))]" mode="join-segs"/>

  <xsl:template match="*[*:seg or *:hi[@rendition = ('subscript', 'superscript')]][count(*) gt 1]"
    mode="join-segs">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="srcpath"
        select="
          string-join(
          (@srcpath,
          node()[(every $att in @*
            satisfies ($att/name() = 'srcpath')) and
          not(self::*:hi[@rendition = ('subscript', 'superscript')])
          ]/@srcpath),
          '&#x20;'
          )"/>
      <xsl:for-each-group select="node()" group-adjacent="tei:phrase-signature(.)">
        <xsl:choose>
          <!-- dissolve if no interesting attributes -->
          <xsl:when
            test="
              exists(current-group()/@*) and
              (every $att in current-group()/@*
                satisfies ($att/name() = 'srcpath')) and
              not(self::*:hi[@rendition = ('subscript', 'superscript')])">
            <xsl:apply-templates select="current-group()" mode="join-segs-unwrap"/>
          </xsl:when>
          <xsl:when test="self::*:seg or self::*:hi[@rendition = ('subscript', 'superscript')]">
            <xsl:copy>
              <xsl:if test="tei:boolean-param($srcpaths) and (current-group()/@srcpath)[. ne ''][1]">
                <xsl:attribute name="srcpath" select="current-group()/@srcpath[. ne '']"
                  separator=" "/>
              </xsl:if>
              <xsl:copy-of select="@* except @srcpath"/>
              <xsl:apply-templates select="current-group()" mode="join-segs-unwrap"/>
            </xsl:copy>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <xsl:function name="tei:boolean-param" as="xs:boolean">
    <xsl:param name="input" as="xs:string"/>
    <xsl:sequence select="$input = ('yes', '1', 'true')"/>
  </xsl:function>

  <xsl:function name="tei:attr-hashes" as="xs:string*">
    <xsl:param name="elt" as="node()*"/>
    <xsl:perform-sort>
      <xsl:sort/>
      <xsl:sequence
        select="
          for $a in ($elt/@*[not(name() = $tei:attr-hash-ignorables)])
          return
            tei:attr-hash($a)"
      />
    </xsl:perform-sort>
  </xsl:function>

  <xsl:variable name="tei:attr-hash-ignorables" as="xs:string*" select="('xml:id', 'srcpath')"/>

  <xsl:function name="tei:attr-hash" as="xs:string">
    <xsl:param name="att" as="attribute(*)"/>
    <xsl:sequence select="concat(name($att), '__=__', $att)"/>
  </xsl:function>

  <xsl:function name="tei:attname" as="xs:string">
    <xsl:param name="hash" as="xs:string"/>
    <xsl:value-of select="replace($hash, '__=__.+$', '')"/>
  </xsl:function>

  <xsl:function name="tei:attval" as="xs:string">
    <xsl:param name="hash" as="xs:string"/>
    <xsl:value-of select="replace($hash, '^.+__=__', '')"/>
  </xsl:function>

  <xsl:function name="tei:signature" as="xs:string*">
    <xsl:param name="elt" as="element(*)?"/>
    <xsl:sequence
      select="
        if (exists($elt))
        then
          string-join((name($elt), tei:attr-hashes($elt)), '___')
        else
          ''"
    />
  </xsl:function>

  <!-- If a span, return its hash. 
       If a whitespace text node in between two spans of same hash, return their hash.
       Otherwise, return the empty string. -->
  <xsl:function name="tei:phrase-signature" as="xs:string">
    <xsl:param name="node" as="node()"/>
    <xsl:apply-templates select="$node" mode="seg-signature"/>
    <!--<xsl:sequence select="if ($node/self::phrase or $node/self::superscript or $node/self::subscript) 
                          then hub:signature($node)
                          else 
                            if ($node/self::*)
                            then ''
                            else
                              if ($node/self::text()
                                    [matches(., '^[\p{Zs}\s]+$')]
                                    [hub:signature($node/preceding-sibling::*[1]) eq hub:signature($node/following-sibling::*[1])]
                                 )
                              then hub:signature($node/preceding-sibling::*[1])
                              else ''
                          " />-->
  </xsl:function>

  <xsl:template match="*:seg | *:hi[@rendition = ('subscript', 'superscript')]" mode="seg-signature"
    as="xs:string">
    <xsl:sequence select="tei:signature(.)"/>
  </xsl:template>

  <xsl:template match="node()" mode="seg-signature" as="xs:string">
    <xsl:sequence select="''"/>
  </xsl:template>

  <xsl:template
    match="
      text()[matches(., '^[\p{Zs}\s]+$')]
      [tei:signature(preceding-sibling::*[1]) = tei:signature(following-sibling::*[1])]"
    mode="seg-signature" as="xs:string">
    <xsl:sequence select="tei:signature(preceding-sibling::*[1])"/>
  </xsl:template>

  <xsl:template
    match="
      anchor
      [tei:signature(preceding-sibling::*[1]) = tei:signature(following-sibling::*[1])]"
    mode="seg-signature" as="xs:string">
    <xsl:sequence select="tei:signature(preceding-sibling::*[1])"/>
  </xsl:template>

  <xsl:template match="*:seg | *:hi[@rendition = ('subscript', 'superscript')]"
    mode="join-segs-unwrap">
    <xsl:apply-templates mode="join-segs"/>
  </xsl:template>

  <xsl:template match="*" mode="join-segs-unwrap">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="join-segs"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="html:span[(count(@*) eq 1) and (@srcpath)] | html:span[not(@*)]"
    mode="clean-up">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>

  <xsl:template match="/html:html[some $t in .//@epub:type
                                  satisfies (starts-with($t, 'tr:'))]
                                  [$tei2html:epub-type eq '3']"
                mode="clean-up">
    <xsl:copy>
      <xsl:attribute name="epub:prefix" select="'tr: http://transpect.io'"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="css:rules" mode="clean-up">
    <xsl:apply-templates select="." mode="hub2htm:css"/>
  </xsl:template>

  <xsl:template match="html:a[@class = $tei2html:indexterm-backlink-class][@href]" mode="clean-up">
    <xsl:variable name="matching-entry" as="element(*)*"
      select="key('by-id', substring-after(@href, '#'))"/>
    <xsl:choose>    
      <xsl:when test="(exists($matching-entry)) and (count($matching-entry) eq 1)">
        <xsl:copy copy-namespaces="no">
          <xsl:attribute name="title"
            select="$matching-entry/ancestor-or-self::html:p/html:span[@class = 'ie-term']"/>
          <xsl:apply-templates select="@*" mode="#current"/>
          <xsl:text>(</xsl:text>
          <xsl:value-of select="key('by-id', substring-after(@href, '#'))"/>
          <xsl:text>)</xsl:text>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="count($matching-entry) gt 1">
          <xsl:comment select="'### more than one entry generated!'"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- for sub and sup (but not limited to them) -->
  <xsl:template match="html:*[html:span[@srcpath][count(@*) = 1]][count(node()) = 1]"
    mode="clean-up">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="srcpath" select="string-join((@srcpath, html:span/@srcpath), ' ')"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="html:p[*[html:div|html:figure][matches(@class, 'table-wrapper')]]" mode="clean-up"
    priority="3">
    <!-- tables are not allowed in paras in epub. but sometimes they appear inside (footnotes etc.). So they are dissolved.-->
    <xsl:choose>
      <xsl:when test="
          some $t in (text(), html:span/text())
            satisfies matches($t, '\S')">
        <xsl:apply-templates select="(html:div|html:figure)[matches(@class, 'table-wrapper')]" mode="#current"/>
        <xsl:copy copy-namespaces="no">
          <xsl:apply-templates select="@*" mode="#current"/>
          <xsl:apply-templates select="node() except (html:div|html:figure)[matches(@class, 'table-wrapper')]"
            mode="#current"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="node()" mode="#current"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template
    match="*[local-name() = ('h1', 'h2', 'h3', 'h4', 'h5', 'h6')][*:span[@class = 'label']]"
    mode="clean-up" exclude-result-prefixes="#all">
    <xsl:variable name="label" select="*:span[@class = 'label']"/>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="node()" group-ending-with="html:span[@class = 'label']">
        <xsl:choose>
          <xsl:when test="current-group()[. &gt;&gt; $label]">
            <span class="justifier">
              <xsl:apply-templates select="current-group()" mode="#current"/>
            </span>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="html:*[contains(@epub:type, 'epigraph')]
                             [not(html:blockquote)]
                             [$tei2html:add-blockquote-to-epigraph]" mode="clean-up" priority="3">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:element name="blockquote">
        <xsl:apply-templates select="node()" mode="#current"/>
      </xsl:element>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*:span[@class = 'label']/@class" mode="clean-up" priority="3">
    <xsl:attribute name="{name()}" select="concat(., tei2html:label-width(..))"/>
  </xsl:template>

  <xsl:template match="/html:html/html:body/*[@epub:type = ('chapter', 'part', 'virtual-chapter', 'virtual-part')][1]/@epub:type[$tei2html:set-bodymatter-epub-type and $epub-version ne 'EPUB2']" mode="clean-up" priority="3">
    <xsl:attribute name="{name()}" select="concat(., ' bodymatter')"/>
  </xsl:template>
  <xsl:template match="/html:html/html:body/*[@epub:type = ('appendix', 'bibliography', 'index', 'glossary', 'rearnotes')
                                             or
                                             (@epub:type = 'part' and (every $c in * satisfies $c[@epub:type = ('appendix', 'bibliography', 'index', 'glossary', 'rearnotes')]))
                                              ][1]/@epub:type[$tei2html:set-backmatter-epub-type and $epub-version ne 'EPUB2']" mode="clean-up" priority="3">
    <xsl:attribute name="{name()}" select="concat(., ' backmatter')"/>
  </xsl:template>


  <xsl:template match="html:nav[@epub:type= 'toc'][empty(descendant::html:li)]" mode="clean-up" priority="3"/>

  <xsl:template match="html:nav[@epub:type= 'toc']//html:span[not(normalize-space())]" mode="clean-up" priority="3">
    <xsl:apply-templates select="node()" mode="#current"/>
    <!-- spans in nav must contain Text-->
  </xsl:template>

  <xsl:template match="mml:math" mode="epub-alternatives clean-up">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="mml:*/@*[local-name() = ('class', 'color', 'display', 'fontfamily', 'fontsize', 
                                                'fontstyle', 'fontweight', 'id', 'mathbackground', 
                                                'mathcolor', 'mathsize', 'mathvariant', 'href', 
                                                'type', 'other', 'style', 'xref')]" mode="tei2html">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="mml:*" mode="tei2html">
    <xsl:element name="{local-name()}" xmlns="http://www.w3.org/1998/Math/MathML">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
 <xsl:template match="  @css:initial-letter[not($tei2html:initial-letter-prop-handling = 'unchanged')] 
                      | @*:drop-cap-chars[not($tei2html:initial-letter-prop-handling = 'unchanged')]" mode="tei2html hub2htm:css-style-overrides hub2htm:css-style-defs"/>
   

  <xsl:template match="seg[@css:initial-letter]
                          [not($tei2html:initial-letter-prop-handling = ('remove', 'unchanged'))]" mode="class-att">
    <xsl:variable name="other-classes">
      <xsl:next-match/>
    </xsl:variable>
    <xsl:if test="$tei2html:initial-letter-prop-handling[normalize-space()] or $other-classes[normalize-space()]">
      <xsl:attribute name="class" select="string-join(($tei2html:initial-letter-prop-handling, $other-classes[normalize-space()]), ' ')"/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
