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
  public function getTitle() {
    return $this->getSection("//*[@id='article-title']");
  }

  /**
   * @return string
   */
  public function getImpactStatement() {
    return $this->getSection("//*[@id='impact-statement']");
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
  public function getAcknowledgements() {
    return $this->getSection("//*[@id='ack-1']");
  }

  /**
   * @return string
   */
  public function getDecisionLetter() {
    return $this->getSection("//*[@id='decision-letter']");
  }

  /**
   * @return string
   */
  public function getAuthorResponse() {
    return $this->getSection("//*[@id='author-response']");
  }

  /**
   * @return string
   */
  public function getReferences() {
    return $this->getSection("//*[@id='references']");
  }

  /**
   * @return string
   */
  public function getAuthorInfoGroupAuthors() {
    return $this->getSection("//*[@id='author-info-group-authors']");
  }

  /**
   * @return string
   */
  public function getAuthorInfoContributions() {
    return $this->getSection("//*[@id='author-info-contributions']");
  }

  /**
   * @return string
   */
  public function getAuthorInfoEqualContrib() {
    return $this->getSection("//*[@id='author-info-equal-contrib']");
  }

  /**
   * @return string
   */
  public function getAuthorInfoOtherFootnotes() {
    return $this->getSection("//*[@id='author-info-other-footnotes']");
  }

  /**
   * @return string
   */
  public function getAuthorInfoCorrespondence() {
    return $this->getSection("//*[@id='author-info-correspondence']");
  }

  /**
   * @return string
   */
  public function getAuthorInfoAdditionalAddress() {
    return $this->getSection("//*[@id='author-info-additional-address']");
  }

  /**
   * @return string
   */
  public function getAuthorInfoCompetingInterest() {
    return $this->getSection("//*[@id='author-info-competing-interest']");
  }

  /**
   * @return string
   */
  public function getAuthorInfoFunding() {
    return $this->getSection("//*[@id='author-info-funding']");
  }

  /**
   * @return string
   */
  public function getArticleInfoIdentification() {
    return $this->getSection("//*[@id='article-info-identification']");
  }

  /**
   * @return string
   */
  public function getArticleInfoHistory() {
    return $this->getSection("//*[@id='article-info-history']");
  }

  /**
   * @return string
   */
  public function getArticleInfoEthics() {
    return $this->getSection("//*[@id='article-info-ethics']");
  }

  /**
   * @return string
   */
  public function getArticleInfoReviewingEditor() {
    return $this->getSection("//*[@id='article-info-reviewing-editor']");
  }

  /**
   * @return string
   */
  public function getArticleInfoLicense() {
    return $this->getSection("//*[@id='article-info-license']");
  }

  /**
   * @return string
   */
  public function getDatasets() {
    return $this->getSection("//*[@id='datasets']");
  }

  /**
   * @return string
   */
  public function getMetatags() {
    return $this->getSection("//*[@id='metatags']");
  }

  /**
   * @param string $xpath_query
   * @param int $limit
   * @return string
   */
  public function getSection($xpath_query, $limit = 0) {
    libxml_use_internal_errors(TRUE);
    $actual = new DOMDocument();
    $actual->loadHTML($this->getHtml());
    $xpath = new DOMXPath($actual);
    $elements = $xpath->query($xpath_query);
    $output = [];
    if (!empty($elements) && $elements->length > 0) {
      $break = ($limit > 0) ? $limit : $elements->length;
      foreach ($elements as $i => $element) {
        if ($i >= $break) {
          break;
        }
        $output[] = $this->getInnerHtml($element);
      }
    }
    libxml_clear_errors();

    return $this->tidyHtml(implode("\n", $output));
  }

  /**
   * @param string $html
   * @return string mixed
   */
  public static function tidyHtml($html) {
    // Fix self-closing tags issue.
    $self_closing = [
      'area',
      'base',
      'br',
      'col',
      'command',
      'embed',
      'hr',
      'img',
      'input',
      'keygen',
      'link',
      'meta',
      'param',
      'source',
      'track',
      'wbr',
    ];

    $from = [
      '/<(?!' . implode('|', $self_closing) . ')([a-z]+)\/>/',
      '/<(?!' . implode('|', $self_closing) . ')([a-z]+)( [^\/>]+)\/>/',
      // Make sure metatags appear on a new line.
      '/(>)(<meta )/',
      // @todo - elife - nlisgo - some spacing introduced in POA xml is causing display issues. This seems to address it. But there may be better approaches.
      '/\n\t+/',
    ];
    $to = [
      '<$1></$1>',
      '<$1$2></$1>',
      "$1\n$2",
      '',
    ];
    return preg_replace($from, $to, $html);
  }

  /**
   * @param string $method
   * @param string|null $argument
   * @param string $xpath_query
   * @return string
   */
  public function getHtmlXpath($method, $argument = NULL, $xpath_query = '')
  {
    if (empty($argument)) {
      $argument = [];
    }
    elseif (is_string($argument)) {
      $argument = [$argument];
    }

    $output = call_user_func_array([$this, $method], $argument);

    if (!empty($output) && !empty($xpath_query)) {
      libxml_use_internal_errors(TRUE);
      $dom = new DOMDocument();
      $dom->loadHTML('<meta http-equiv="content-type" content="text/html; charset=utf-8"><expected>' . $output . '</expected>');
      $xpath = new DOMXPath($dom);
      $nodeList = $xpath->query('//expected' . $xpath_query);
      if ($nodeList->length > 0) {
        $output = $this->getInnerHtml($nodeList->item(0));
      }
      else {
        $output = '';
      }
      libxml_clear_errors();
    }

    return $output;
  }

  /**
   * @param string $doi
   * @return string
   */
  public function getDoi($doi) {
    return $this->getSection("//*[@data-doi='" . $doi . "'][not(ancestor::*[@id='main-text'])]", 1);
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
   * @param int $author_pos
   * @return string
   */
  public function getAuthorAffiliation($author_pos) {
    return $this->getSection("//*[@id='author-affiliation-details-" . $author_pos . "']");
  }

  /**
   * @param string $aff_id
   * @return string
   */
  public function getAffiliation($aff_id) {
    return $this->getSection("(//*[@id='" . $aff_id . "'])", 1);
  }

  /**
   * @param string $bib_id
   * @return string
   */
  public function getReference($bib_id) {
    return $this->getSection("(//*[@id='" . $bib_id . "'])", 1);
  }

  /**
   * @param string $app_id
   * @return string
   */
  public function getAppendix($app_id) {
    return $this->getSection("(//*[@id='" . $app_id . "'])", 1);
  }

  /**
   * @param string $equ_id
   * @return string
   */
  public function getEquation($equ_id) {
    return $this->getSection("//*[@id='" . $equ_id . "']", 1);
  }

  /**
   * @param string $dataset_id
   * @return string
   */
  public function getDataset($dataset_id) {
    return $this->getSection("//*[@id='" . $dataset_id . "']");
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
