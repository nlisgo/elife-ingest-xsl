<?php

namespace spec\eLifeIngestXsl;

use DOMDocument;
use eLifeIngestXsl\ConvertXML\XMLString;
use PhpSpec\Exception\Example\FailureException;
use PhpSpec\ObjectBehavior;
use Prophecy\Argument;

class ConvertXMLToHtmlSpec extends ObjectBehavior {
  private function setupXML($filename = '00288-vor') {
    $xml = XMLString::fromString(file_get_contents(dirname(__FILE__) . '/../../../tests/fixtures/jats/' . $filename . '.xml'));
    $this->beConstructedWith($xml);
  }

  public function it_is_initializable() {
    $this->setupXML();
    $this->shouldHaveType('eLifeIngestXsl\ConvertXML');
  }

  public function it_might_have_an_abstract() {
    $this->setupXML();
    $abstract = file_get_contents(dirname(__FILE__) . '/../../../tests/fixtures/html/00288-vor-section-abstract.html');
    $this->getAbstract()->shouldHaveHTML($abstract);
  }

  public function it_might_have_a_digest() {
    $this->setupXML();
    $digest = file_get_contents(dirname(__FILE__) . '/../../../tests/fixtures/html/00288-vor-section-digest.html');
    $this->getDigest()->shouldHaveHTML($digest);
  }

  public function it_might_not_have_a_digest() {
    $this->setupXML('01911-poa');
    $this->getDigest()->shouldEqual('');
  }

  public function it_might_have_a_doi_section() {
    $this->setupXML();
    $abstract = file_get_contents(dirname(__FILE__) . '/../../../tests/fixtures/html/00288-vor-eLife.00288.001-doi-abstract.html');
    $this->getDoi('10.7554/eLife.00288.001')->shouldHaveHTML($abstract);

    $this->getDoi('10.7554/eLife.00288.043')->shouldNotEqual('');
  }

  public function it_might_not_have_a_doi_section() {
    $this->setupXML();
    $this->getDoi('10.7554/eLife.00288.044')->shouldEqual('');
    $this->getDoi('10.7554/eLife.00288.099')->shouldEqual('');
  }

  public function it_might_have_a_references_section() {
    $this->setupXML();
    $this->getReferences()->shouldNotEqual('');
  }

  public function it_might_not_have_a_references_section() {
    $this->setupXML('01911-poa');
    $this->getReferences()->shouldEqual('');
  }

  public  function it_might_have_an_acknowledgements_section() {
    $this->setupXML();
    $this->getAcknowledgements()->shouldNotEqual('');
  }

  public  function it_might_not_have_an_acknowledgements_section() {
    $this->setupXML('01911-poa');
    $this->getAcknowledgements()->shouldEqual('');
  }

  public  function it_might_have_a_main_text_section() {
    $this->setupXML();
    $this->getMainText()->shouldNotEqual('');
  }

  public  function it_might_not_have_a_main_text_section() {
    $this->setupXML('01911-poa');
    $this->getMainText()->shouldEqual('');
  }

  public  function it_might_have_a_decision_letter() {
    $this->setupXML();
    $this->getDecisionLetter()->shouldNotEqual('');
  }

  public  function it_might_not_have_a_decision_letter() {
    $this->setupXML('01911-poa');
    $this->getDecisionLetter()->shouldEqual('');
  }

  public  function it_might_have_a_author_response() {
    $this->setupXML();
    $this->getAuthorResponse()->shouldNotEqual('');
  }

  public  function it_might_not_have_a_author_response() {
    $this->setupXML('01911-poa');
    $this->getAuthorResponse()->shouldEqual('');
  }

  public  function it_might_have_a_datasets_section() {
    $this->setupXML('03318-vor');
    $this->getDatasets()->shouldNotEqual('');
  }

  public  function it_might_not_have_a_datasets_section() {
    $this->setupXML();
    $this->getDatasets()->shouldEqual('');
  }

  public function getMatchers() {
    return [
      'haveHTML' => function ($actual, $expected) {
        $html_prefix = '<meta http-equiv="content-type" content="text/html; charset=utf-8">';
        $wrapper = 'wrapper';
        libxml_use_internal_errors(TRUE);
        $actualDom = new DOMDocument();
        $actualDom->loadHTML($html_prefix . '<' . $wrapper . '>' . $actual . '</' . $wrapper . '>');

        $expectedDom = new DOMDocument();
        $expectedDom->loadHTML($html_prefix . '<' . $wrapper . '>' . $expected . '</' . $wrapper . '>');

        // Remove white space between tags.
        $from = ['/\>[^\S ]+/s', '/[^\S ]+\</s', '/(\s)+/s', '/> </s'];
        $to = ['>', '<', '\\1', '><'];
        $clean_actual = preg_replace($from, $to, $this->getInnerHtml($actualDom->getElementsByTagName($wrapper)->item(0)));
        $clean_expected = preg_replace($from, $to, $this->getInnerHtml($expectedDom->getElementsByTagName($wrapper)->item(0)));

        if ($clean_actual != $clean_expected) {
          throw new FailureException(sprintf('Expected "%s" but found "%s".', $clean_expected, $clean_actual));
        }
        return TRUE;
      },
    ];
  }

  /**
   * Get inner HTML.
   */
  function getInnerHtml($node) {
    $innerHTML = '';
    $children = $node->childNodes;
    foreach ($children as $child) {
      $innerHTML .= $child->ownerDocument->saveXML($child);
    }

    return trim($innerHTML);
  }
}
