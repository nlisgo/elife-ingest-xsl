<?php

use eLifeIngestXsl\ConvertXML\XMLString;
use eLifeIngestXsl\ConvertXMLToBibtex;
use eLifeIngestXsl\ConvertXMLToCitationFormat;
use eLifeIngestXsl\ConvertXMLToHtml;
use eLifeIngestXsl\ConvertXMLToRis;

class simpleTest extends PHPUnit_Framework_TestCase
{
    private $jats_folder = '';
    private $bib_folder = '';
    private $ris_folder = '';
    private $html_folder = '';
    private $xpath_folder = '';

    public function setUp()
    {
        $this->setFolders();
    }

    protected function setFolders() {
        if (empty($this->jats_folder)) {
            $realpath = realpath(dirname(__FILE__));
            $this->jats_folder = $realpath . '/fixtures/jats/';
            $this->bib_folder = $realpath . '/fixtures/bib/';
            $this->ris_folder = $realpath . '/fixtures/ris/';
            $this->html_folder = $realpath . '/fixtures/html/';
            $this->xpath_folder = $realpath . '/fixtures/xpath/';
        }
    }

    /**
     * @dataProvider jatsToBibtexProvider
     */
    public function testJatsToBibtex($expected, $actual) {
        $this->assertEquals($expected, $actual);
    }

    public function jatsToBibtexProvider() {
        return $this->jatsToCitationProvider('bib');
    }

    /**
     * @dataProvider jatsToRisProvider
     */
    public function testJatsToRis($expected, $actual) {
        $this->assertEquals($expected, $actual);
    }

    public function jatsToRisProvider() {
        return $this->jatsToCitationProvider('ris');
    }

    protected function jatsToCitationProvider($ext) {
        $compares = [];
        $this->setFolders();
        $folder = $this->{$ext . '_folder'};
        $cits = glob($folder . '*.' . $ext);

        foreach ($cits as $cit) {
            $file = basename($cit, '.' . $ext);
            $convert = $this->convertCitationFormat($file, $ext);
            $compares[] = [
                file_get_contents($cit),
                $convert->getOutput(),
            ];
        }

        return $compares;
    }

    /**
     * @param string $file
     * @param string $ext
     * @return ConvertXMLToCitationFormat
     */
    protected function convertCitationFormat($file, $ext = 'bib') {
        $xml_string = XMLString::fromString(file_get_contents($this->jats_folder . $file . '.xml'));
        if ($ext == 'ris') {
            return new ConvertXMLToRis($xml_string);
        }
        else {
            return new ConvertXMLToBibtex($xml_string);
        }
    }

    /**
     * @dataProvider jatsToHtmlAbstractProvider
     */
    public function testJatsToHtmlAbstract($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlAbstractProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('abstract', 'getAbstract');
    }

    /**
     * @dataProvider jatsToHtmlMainTextProvider
     */
    public function testJatsToHtmlMainText($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlMainTextProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('main-text', 'getMainText');
    }

    /**
     * @dataProvider jatsToHtmlDigestProvider
     */
    public function testJatsToHtmlDigest($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlDigestProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('digest', 'getDigest');
    }

    /**
     * @dataProvider jatsToHtmlDecisionLetterProvider
     */
    public function testJatsToHtmlDecisionLetter($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlDecisionLetterProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('decision-letter', 'getDecisionLetter');
    }

    /**
     * @dataProvider jatsToHtmlAuthorResponseProvider
     */
    public function testJatsToHtmlAuthorResponse($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlAuthorResponseProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('author-response', 'getAuthorResponse');
    }

    /**
     * @dataProvider jatsToHtmlAcknowledgementsProvider
     */
    public function testJatsToHtmlAcknowledgements($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlAcknowledgementsProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('acknowledgements', 'getAcknowledgements');
    }

    /**
     * @dataProvider jatsToHtmlReferencesProvider
     */
    public function testJatsToHtmlReferences($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlReferencesProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('references', 'getReferences');
    }

