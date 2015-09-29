<?php

namespace eLifeIngestXsl;

use DOMDocument;
use eLifeIngestXsl\ConvertXML\XMLString;
use eLifeIngestXsl\ConvertXML\XSLString;
use XSLTProcessor;

class ConvertXML {
  /**
   * @var string
   */
  private $xml;
  /**
   * @var string
   */
  private $xsl;

  /**
   * @param XMLString $xml
   * @param XSLString $xsl
   */
  public function __construct(XMLString $xml, XSLString $xsl) {
    $this->xml = $xml->getValue();
    $this->xsl = $xsl->getValue();
  }

  public function getXML() {
    return XMLString::fromString($this->xml);
  }

  public function getXSL() {
    return XSLString::fromString($this->xsl);
  }

  public function getOutput() {
    $xml = new DOMDocument;
    $xml->loadXML($this->xml);

    $xsl = new DOMDocument;
    $xsl->loadXML($this->xsl);

    // Configure the transformer.
    $proc = new XSLTProcessor;
    // Attach the xsl rules.
    $proc->importStyleSheet($xsl);

    return $proc->transformToXML($xml);
  }
}
