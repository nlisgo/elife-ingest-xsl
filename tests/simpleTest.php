<?php


class simpleTest extends PHPUnit_Framework_TestCase
{
    private $temp_folder = '';
    private $bib_folder = '';
    private $ris_folder = '';

    public function setUp()
    {
        $this->temp_folder = 'tests/tmp/';
        $this->bib_folder = 'tests/fixtures/bib/';
        $this->ris_folder = 'tests/fixtures/ris/';
        $this->html_folder = 'tests/fixtures/html/';
    }

    public function testJatsToBibtex()
    {
        $cits = glob($this->bib_folder . "*.bib");
        $compares = [];

        foreach ($cits as $cit) {
            $file = basename($cit);
            $compares[] = [
                file_get_contents($cit),
                file_get_contents($this->temp_folder . $file),
            ];
        }

        foreach ($compares as $compare) {
            $this->assertEquals($compare[0], $compare[1]);
        }
    }

    public function testJatsToRis()
    {
        $cits = glob($this->ris_folder . "*.ris");
        $compares = [];

        foreach ($cits as $cit) {
            $file = basename($cit);
            $compares[] = [
                file_get_contents($cit),
                file_get_contents($this->temp_folder . $file),
            ];
        }

        foreach ($compares as $compare) {
            $this->assertEquals($compare[0], $compare[1]);
        }
    }

    public function testJatsToHtmlAbstract() {
        $compares = $this->compareHtmlSection('-abstract', "//*[@id='abstract']");

        foreach ($compares as $compare) {
            $this->assertEqualHtml($compare[0], $compare[1]);
        }
    }

    public function testJatsToHtmlDigest() {
        $compares = $this->compareHtmlSection('-digest', "//*[@id='elife-digest']");

        foreach ($compares as $compare) {
            $this->assertEqualHtml($compare[0], $compare[1]);
        }
    }

    public function testJatsToHtmlDoiFig() {
        $compares = $this->compareDoiHtmlSection('-doi-fig');

        foreach ($compares as $compare) {
            $this->assertEqualHtml($compare[0], $compare[1]);
        }
    }

    public function testJatsToHtmlDoiTableWrap() {
        $compares = $this->compareDoiHtmlSection('-doi-table-wrap');

        foreach ($compares as $compare) {
            $this->assertEqualHtml($compare[0], $compare[1]);
        }
    }

    public function testJatsToHtmlDoiBoxedText() {
        $compares = $this->compareDoiHtmlSection('-doi-boxed-text');

        foreach ($compares as $compare) {
            $this->assertEqualHtml($compare[0], $compare[1]);
        }
    }

    public function testJatsToHtmlDoiMedia() {
        $compares = $this->compareDoiHtmlSection('-doi-media');

        foreach ($compares as $compare) {
            $this->assertEqualHtml($compare[0], $compare[1]);
        }
    }

    /**
     * Prepare array of actual and expected results for DOI HTML.
     */
    protected function compareDoiHtmlSection($suffix) {
        $htmls = glob($this->html_folder . '*' . $suffix . '.html');
        $sections = [];

        foreach ($htmls as $html) {
            $found = preg_match('/^(?P<filename>[0-9]{5}\-[^\-]+)\-(?P<doi>[^\-]+)' . $suffix . '\.html$/', basename($html), $matches);
            if ($found) {
                $sections[] = [
                    'suffix' => '-' . $matches['doi'] . $suffix,
                    'query' => "//*[@data-doi='10.7554/" . $matches['doi'] . "']",
                ];
            }
        }
        $compares = [];

        foreach ($sections as $section) {
            $compares = array_merge($compares, $this->compareHtmlSection($section['suffix'], $section['query']));
        }

        return $compares;
    }

    /**
     * Prepare array of actual and expected results.
     */
    protected function compareHtmlSection($suffix, $xpath_query) {
        $html_prefix = '<meta http-equiv="content-type" content="text/html; charset=utf-8">';
        $expected = 'expected';
        $htmls = glob($this->html_folder . "*" . $suffix . ".html");
        $compares = [];

        libxml_use_internal_errors(TRUE);
        foreach ($htmls as $html) {
            $file = str_replace($suffix, '', basename($html));
            $actualDom = new DOMDocument();
            $actual_html = file_get_contents(__DIR__ . '/tmp/' . $file);
            $actualDom->loadHTML($html_prefix . $actual_html);
            $xpath = new DOMXPath($actualDom);
            $elements = $xpath->query($xpath_query);

            $expectedDom = new DOMDocument();
            $expected_html = file_get_contents($html);
            $expectedDom->loadHTML($html_prefix . '<' . $expected . '>' . $expected_html . '</' . $expected . '>');

            $compares[] = [
                $this->getInnerHtml($expectedDom->getElementsByTagName($expected)->item(0)),
                $this->getInnerHtml($elements->item(0)),
            ];
        }
        libxml_clear_errors();

        return $compares;
    }

    /**
     * Compare two HTML fragments.
     */
    protected function assertEqualHtml($expected, $actual)
    {
        $from = ['/\>[^\S ]+/s', '/[^\S ]+\</s', '/(\s)+/s', '/> </s'];
        $to = ['>', '<', '\\1', '><'];
        $this->assertEquals(
            preg_replace($from, $to, $expected),
            preg_replace($from, $to, $actual)
        );
    }

    /**
     * Get inner HTML.
     */
    function getInnerHtml($node) { 
        $innerHTML= ''; 
        $children = $node->childNodes; 
        foreach ($children as $child) { 
            $innerHTML .= $child->ownerDocument->saveXML($child); 
        }

        return trim($innerHTML);
    } 
}
