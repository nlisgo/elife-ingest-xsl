<?php

namespace spec\eLifeIngestXsl\ConvertXML;

use PhpSpec\ObjectBehavior;
use Prophecy\Argument;

final class XMLStringSpec extends ObjectBehavior {
  private $value;

  public function let() {
    $this->value = <<<XML
<?xml version="1.0"?>
<hello-world>
    <greeter>An XSLT Programmer</greeter>
    <greeting>Hello, World!</greeting>
</hello-world>
XML;

    $this->beConstructedThrough('fromString', [$this->value]);
  }

  public function it_is_an_xml_string() {
    $this->getValue()->shouldReturn($this->value);
  }
}
