<?php

namespace spec\eLifeIngestXsl;

use eLifeIngestXsl\ConvertXML\XMLString;
use PhpSpec\ObjectBehavior;
use Prophecy\Argument;

final class ConvertXMLToBibtexSpec extends ObjectBehavior {
  private $xml;
  private $output;

  function it_is_initializable() {
    $this->shouldHaveType('eLifeIngestXsl\ConvertXMLToCitationFormat');
  }

  public function let() {
    $this->xml = XMLString::fromString(file_get_contents(dirname(__FILE__) . '/../../../tests/fixtures/jats/00288-vor.xml'));
    $this->output = file_get_contents(dirname(__FILE__) . '/../../../tests/fixtures/bib/00288-vor.bib');

    $this->beConstructedWith($this->xml);
  }

  public function it_must_have_an_output() {
    $this->getOutput()->shouldReturn($this->output);
  }
}
