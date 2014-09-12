<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:letex="http://www.le-tex.de/namespace"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:hub2htm="http://www.le-tex.de/namespace/hub2htm" 
  xmlns:tei2html="http://www.le-tex.de/namespace/tei2html" 
  xmlns:l10n="http://www.le-tex.de/namespace/l10n"
  xmlns:epub="http://www.idpf.org/2007/ops"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:import href="http://transpect.le-tex.de/hub2html/xsl/css-rules.xsl"/>
  <xsl:import href="http://transpect.le-tex.de/xslt-util/lengths/lengths.xsl"/>
  <xsl:import href="http://transpect.le-tex.de/hub2html/xsl/css-atts2wrap.xsl"/>
  
  <xsl:param name="debug" select="'yes'"/>
  <xsl:param name="debug-dir-uri" select="'debug'"/>
  
  <xsl:param name="common-path" />
  <xsl:param name="publisher-path" />
  <xsl:param name="series-path" />
  <xsl:param name="work-path" />
  
  <xsl:param name="divify-sections" select="'no'"/>

  <xsl:param name="css-location" select="concat($common-path, '/css/stylesheet.css')"/>

  <!-- for calculating whether a table covers the whole width or only part of it: -->
  <xsl:param name="page-width" select="'180mm'"/>
  <xsl:param name="page-width-twips" select="letex:length-to-unitless-twip($page-width)" as="xs:double"/>
  
  <xsl:output method="xhtml" indent="no" 
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0//EN" 
    saxon:suppress-indentation="p li h1 h2 h3 h4 h5 h6 th td dd dt"/>

  <xsl:param name="lang" select="(/*/@xml:lang, 'en')[1]" as="xs:string"/>
  
  <xsl:variable name="l10n" select="document(concat('l10n.', ($lang, 'en')[1], '.xml'))"
    as="document-node(element(l10n:l10n))"/>
  
  <xsl:key name="l10n-string" match="l10n:string" use="@id"/>
  
  <xsl:template match="* | @*" mode="expand-css clean-up table-widths epub-alternatives">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current" />  
    </xsl:copy>
  </xsl:template>
  
  <!-- collateral. Otherwise the generated IDs might differ due to temporary trees / variables 
    when transforming the content -->  
  <xsl:template match="index/term | xref | fn" mode="epub-alternatives">
    <xsl:copy copy-namespaces="no">
      <xsl:attribute name="id" select="generate-id()"/>
      <xsl:apply-templates select="@* except @xml:id, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- handle conditional texts -->
  <xsl:template match="*[@rendition = 'PrintOnly']" mode="epub-alternatives"/>
  
  <xsl:template match="*[p[ancestor-or-self::*[@rendition eq 'EpubAlternative']]]" mode="epub-alternatives" priority="2">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, head | info | p[descendant-or-self::*[@rendition eq 'EpubAlternative']]" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[preceding-sibling::p[descendant-or-self::*[@rendition eq 'EpubAlternative']]]" mode="epub-alternatives"
    priority="2"/>
  
  <xsl:template match="html:span[not(@*)]" mode="clean-up">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  
  <xsl:template match="*" mode="tei2html" priority="-1">
    <xsl:message>tei2html: unhandled: <xsl:apply-templates select="." mode="css:unhandled"/>
    </xsl:message>
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="#current" />  
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*" mode="tei2html" priority="-1.5">
    <xsl:message>tei2html: unhandled attr: <xsl:apply-templates select="." mode="css:unhandled"/>
    </xsl:message>
  </xsl:template>
  
  <xsl:template match="/TEI" mode="tei2html">
    <html>
      <head>
        <link href="{$css-location}" type="text/css" rel="stylesheet"/>
        <xsl:if test="$publisher-path">
          <link href="{$publisher-path}/css/overrides.css" type="text/css" rel="stylesheet"/>
        </xsl:if>
        <xsl:if test="$series-path">
          <link href="{$series-path}/css/overrides.css" type="text/css" rel="stylesheet"/>
        </xsl:if>
        <xsl:if test="$work-path">
          <link href="{$work-path}/css/overrides.css" type="text/css" rel="stylesheet"/>
        </xsl:if>
        <title>
          <xsl:apply-templates select="book-meta/book-title-group/book-title/node() | title-group/title/node()"
            mode="#current">
            <!-- suppress replicated target with id: -->
            <xsl:with-param name="in-toc" select="true()" tunnel="yes"/>
          </xsl:apply-templates>
        </title>
        <!-- hier nur drin, weil es unten nicht über template meta matcht -->
