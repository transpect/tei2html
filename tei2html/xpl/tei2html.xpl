<?xml version="1.0" encoding="utf-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
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
  <p:input port="additional-inputs" sequence="true"/>
  <p:input port="paths" kind="parameter" primary="true"/>
  <p:output port="result" primary="true" />
  <p:serialization port="result" 
    omit-xml-declaration="false"
    method="xhtml"
    doctype-public="-//W3C//DTD XHTML 1.0//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" />
  
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/dynamic-transformation-pipeline.xpl"/>
    
  <bc:dynamic-transformation-pipeline load="tei2html/tei2html-driver">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:input port="additional-inputs">
      <p:pipe port="additional-inputs" step="tei2html"/>
    </p:input>
    <p:input port="options"><p:empty/></p:input>
  </bc:dynamic-transformation-pipeline>
  
</p:declare-step>