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
    'eif',
    'pl-references',
    'bib',
    'ris',
    'html',
  ];
  $method = 'getOutput';
  $args = [];

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
      case '--method':
      case '-m':
        $method = array_shift($_SERVER['argv']);
        break;
      case '--args':
      case '-a':
        $args_string = array_shift($_SERVER['argv']);
        $args = explode('|', $args_string);
        break;
    }
  }

  $params += [
    'type' => 'html',
  ];

  $convertxml = '';
  $xmlstring = \eLifeIngestXsl\ConvertXML\XMLString::fromString($xml);

  switch ($params['type']) {
    case 'eif':
      $convertxml = new \eLifeIngestXsl\ConvertXMLToEif($xmlstring);
      break;
    case 'pl-references':
      $convertxml = new \eLifeIngestXsl\ConvertXMLToPlReferences($xmlstring);
      break;
    case 'bib':
      $convertxml = new \eLifeIngestXsl\ConvertXMLToBibtex($xmlstring);
      break;
    case 'ris':
      $convertxml = new \eLifeIngestXsl\ConvertXMLToRis($xmlstring);
      break;
    default:
      $convertxml = new \eLifeIngestXsl\ConvertXMLToHtml($xmlstring);
  }

  echo call_user_func_array([$convertxml, $method], $args);
}
