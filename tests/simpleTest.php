<?php

use eLifeIngestXsl\ConvertXML\XMLString;
use eLifeIngestXsl\ConvertXMLToBibtex;
use eLifeIngestXsl\ConvertXMLToCitationFormat;
use eLifeIngestXsl\ConvertXMLToEif;
use eLifeIngestXsl\ConvertXMLToHtml;
use eLifeIngestXsl\ConvertXMLToRis;

class simpleTest extends PHPUnit_Framework_TestCase
{
    private $jats_folder = '';
    private $bib_folder = '';
    private $ris_folder = '';
    private $eif_folder = '';
    private $eif_jats_folder = '';
    private $html_folder = '';

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
            $this->eif_folder = $realpath . '/fixtures/eif/';
            $this->eif_jats_folder = $realpath . '/fixtures/eif-jats/';
            $this->html_folder = $realpath . '/fixtures/html/';
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
     * @dataProvider jatsToEifProvider
     */
    public function testJatsToEif($expected, $actual) {
        $this->assertEifJsonEquals($expected, $actual);
    }

    public function jatsToEifProvider() {
        $ext = 'json';
        $compares = [];
        $this->setFolders();
        $folder = $this->eif_folder;
        $eifs = glob($folder . '*.' . $ext);

        foreach ($eifs as $eif) {
            $file = basename($eif, '.' . $ext);
            $convert = $this->convertEifFormat($file);
            $compares[] = [
                json_decode(file_get_contents($eif)),
                json_decode($convert->getOutput($file)),
            ];
        }

        return $compares;
    }

    /**
     * @param string $file
     * @return ConvertXMLToEif
     */
    protected function convertEifFormat($file) {
        return new ConvertXMLToEif(XMLString::fromString(file_get_contents($this->eif_jats_folder . $file . '.xml')));
    }

    /**
     * @dataProvider eifPartialMatchProvider
     */
    public function testJatsToEifPartialMatch($expected, $actual, $message = '') {
        $expected = get_object_vars($expected);
        $actual = get_object_vars($actual);
        $this->assertGreaterThanOrEqual(count($expected), count($actual));
        foreach ($expected as $key => $needle) {
            $this->assertArrayHasKey($key, $actual);
            $this->assertEifJsonEquals($expected[$key], $actual[$key], $message);
        }
    }

    public function eifPartialMatchProvider() {
        return $this->eifPartialExamples('match');
    }

