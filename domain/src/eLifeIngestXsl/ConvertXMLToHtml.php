<?php

namespace eLifeIngestXsl;

use DOMDocument;
use DOMNode;
use DOMXPath;
use eLifeIngestXsl\ConvertXML\XMLString;
use eLifeIngestXsl\ConvertXML\XSLString;

class ConvertXMLToHtml extends ConvertXML {

  /**
   * @var string
   */
  private $html;

  /**
   * @param XMLString $xml
   */
  public function __construct(XMLString $xml) {
    $xsl = XSLString::fromString(file_get_contents(dirname(__FILE__) . '/../../../lib/xsl/jats-to-html.xsl'));
    parent::__construct($xml, $xsl);

    $this->html = $this->getOutput();
  }

  /**
   * @return string
   */
  private function getHtml() {
    return '<meta http-equiv="content-type" content="text/html; charset=utf-8">' . $this->html;
  }

  /**
   * @return string
   */
  public function getAbstract() {
    return $this->getSection("//*[@id='abstract']");
  }

  /**
   * @return string
   */
  public function getDigest() {
    return $this->getSection("//*[@id='elife-digest']");
  }

  /**
   * @param string $xpath_query
   * @return string
   */
  public function getSection($xpath_query) {
    libxml_use_internal_errors(TRUE);
    $actual = new DOMDocument();
    $actual->loadHTML($this->getHtml());
    $xpath = new DOMXPath($actual);
    $elements = $xpath->query($xpath_query);
    if (!empty($elements) && $elements->length > 0) {
      $output = $this->getInnerHtml($elements->item(0));
      libxml_clear_errors();

      return $output;
    }
  }

  /**
   * @param string $doi
   * @return string
   */
  public function getDoi($doi) {
    return $this->getSection("//*[@data-doi='" . $doi . "']");
  }

  /**
   * @param DOMNode $node
   * @return string
   */
  private function getInnerHtml($node) {
    $innerHTML = '';
    $children = $node->childNodes;
    foreach ($children as $child) {
      $innerHTML .= $child->ownerDocument->saveXML($child);
    }

    return trim($innerHTML);
  }
}
