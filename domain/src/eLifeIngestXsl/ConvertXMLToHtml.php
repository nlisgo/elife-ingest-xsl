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
  public function getMainText() {
    return $this->getSection("//*[@id='main-text']");
  }

  /**
   * @return string
   */
  public function getDigest() {
    return $this->getSection("//*[@id='elife-digest']");
  }

  /**
   * @return string
   */
  public function getAcknowledgements()
  {
    return $this->getSection("//*[@id='ack-1']");
  }

  /**
   * @return string
   */
  public function getDecisionLetter()
  {
    return $this->getSection("//*[@id='decision-letter']");
  }

  /**
   * @return string
   */
  public function getAuthorResponse()
  {
    return $this->getSection("//*[@id='author-response']");
  }

  /**
   * @return string
   */
  public function getReferences()
  {
    return $this->getSection("//*[@id='references']");
  }

  /**
   * @return string
   */
  public function getDatasets()
  {
    return $this->getSection("//*[contains(concat(' ', @class, ' '), ' datasets ')]");
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
    $output = NULL;
    if (!empty($elements) && $elements->length > 0) {
      $output = $this->getInnerHtml($elements->item(0));
    }
    libxml_clear_errors();
    return $output;
  }

  /**
   * @param string $doi
   * @return string
   */
  public function getDoi($doi) {
    return $this->getSection("//*[@data-doi='" . $doi . "']");
  }

  /**
   * @param string $id
   * @param string $within
   * @return string
   */
  public function getId($id, $within = "//*[@id='main-text']") {
    return $this->getSection($within . "//*[@id='" . $id . "']");
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
