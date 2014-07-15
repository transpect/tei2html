<?xml version="1.0" encoding="utf-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:letex="http://www.le-tex.de/namespace"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:bc="http://transpect.le-tex.de/book-conversion"
  xmlns:tei2html="http://www.le-tex.de/namespace/tei2html"  
  version="1.0"
  name="tei2html"
  type="tei2html:tei2html"
  >

  <p:option name="srcpaths" required="false" select="'no'"/>
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" required="false" select="'debug'"/>
  
  <p:input port="source" primary="true" />
  <p:input port="additional-inputs" sequence="true">
    <p:empty/>
  </p:input>
  <p:input port="paths" kind="parameter" primary="true"/>
  <p:output port="result" primary="true" />
  <p:serialization port="result" 
    omit-xml-declaration="false"
    method="xhtml"
    doctype-public="-//W3C//DTD XHTML 1.0//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" />
  
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/dynamic-transformation-pipeline.xpl"/>
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/simple-progress-msg.xpl"/>
  
  <p:variable name="status-dir-uri" select="concat($debug-dir-uri, '/status')"/>
  
  <letex:simple-progress-msg name="start-msg" file="tei2html-start.txt">
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Starting TEI to HTML conversion</c:message>
          <c:message xml:lang="de">Beginne Konvertierung von TEI nach HTML</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </letex:simple-progress-msg>
  
  <bc:dynamic-transformation-pipeline load="tei2html/tei2html-driver"
    fallback-xsl="http://transpect.le-tex.de/tei2html/xsl/tei2html.xsl"
    fallback-xpl="http://transpect.le-tex.de/tei2html/xpl/tei2html_default.xpl">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:input port="additional-inputs">
      <p:pipe port="additional-inputs" step="tei2html"/>
    </p:input>
    <p:input port="options"><p:empty/></p:input>
  </bc:dynamic-transformation-pipeline>
  
  <letex:simple-progress-msg name="success-msg" file="tei2html-success.txt">
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Successfully finished TEI to HTML conversion</c:message>
          <c:message xml:lang="de">Konvertierung von TEI nach HTML erfolgreich abgeschlossen</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </letex:simple-progress-msg>
  
</p:declare-step>