<!--        <meta name="lang" content="{teiHeader/profileDesc/langUsage/language/@ident}"/>-->
        <xsl:call-template name="meta" /> 
        <xsl:apply-templates select="teiHeader/encodingDesc/css:rules" mode="#current"/>
      </head>
      <body>
        <xsl:call-template name="html-body"/>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="css:rule" mode="tei2html">
    <xsl:call-template name="css:move-to-attic">
      <xsl:with-param name="atts" select="@*[css:map-att-to-elt(., current())]"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="css:rules" mode="clean-up">
    <xsl:apply-templates select="." mode="hub2htm:css"/>
  </xsl:template>
  
  <xsl:template name="html-body">
    <xsl:apply-templates select="text" mode="#current">
      <xsl:with-param name="footnote-ids" select="//note[@type = 'footnote']/@xml:id" as="xs:string*" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="body" mode="tei2html">
    <xsl:apply-templates mode="#current"/>
    <xsl:call-template name="tei2html:footnotes"/>
  </xsl:template>
  
  <xsl:template match="text | front | div[$divify-sections = 'no'][not(@type = ('imprint', 'dedication', 'preface', 'marginal'))]" mode="tei2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  
  <xsl:template match="div[@type]" mode="tei2html" priority="3">
    <div>
      <xsl:apply-templates select="@* except @rend" mode="#current"/>
      <xsl:sequence select="letex:create-epub-type-attribute($tei2html:epub-type, .)"/>
      <xsl:attribute name="class" select="@type"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </div>
  </xsl:template>
  
<!--  <xsl:template match="div[@type = ('imprint', 'dedication', 'preface', 'marginal')]" mode="tei2html" priority="2">
    <div>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </div>
  </xsl:template>-->
  
  <xsl:template match="*:div" mode="tei2html">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
  </xsl:template>
  
  <xsl:template name="meta">
    <!-- warum matcht langUsage nicht? -->
    <xsl:apply-templates select="teiHeader/profileDesc/langUsage" mode="#current"/>    
    <xsl:apply-templates select="teiHeader/profileDesc/textClass/keywords" mode="#current"/>
  </xsl:template>

  <xsl:template match="keywords" mode="tei2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="langUsage" mode="tei2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="keywords/term" mode="tei2html"/>
  
  <xsl:template match="keywords/term[@key = 'source-dir-uri']" mode="tei2html" priority="2">
    <meta name="{@key}" content="{.}"/>
  </xsl:template>
  
  <xsl:template match="keywords/term[@key = 'source-basename']" mode="tei2html" priority="2">
    <meta name="{@key}" content="{.}"/>
  </xsl:template>
  
  <xsl:template match="langUsage/language" mode="tei2html" priority="2">
    <meta name="lang" content="{@ident}"/>
  </xsl:template>
  
  <!-- Default handler for the content of para-like and phrase-like elements,
    invoked by an xsl:next-match for the same matching elements. Don't forget 
    to include the names of the elements that you want to handle here. Otherwise
    they'll be reported as unhandled.
    And don’t ever change the priority unless you’ve made sure that no other template
    relies on this value to be 0.25.
    -->
  <xsl:template match="head | quote | seg | p |  table | caption | note | italic | bold |
    underline | sub | sup | l | lg | hi | argument" mode="tei2html" priority="-0.25" >
    <xsl:call-template name="css:content"/>
  </xsl:template>
  
  <xsl:template name="css:other-atts">
    <!-- In the context of an element with CSSa attributes -->
    <xsl:apply-templates select="@*[not(namespace-uri() = 'http://www.w3.org/1996/css' or self::attribute(xml:lang))]
                                   [not(css:map-att-to-elt(., ..))]" mode="#current"/>
    <xsl:apply-templates select="." mode="class-att"/>
    <xsl:sequence select="hub2htm:style-overrides(.)"/>
  </xsl:template>

  <xsl:template match="html:span[(count(@*) eq 1) and (@srcpath)]" mode="clean-up">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="epigraph" mode="tei2html">
    <div class="motto">
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="floatingText" mode="tei2html">
    <div>
      <xsl:attribute name="class" select="if (@rend != @type) then concat(@type, ' ', @rend) else @rend"/>
      <xsl:apply-templates select="@* except (@rend, @type), body/*" mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:function name="tei2html:strip-combining" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:sequence select="replace(normalize-unicode($input, 'NFKD'), '\p{Mn}', '')"/>
  </xsl:function>
  
  <xsl:template match="*" mode="class-att"/>

  <xsl:template match="*[@rend][not(local-name() = 'head')]" mode="class-att">
    <xsl:apply-templates select="@rend" mode="#current"/>
  </xsl:template>

<!--  <xsl:template match="verse-line[@content-type | @style-type]" mode="class-att" priority="2">
    <xsl:variable name="att" as="attribute(class)?">
      <xsl:next-match/>
    </xsl:variable>
    <xsl:if test="$att">
      <xsl:attribute name="class" select="string-join(('verse-line', $att), ' ')"/>
    </xsl:if>
  </xsl:template>-->

  <xsl:variable name="tei2html:ignore-style-name-regex-x"
    select="'^(NormalParagraphStyle|Hyperlink)$'"
    as="xs:string"/>

  <xsl:template match="@rend" mode="class-att">
    <xsl:if test="not(matches(., $tei2html:ignore-style-name-regex-x, 'x'))">
      <xsl:attribute name="class" select="replace(., ':', '_')"/>  
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="title[not($divify-sections = 'yes')]" mode="class-att" priority="2">
    <xsl:attribute name="class" select="(parent::title-group[not(ends-with(../name(), 'meta'))],
                                         ancestor::*[ends-with(name(), 'meta')], 
                                         .)[1]/../
                                                 (name(), @book-part-type)[last()]"/>
  </xsl:template>
    
  <xsl:template match="label" mode="class-att">
    <xsl:attribute name="class" select="'label'"/>
  </xsl:template>
  
  <xsl:template match="@id | @srcpath" mode="tei2html">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="table[@id = ../@id]/@id" mode="tei2html"/>
  
  <xsl:template match="@css:* | @xml:lang" mode="tei2html_DISABLED">
    <xsl:copy/>
  </xsl:template>
  
  <!-- will be handled by class-att mode -->