    /**
     * @dataProvider jatsToHtmlDoiAbstractProvider
     */
    public function testJatsToHtmlDoiAbstract($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlDoiAbstractProvider() {
        $this->setFolders();
        return $this->compareDoiHtmlSection('abstract');
    }

    /**
     * @dataProvider jatsToHtmlDoiFigProvider
     */
    public function testJatsToHtmlDoiFig($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlDoiFigProvider() {
        $this->setFolders();
        return $this->compareDoiHtmlSection('fig');
    }

    /**
     * @dataProvider jatsToHtmlDoiFigGroupProvider
     */
    public function testJatsToHtmlDoiFigGroup($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlDoiFigGroupProvider() {
        $this->setFolders();
        return $this->compareDoiHtmlSection('fig-group');
    }

    /**
     * @dataProvider jatsToHtmlDoiTableWrapProvider
     */
    public function testJatsToHtmlDoiTableWrap($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlDoiTableWrapProvider() {
        $this->setFolders();
        return $this->compareDoiHtmlSection('table-wrap');
    }

    /**
     * @dataProvider jatsToHtmlDoiBoxedTextProvider
     */
    public function testJatsToHtmlDoiBoxedText($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlDoiBoxedTextProvider() {
        $this->setFolders();
        return $this->compareDoiHtmlSection('boxed-text');
    }

    /**
     * @dataProvider jatsToHtmlDoiSupplementaryMaterialProvider
     */
    public function testJatsToHtmlDoiSupplementaryMaterial($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlDoiSupplementaryMaterialProvider() {
        $this->setFolders();
        return $this->compareDoiHtmlSection('supplementary-material');
    }

    /**
     * @dataProvider jatsToHtmlDoiMediaProvider
     */
    public function testJatsToHtmlDoiMedia($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlDoiMediaProvider() {
        $this->setFolders();
        return $this->compareDoiHtmlSection('media');
    }

    /**
     * @dataProvider jatsToHtmlDoiSubArticleProvider
     */
    public function testJatsToHtmlDoiSubArticle($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlDoiSubArticleProvider() {
        $this->setFolders();
        return $this->compareDoiHtmlSection('sub-article');
    }

    /**
     * @dataProvider xpathMatchProvider
     */
    public function testJatsToHtmlXpathMatch($file, $method, $xpath, $expected) {
        $actual_html = $this->getActualHtml($file);
        $section = call_user_func([$actual_html, $method]);
        $found = $this->runXpath($section, $xpath);
        $this->assertGreaterThan(0, $found->length);
        $this->assertEquals($expected, trim($found->item(0)->nodeValue));
    }

    public function xpathMatchProvider() {
        return $this->xpathExamples('match');
    }

    protected function xpathExamples($suffix) {
        $this->setUp();
        $jsons = glob($this->xpath_folder . '*-' . $suffix . '.json');
        $provider = [];

        foreach ($jsons as $json) {
            $found = preg_match('/^(?P<filename>[0-9]{5}\-[^\-]+)\-' . $suffix . '\.json/', basename($json), $match);
            if ($found) {
                $queries = file_get_contents($json);
                $queries = json_decode($queries);
                foreach ($queries as $query) {
                    $provider[] = [
                        $match['filename'],
                        $query->method,
                        $query->xpath,
                        $query->string,
                    ];
                }
            }
        }

        return $provider;
    }

    protected function runXpath($html, $xpath_query) {
        $domDoc = new DOMDocument();
        $domDoc->loadHTML('<meta http-equiv="content-type" content="text/html; charset=utf-8"><actual>' . $html . '</actual>');
        $xpath = new DOMXPath($domDoc);
        $nodeList = $xpath->query($xpath_query);
        return $nodeList;
    }

    /**
     * Prepare array of actual and expected results for DOI HTML.
     */
    protected function compareDoiHtmlSection($fragment_suffix) {
        $suffix = '-doi-' . $fragment_suffix;
        $htmls = glob($this->html_folder . '*' . $suffix . '.html');
        $sections = [];

        foreach ($htmls as $html) {
            $found = preg_match('/^(?P<filename>[0-9]{5}\-[^\-]+)\-(?P<doi>[^\-]+)' . $suffix . '\.html$/', basename($html), $matches);
            if ($found) {
                $sections[] = [
                    'suffix' => '-' . $matches['doi'] . $suffix,
                    'doi' => '10.7554/' . $matches['doi'],
                ];
            }
        }
        $compares = [];

        foreach ($sections as $section) {
            $compares = array_merge($compares, $this->compareHtmlSection($section['suffix'], 'getDoi', $section['doi'], ''));
        }

        return $compares;
    }

    /**
     * Prepare array of actual and expected results.
     */
    protected function compareHtmlSection($type, $method, $params = [], $suffix = '-section-') {
        $section_suffix = $suffix . $type;
        if (is_string($params)) {
            $params = [$params];
        }
        $html_prefix = '<meta http-equiv="content-type" content="text/html; charset=utf-8">';
        $expected = 'expected';
        $htmls = glob($this->html_folder . "*" . $section_suffix . ".html");
        $compares = [];

        libxml_use_internal_errors(TRUE);
        foreach ($htmls as $html) {
            $file = str_replace($section_suffix, '', basename($html, '.html'));
            $actual_html = $this->getActualHtml($file);

            $expectedDom = new DOMDocument();
            $expected_html = file_get_contents($html);
            $expectedDom->loadHTML($html_prefix . '<' . $expected . '>' . $expected_html . '</' . $expected . '>');

            $compares[] = [
                $this->getInnerHtml($expectedDom->getElementsByTagName($expected)->item(0)),
                call_user_func_array([$actual_html, $method], $params),
            ];
        }
        libxml_clear_errors();

        return $compares;
    }

    protected function getActualHtml($file) {
        return new ConvertXMLToHtml(XMLString::fromString(file_get_contents($this->jats_folder . $file . '.xml')));
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
