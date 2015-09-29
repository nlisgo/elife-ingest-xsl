<?php

namespace spec\eLifeIngestXsl;

use eLifeIngestXsl\ConvertXML\XMLString;
use PhpSpec\ObjectBehavior;
use Prophecy\Argument;

class ConvertXMLToCitationFormatSpec extends ObjectBehavior {
  private $xml;

  function it_is_initializable() {
    $this->shouldHaveType('eLifeIngestXsl\ConvertXML');
  }

  public function let() {
    $this->xml = XMLString::fromString(file_get_contents(dirname(__FILE__) . '/../../../tests/fixtures/jats/00288-vor.xml'));
    $this->beConstructedWith($this->xml);
  }

  public function it_must_have_an_output() {
    $this->getOutput()->shouldNotBeNull();
  }
}