<!--  <xsl:template match="@rend" mode="tei2html"/>-->

  <xsl:variable name="default-structural-containers" as="xs:string+"
    select="('part', 'front-matter-part', 'section', 'appendix', 'acknowledgements', 'ref-list', 'dedication', 'preface')"/>

  <!-- everything that goes into a div (except footnote-like content): -->
  <xsl:template match="  *[name() = $default-structural-containers][$divify-sections = 'yes']
                       | figure | caption | abstract | verse-group" 
    mode="tei2html" priority="2">
    <div class="{name()}">
      <xsl:copy-of select="@*"/>
      <xsl:next-match/>
    </div>
  </xsl:template>

  <xsl:template match="*[name() = $default-structural-containers][not($divify-sections = 'yes')]" 
    mode="tei2html" priority="2">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="anchor[@xml:id]" mode="tei2html">
    <a id="{@xml:id}"/>
  </xsl:template>
  
  <xsl:template match="@xml:id" mode="clean-up">
    <xsl:attribute name="id" select="."/>
  </xsl:template>
  
<!--  <xsl:template match="boxed-text[@content-type eq 'marginalia']" mode="tei2html">
     <div class="{@content-type}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </div>   
  </xsl:template>
-->

  
  <xsl:template match="label[not(parent::item)]" mode="tei2html" priority="0.5">
    <span class="label">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </span>
  </xsl:template>
  
  <xsl:template match="*:label[ancestor::*:note]" mode="tei2html" priority="1.5"/>

  <xsl:template match="*[note[@type = 'footnote']]" mode="tei2html">
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="note[not(@type = 'footnote')]" mode="tei2html">
    <p>
      <xsl:next-match/>
    </p>
  </xsl:template>
  
  <xsl:template match="byline" mode="tei2html">
    <p>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </p>
  </xsl:template>
    
  <xsl:template match="*" mode="notes">
    <xsl:param name="footnote-ids" tunnel="yes" as="xs:string*"/>
    <div class="{name()}" id="fn_{@xml:id}">
      <p class="footnote-marker">
        <sup>
         <a href="#fna_{@xml:id}">
             <xsl:value-of select="index-of($footnote-ids, @xml:id)"/>
         </a>
        </sup>
        <xsl:text>&#160;</xsl:text>
      </p>
      <div class="footnote-text">
        <xsl:apply-templates  select="* except (*:p[1]/label, *:p[1]/seg[@type = 'tab'])" mode="tei2html"/>
      </div>
    </div>
  </xsl:template>
  
  <xsl:template match="*:seg[@type = 'tab'][preceding-sibling::*[1][self::*:label]][ancestor::*:note]" mode="tei2html"/>
  
  <xsl:template match="note[@type = 'footnote']" mode="tei2html">
    <xsl:param name="footnote-ids" tunnel="yes" as="xs:string*"/>
    <xsl:param name="in-toc" tunnel="yes" as="xs:boolean?"/>
    <xsl:if test="not($in-toc)">
      <span class="note-anchor" id="fna_{@xml:id}">
        <a href="#fn_{@xml:id}">
          <sup>
            <xsl:value-of select="index-of($footnote-ids, @xml:id)"/>
          </sup>
        </a>
      </span>
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
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </dl>
  </xsl:template>
  
  <xsl:template match="item[parent::list[@type eq 'gloss']]" mode="tei2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="item[parent::list[@type eq 'gloss']]/label" mode="tei2html">
    <dt>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </dt>
  </xsl:template>
  
  <xsl:template match="item[parent::list[@type eq 'gloss']]/gloss" mode="tei2html">
    <dd>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </dd>
  </xsl:template>

  <xsl:template match="list[@type eq 'bulleted']" mode="tei2html">
    <ul class="{descendant::p[1]/@rend}">
      <xsl:apply-templates mode="#current"/>
    </ul>
  </xsl:template>
  
  <xsl:template match="list[@type eq 'ordered']" mode="tei2html">
    <ol class="{descendant::p[1]/@rend}">
      <xsl:apply-templates mode="#current"/>
    </ol>
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

  <xsl:template match="argument" mode="tei2html">
    <div class="introduction">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="quote" mode="tei2html">
    <blockquote>
      <xsl:call-template name="css:content"/>
    </blockquote>
  </xsl:template>
  
  <xsl:template match="figure" mode="tei2html">
      <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="figure/head" mode="tei2html">
    <p>
      <xsl:apply-templates select="@* except @rend" mode="#current"/>
      <xsl:attribute name="class" select="concat(@rend, ' figure-head')"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </p>
  </xsl:template>
  
  <xsl:template match="@preformat-type" mode="tei2html">
    <xsl:attribute name="class" select="."/>
  </xsl:template>
  
  <xsl:template name="tei2html:footnotes">
    <xsl:variable name="footnotes" select=".//note[@type = 'footnote']" as="element(note)*"/>
    <xsl:if test="$footnotes">
      <div class="notes">
        <xsl:sequence select="letex:create-epub-type-attribute($tei2html:epub-type, $footnotes[1])"/>
        <xsl:apply-templates select="$footnotes" mode="notes"/>
      </div>  
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="divGen[@type = 'toc']" mode="tei2html">
    <xsl:element name="{if ($tei2html:epub-type = '2') then 'div' else 'nav'}">
      <xsl:attribute name="class" select="'toc'"/>
      <xsl:sequence select="letex:create-epub-type-attribute($tei2html:epub-type, .)"/>
      <xsl:choose>
        <xsl:when test="exists(* except head)">
          <!-- explicitly rendered toc -->
          <xsl:apply-templates mode="tei2html"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="head" mode="#current"/>
          <xsl:apply-templates select="//head[parent::div[@type = ('section', 'glossary', 'acknowledgements', 'appendix', 'chapter', 'dedication', 'preface', 'part')]
            | parent::divGen[@type ='index']
            ]
            [(@type = 'main') or (head[@type = 'sub'][not(preceding-sibling::*[1][self::head[@type = 'main']] or following-sibling::*[1][self::head[@type = 'main']])])]
            [not(ancestor::divGen[@type ='toc'])]
            [tei2html:heading-level(.) le number((@rendition, 100)[1]) + 1]" mode="toc"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
    
  <xsl:template match="div[@type = 'imprint']" mode="tei2html">
    <div class="imprint">
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="head[not(@type = 'sub')]" mode="toc">
    <p class="toc{tei2html:heading-level(.)}">
      <a href="#{(@id, generate-id())[1]}">
        <xsl:if test="label">
          <xsl:apply-templates select="label/node()" mode="strip-indexterms-etc"/>
          <xsl:apply-templates select="label" mode="label-sep"/>
        </xsl:if>
        <xsl:apply-templates mode="tei2html">
          <xsl:with-param name="in-toc" select="true()" as="xs:boolean" tunnel="yes"/>
        </xsl:apply-templates>
      </a>
    </p>
  </xsl:template>
  
  <xsl:template match="target[@id]" mode="tei2html" priority="2">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="not($in-toc)">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="head[@type = 'sub'][preceding-sibling::*[1][self::head[@type = 'main']] or following-sibling::*[1][self::head[@type = 'main']]] |
                       head[ancestor::*[self::floatingText]]" mode="tei2html" priority="2">
    <p>
      <xsl:apply-templates select="@* except @rend" mode="#current"/>
      <xsl:attribute name="class" select="if (@type = 'sub') then concat(@rend, ' subtitle') else concat(@rend, ' ', normalize-space((ancestor::*[self::floatingText]/@type)[1]), '-head')"/>
      <xsl:apply-templates select="node()" mode="#current"/>
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

  <xsl:template match="head[not(@type = 'sub')][not(ancestor::*[self::figure or self::table or self::floatingText])]" mode="tei2html">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:variable name="heading-level" select="tei2html:heading-level(.)"/>
    <xsl:element name="{concat('h', $heading-level)}">
      <xsl:apply-templates select="@* except @rend" mode="#current"/>
      <xsl:attribute name="class" select="if(parent::div[@type] or parent::divGen[@type]) then (parent::div, parent::divGen)[1]/@type else local-name()"/>
      <xsl:attribute name="title" select="tei2html:heading-title(.)"/>
      <xsl:if test="not($in-toc)">
        <a id="{generate-id()}" />  
      </xsl:if>
      <xsl:sequence select="tei2html:heading-content(.)"/>
    </xsl:element>
  </xsl:template>
  

  <xsl:function name="tei2html:heading-title" as="xs:string?">
    <xsl:param name="context"/>
    <xsl:value-of select="tei2html:heading-content($context)"/>  
  </xsl:function>
  
  <xsl:function name="tei2html:heading-content">
    <xsl:param name="context"/>
    <xsl:if test="$context/label">
      <xsl:apply-templates select="$context/label/node()" mode="strip-indexterms-etc"/>
      <xsl:apply-templates select="$context/label" mode="label-sep"/>
    </xsl:if>
    <xsl:apply-templates select="$context/node() except $context/label" mode="tei2html"/>
  </xsl:function>
  
  <xsl:variable name="tei:anonymous-chapter-regex" select="'p_h_anonym'" as="xs:string"/>
