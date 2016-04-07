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
  $xmlstring = \eLifeIngestXsl\ConvertXML\XMLString::fromString($xml);

  $convertxml = new \eLifeIngestXsl\ConvertXMLToHtml($xmlstring);

  $sections = [
    '//h1[contains(concat(" ", normalize-space(@class), " "), " page-title ")]' => $convertxml->getTitle(),
    '//*[@id="abstract"]/div' => $convertxml->getAbstract(),
    '//*[@id="digest"]/div' => $convertxml->getDigest(),
    '//*[@id="main-text"]/div' => $convertxml->getMainText(),
    '//*[@id="references"]/div' => $convertxml->getReferences(),
    '//*[@id="acknowledgements"]/div' => $convertxml->getAcknowledgements(),
    '//*[@id="decision-letter"]/div' => $convertxml->getDecisionLetter(),
    '//*[@id="author-response"]/div' => $convertxml->getAuthorResponse(),
  ];

  $excludes = [
    '//*[contains(concat(" ", normalize-space(@class), " "), " author-list-full ")]',
    '//*[contains(concat(" ", normalize-space(@class), " "), " elife-article-indicators ")]',
    '//*[contains(concat(" ", normalize-space(@class), " "), " panel-region-content-top ")]',
    '//*[contains(concat(" ", normalize-space(@class), " "), " pane-panels-ajax-tab-tabs ")]',
    '//*[contains(concat(" ", normalize-space(@class), " "), " author-list ")]',
    '//*[contains(concat(" ", normalize-space(@class), " "), " elife-institutions-list ")]',
    '//*[contains(concat(" ", normalize-space(@class), " "), " pane-elife-article-doi ")]',
    '//*[contains(concat(" ", normalize-space(@class), " "), " pane-elife-article-toolbox ")]',
    '//*[contains(concat(" ", normalize-space(@class), " "), " pane-elife-article-jumpto ")]',
    '//*[contains(concat(" ", normalize-space(@class), " "), " pane-elife-article-categories ")]',
  ];

  $dom_template = new DOMDocument();
  $dom_template->loadHTMLFile(__DIR__ . '/elife-research-article.tpl.html');

  $html_prefix = '<meta http-equiv="content-type" content="text/html; charset=utf-8">';
  $wrapper = 'wrapper';
  foreach ($sections as $xpath_query => $html) {
    if (!empty($html)) {
      $xpath = new DOMXpath($dom_template);
      $elements = $xpath->query($xpath_query);
      if ($elements->length) {
        $replace_node = $elements->item(0);
        $replace_dom = new DOMDocument();
        $replace_dom->loadHTML($html_prefix . '<' . $wrapper . '>' . $html . '</' . $wrapper . '>');
        $children = $replace_node->childNodes;
        while ($children->length > 0) {
          $replace_node->removeChild($children->item(0));
        }
        $children = $replace_dom->getElementsByTagName($wrapper)->item(0)->childNodes;
        foreach ($replace_dom->getElementsByTagName($wrapper)->item(0)->childNodes as $child) {
          $replace_node->appendChild($dom_template->importNode($child, TRUE));
        }
      }
    }
    else {
      $excludes[] = $xpath_query;
    }
  }

  foreach ($excludes as $xpath_query) {
    $xpath = new DOMXpath($dom_template);
    $elements = $xpath->query($xpath_query);
    if ($elements->length) {
      $exclude_node = $elements->item(0);
      $exclude_node->parentNode->removeChild($exclude_node);
    }
  }

  $xpath = new DOMXpath($dom_template);
  $elements = $xpath->query('//*[contains(concat(" ", normalize-space(@class), " "), " elife-article-layout ")]');
  if ($elements->length) {
    $class = $elements->item(0)->getAttribute('class');
    $class = preg_replace('/(\s*)elife\-article\-layout(\s*)/', '$1$2', $class);
    $class = explode(' ', $class);
    $elements->item(0)->setAttribute('class', implode(' ', $class));
  }

  echo $dom_template->saveHTML();
}
