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
     * @dataProvider jatsToHtmlTitleProvider
     */
    public function testJatsToHtmlTitle($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlTitleProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('title', 'getTitle');
    }

    /**
     * @dataProvider jatsToHtmlImpactStatementProvider
     */
    public function testJatsToHtmlImpactStatement($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlImpactStatementProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('impact-statement', 'getImpactStatement');
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
     * @dataProvider jatsToHtmlAuthorInfoGroupAuthorsProvider
     */
    public function testJatsToHtmlAuthorInfoGroupAuthors($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlAuthorInfoGroupAuthorsProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('author-info-group-authors', 'getAuthorInfoGroupAuthors');
    }

    /**
     * @dataProvider jatsToHtmlAuthorInfoContributionsProvider
     */
    public function testJatsToHtmlAuthorInfoContributions($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlAuthorInfoContributionsProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('author-info-contributions', 'getAuthorInfoContributions');
    }

    /**
     * @dataProvider jatsToHtmlAuthorInfoEqualContribProvider
     */
    public function testJatsToHtmlAuthorInfoEqualContrib($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlAuthorInfoEqualContribProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('author-info-equal-contrib', 'getAuthorInfoEqualContrib');
    }

    /**
     * @dataProvider jatsToHtmlAuthorInfoOtherFootnotesProvider
     */
    public function testJatsToHtmlAuthorInfoOtherFootnotes($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlAuthorInfoOtherFootnotesProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('author-info-other-footnotes', 'getAuthorInfoOtherFootnotes');
    }

    /**
     * @dataProvider jatsToHtmlAuthorInfoCorrespondenceProvider
     */
    public function testJatsToHtmlAuthorInfoCorrespondence($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlAuthorInfoCorrespondenceProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('author-info-correspondence', 'getAuthorInfoCorrespondence');
    }

    /**
     * @dataProvider jatsToHtmlAuthorInfoAdditionalAddressProvider
     */
    public function testJatsToHtmlAuthorInfoAdditionalAddress($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlAuthorInfoAdditionalAddressProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('author-info-additional-address', 'getAuthorInfoAdditionalAddress');
    }

    /**
     * @dataProvider jatsToHtmlAuthorInfoCompetingInterestProvider
     */
    public function testJatsToHtmlAuthorInfoCompetingInterest($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlAuthorInfoCompetingInterestProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('author-info-competing-interest', 'getAuthorInfoCompetingInterest');
    }

    /**
     * @dataProvider jatsToHtmlAuthorInfoFundingProvider
     */
    public function testJatsToHtmlAuthorInfoFunding($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlAuthorInfoFundingProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('author-info-funding', 'getAuthorInfoFunding');
    }

    /**
     * @dataProvider jatsToHtmlArticleInfoEthicsProvider
     */
    public function testJatsToHtmlArticleInfoEthics($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlArticleInfoEthicsProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('article-info-ethics', 'getArticleInfoEthics');
    }

    /**
     * @dataProvider jatsToHtmlArticleInfoLicenseProvider
     */
    public function testJatsToHtmlArticleInfoLicense($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlArticleInfoLicenseProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('article-info-license', 'getArticleInfoLicense');
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
     * @dataProvider jatsToHtmlIdSubsectionProvider
     */
    public function testJatsToHtmlIdSubsection($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlIdSubsectionProvider() {
        $this->setFolders();
        return $this->compareIdHtmlSection('subsection');
    }

    /**
     * @dataProvider jatsToHtmlAffProvider
     */
    public function testJatsToHtmlAff($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlAffProvider() {
        $this->setFolders();
        return $this->compareAffHtmlSection();
    }

    /**
     * @dataProvider jatsToHtmlAppProvider
     */
    public function testJatsToHtmlApp($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlAppProvider() {
        $this->setFolders();
        return $this->compareAppHtmlSection();
    }

    /**
     * @dataProvider jatsToHtmlEquProvider
     */
    public function testJatsToHtmlEqu($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlEquProvider() {
        $this->setFolders();
        return $this->compareEquHtmlSection();
    }

    /**
     * @dataProvider jatsToHtmlReferenceProvider
     */
    public function testJatsToHtmlReference($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlReferenceProvider() {
        $this->setFolders();
        return $this->compareReferenceHtmlSection();
    }

    /**
     * @dataProvider xpathMatchProvider
     */
    public function testJatsToHtmlXpathMatch($file, $method, $arguments, $xpath, $expected, $type) {
        $actual_html = $this->getActualHtml($file);
        $section = call_user_func_array([$actual_html, $method], $arguments);
        $actual = $this->runXpath($section, $xpath, $type);
        if ($type == 'string') {
            $this->assertEquals($expected, $actual);
        }
        else {
            $this->assertEqualHtml($expected, $actual);
        }
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
                        (!empty($query->arguments)) ? $query->arguments : [],
                        $query->xpath,
                        (isset($query->string)) ? $query->string : $query->html,
                        (isset($query->string)) ? 'string' : 'html',
                    ];
                }
            }
        }

        return $provider;
    }

    protected function runXpath($html, $xpath_query, $type = 'string') {
        $domDoc = new DOMDocument();
        $domDoc->loadHTML('<meta http-equiv="content-type" content="text/html; charset=utf-8"><actual>' . $html . '</actual>');
        $xpath = new DOMXPath($domDoc);
        $nodeList = $xpath->query($xpath_query);
        $this->assertGreaterThanOrEqual(1, $nodeList->length);
        if ($type == 'string') {
            $output = $nodeList->item(0)->nodeValue;
        }
        else {
            $output = $domDoc->saveHTML($nodeList->item(0));
        }

        return trim($output);
    }

    /**
     * Prepare array of actual and expected results for affiliation HTML.
     */
    protected function compareAffHtmlSection() {
        $suffix = '-aff';
        $htmls = glob($this->html_folder . '*' . $suffix . '.html');
        $sections = [];

        foreach ($htmls as $html) {
            $found = preg_match('/^(?P<filename>[0-9]{5}\-[^\-]+)\-(?P<aff_id>[^\-]+)' . $suffix . '\.html$/', basename($html), $match);
            if ($found) {
                $sections[] = [
                    'prefix' => $match['filename'],
                    'suffix' => '-' . $match['aff_id'] . $suffix,
                    'aff_id' => $match['aff_id'],
                ];
            }
        }
        $compares = [];

        foreach ($sections as $section) {
            $compares = array_merge($compares, $this->compareHtmlSection($section['suffix'], 'getAffiliation', $section['aff_id'], '', $section['prefix']));
        }

        return $compares;
    }

    /**
     * Prepare array of actual and expected results for appendix HTML.
     */
    protected function compareAppHtmlSection() {
        $suffix = '-app';
        $htmls = glob($this->html_folder . '*' . $suffix . '.html');
        $sections = [];

        foreach ($htmls as $html) {
            $found = preg_match('/^(?P<filename>[0-9]{5}\-[^\-]+)\-(?P<app_id>[^\-]+)' . $suffix . '\.html$/', basename($html), $match);
            if ($found) {
                $sections[] = [
                    'prefix' => $match['filename'],
                    'suffix' => '-' . $match['app_id'] . $suffix,
                    'app_id' => $match['app_id'],
                ];
            }
        }
        $compares = [];

        foreach ($sections as $section) {
            $compares = array_merge($compares, $this->compareHtmlSection($section['suffix'], 'getAppendix', $section['app_id'], '', $section['prefix']));
        }

        return $compares;
    }

    /**
     * Prepare array of actual and expected results for equation HTML.
     */
    protected function compareEquHtmlSection() {
        $suffix = '-equ';
        $htmls = glob($this->html_folder . '*' . $suffix . '.html');
        $sections = [];

        foreach ($htmls as $html) {
            $found = preg_match('/^(?P<filename>[0-9]{5}\-[^\-]+)\-(?P<equ_id>[^\-]+)' . $suffix . '\.html$/', basename($html), $match);
            if ($found) {
                $sections[] = [
                    'prefix' => $match['filename'],
                    'suffix' => '-' . $match['equ_id'] . $suffix,
                    'equ_id' => $match['equ_id'],
                ];
            }
        }
        $compares = [];

        foreach ($sections as $section) {
            $compares = array_merge($compares, $this->compareHtmlSection($section['suffix'], 'getEquation', $section['equ_id'], '', $section['prefix']));
        }

        return $compares;
    }

    /**
     * Prepare array of actual and expected results for reference HTML.
     */
    protected function compareReferenceHtmlSection() {
        $suffix = '-bib';
        $htmls = glob($this->html_folder . '*' . $suffix . '.html');
        $sections = [];

        foreach ($htmls as $html) {
            $found = preg_match('/^(?P<filename>[0-9]{5}\-[^\-]+)\-(?P<bib_id>[^\-]+)' . $suffix . '\.html$/', basename($html), $match);
            if ($found) {
                $sections[] = [
                    'prefix' => $match['filename'],
                    'suffix' => '-' . $match['bib_id'] . $suffix,
                    'bib_id' => $match['bib_id'],
                ];
            }
        }
        $compares = [];

        foreach ($sections as $section) {
            $compares = array_merge($compares, $this->compareHtmlSection($section['suffix'], 'getReference', $section['bib_id'], '', $section['prefix']));
        }

        return $compares;
    }

    /**
     * Prepare array of actual and expected results for HTML targetted by id.
     */
    protected function compareIdHtmlSection($type_suffix) {
        $suffix = '-id-' . $type_suffix;
        $htmls = glob($this->html_folder . '*' . $suffix . '.html');
        $sections = [];

        foreach ($htmls as $html) {
            $found = preg_match('/^(?P<filename>[0-9]{5}\-[^\-]+)\-(?P<id>.+)' . $suffix . '\.html$/', basename($html), $match);
            if ($found) {
                $sections[] = [
                    'prefix' => $match['filename'],
                    'suffix' => '-' . $match['id'] . $suffix,
                    'id' => $match['id'],
                ];
            }
        }
        $compares = [];

        foreach ($sections as $section) {
            $compares = array_merge($compares, $this->compareHtmlSection($section['suffix'], 'getId', $section['id'], '', $section['prefix']));
        }

        return $compares;
    }

    /**
     * Prepare array of actual and expected results for DOI HTML.
     */
    protected function compareDoiHtmlSection($fragment_suffix) {
        $suffix = '-doi-' . $fragment_suffix;
        $htmls = glob($this->html_folder . '*' . $suffix . '.html');
        $sections = [];

        foreach ($htmls as $html) {
            $found = preg_match('/^(?P<filename>[0-9]{5}\-[^\-]+)\-(?P<doi>[^\-]+)' . $suffix . '\.html$/', basename($html), $match);
            if ($found) {
                $sections[] = [
                    'prefix' => $match['filename'],
                    'suffix' => '-' . $match['doi'] . $suffix,
                    'doi' => '10.7554/' . $match['doi'],
                ];
            }
        }
        $compares = [];

        foreach ($sections as $section) {
            $compares = array_merge($compares, $this->compareHtmlSection($section['suffix'], 'getDoi', $section['doi'], '', $section['prefix']));
        }

        return $compares;
    }

    /**
     * Prepare array of actual and expected results.
     */
    protected function compareHtmlSection($type, $method, $params = [], $suffix = '-section-', $prefix = '*') {
        $section_suffix = $suffix . $type;
        if (is_string($params)) {
            $params = [$params];
        }
        $html_prefix = '<meta http-equiv="content-type" content="text/html; charset=utf-8">';
        $expected = 'expected';
        $htmls = glob($this->html_folder . $prefix . $section_suffix . ".html");
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
    protected function assertEqualHtml($expected, $actual) {
        $from = [
            '/\>[^\S ]+/s',
            '/[^\S ]+\</s',
            '/(\s)+/s',
            '/> </s',
            '/>\s+\[/s',
            '/\]\s+</s',
        ];
        $to = [
            '>',
            '<',
            '\\1',
            '><',
            '>[',
            ']<',
        ];
        $this->assertEquals(
            ConvertXMLToHtml::tidyHtml(preg_replace($from, $to, $expected)),
            ConvertXMLToHtml::tidyHtml(preg_replace($from, $to, $actual))
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
