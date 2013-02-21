<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:hru="http://www.cornelsen.de/namespace/hru"
  xmlns:letex="http://www.le-tex.de/namespace"
  version="1.0"
  name="tei2html"
  type="hru:tei2html"
  >

  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" required="false" select="resolve-uri('debug')"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.le-tex.de/xproc-util/store-debug/store-debug.xpl" />

  <p:input port="source" primary="true" />
  <p:output port="result" primary="true" />
  <p:serialization port="result" omit-xml-declaration="false" 
    doctype-public="-//W3C//DTD XHTML 1.0//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" />

  <p:xslt name="pull-up-non-table" initial-mode="pull-up-non-table">
    <p:input port="parameters"><p:empty/></p:input>
    <p:input port="stylesheet">
      <p:document href="../xslt/tei2html.xsl" />
    </p:input>
  </p:xslt>

  <letex:store-debug pipeline-step="tei2html/pull-up-non-table">
    <p:with-option name="active" select="$debug" />
    <p:with-option name="base-uri" select="$debug-dir-uri" />
  </letex:store-debug>

  <p:xslt name="transform" initial-mode="tei2html">
    <p:input port="parameters"><p:empty/></p:input>
    <p:input port="stylesheet">
      <p:document href="../xslt/tei2html.xsl" />
    </p:input>
  </p:xslt>

  <letex:store-debug pipeline-step="tei2html/result" extension="html">
    <p:with-option name="active" select="$debug" />
    <p:with-option name="base-uri" select="$debug-dir-uri" />
  </letex:store-debug>

</p:declare-step>
