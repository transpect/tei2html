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
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  version="2.0">

  <xsl:import href="http://transpect.le-tex.de/hub2html/xsl/css-rules.xsl"/>
  <xsl:import href="http://transpect.le-tex.de/hub2html/xsl/css-atts2wrap.xsl"/>
  <xsl:import href="http://transpect.le-tex.de/xslt-util/lengths/lengths.xsl"/>
  
  <xsl:param name="debug" select="'yes'"/>
  <xsl:param name="debug-dir-uri" select="'debug'"/>
  
  <xsl:param name="common-path" />
  <xsl:param name="publisher-path" />
  <xsl:param name="series-path" />
  <xsl:param name="work-path" />
  
  <xsl:param name="divify-sections" select="'no'"/>

  <xsl:param name="css-location" select="concat($common-path, '/css/stylesheet.css')"/>

  <!-- Resolve Relative links to the parent directory against the following URI
       (for example, the source XML directory's URL in the code repository),
       empty string or unset param if no resolution required: -->
  <xsl:param name="rr" select="'https://hosting-1.hogrefe.de/BookTagSet/trunk/doc/'"/>

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
  <xsl:template match="index-term | xref | fn" mode="epub-alternatives">
    <xsl:copy copy-namespaces="no">
      <xsl:attribute name="id" select="generate-id()"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
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
        <xsl:apply-templates select=".//custom-meta-group/css:rules" mode="hub2htm:css"/>
      </head>
      <body>
        <xsl:apply-templates select="text" mode="#current">
          <xsl:with-param name="footnote-ids" select="//fn/@id" as="xs:string*" tunnel="yes"/>
        </xsl:apply-templates>
      </body>
    </html>
  </xsl:template>
  
    <xsl:template match="text | body | front | div[$divify-sections = 'no']" mode="tei2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  

  <!-- Default handler for the content of para-like and phrase-like elements,
    invoked by an xsl:next-match for the same matching elements. Don't forget 
    to include the names of the elements that you want to handle here. Otherwise
    they'll be reported as unhandled.
    And don’t ever change the priority unless you’ve made sure that no other template
    relies on this value to be 0.25.
    -->
  <xsl:template match="head | quote | seg | p |  table | caption | ref | mixed-citation | copyright-statement | styled-content | italic | bold |
    underline | sub | sup | verse-line | verse-group | copyright-statement" mode="tei2html" priority="-0.25" >
    <xsl:call-template name="css:content"/>
  </xsl:template>
  
  <xsl:template name="css:other-atts">
    <!-- In the context of an element with CSSa attributes -->
    <xsl:apply-templates select="@*[not(namespace-uri() = 'http://www.w3.org/1996/css' or self::attribute(xml:lang))]
                                   [not(css:map-att-to-elt(., ..))]" mode="#current"/>
    <xsl:apply-templates select="." mode="class-att"/>
    <xsl:sequence select="hub2htm:style-overrides(.)"/>
  </xsl:template>

  <xsl:function name="tei2html:strip-combining" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:sequence select="replace(normalize-unicode($input, 'NFKD'), '\p{Mn}', '')"/>
  </xsl:function>
  
  <xsl:template match="*" mode="class-att"/>

  <xsl:template match="*[@content-type | @style-type]" mode="class-att">
    <xsl:apply-templates select="@content-type | @style-type" mode="#current"/>
  </xsl:template>

  <xsl:template match="verse-line[@content-type | @style-type]" mode="class-att" priority="2">
    <xsl:variable name="att" as="attribute(class)?">
      <xsl:next-match/>
    </xsl:variable>
    <xsl:if test="$att">
      <xsl:attribute name="class" select="string-join(('verse-line', $att), ' ')"/>
    </xsl:if>
  </xsl:template>

  <xsl:variable name="tei2html:ignore-style-name-regex-x"
    select="'^(NormalParagraphStyle|Hyperlink)$'"
    as="xs:string"/>

  <xsl:template match="@content-type[not(../@style-type)] | @style-type" mode="class-att">
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
  <xsl:template match="@content-type | @style-type | @specific-use" mode="tei2html"/>

  <xsl:variable name="default-structural-containers" as="xs:string+"
    select="('book-part', 'front-matter-part', 'sec', 'app', 'ack', 'ref-list', 'dedication', 'foreword', 'preface', 'contrib-group')"/>

  <!-- everything that goes into a div (except footnote-like content): -->
  <xsl:template match="  *[name() = $default-structural-containers][$divify-sections = 'yes']
                       | fig | caption | abstract | verse-group" 
    mode="tei2html" priority="2">
    <div class="{string-join((name(), @book-part-type, @sec-type, @content-type), ' ')}">
      <xsl:next-match/>
    </div>
  </xsl:template>

  <xsl:template match="*[name() = $default-structural-containers][not($divify-sections = 'yes')]" 
    mode="tei2html" priority="2">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="break" mode="tei2html">
    <br/>
  </xsl:template>

  <xsl:template match="target[@id]" mode="tei2html">
    <a id="{@id}"/>
  </xsl:template>
  
  <xsl:template match="boxed-text[@content-type eq 'marginalia']" mode="tei2html">
     <div class="{@content-type}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </div>   
  </xsl:template>


  <xsl:template match="*[p[@specific-use eq 'EpubAlternative']]" mode="epub-alternatives" priority="2">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, title | info | p[@specific-use eq 'EpubAlternative']" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="permissions[preceding-sibling::*/p[@specific-use eq 'EpubAlternative']]" mode="epub-alternatives"
    priority="2"/>

  <xsl:template match="*[fn]" mode="tei2html">
    <xsl:next-match/>
  </xsl:template>

  <xsl:template match="*" mode="notes">
    <xsl:param name="footnote-ids" tunnel="yes" as="xs:string*"/>
    <div class="{name()}" id="fn_{@id}">
      <span class="note-mark">
        <a href="#fna_{@id}">
          <sup>
            <xsl:value-of select="index-of($footnote-ids, @id)"/>
          </sup>
        </a>
      </span>
      <xsl:apply-templates mode="tei2html"/>
    </div>
  </xsl:template>

  <xsl:template match="fn" mode="tei2html">
    <xsl:param name="footnote-ids" tunnel="yes" as="xs:string*"/>
    <xsl:param name="in-toc" tunnel="yes" as="xs:boolean?"/>
    <xsl:if test="not($in-toc)">
      <span class="note-anchor" id="fna_{@id}">
        <a href="#fn_{@id}">
          <sup>
            <xsl:value-of select="index-of($footnote-ids, @id)"/>
          </sup>
        </a>
      </span>
    </xsl:if>
  </xsl:template>
 
 
  <xsl:template match="def-list" mode="tei2html">
    <dl>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </dl>
  </xsl:template>
    
  <xsl:template match="def-item" mode="tei2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="def-item/term" mode="tei2html">
    <dt>
      <xsl:copy-of select="../@id"/>
      <xsl:call-template name="css:content"/>
    </dt>
  </xsl:template>
  
  <xsl:template match="def-item/def" mode="tei2html">
    <dd>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </dd>
  </xsl:template>

  <xsl:template match="list[@list-type eq 'bullet']" mode="tei2html">
    <ul>
      <xsl:apply-templates mode="#current"/>
    </ul>
  </xsl:template>
  
  <xsl:template match="list[matches(@list-type, '^(order|alpha|roman)')]" mode="tei2html">
    <ol>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </ol>
  </xsl:template>
  
  <xsl:template match="@list-type" mode="tei2html">
    <xsl:choose>
      <xsl:when test=". = 'order'"/>
      <xsl:when test=". = 'alpha-lower'"><xsl:attribute name="class" select="'lower-alpha'"/></xsl:when>
      <xsl:when test=". = 'alpha-upper'"><xsl:attribute name="class" select="'upper-alpha'"/></xsl:when>
      <xsl:when test=". = 'roman-lower'"><xsl:attribute name="class" select="'lower-roman'"/></xsl:when>
      <xsl:when test=". = 'roman-upper'"><xsl:attribute name="class" select="'upper-roman'"/></xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="list-item" mode="tei2html">
    <li>
      <xsl:apply-templates mode="#current"/>
    </li>
  </xsl:template>
  
  <xsl:template match="preformat" mode="tei2html">
    <pre>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </pre>
  </xsl:template>

  <xsl:template match="disp-quote" mode="tei2html">
    <blockquote>
      <xsl:call-template name="css:content"/>
    </blockquote>
  </xsl:template>
  
  <xsl:template match="fig" mode="tei2html">
    <div class="{local-name()}">
      <xsl:apply-templates select="@*, * except (label | caption | permissions), caption, permissions" mode="#current"/>
    </div>
  </xsl:template>

  <xsl:template match="table-wrap | table-wrap-foot" mode="tei2html">
    <div class="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </div>
  </xsl:template>

  <xsl:template match="@preformat-type" mode="tei2html">
    <xsl:attribute name="class" select="."/>
  </xsl:template>
  
  <xsl:template match="book-part | front-matter-part | foreword | preface | dedication" mode="tei2html">
    <xsl:apply-templates select="book-part-meta | front-matter | book-body | body | book-back | back | named-book-part-body" mode="tei2html"/>
  </xsl:template>
  
  <xsl:template match="body | book-body | title-group | book-part-meta | front-matter | book-back | back" mode="tei2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="body[not(descendant::body)] | named-book-part-body | app | app-group" mode="tei2html">
    <xsl:apply-templates mode="#current"/>
    <xsl:call-template name="tei2html:footnotes"/>
  </xsl:template>
  
  <xsl:template name="tei2html:footnotes">
    <xsl:variable name="footnotes" select=".//fn" as="element(fn)*"/>
    <xsl:if test="$footnotes">
      <div class="notes">
        <xsl:apply-templates select="$footnotes" mode="notes"/>
      </div>  
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="toc" mode="tei2html">
    <div class="toc">
      <xsl:choose>
        <xsl:when test="exists(* except title-group)">
          <!-- explicitly rendered toc -->
          <xsl:apply-templates mode="tei2html"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="title-group" mode="tei2html"/>
          <xsl:apply-templates
            select="//title[parent::sec | parent::title-group | parent::app | parent::ref-list]
                           [not(ancestor::boxed-text or ancestor::toc)]
                           [tei2html:heading-level(.) le number((current()/@depth, 100)[1]) + 1]"
            mode="toc"/>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
  
  <xsl:template match="title" mode="toc">
    <p class="toc{tei2html:heading-level(.)}">
      <a href="#{(@id, generate-id())[1]}">
        <xsl:if test="../label">
          <xsl:apply-templates select="../label/node()" mode="strip-indexterms-etc"/>
          <xsl:text>&#x2002;</xsl:text>
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
  
  <xsl:template match="head" mode="tei2html">
    <xsl:variable name="heading-level" select="tei2html:heading-level(.)"/>
    <xsl:element name="{concat('h', $heading-level)}">
      <xsl:attribute name="class" select="if(parent::div[@type]) then parent::div/@type else local-name()"/>
      <xsl:next-match/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="label[../title union ../caption/title]" mode="tei2html">
    <xsl:param name="actually-process-it" as="xs:boolean?"/>
    <xsl:if test="$actually-process-it">
      <span>
        <xsl:call-template name="css:content"/>
      </span>
      <xsl:apply-templates select="." mode="label-sep"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="label" mode="tei2html"/>
  
  <xsl:template match="title | book-title" mode="tei2html">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:variable name="level" select="tei2html:heading-level(.)" as="xs:integer?"/>
    <xsl:element name="{if ($level) then concat('h', $level) else 'p'}">
      <xsl:copy-of select="(../@id, parent::title-group/../../@id)[1][not($divify-sections = 'yes')]"/>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="." mode="class-att"/>
      <xsl:sequence select="hub2htm:style-overrides(.)"/>
      <xsl:variable name="label" as="element(label)?" select="(../label, parent::caption/../label)[1]"/>
      <xsl:attribute name="title">
        <xsl:apply-templates select="$label" mode="strip-indexterms-etc"/>
        <xsl:apply-templates select="$label" mode="label-sep"/>
        <xsl:variable name="stripped" as="text()">
          <xsl:value-of>
            <xsl:apply-templates mode="strip-indexterms-etc"/>  
          </xsl:value-of>
        </xsl:variable>
        <xsl:sequence select="replace($stripped, '^[\p{Zs}\s]*(.+?)[\p{Zs}\s]*$', '$1')"/>
      </xsl:attribute>
      <xsl:apply-templates select="$label" mode="#current">
        <xsl:with-param name="actually-process-it" select="true()"/>
      </xsl:apply-templates>
      <xsl:if test="not($in-toc)">
        <a id="{generate-id()}" />  
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="index-term | fn" mode="strip-indexterms-etc"/>
  
  <!-- Discard certain css markup on titles that would otherwise survive on paras: -->
  <xsl:template match="title/@css:*[matches(local-name(), '^(margin-|text-align)')]" mode="tei2html"/>
  
  <xsl:template match="table-wrap/label" mode="label-sep">
    <xsl:text>&#x2002;</xsl:text>
  </xsl:template>
  <xsl:template match="label" mode="label-sep">
    <xsl:text>&#x2003;</xsl:text>
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
  
  <xsl:template match="styled-content" mode="tei2html">
    <span>
      <xsl:next-match/>
    </span>
  </xsl:template>
  
  <xsl:template match="sup | sub" mode="tei2html">
    <xsl:element name="{name()}">
      <xsl:next-match/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="italic" mode="tei2html">
    <i>
      <xsl:next-match/>
    </i>
  </xsl:template>
  
  <xsl:template match="bold" mode="tei2html">
    <b>
      <xsl:next-match/>
    </b>
  </xsl:template>
    
  <xsl:template match="ref | copyright-statement" mode="tei2html">
    <p class="{name()}">
      <xsl:next-match/>
    </p>
  </xsl:template>
  
  <xsl:template match="ref[@id]/node()[last()]" mode="tei2html">
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

  <xsl:template match="mixed-citation" mode="tei2html"> 
    <span class="{local-name()}">
      <xsl:next-match/>
    </span> 
  </xsl:template>
  
  <xsl:template match="quote" mode="tei2html">
    <blockquote class="{local-name()}">
      <xsl:next-match/>
    </blockquote>
  </xsl:template>
  
  <xsl:template match="seg" mode="tei2html">
    <span class="{local-name()}">
      <xsl:next-match/>
    </span>
  </xsl:template>
  
  <xsl:template match="@rend" mode="tei2html"/>
  
  <xsl:template match="pb" mode="tei2html">
    <div style="page-break-after:always" class="{local-name()}"></div>
  </xsl:template>

  <xsl:template match="index" mode="tei2html">
    <div class="{local-name()}">
    <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:for-each-group select="//index-term[not(parent::index-term)]" group-by="substring(term, 1, 1)"
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
    <xsl:param name="index-terms" as="element(index-term)*"/>
    <!-- §§§ We need to know a book’s main language! -->
    <xsl:for-each-group select="$index-terms" group-by="term"
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
      <xsl:for-each select="current-group()[not(index-term)]">
        <a href="#it_{@id}" id="ie_{@id}">
          <xsl:value-of select="position()"/>
        </a>
        <xsl:if test="position() ne last()">
          <xsl:text xml:space="preserve">, </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </p>
    <xsl:call-template name="group-index-terms">
      <xsl:with-param name="index-terms" select="current-group()/index-term"/>
      <xsl:with-param name="level" select="$level + 1"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="index-term[not(parent::index-term)]" mode="tei2html">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="not($in-toc)">
      <span class="indexterm" id="it_{descendant-or-self::index-term[last()]/@id}">
        <xsl:attribute name="title">
          <xsl:apply-templates mode="#current"/>
        </xsl:attribute>
        <a href="#ie_{descendant-or-self::index-term[last()]/@id}" class="it"/>
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

  <xsl:template match="index-term/term" mode="tei2html">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="index-term[parent::index-term]" mode="tei2html">
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

  <xsl:template match="p[boxed-text | fig | table-wrap]" mode="tei2html" priority="1.2">
    <xsl:for-each-group select="node()" group-adjacent="boolean(self::boxed-text | self::fig | self::table-wrap)">
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
  
  <xsl:template match="boxed-text" mode="tei2html">
    <div class="box {@content-type}">
      <xsl:apply-templates select="@* except @content-type, node()" mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="graphic | inline-graphic" mode="tei2html">
    <img alt="An dieser Stelle kann leider das hinterlegte Bild nicht dargestellt werden.">
      <xsl:call-template name="css:content"/>
    </img>
  </xsl:template>
  
  <xsl:template match="graphic/@xlink:href" mode="tei2html">
    <xsl:attribute name="src" select="."/>
  </xsl:template>

  <xsl:template match="graphic/@css:*" mode="tei2html"/>

  <xsl:template match="*[name() = ('graphic', 'inline-graphic')]/@*[name() = ('css:width', 'css:height')]"
    mode="hub2htm:css-style-overrides"/>

  <xsl:template match="graphic/attrib" mode="tei2html">
    <xsl:attribute name="title" select="concat('Attribution: ', .)"/>
  </xsl:template>
  
  <xsl:template match="tr | tbody | thead | tfoot | td | th | colgroup | col | table[not(matches(@css:width, 'pt$'))]" mode="tei2html">
    <xsl:element name="{local-name()}" exclude-result-prefixes="#all">
      <xsl:call-template name="css:content"/>
    </xsl:element>
  </xsl:template>  

  <xsl:template match="table[matches(@css:width, 'pt$')]" mode="tei2html">
    <xsl:variable name="conditional-percent-widths" as="element(table)">
      <xsl:apply-templates select="." mode="table-widths"/>
    </xsl:variable>
    <xsl:apply-templates select="$conditional-percent-widths" mode="#current">
      <xsl:with-param name="root" select="root(.)" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <!-- There should always be @css:width. @width is only decorational (will be valuable just in case 
    all @css:* will be stripped -->
  <xsl:template match="@width" mode="tei2html"/>

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

  <xsl:template match="table[not(col | colgroup)][@css:width]/*/tr/*/@css:width
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

  <xsl:template match="table[exists(col | colgroup)]/*/tr/*/@css:width" mode="table-widths"/>
    
  
  <xsl:template match="*[matches(@role, 'master_page_objects_p_pagenumber')]" mode="tei2html"/>
  <xsl:template match="*[matches(@role, 'master_page_objects_p_runninghead')]" mode="tei2html"/>


  <xsl:template match="@colspan | @rowspan" mode="tei2html">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="ext-link" mode="tei2html">
    <a>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:if test="not(node())">
        <xsl:value-of select="@xlink:href"/>
      </xsl:if>
    </a>
  </xsl:template>

  <xsl:template match="@xlink:href" mode="tei2html">
    <xsl:attribute name="{if (contains(../name(), 'graphic')) then 'src' else 'href'}" 
                   select="if ($rr and matches(., '^\.\./'))
                           then resolve-uri(., $rr)
                           else ."/>
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


  <!-- Example:
       <linked-item number="4.2" label="Figure 4.2.">
         <title>Title, potentially including markup. If there is an alt-title[@alt-title-type eq 'xref'], it should be used</title>
         <teaser>The beginning of the contents, without index terms and footnotes</teaser>
       </linked-item>
  -->
  <xsl:template match="*" mode="linked-item" xmlns="">
    <linked-item>
      <xsl:copy-of select="@id"/>
      <xsl:attribute name="ref-type" select="tei2html:ref-type(.)"/>
      <xsl:variable name="title-container" as="element(*)">
        <xsl:choose>
          <xsl:when test="self::book-part">
            <xsl:sequence select="book-part-meta/title-group"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:for-each select="$title-container/alt-title[@alt-title-type eq 'number']">
        <xsl:attribute name="number" select="."/>
      </xsl:for-each>
      <xsl:for-each select="$title-container/label">
        <xsl:attribute name="label" select="."/>
      </xsl:for-each>
      <xsl:apply-templates select="($title-container/(title, alt-title[@alt-title-type eq 'xref']))[last()]" mode="#current"/>
      <teaser>
        <xsl:apply-templates mode="render-xref"/>
      </teaser>
    </linked-item>
  </xsl:template>
  
  <xsl:template match="title | alt-title[@alt-title-type eq 'xref']" mode="linked-item" xmlns="">
    <title>
      <xsl:apply-templates mode="render-xref"/>
    </title>
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
  
  <xsl:template match="ref-type-group[@type = ('sec', 'part', 'chapter')]/rendering[@type = ('title', 'number')]" mode="render-xref">
    <xsl:value-of select="key('l10n-string', if(count(item) gt 1) then ../@type else concat(../@type, 's'), $l10n)"/>
    <xsl:text>&#xa0;</xsl:text>
    <xsl:for-each select="item">
      <xsl:apply-templates select="." mode="#current"/>
      <xsl:if test="position() lt last()">
        <xsl:text xml:space="preserve">, </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="ref-type-group/rendering/item" mode="render-xref">
    <xsl:param name="in-toc" as="xs:boolean?" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="$in-toc">
        <xsl:apply-templates mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <a href="#{@id}">
          <xsl:apply-templates mode="#current"/>
        </a>    
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:function name="tei2html:is-book-part-like" as="xs:boolean">
    <xsl:param name="elt" as="element(*)"/>
    <!-- add more: -->
    <xsl:sequence select="exists($elt/(self::toc | self::book-part | self::preface | self::foreword | self::dedication |
      self::front-matter-part))"/>
  </xsl:function>
  
  <xsl:function name="tei2html:heading-level" as="xs:integer?">
    <xsl:param name="elt" as="element(*)"/>
    <xsl:choose>
      <xsl:when test="$elt/ancestor::table-wrap"/>
      <xsl:when test="$elt/ancestor::verse-group"/>
      <xsl:when test="$elt/ancestor::fig"/>
      <xsl:when test="$elt/parent::book-title-group"><xsl:sequence select="1"/></xsl:when>
      <xsl:when test="$elt/parent::title-group">
        <xsl:sequence select="2"/>
        <!--<xsl:sequence select="count($elt/ancestor::*[tei2html:is-book-part-like(.)]) + 1"/>-->
      </xsl:when>
      <xsl:when test="$elt/parent::div/@type = ('part', 'chapter', 'appendix')">
        <xsl:sequence select="3"/>
      </xsl:when>
      <xsl:when test="$elt/parent::div/@type = ('section')">
        <xsl:sequence select="count($elt/ancestor::div[@type eq 'section']) +3"/>
      </xsl:when>
      <xsl:when test="$elt/parent::sec[ancestor::boxed-text]">
        <xsl:sequence select="count($elt/ancestor::*[ancestor::boxed-text]) + 3"/>
      </xsl:when>
      <xsl:when test="$elt/parent::*[local-name() = ('index')]">
        <xsl:sequence select="2"/>
      </xsl:when>
      <xsl:when test="$elt/parent::*[local-name() = ('ref-list', 'sec', 'abstract', 'ack', 'app', 'app-group', 'bio')]">
        <xsl:variable name="ancestor-title" select="$elt/../../(title | (. | ../book-part-meta)/title-group/title)" as="element(title)?"/>
        <xsl:sequence select="if (exists($ancestor-title)) 
                              then tei2html:heading-level($ancestor-title) + 1
                              else 2"/></xsl:when>
      <xsl:otherwise>
        <xsl:message>No heading level for <xsl:copy-of select="$elt/.."/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

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