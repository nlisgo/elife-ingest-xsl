<?php

namespace eLifeIngestXsl\ConvertXML;

final class XMLString {
  /**
   * @var string
   */
  private $value;

  /**
   * @param string $value
   */
  private function __construct($value) {
    $value = is_string($value) ? trim($value) : $value;

    $this->value = $value;
  }

  /**
   * @param string $value
   *
   * @return XMLString
   */
  public static function fromString($value)
  {
    return new self($value);
  }

  /**
   * @return string
   */
  public function getValue()
  {
    return $this->value;
  }

  /**
   * @return string
   */
  public function __toString()
  {
    return $this->getValue();
  }
}
