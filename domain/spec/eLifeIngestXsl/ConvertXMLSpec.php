<?php

namespace spec\eLifeIngestXsl;

use eLifeIngestXsl\ConvertXML\XMLString;
use eLifeIngestXsl\ConvertXML\XSLString;
use PhpSpec\Exception\Example\FailureException;
use PhpSpec\ObjectBehavior;
use Prophecy\Argument;

final class ConvertXMLSpec extends ObjectBehavior {
  private $xml;
  private $xsl;
  private $output;

  public function let() {
    $this->xml = XMLString::fromString('<?xml version="1.0"?><hello-world><greeter>An XSLT Programmer</greeter><greeting>Hello, World!</greeting></hello-world>');
    $this->xsl = XSLString::fromString('<?xml version="1.0"?><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"><xsl:template match="/hello-world"><HTML><HEAD><TITLE></TITLE></HEAD><BODY><H1><xsl:value-of select="greeting"/></H1><xsl:apply-templates select="greeter"/></BODY></HTML></xsl:template><xsl:template match="greeter"><DIV>from <I><xsl:value-of select="."/></I></DIV></xsl:template></xsl:stylesheet>');
    $this->output = '<HTML><HEAD><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><TITLE></TITLE></HEAD><BODY><H1>Hello, World!</H1><DIV>from <I>An XSLT Programmer</I></DIV></BODY></HTML>';
    $this->beConstructedWith($this->xml, $this->xsl);
  }

  public function it_must_have_an_xml_string() {
    $this->getXML()->shouldBeLike($this->xml);
  }

  public function it_must_have_an_xsl_template() {
    $this->getXSL()->shouldBeLike($this->xsl);
  }

  public function it_must_have_an_output() {
    $this->getOutput()->shouldNotBeNull();
    $this->getOutput()->shouldBeString();
    $this->getOutput()->shouldHaveXML($this->output);
  }

  public function getMatchers()
  {
    return [
      'haveXML' => function ($actual, $expected) {
        // Remove white space between tags.
        $from = ['/\>[^\S ]+/s', '/[^\S ]+\</s', '/(\s)+/s', '/> </s'];
        $to = ['>', '<', '\\1', '><'];
        $clean_actual = preg_replace($from, $to, $actual);
        $clean_expected = preg_replace($from, $to, $expected);
        if ($clean_actual != $clean_expected) {
          throw new FailureException(sprintf('Expected "%s" but found "%s".', $clean_expected, $clean_actual));
        }
        return TRUE;
      },
    ];
  }
}