<!--  <xsl:template match="head[matches(@rend, $tei:anonymous-chapter-regex)]" mode="tei2html">
    <xsl:copy>
      <xsl:apply-templates select="@* except @rend" mode="#current"/>
      <xsl:attribute name="title" select="."/>
    </xsl:copy>
  </xsl:template>
  -->
  <xsl:variable name="tei2html:dissolve-br-in-toc-head" as="xs:boolean" select="false()"/>
  
  <xsl:template match="*:head/*:lb[$tei2html:dissolve-br-in-toc-head]" mode="strip-indexterms-etc">
    <xsl:choose>
      <xsl:when test="preceding-sibling::node()[1]/(self::text()) and matches(preceding-sibling::node()[1], '\s$') or
        following-sibling::node()[1]/(self::text()) and matches(following-sibling::node()[1], '^\s')"/>
      <xsl:otherwise>
        <xsl:sequence select="'&#160;'"/>
      </xsl:otherwise>
    </xsl:choose>  
  </xsl:template>
  
  <xsl:template match="index/term | fn" mode="strip-indexterms-etc"/>
  
  <!-- Discard certain css markup on titles that would otherwise survive on paras: -->
  <xsl:template match="title/@css:*[matches(local-name(), '^(margin-|text-align)')]" mode="tei2html"/>
  
  <xsl:template match="label" mode="label-sep">
    <xsl:text>&#160;</xsl:text>
  </xsl:template>
  
  <xsl:template match="contrib-group/contrib" mode="tei2html">
