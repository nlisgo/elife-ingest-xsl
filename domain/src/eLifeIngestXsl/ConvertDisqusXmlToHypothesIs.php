<?php

namespace eLifeIngestXsl;

use eLifeIngestXsl\ConvertXML\XMLString;
use eLifeIngestXsl\ConvertXML\XSLString;
use InvalidArgumentException;
use League\CommonMark\DocParser;
use League\CommonMark\Environment;
use League\CommonMark\HtmlRenderer;
use League\HTMLToMarkdown\HtmlConverter;
use Westsworld\TimeAgo;

final class ConvertDisqusXmlToHypothesIs extends ConvertXML {
  /**
   * @var int
   */
  private $json_options = 0; // 192;

  /**
   * @var string
   */
  private $creator = 'acct:disqus-import@test.elifesciences.org';

  /**
   * @var array
   */
  private $disqus = [];

  /**
   * @param XMLString $xml
   *
   * @throws InvalidArgumentException
   */
  public function __construct(XMLString $xml) {
    // Strip out stuff that's breaking but not necessary and fix url's
    $xml = XMLString::fromString(preg_replace(['~<disqus[^>]+>~', '~ dsq:id=~', '~https?://(elife\.|prod\.)?elifesciences\.org/~', '~(https://elifesciences\.org)/content/[0-9]+/e([0-9]{5})~'], ['<disqus>', ' id=', 'https://elifesciences.org/', '$1/articles/$2'], $xml->getValue()));
    $xsl = XSLString::fromString(file_get_contents(dirname(__FILE__) . '/../../../lib/xsl/disqus-to-hypothes-is.xsl'));
    parent::__construct($xml, $xsl);
  }

  public function getOutput() {
    $json = json_decode(parent::getOutput());
    foreach ($json as $k => $item) {
      if (!empty($this->creator)) {
        $item->creator = $this->creator;
      }
      // $markdown = $this->htmlToMarkdown(sprintf('<p><em>Legacy comment by %s</em></p>', $item->name) . $item->body);
      $markdown = $this->htmlToMarkdown($item->body);
      $markdown = $this->convertMediaLinks($markdown);
      $item->body = [
        [
          'type' => 'TextualBody',
          'value' => $markdown,
          'format' => 'text/markdown',
        ],
      ];
      // unset($item->name);
      $json[$k] = $item;
    }

    return json_encode($json, $this->json_options);
  }

  public function convertMediaLinks($markdown) {
    $markdown = preg_replace('~\[(http[^\]]+)\.\.\.\]\((\1[^\)]+)\)~', '$2', $markdown);
    return $markdown;
  }

  public function htmlToMarkdown($html) {
    $converter = new HtmlConverter();
    return $converter->convert($html);
  }

  public function getTree() {
    $json = json_decode($this->getOutput());
    $children = [];
    $tree = [];

    foreach ($json as $item)  {
      $this->disqus[$item->id] = $item;
      $children[$item->target][$item->id] = $item;
      if (strpos($item->target, 'elife-legacy:') === FALSE) {
        $tree[$item->target] = [];
      }
    }

    $find_children = function ($id) use ($children, &$find_children) {
      $found = [];
      if (isset($children[$id])) {
        foreach (array_reverse(array_keys($children[$id])) as $child_id) {
          $found[$child_id] = $find_children($child_id);
        }
      }
      return $found;
    };

    foreach (array_keys($tree) as $target) {
      if (count($children[$target]) > 0) {
        foreach (array_reverse(array_keys($children[$target])) as $id) {
          $tree[$target][$id] = $find_children($id);
        }
      }
      else {
        unset($tree[$target]);
      }
    }

    ksort($tree);

    return json_encode($tree, $this->json_options);
  }

  public function presentOutput() {
    $tree = json_decode($this->getTree());
    $output = '';
    foreach ($tree as $target => $items) {
      $output .= sprintf('<h2><a href="%s">%s</a></h2>', $target, $target) . PHP_EOL;
      $output .= $this->prepareBranch($items);
    }
    $title = 'All disqus comments for eLife';
    return sprintf('<html><head><title>%s</title></head><body><h1>%s</h1>%s</body></html>', $title, $title, $output);
  }

  public function prepareBranch($branch) {
    $output = '';
    if (!empty($branch)) {
      $environment = Environment::createCommonMarkEnvironment();
      $parser = new DocParser($environment);
      $htmlRenderer = new HtmlRenderer($environment);
      $timeago = new TimeAgo();
      $output .= '<ul>' . PHP_EOL;
        foreach ($branch as $id => $children) {
          $item = $this->disqus[$id];
          $document = $parser->parse($item->body[0]->value);
          $output .= sprintf("<li><h3>%s</h3>\n%s</li>", $timeago->inWords($item->created), $htmlRenderer->renderBlock($document) . $this->prepareBranch($children)) . PHP_EOL;
        }
      $output .= '</ul>' . PHP_EOL;
    }
    return $output;
  }
}
