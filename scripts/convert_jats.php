#!/usr/bin/env php
<?php

if (is_file($autoload = getcwd() . '/vendor/autoload.php')) {
  require $autoload;
} elseif (is_file($autoload = getcwd() . '/../../autoload.php')) {
  require $autoload;
}

if (is_file($autoload = __DIR__ . '/../vendor/autoload.php')) {
  require($autoload);
} elseif (is_file($autoload = __DIR__ . '/../../../autoload.php')) {
  require($autoload);
} else {
  fwrite(STDERR,
    'You must set up the project dependencies, run the following commands:' . PHP_EOL .
    'curl -s http://getcomposer.org/installer | php' . PHP_EOL .
    'php composer.phar install' . PHP_EOL
  );
  exit(1);
}

$xml = '';

while (($buffer = fgets(STDIN)) !== FALSE) {
  $xml .= $buffer;
}

if (!empty($xml)) {

  $params = [];
  $types = [
    'bib',
    'ris',
    'html',
  ];

  while ($param = array_shift($_SERVER['argv'])) {
    switch ($param) {
      case '--type':
      case '-t':
        $type = array_shift($_SERVER['argv']);
        if (empty($type) || !in_array($type, $types)) {
          fwrite(STDERR,
            'Please declare a supported conversion type:' . PHP_EOL .
            '* ' . implode(PHP_EOL . '* ', $types) . PHP_EOL
          );
          exit(1);
        }
        $params['type'] = $type;
        break;
    }
  }

  $params += [
    'type' => 'html',
  ];

  $convertxml = '';
  $xmlstring = \eLifeIngestXsl\ConvertXML\XMLString::fromString($xml);

  switch ($params['type']) {
    case 'bib':
      $convertxml = new \eLifeIngestXsl\ConvertXMLToBibtex($xmlstring);
      break;
    case 'ris':
      $convertxml = new \eLifeIngestXsl\ConvertXMLToRis($xmlstring);
      break;
    default:
      $convertxml = new \eLifeIngestXsl\ConvertXMLToHtml($xmlstring);
  }

  echo $convertxml->getOutput();
}