<!--    <p class="{string-join((@contrib-type, local-name()), ' ')}">-->
      <xsl:apply-templates mode="#current"/>
<!--    </p>-->
  </xsl:template>

  <xsl:template match="string-name" mode="tei2html">
    <xsl:apply-templates mode="#current"/>
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
  
  <xsl:template match="hi" mode="tei2html" priority="2">
    <span>
      <xsl:next-match/>
    </span>
  </xsl:template>
  
  <xsl:template match="sup | sub" mode="tei2html">
    <xsl:element name="{name()}">
      <xsl:next-match/>
    </xsl:element>
  </xsl:template>
  
    
  <xsl:template match="ref | link" mode="tei2html" priority="5">
    <a>
      <xsl:attribute name="href" select="@target"/>
      <xsl:attribute name="class" select="name()"/>
      <xsl:apply-templates select="@* except @target, node()" mode="#current"/>
      <xsl:if test="not(node())">
        <xsl:value-of select="(@xlink:href|@target)[1]"/>
      </xsl:if>
    </a>
  </xsl:template>
  
<!--  <xsl:template match="ref[@id]/node()[last()]" mode="tei2html">
    <xsl:next-match/>
    <xsl:text>&#x2002;</xsl:text>
    <xsl:for-each select="key('by-rid', ../@id)">
      <a href="#xref_{@id}">
        <xsl:number format="a" value="position()"/>
      </a>
      <xsl:if test="position() ne last()">
        <xsl:text xml:space="preserve">, </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

