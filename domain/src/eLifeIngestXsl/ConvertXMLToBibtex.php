<?php

namespace eLifeIngestXsl;

use eLifeIngestXsl\ConvertXML\XMLString;

final class ConvertXMLToBibtex extends ConvertXMLToCitationFormat {
  /**
   * @param XMLString $xml
   */
  public function __construct(XMLString $xml) {
    parent::__construct($xml, 'bibtex');
  }
}
