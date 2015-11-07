<?php

namespace eLifeIngestXsl;

use eLifeIngestXsl\ConvertXML\XMLString;
use Symfony\Component\Process\Process;
use \Exception;

final class ConvertXMLToEif extends ConvertXMLToCitationFormat {
  private $version = 1;
  private $filename = NULL;
  private $updated_date = NULL;
  private $validator = '';

  /**
   * @param XMLString $xml
   * @param int $version
   */
  public function __construct(XMLString $xml) {
    parent::__construct($xml, 'eif');
    $realpath = realpath(dirname(__FILE__));
    // @todo - elife - nlisgo - there has to be a better way to reference validator.js
    $this->validator = '`which node` ' . $realpath . '/../../../bower_components/elife-eif-schema/validator.js';
  }

  public function setVersion($version) {
    $this->version = $version;
  }

  public function setFilename($filename) {
    $this->filename = $filename;
    if ($found = preg_match('/\-v(?P<version>[0-9]+)/', $filename, $match)) {
      $this->setVersion($match['version']);
    }
  }

  public function setUpdatedDate($updated_date, $format_string = TRUE) {
    if ($format_string) {
      $updated_date = strtotime($updated_date);
    }
    $this->updated_date = date('Y-m-d H:i:s', $updated_date);
  }

  public function getOutput($filename = NULL) {
    if ($filename) {
      $this->setFilename($filename);
    }
    $output = parent::getOutput();

    $json = json_decode($output);
    if (!is_null($this->updated_date)) {
      $json->update = $this->updated_date;
    }
    $json->path .= 'v' . $this->version;
    $json->version = (string) $this->version;
    $json->{'article-version-id'} = ltrim($json->{'elocation-id'}, 'e') . '.' . $this->version;
    if (isset($json->fragments)) {
      $json->fragments = $this->addFragmentPaths($json->fragments, $json->path);
    }

    $output = json_encode($json, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);

    if ($this->validate($output)) {
      return $output;
    }
  }

  public function validate($json) {
    $process = new Process($this->validator, NULL, NULL, $json);
    $process->setTimeout(2);
    $process->run();

    if ($process->isSuccessful()) {
      return TRUE;
    }
    else {
      throw new Exception(
        $process->getOutput()
      );
    }
  }

  protected function addFragmentPaths($fragments, $base_path, $level = 0) {
    $totals = [];
    foreach ($fragments as $k => $fragment) {
      $totals += [
        $fragment->type => 0,
      ];
      $totals[$fragment->type]++;

      if ($fragment->type == 'abstract' && !isset($fragment->subtype)) {
        $slug = $fragment->type;
      }
      elseif ($fragment->type == 'fig') {
        $slug = (($level == 0) ? 'figure' : 'figure-supp') . $totals[$fragment->type];
      }
      elseif ($fragment->type == 'table-wrap') {
        $slug = 'table' . $totals[$fragment->type];
      }
      elseif ($fragment->type == 'boxed-text') {
        $slug = 'box' . $totals[$fragment->type];
      }
      elseif ($fragment->type == 'supplementary-material') {
        $slug = 'supp-material' . $totals[$fragment->type];
      }
      elseif ($fragment->type == 'sub-article' && $fragment->subtype == 'article-commentary') {
        $slug = 'decision';
      }
      elseif ($fragment->type == 'sub-article' && $fragment->subtype == 'reply') {
        $slug = 'response';
      }
      else {
        $slug = $fragment->type . $totals[$fragment->type];
      }

      // @todo - elife - nlisgo - Remove subtype until it is supported.
      unset($fragment->subtype);

      $fragments[$k]->path = $base_path . '/' . $slug;
      if (isset($fragment->fragments)) {
        $fragment->fragments = $this->addFragmentPaths($fragment->fragments, $fragments[$k]->path, $level + 1);
      }
    }
    return $fragments;
  }
}