-->
  
  <xsl:template match="seg" mode="tei2html">
    <span>
      <xsl:next-match/>
    </span>
  </xsl:template>
  
  <xsl:template match="@rend" mode="tei2html">
    <xsl:attribute name="class" select="."/>
  </xsl:template>
  

  
  <xsl:template match="pb" mode="tei2html">
    <div style="page-break-before:always" class="{local-name()}">
      <xsl:sequence select="letex:create-epub-type-attribute($tei2html:epub-type, .)"/>
    </div>
  </xsl:template>

  <!-- override this in your adaptions with 3, then epub-types are created -->
  <xsl:variable name="tei2html:epub-type" as="xs:string" select="'2'"/>
  
  <xsl:function name="letex:create-epub-type-attribute" as="attribute()?">
    <xsl:param name="tei2html:epub-type" as="xs:string"/>
    <xsl:param name="context" as="element(*)"/>
    <xsl:if test="$tei2html:epub-type eq '3'">
      <xsl:choose>
        <xsl:when test="$context[self::*:pb]">
          <xsl:attribute name="epub:type" select="'pagebreak'"/>
        </xsl:when>
        <xsl:when test="$context[self::*:div[@type = ('glossary', 'preface', 'bibliography', 'acknowledgements', 'chapter', 'foreword')]]">
          <xsl:attribute name="epub:type" select="$context/@type"/>
        </xsl:when>
        <xsl:when test="$context[self::*:div[@type = 'marginal']]">
          <xsl:attribute name="epub:type" select="'sidebar'"/>
        </xsl:when>
        <xsl:when test="$context[self::*:divGen[@type = ('index', 'toc')]]">
          <xsl:attribute name="epub:type" select="$context/@type"/>
        </xsl:when>
        <xsl:when test="$context[self::*:note[@type = ('footnotes')]]">
          <xsl:attribute name="epub:type" namespace="http://www.idpf.org/2007/ops" select="$context/@type"/>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:function>
  
  <xsl:template match="lb" mode="tei2html">
    <br/>
  </xsl:template>

  <xsl:template match="divGen[@type= 'index']" mode="tei2html">
    <div class="{local-name()}">
      <xsl:sequence select="letex:create-epub-type-attribute($tei2html:epub-type, .)"/>
       <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:for-each-group select="//index/term[not(parent::term)]" group-by="substring(., 1, 1)"
        collation="http://saxon.sf.net/collation?lang={(/*/@xml:lang, 'de')[1]};strength=primary">
        <xsl:sort select="current-grouping-key()" 
          collation="http://saxon.sf.net/collation?lang={(/*/@xml:lang, 'de')[1]};strength=primary"/>
        <h4>
          <xsl:value-of select="upper-case(tei2html:strip-combining(current-grouping-key()))"/>
        </h4>
        <xsl:call-template name="group-index-terms">
          <xsl:with-param name="level" select="1"/>
          <xsl:with-param name="index-terms" select="current-group()"/>
        </xsl:call-template>
      </xsl:for-each-group>
    </div>
  </xsl:template>
  
  <xsl:template name="group-index-terms">
    <xsl:param name="level" as="xs:integer"/>
    <xsl:param name="index-terms" as="element(term)*"/>
    <!-- §§§ We need to know a book’s main language! -->
    <xsl:for-each-group select="$index-terms" group-by="."
      collation="http://saxon.sf.net/collation?lang={(/*/@xml:lang, 'de')[1]};strength=identical">
      <xsl:sort collation="http://saxon.sf.net/collation?lang={(/*/@xml:lang, 'de')[1]};strength=primary"/>
      <xsl:sort collation="http://saxon.sf.net/collation?lang={(/*/@xml:lang, 'de')[1]};strength=identical"/>
      <xsl:call-template name="index-entry">
        <xsl:with-param name="level" select="$level"/>
      </xsl:call-template>
    </xsl:for-each-group>
  </xsl:template>
  
  <xsl:template name="index-entry">
    <xsl:param name="level" as="xs:integer"/>
    <p class="ie ie{$level}">
      <xsl:value-of select="current-grouping-key()"/>
      <xsl:text>&#x2002;</xsl:text>
      <xsl:for-each select="current-group()[not(term)]">
        <a href="#it_{@id}" id="ie_{@id}">
          <xsl:value-of select="position()"/>
        </a>
        <xsl:if test="position() ne last()">
          <xsl:text xml:space="preserve">, </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </p>
    <xsl:call-template name="group-index-terms">
      <xsl:with-param name="index-terms" select="current-group()/term"/>
      <xsl:with-param name="level" select="$level + 1"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="index[not(parent::index)]" mode="tei2html">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="not($in-toc)">
      <span class="indexterm" id="it_{descendant-or-self::term[last()]/@id}">
        <xsl:attribute name="title">
          <xsl:apply-templates select="term" mode="#current"/>
        </xsl:attribute>
        <a href="#ie_{descendant-or-self::term[last()]/@id}" class="it"/>
      </span>
    </xsl:if>
  </xsl:template>
  
  <xsl:key name="by-id" match="*[@id]" use="@id"/>
  
  <xsl:template match="html:a[@class eq 'it'][@href]" mode="clean-up">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:text>(</xsl:text>
      <xsl:value-of select="key('by-id', substring-after(@href, '#'))"/>
      <xsl:text>)</xsl:text>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="term" mode="tei2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="index[parent::index]" mode="tei2html">
    <xsl:text xml:space="preserve">, </xsl:text>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="see" mode="tei2html">
    <xsl:text xml:space="preserve"> see </xsl:text>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="see-also" mode="tei2html">
    <xsl:text xml:space="preserve"> see also </xsl:text>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="p[floatingText | figure | table]" mode="tei2html" priority="1.2">
    <xsl:for-each-group select="node()" group-adjacent="boolean(self::floatingText | self::figure | self::table)">
      <xsl:choose>
        <xsl:when test="current-grouping-key()">
          <xsl:apply-templates select="current-group()" mode="#current"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="{name(..)}">
            <xsl:apply-templates select="../@*, current-group()" mode="#current"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>  
  </xsl:template>
  
    
  <xsl:template match="graphic" mode="tei2html">
    <img>
      <xsl:attribute name="alt" select="replace(@url, '^.*?/([^/]+)$', '$1')"/>
      <xsl:attribute name="src" select="resolve-uri(@url)"/>
      <xsl:apply-templates select="@rend" mode="class-att"/>
      <xsl:copy-of select="@* except (@url, @rend)"/>
      <xsl:call-template name="css:content"/>
    </img>
  </xsl:template>  
  
