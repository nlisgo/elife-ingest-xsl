<?php

namespace eLifeIngestXsl;

use Assert;
use eLifeIngestXsl\ConvertXML\XMLString;
use eLifeIngestXsl\ConvertXML\XSLString;
use InvalidArgumentException;

class ConvertXMLToCitationFormat extends ConvertXML {

  /**
   * @param XMLString $xml
   * @param string $type
   *
   * @throws InvalidArgumentException
   */
  public function __construct(XMLString $xml, $type = 'bibtex') {
    Assert\that($type)
      ->string()
      ->regex('#^(pl\-references|eif|bibtex|ris)$#');

    $xsl = XSLString::fromString(file_get_contents(dirname(__FILE__) . '/../../../lib/xsl/jats-to-' . $type . '.xsl'));
    parent::__construct($xml, $xsl);
  }
}
