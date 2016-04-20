<?php

namespace eLifeIngestXsl;

use eLifeIngestXsl\ConvertXML\XMLString;
use PatternLab\Configurer;

final class ConvertXMLToPlReferences extends ConvertXMLToCitationFormat {
  private $filename = NULL;
  private $json;
  private $pl_assets_path = NULL;

  /**
   * @param XMLString $xml
   */
  public function __construct(XMLString $xml) {
    parent::__construct($xml, 'pl-references');
  }

  public function prepareAssets($dest = NULL, $assets_path = NULL) {
    $this->pl_assets_path = trim($assets_path, " /");
    if (!empty($this->pl_assets_path)) {
      $this->pl_assets_path .= '/';
    }

    // Copy over the pattern-library source assets.
    $source = dirname(__FILE__) . '/../../../vendor/elife/pattern-library/source/assets';
    $dest = (is_null($dest) ? dirname(__FILE__) . '/../../..' : rtrim($dest, '/')) . '/assets';
    if (!file_exists($dest)) {
      mkdir($dest, 0755);

      foreach (
        $iterator = new \RecursiveIteratorIterator(
          new \RecursiveDirectoryIterator($source, \RecursiveDirectoryIterator::SKIP_DOTS),
          \RecursiveIteratorIterator::SELF_FIRST) as $item
      ) {
        if ($item->isDir()) {
          mkdir($dest . DIRECTORY_SEPARATOR . $iterator->getSubPathName());
        } else {
          copy($item, $dest . DIRECTORY_SEPARATOR . $iterator->getSubPathName());
        }
      }
    }
  }

  public function setFilename($filename) {
    $this->filename = $filename;
  }

  public function getOutputWithAssets($assets_dest, $assets_path, $filename = NULL) {
    $this->prepareAssets($assets_dest, $assets_path);
    return $this->getOutput($filename);
  }

  public function getJson($return_object = FALSE) {
    $output = parent::getOutput();

    $json = json_decode($output);

    if (isset($json->references)) {
      $abstracts = [];
      // Add CrossRef abstract link if doi is available.
      foreach ($json->references as $reference) {
        if (isset($reference->titleLink)) {
          if (preg_match('/^http:\/\/dx\.doi\.org\/(?P<doi>10\.[0-9]{4,}[^\s\"\/<>]*\/[^\s\"]+)/', $reference->titleLink, $match)) {
            $abstracts[$match['doi']] = [
              'CrossRef' => $reference->titleLink,
            ];
          }
        }
      }
      // If doi is available then query PubMed for a PubMed Id.
      if (!empty($abstracts)) {
        $request_uri = 'http://www.ncbi.nlm.nih.gov/pmc/utils/idconv/v1.0/?format=json&ids=' . implode(',', array_keys($abstracts));
        if ($result = @file_get_contents($request_uri)) {
          $data = json_decode($result);
          if (!empty($data->records)) {
            foreach ($data->records as $record) {
              if (!empty($record->pmid)) {
                $abstracts[$record->doi]['PubMed'] = 'http://www.ncbi.nlm.nih.gov/pubmed/' . $record->pmid;
              }
            }
          }
        }
      }

      $references = [];
      // Amend references json with the abstract links.
      foreach ($json->references as $reference) {
        if (isset($reference->titleLink)) {
          if (preg_match('/^http:\/\/dx\.doi\.org\/(?P<doi>10\.[0-9]{4,}[^\s\"\/<>]*\/[^\s\"]+)/', $reference->titleLink, $match)) {
            foreach ($abstracts[$match['doi']] as $name => $link) {
              $abstract = new \stdClass();
              $abstract->name = $name;
              $abstract->link = $link;
              $reference->abstracts[] = $abstract;
            }
          }
        }
        foreach (['authors', 'abstracts'] as $array) {
          if (!empty($reference->{$array})) {
            $reference->{'has' . ucfirst($array)} = TRUE;
          }
        }
        $references[] = $reference;
      }
      $json->references = $references;
    }

    $this->json = json_encode($json, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);
    return ($return_object) ? $json : $this->json;
  }

  public function getOutput($filename = NULL) {
    if ($filename) {
      $this->setFilename($filename);
    }

    $json = $this->getJson(TRUE);

    $configurer = new Configurer;

    ob_start();
    $config = $configurer->getConfig();
    ob_end_clean();

    $p = 'molecules-reference-list';
    $builder = new Builder($config, $p, $json);
    list($raw_output, $raw_escape) = $builder->renderPattern('01-molecules/components/reference-list.mustache');

    if (!is_null($this->pl_assets_path)) {
      $pl_head_assets_tpl = file_get_contents(dirname(__FILE__) . '/../../../lib/tpl/pl_head_assets.tpl.html');
      $pl_head_assets = PHP_EOL . preg_replace('/\[ASSETS_PATH\]/', $this->pl_assets_path . 'assets/', $pl_head_assets_tpl) . PHP_EOL;
    }
    else {
      $pl_head_assets = '';
    }

    $output = implode(PHP_EOL, [
      '<!DOCTYPE html>',
      '<html lang="en">',
      '<head>',
      '<meta charset="UTF-8">',
      '<meta name="viewport" content="width=device-width" />',
    ]);
    $output .= $pl_head_assets;
    $output .= implode(PHP_EOL, [
      '</head>',
      '<body>',
    ]);
    $output .= $raw_output;
    $output .= implode(PHP_EOL, [
      '</body>',
      '</html>',
    ]);

    return  $output;
  }
}
