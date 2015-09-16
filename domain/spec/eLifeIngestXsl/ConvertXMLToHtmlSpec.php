<?php

namespace spec\eLifeIngestXsl;

use DOMDocument;
use eLifeIngestXsl\ConvertXML\XMLString;
use PhpSpec\Exception\Example\FailureException;
use PhpSpec\ObjectBehavior;
use Prophecy\Argument;

class ConvertXMLToHtmlSpec extends ObjectBehavior {
  public function it_is_initializable() {
    $this->defaultSetup();
    $this->shouldHaveType('eLifeIngestXsl\ConvertXML');
  }

  private function defaultSetup() {
    $xml = XMLString::fromString(file_get_contents(dirname(__FILE__) . '/../../../tests/fixtures/jats/00288-vor.xml'));
    $this->beConstructedWith($xml);
  }

  public function it_might_have_an_abstract() {
    $this->defaultSetup();
    $abstract = file_get_contents(dirname(__FILE__) . '/../../../tests/fixtures/html/00288-vor-abstract.html');
    $this->getAbstract()->shouldHaveHTML($abstract);
  }

  public function it_might_have_a_digest() {
    $this->defaultSetup();
    $digest = file_get_contents(dirname(__FILE__) . '/../../../tests/fixtures/html/00288-vor-digest.html');
    $this->getDigest()->shouldHaveHTML($digest);
  }

  public function it_might_not_have_a_digest() {
    $xml = XMLString::fromString(file_get_contents(dirname(__FILE__) . '/../../../tests/fixtures/jats/01911-poa.xml'));
    $this->beConstructedWith($xml);
    $this->getDigest()->shouldBeNull();
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