<!--  <xsl:template match="@url | @type [. = 'tab']" mode="tei2html" priority="-0.5"/>-->
  
  <xsl:template match="graphic/@xlink:href" mode="tei2html">
    <xsl:attribute name="src" select="."/>
  </xsl:template>

  <xsl:template match="graphic/@css:*" mode="tei2html"/>

  <xsl:template match="*[name() = ('graphic', 'inline-graphic')]/@*[name() = ('css:width', 'css:height')]"
    mode="hub2htm:css-style-overrides"/>

  <xsl:template match="tbody | thead | tfoot | th | colgroup | col" mode="tei2html">
    <xsl:element name="{local-name()}" exclude-result-prefixes="#all">
      <xsl:call-template name="css:content"/>
    </xsl:element>
  </xsl:template>  

  <xsl:template match="table[not(matches(@css:width, '(pt|mm)$'))]" mode="tei2html">
    <div class="table-wrapper">
      <xsl:apply-templates select="head" mode="#current">
        <xsl:with-param name="not-discard-table-head" as="xs:boolean" tunnel="yes" select="true()"/>
      </xsl:apply-templates>
      <xsl:element name="{local-name()}" exclude-result-prefixes="#all">
        <xsl:call-template name="css:content"/>
      </xsl:element>
    </div>
  </xsl:template>
  
  <xsl:template match="table/head" mode="tei2html">
    <xsl:param name="not-discard-table-head" as="xs:boolean?" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="$not-discard-table-head">
        <xsl:element name="p" exclude-result-prefixes="#all">
          <xsl:call-template name="css:content"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
   </xsl:template>
  
  <xsl:template match="row" mode="tei2html">
    <xsl:element name="tr" exclude-result-prefixes="#all">
      <xsl:call-template name="css:content"/>
    </xsl:element>
  </xsl:template>  
  
  <xsl:template match="cell" mode="tei2html">
    <xsl:element name="td" exclude-result-prefixes="#all">
      <xsl:call-template name="css:content"/>
    </xsl:element>
  </xsl:template>  
  
  <xsl:template match="cell/@css:width" mode="table-widths">
    <xsl:variable name="cell-width" select="if (matches(., '(pt|mm)$')) then letex:length-to-unitless-twip(.) else ."/>
    <xsl:variable name="table-width" select="if (ancestor::table[1]/@css:width) then letex:length-to-unitless-twip(ancestor::table[1]/@css:width) else '5000'"/>
    <xsl:attribute name="css:width" select="replace((xs:string((100 * $cell-width) div $table-width)), '(\d+)(\.?)(\d{2})?(\d*)', '$1$2$3%')"/>    
  </xsl:template>
  
  <xsl:template match="table[matches(@css:width, '(pt|mm)$')]" mode="tei2html">
    <xsl:variable name="conditional-percent-widths" as="element(table)">
      <xsl:apply-templates select="." mode="table-widths"/>
    </xsl:variable>
    <xsl:apply-templates select="$conditional-percent-widths" mode="#current">
      <xsl:with-param name="root" select="root(.)" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <!-- There should always be @css:width. @width is only decorational (will be valuable just in case 
    all @css:* will be stripped -->

  <xsl:template match="table[@css:width]" mode="table-widths">
    <xsl:variable name="twips" select="letex:length-to-unitless-twip(@css:width)" as="xs:double?"/>
    <xsl:choose>
      <xsl:when test="$twips">
        <xsl:copy copy-namespaces="no">
          <xsl:apply-templates select="@*, node()" mode="#current">
            <xsl:with-param name="table-twips" select="$twips" tunnel="yes"/>
            <xsl:with-param name="table-percentage" select="tei2html:table-width-grid($twips, $page-width-twips)" tunnel="yes"/>
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
      <xsl:when test="$table-percentage eq 0">
        <xsl:copy/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="css:width" select="concat($table-percentage, '%')"/>    
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="table[not(col | colgroup)][@css:width]/*/row/*/@css:width
                       | table[exists(col | colgroup)][@css:width]//col/@width" mode="table-widths">
    <xsl:param name="table-twips" as="xs:double?" tunnel="yes"/>
    <xsl:param name="table-percentage" as="xs:integer?" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="not($table-twips) or not($table-percentage)">
        <xsl:attribute name="css:width" select="."/>
      </xsl:when>
      <xsl:when test="$table-percentage eq 0">
        <xsl:attribute name="css:width" select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="css:width" 
          select="concat(string(xs:integer(1000 * (letex:length-to-unitless-twip(.) div $table-twips)) * 0.1), '%')"/>    
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="table[exists(col | colgroup)]/*/row/*/@css:width" mode="table-widths"/>
  

  <xsl:template match="@colspan | @rowspan" mode="tei2html">
    <xsl:copy/>
  </xsl:template>
  
   
  <xsl:key name="by-id" match="*[@id]" use="@id"/>
  <xsl:key name="by-rid" match="*[@rid]" use="@rid"/>
  
  <xsl:variable name="root" select="/" as="document-node()"/>

  <xsl:template match="xref" mode="tei2html">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:variable name="linked-items" as="element(linked-item)*">
      <xsl:apply-templates select="key('by-id', tokenize(@rid, '\s+'), $root)" mode="linked-item"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="node()">
        <!-- explicit referring text -->
        <xsl:choose>
          <xsl:when test="$in-toc">
            <xsl:apply-templates mode="#current"/>
          </xsl:when>
          <xsl:when test="count($linked-items) eq 1">
            <xsl:if test="$linked-items[1]/@ref-type = 'ref'">
              <span class="cit">
                <xsl:text>[</xsl:text>
                <xsl:number format="a" 
                  value="index-of(for $xr in key('by-rid', @rid, $root) return $xr/@id, @id)"/>
                <xsl:text>]</xsl:text>
              </span>
            </xsl:if>
            <a href="#{$linked-items[1]/@id}" id="xref_{@id}">
              <!--<xsl:if test=". is (key('by-rid', $linked-items[1]/@id, $root))[1]">
                <xsl:attribute name="id" select="concat('xref_', $linked-items[1]/@id)"/>
              </xsl:if>-->
              <xsl:apply-templates mode="#current"/>
            </a>
          </xsl:when>
          <xsl:when test="count($linked-items) eq 0">
            <xsl:apply-templates mode="#current"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>Cannot link: multiple resolutions for xref with an explicit link text. <xsl:copy-of select="."
              /></xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <!-- generate referring text -->
        <xsl:call-template name="render-rids">
          <xsl:with-param name="linked-items" select="$linked-items"/>
          <xsl:with-param name="in-toc" select="$in-toc" tunnel="yes"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="render-rids">
    <xsl:param name="linked-items" as="element(linked-item)*"/>
    <xsl:variable name="grouped-items" as="element(linked-items)" xmlns="">
      <linked-items  xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:for-each-group select="$linked-items" group-by="@ref-type">
          <ref-type-group type="{current-grouping-key()}">
            <xsl:for-each-group select="current-group()" group-adjacent="tei2html:link-rendering-type(., ('label', 'number', 'title', 'teaser'))">
              <rendering type="{current-grouping-key()}">
                <xsl:variable name="context" select="." as="element(*)"/>
                <xsl:for-each select="current-group()/(@* | *)[name() = current-grouping-key()]">
                  <item id="{$context/@id}">
                    <xsl:apply-templates select="." mode="render-xref"/>
                  </item>
                </xsl:for-each>
              </rendering>
            </xsl:for-each-group>  
          </ref-type-group>
        </xsl:for-each-group>    
      </linked-items>
    </xsl:variable>    
    <xsl:apply-templates select="$grouped-items" mode="render-xref"/>
  </xsl:template>

  <xsl:function name="tei2html:ref-type" as="xs:string">
    <xsl:param name="elt" as="element(*)"/>
    <xsl:choose>
      <xsl:when test="$elt/self::book-part">
        <xsl:sequence select="($elt/@book-part-type, $elt/name())[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$elt/name()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  
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
  
  <xsl:function name="tei2html:link-rendering-type" as="xs:string">
    <xsl:param name="elt" as="element(linked-item)"/>
    <!-- preference: sequence of 'number', 'title', 'label', 'teaser' --> 
    <xsl:param name="preference" as="xs:string*"/>
    <xsl:sequence select="(for $p in $preference return $elt/(@* | *)[name() eq $p]/name(), '')[1]"/>
  </xsl:function>

  <xsl:template match="linked-items | ref-type-group" mode="render-xref">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="sp" mode="tei2html">
    <div class="speech">
      <xsl:apply-templates select="node()" mode="#current"/>
    </div>
  </xsl:template> 
  
  <xsl:template match="lg" mode="tei2html">
    <div class="{@type}">
      <xsl:apply-templates select="node()" mode="#current"/>
    </div>
  </xsl:template> 
  
  <xsl:template match="l" mode="tei2html">
    <p>
      <xsl:copy-of select="@srcpath"/>
      <xsl:attribute name="class" select="@rend"/>
      <xsl:apply-templates select="node()" mode="tei2html"/>
    </p>
  </xsl:template> 
  
  <xsl:function name="tei2html:heading-level" as="xs:integer?">
    <xsl:param name="elt" as="element(*)"/>
    <xsl:choose>
      <xsl:when test="$elt/ancestor::table"/>
      <xsl:when test="$elt/ancestor::lg"/>
      <xsl:when test="$elt/ancestor::figure"/>
      <xsl:when test="$elt/ancestor::floatingText"/>
      <xsl:when test="$elt/parent::div/@type = ('part', 'appendix', 'imprint', 'acknowledgements', 'dedication', 'glossary', 'preface') or 
                      $elt/parent::divGen/@type = ('index', 'toc')">
        <xsl:sequence select="2"/>
      </xsl:when>
      <xsl:when test="$elt/parent::div/@type = ('chapter')">
        <xsl:sequence select="if ($elt/ancestor::div/@type = 'virtual-part') then 2 else 3"/>
      </xsl:when>
      <xsl:when test="$elt/parent::div/@type = ('section')">
        <xsl:sequence select="count($elt/ancestor::div[@type eq 'section']) +3"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="custom" as="xs:integer?">
          <xsl:apply-templates select="$elt" mode="tei2html_heading-level"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$custom">
            <xsl:sequence select="$custom"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>No heading level for <xsl:copy-of select="$elt/.."/></xsl:message>    
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template match="*" mode="tei2html_heading-level" as="xs:integer?"/>

  <xsl:function name="tei2html:table-width-grid" as="xs:integer">
    <!-- returns 0, 50, or 100. It should be interpreted and used as a width
      percentage, except when it’s 0. Then the original widths should be kept. -->
    <xsl:param name="page-width-twip" as="xs:double"/>
    <xsl:param name="object-width-twip" as="xs:double"/>
    <xsl:choose>
      <xsl:when test="$object-width-twip gt 0.75 * $page-width-twip">
        <xsl:sequence select="100"/>
      </xsl:when>
      <xsl:when test="$object-width-twip gt 0.4 * $page-width-twip">
        <xsl:sequence select="50"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
    

  <xsl:function name="letex:contains" as="xs:boolean">
    <xsl:param name="space-sep-list" as="xs:string?" />
    <xsl:param name="item" as="xs:string+" />
    <xsl:sequence select="$item = tokenize($space-sep-list, '\s+', 's')" />
  </xsl:function>

</xsl:stylesheet>