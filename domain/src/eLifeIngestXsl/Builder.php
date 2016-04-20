<?php

namespace eLifeIngestXsl;

class Builder extends \PatternLab\Builder {
  private $p;
  private $data;

  public function __construct($config, $p, $json) {
    parent::__construct($config);
    $this->p = $p;
    $this->data = json_decode(json_encode($json), TRUE);
    $this->noCacheBuster = FALSE;
    $this->gatherData();
    $this->gatherPatternInfo();
    $this->loadMustachePatternLoaderInstance();
    $this->loadMustacheVanillaInstance();
  }

  public function renderPattern($r, $p = NULL) {
    $p = is_null($p) ? $this->p : $p;
    if ($p == $this->p && isset($this->d['patternSpecific']) && array_key_exists($p, $this->d['patternSpecific'])) {
      $this->d['patternSpecific'][$p]['data'] = $this->data;
    }
    return parent::renderPattern($r, $p);
  }
}