    protected function eifPartialExamples($suffix) {
        $this->setUp();
        $jsons = glob($this->eif_folder . 'partial/*-' . $suffix . '.json');
        $provider = [];

        foreach ($jsons as $json) {
            $found = preg_match('/^(?P<filename>elife\-[0-9]{5}\-v[0-9]+)\-' . $suffix . '\.json/', basename($json), $match);
            if ($found) {
                $queries = json_decode(file_get_contents($json));
                foreach ($queries as $query) {
                    $provider[] = [
                        $query->data,
                        json_decode($this->convertEifFormat($match['filename'])->getOutput($match['filename'])),
                        !empty($query->description) ? $query->description : '',
                    ];
                }
            }
        }

        return $provider;
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
     * @dataProvider jatsToHtmlCcLinkProvider
     */
    public function testJatsToHtmlCcLink($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlCcLinkProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('cc-link', 'getCcLink');
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
     * @dataProvider jatsToHtmlOriginalArticleProvider
     */
    public function testJatsToHtmlOriginalArticle($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlOriginalArticleProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('original-article', 'getOriginalArticle');
    }

    /**
     * @dataProvider jatsToHtmlDatasetsProvider
     */
    public function testJatsToHtmlDatasets($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlDatasetsProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('datasets', 'getDatasets');
    }

    /**
     * @dataProvider jatsToHtmlMetatagsProvider
     */
    public function testJatsToHtmlMetatags($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlMetatagsProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('metatags', 'getMetatags');
    }

    /**
     * @dataProvider jatsToHtmlDcDescriptionProvider
     */
    public function testJatsToHtmlDcDescription($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlDcDescriptionProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('dc-description', 'getDcDescription');
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
     * @dataProvider jatsToHtmlArticleInfoIdentificationProvider
     */
    public function testJatsToHtmlArticleInfoIdentification($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlArticleInfoIdentificationProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('article-info-identification', 'getArticleInfoIdentification');
    }

    /**
     * @dataProvider jatsToHtmlArticleInfoHistoryProvider
     */
    public function testJatsToHtmlArticleInfoHistory($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlArticleInfoHistoryProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('article-info-history', 'getArticleInfoHistory');
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
     * @dataProvider jatsToHtmlArticleInfoReviewingEditorProvider
     */
    public function testJatsToHtmlArticleInfoReviewingEditor($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlArticleInfoReviewingEditorProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('article-info-reviewing-editor', 'getArticleInfoReviewingEditor');
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
     * @dataProvider jatsToHtmlMainFiguresProvider
     */
    public function testJatsToHtmlMainFigures($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlMainFiguresProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('main-figures', 'getMainFigures');
    }

    /**
     * @dataProvider jatsToHtmlSupplementaryMaterialProvider
     */
    public function testJatsToHtmlSupplementaryMaterial($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlSupplementaryMaterialProvider() {
        $this->setFolders();
        return $this->compareHtmlSection('supplementary-material', 'getSupplementaryMaterial');
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
     * @dataProvider jatsToHtmlDcDescriptionFigProvider
     */
    public function testJatsToHtmlDcDescriptionFig($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlDcDescriptionFigProvider() {
        $this->setFolders();
        return $this->compareDcDescriptionHtmlSection('fig');
    }

    /**
     * @dataProvider jatsToHtmlDcDescriptionFigGroupProvider
     */
    public function testJatsToHtmlDcDescriptionFigGroup($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlDcDescriptionFigGroupProvider() {
        $this->setFolders();
        return $this->compareDcDescriptionHtmlSection('fig-group');
    }

    /**
     * @dataProvider jatsToHtmlDcDescriptionTableWrapProvider
     */
    public function testJatsToHtmlDcDescriptionTableWrap($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlDcDescriptionTableWrapProvider() {
        $this->setFolders();
        return $this->compareDcDescriptionHtmlSection('table-wrap');
    }

    /**
     * @dataProvider jatsToHtmlDcDescriptionBoxedTextProvider
     */
    public function testJatsToHtmlDcDescriptionBoxedText($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlDcDescriptionBoxedTextProvider() {
        $this->setFolders();
        return $this->compareDcDescriptionHtmlSection('boxed-text');
    }

    /**
     * @dataProvider jatsToHtmlDcDescriptionSupplementaryMaterialProvider
     */
    public function testJatsToHtmlDcDescriptionSupplementaryMaterial($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlDcDescriptionSupplementaryMaterialProvider() {
        $this->setFolders();
        return $this->compareDcDescriptionHtmlSection('supplementary-material');
    }

    /**
     * @dataProvider jatsToHtmlDcDescriptionMediaProvider
     */
    public function testJatsToHtmlDcDescriptionMedia($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlDcDescriptionMediaProvider() {
        $this->setFolders();
        return $this->compareDcDescriptionHtmlSection('media');
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
        return $this->compareTargetedHtmlSection('aff', 'getAffiliation');
    }

    /**
     * @dataProvider jatsToHtmlAuthorAffiliationProvider
     */
    public function testJatsToHtmlAuthorAffiliation($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlAuthorAffiliationProvider() {
        $this->setFolders();
        return $this->compareTargetedHtmlSection('author-affiliation', 'getAuthorAffiliation');
    }

    /**
     * @dataProvider jatsToHtmlAppProvider
     */
    public function testJatsToHtmlApp($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlAppProvider() {
        $this->setFolders();
        return $this->compareTargetedHtmlSection('app', 'getAppendix');
    }

    /**
     * @dataProvider jatsToHtmlEquProvider
     */
    public function testJatsToHtmlEqu($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlEquProvider() {
        $this->setFolders();
        return $this->compareTargetedHtmlSection('equ', 'getEquation');
    }

    /**
     * @dataProvider jatsToHtmlDataroProvider
     */
    public function testJatsToHtmlDataro($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlDataroProvider() {
        $this->setFolders();
        return $this->compareTargetedHtmlSection('dataro', 'getDataset');
    }

    /**
     * @dataProvider jatsToHtmlReferenceProvider
     */
    public function testJatsToHtmlReference($expected, $actual) {
        $this->assertEqualHtml($expected, $actual);
    }

    public function jatsToHtmlReferenceProvider() {
        $this->setFolders();
        return $this->compareTargetedHtmlSection('bib', 'getReference');
    }

    /**
     * @dataProvider htmlXpathMatchProvider
     */
    public function testJatsToHtmlXpathMatch($file, $method, $arguments, $xpath, $expected, $type, $message = '') {
        $actual_html = $this->getActualHtml($file);
        $section = call_user_func_array([$actual_html, $method], $arguments);
        $actual = $this->runXpath($section, $xpath, $type);
        if ($type == 'string') {
            $this->assertEquals($expected, $actual, $message);
        }
        else {
            $this->assertEqualHtml($expected, $actual, $message);
        }
    }

    public function htmlXpathMatchProvider() {
        return $this->htmlXpathExamples('match');
    }

    protected function htmlXpathExamples($suffix) {
        $this->setUp();
        $jsons = glob($this->html_folder . 'xpath/*-' . $suffix . '.json');
        $provider = [];

        foreach ($jsons as $json) {
            $found = preg_match('/^(?P<filename>[0-9]{5}\-v[0-9]+\-[^\-]+)\-' . $suffix . '\.json/', basename($json), $match);
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
                        (isset($query->description)) ? $query->description : '',
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
            $output = preg_replace('/\n/', '', $nodeList->item(0)->nodeValue);
        }
        else {
            $output = $domDoc->saveHTML($nodeList->item(0));
        }

        return trim($output);
    }

    /**
     * Prepare array of actual and expected results for HTML targeted by id.
     */
    protected function compareIdHtmlSection($type_suffix) {
        return $this->compareTargetedHtmlSection('id-' . $type_suffix, 'getId');
    }

    /**
     * Prepare array of actual and expected results for DOI HTML.
     */
    protected function compareDoiHtmlSection($fragment_suffix) {
        return $this->compareTargetedHtmlSection('doi-' . $fragment_suffix, 'getDoi', '10.7554/');
    }

    /**
     * Prepare array of actual and expected results for DC.Description HTML.
     */
    protected function compareDcDescriptionHtmlSection($fragment_suffix) {
        return $this->compareTargetedHtmlSection('dc-description-' . $fragment_suffix, 'getDcDescription', '10.7554/');
    }

    /**
     * Prepare array of actual and expected results for targeted HTML.
     */
    private function compareTargetedHtmlSection($suffix_id, $method, $id_prefix = '') {
        $suffix = '-' . $suffix_id;
        $htmls = glob($this->html_folder . '*' . $suffix . '.html');
        $sections = [];

        foreach ($htmls as $html) {
            $found = preg_match('/^(?P<filename>[0-9]{5}\-v[0-9]+\-[^\-]+)\-(?P<id>.+)' . $suffix . '\.html$/', basename($html), $match);
            if ($found) {
                $sections[] = [
                    'prefix' => $match['filename'],
                    'suffix' => '-' . $match['id'] . $suffix,
                    'id' => $id_prefix . $match['id'],
                ];
            }
        }
        $compares = [];

        foreach ($sections as $section) {
            $compares = array_merge($compares, $this->compareHtmlSection($section['suffix'], $method, $section['id'], '', $section['prefix']));
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
    protected function assertEqualHtml($expected, $actual, $message = '') {
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
            ConvertXMLToHtml::tidyHtml(preg_replace($from, $to, $actual)),
            $message
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

    /**
     * Asserts that two Eif JSON structures are equal.
     *
     * Adapted from example code in https://github.com/lanthaler/JsonLD
     *
     * @param  object|array $expected
     * @param  object|array $actual
     * @param  string $message
     */
    public function assertEifJsonEquals($expected, $actual, $message = '') {
        $expected = $this->normaliseEifJson($expected);
        $actual = $this->normaliseEifJson($actual);
        $this->assertEquals($expected, $actual, $message);
    }

    /**
     * Brings the keys of objects to a deterministic order to enable comparison
     * of Eif JSON structures
     *
     * @param mixed $element The element to normalise.
     *
     * @return mixed The same data with all object keys ordered in a
     *               deterministic way.
     */
    private function normaliseEifJson($element) {
        if (is_array($element)) {
            foreach ($element as &$item) {
                $item = $this->normaliseEifJson($item);
            }
        }
        elseif (is_object($element)) {
            $element = get_object_vars($element);
            ksort($element);
            $element = (object) $element;
            foreach ($element as &$item) {
                $item = $this->normaliseEifJson($item);
            }
        }
        return $element;
    }

    /**
     * Brings the keys of objects to a deterministic order to enable comparison
     * of Eif JSON structures
     *
     * If an ordinal is detected in the keys of an object than for comparison we
     * are converting these to an array. The structure of the objects that we
     * are comparing are different to the original but it will throw a
     * meaningful error message. Otherwise, there is no way to detect the
     * difference between:
     *
     * "citations": {
     *   "bib1": {},
     *   "bib2": {}
     * }
     *
     * and
     *
     * "citations": {
     *   "bib2": {},
     *   "bib1": {}
     * }
     *
     * For comparison purposes if an ordinal is detected then we care about the
     * difference so in the normalisation process the above is converted to:
     *
     * "citations": [
     *   {"bib1": {}},
     *   {"bib2": {}}
     * ]
     *
     * and
     *
     * "citations": [
     *   {"bib2": {}},
     *   {"bib1": {}}
     * ]
     *
     * @param mixed $element The element to normalise.
     *
     * @return mixed The same data with all object keys ordered in a
     *               deterministic way.
     */
    private function normaliseEifJsonWithOrdinals($element, $detect_ordinals = TRUE) {
        if (is_array($element)) {
            foreach ($element as &$item) {
                $item = $this->normaliseEifJsonWithOrdinals($item);
            }
        }
        elseif (is_object($element)) {
            $element = get_object_vars($element);
            if (count($element) > 1) {
                $ordinals = [];
                if ($detect_ordinals) {
                    $type = NULL;
                    foreach ($element as $i => $value) {
                        // If ordinal is not found in each key with the same prefix then
                        // consider as if no ordinals had been detected and allow the
                        // object keys to be normalised.
                        $ordinal_found = preg_match('/^(?P<type>[^0-9]*)[0-9]+$/', $i, $match);
                        if (!$ordinal_found || (!is_null($type) && $type != $match['type'])) {
                            $ordinals = [];
                            break;
                        }
                        $type = $match['type'];
                        $ordinals[] = [$i => $value];
                    }
                }
                // Sort element by keys if ordinal is not detected.
                if (empty($ordinals)) {
                    ksort($element);
                    $element = (object) $element;
                }
                // If ordinals are detected than apply an array.
                else {
                    $element = $ordinals;
                }
            }
            foreach ($element as &$item) {
                $item = $this->normaliseEifJsonWithOrdinals($item);
            }
        }
        return $element;
    }
}
