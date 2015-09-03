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

        $compares = $this->compareSection('-abstract', "//*[@id='abstract']");

        foreach ($compares as $compare) {
            $this->assertEqualHtml($compare[0], $compare[1]);
        }
    }

    public function testJatsToHtmlDigest() {

        $compares = $this->compareSection('-digest', "//*[@id='elife-digest']");

        foreach ($compares as $compare) {
            $this->assertEqualHtml($compare[0], $compare[1]);
        }
    }

    /**
     * Prepare array of actual and expected results.
     */
    protected function compareSection($suffix, $xpath_query) {
        $expected = 'expected';
        $htmls = glob($this->html_folder . "*" . $suffix . ".html");
        $compares = [];

        foreach ($htmls as $html) {
            $file = str_replace($suffix, '', basename($html));
            $actualDom = new DomDocument();
            libxml_use_internal_errors(TRUE);
            $actualDom->loadHTMLFile($this->temp_folder . $file);
            libxml_clear_errors();
            $xpath = new DOMXPath($actualDom);
            $elements = $xpath->query($xpath_query);

            $expectedDom = new DomDocument();
            $html = file_get_contents($html);
            $expectedDom->loadXML('<' . $expected . '>' . $html . '</' . $expected . '>');

            $compares[] = [
                $this->getInnerHtml($expectedDom->getElementsByTagName($expected)->item(0)),
                $this->getInnerHtml($elements->item(0)),
            ];
        }

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
