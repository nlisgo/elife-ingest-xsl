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
        $this->assertEquals($expected, $actual);
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
                $this->prepareEifForComparison(json_decode(file_get_contents($eif))),
                $this->prepareEifForComparison(json_decode($convert->getOutput())),
            ];
        }

        return $compares;
    }

    /**
     * @param string $file
     * @return ConvertXMLToEif
     */
    protected function convertEifFormat($file) {
        return new ConvertXMLToEif(XMLString::fromString(file_get_contents($this->jats_folder . $file . '.xml')));
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
            $this->assertEquals($expected[$key], $actual[$key], $message);
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
            $found = preg_match('/^(?P<filename>[0-9]{5}\-v[0-9]+\-[^\-]+)\-' . $suffix . '\.json/', basename($json), $match);
            if ($found) {
                $queries = json_decode(file_get_contents($json));
                foreach ($queries as $query) {
                    $provider[] = [
                        $this->prepareEifForComparison((!empty($query->data) ? $query->data : $query)),
                        $this->prepareEifForComparison(json_decode($this->convertEifFormat($match['filename'])->getOutput())),
                        (!empty($query->data) && !empty($query->description) ? $query->description : '')
                    ];
                }
            }
        }

        return $provider;
    }

    protected function prepareEifForComparison($json) {
        $prepare_contributors = function($contributors) {
            foreach ($contributors as $contrib_pos => $contrib) {
                $contrib = get_object_vars($contrib);
                foreach ($contrib as $k => $value) {
                    if ($k == 'references') {
                        // Preserve order of values in references section.
                        $value = get_object_vars($value);
                        ksort($value);
                    }
                    if ($k == 'affiliations') {
                        // Preserve order of affiliations but sort the
                        // affiliation values.
                        foreach ($value as $aff_pos => $aff) {
                            $aff = get_object_vars($aff);
                            ksort($aff);
                            $value[$aff_pos] = $aff;
                        }
                    }
                    $contrib[$k] = $value;
                }
                ksort($contrib);
                $contributors[$contrib_pos] = $contrib;
            }
            return json_decode(json_encode($contributors), FALSE);
        };
        $prepare_fragments = function($fragments) use ($prepare_contributors, &$prepare_fragments) {
            // Preserve order of fragments but order the values within a
            // fragment.
            foreach ($fragments as $frag_pos => $frag) {
                $frag = get_object_vars($frag);
                // Preserve the order of contributors, if present.
                if (!empty($frag['contributors'])) {
                    $frag['contributors'] = $prepare_contributors($frag['contributors']);
                }
                // Move on to next level of fragments (e.g. figure supplement).
                if (!empty($frag['fragments'])) {
                    $frag['fragments'] = $prepare_fragments($frag['fragments']);
                }
                ksort($frag);
                $fragments[$frag_pos] = $frag;
            }
            return $fragments;
        };
        // Order the keyword and category types but preserve the order of the
        // values.
        foreach (['keywords', 'categories'] as $cat_type) {
            if (!empty($json->{$cat_type})) {
                $cats = get_object_vars($json->{$cat_type});
                ksort($cats);
                $json->{$cat_type} = json_decode(json_encode($cats), FALSE);
            }
        }
        // Contributors must appear in a fixed order but the some contributor
        // values can be sorted for easier comparison.
        if (!empty($json->contributors)) {
            $json->contributors = $prepare_contributors($json->contributors);
        }
        if (!empty($json->referenced)) {
            $referenced = get_object_vars($json->referenced);
            // Preserve order of referenced keys but the value of non-string
            // key-values can be sorted for easier comparison.
            foreach (['affiliation', 'funding', 'related-object'] as $ref_sec) {
                if (!empty($referenced[$ref_sec])) {
                    $ref_sec_values = get_object_vars($referenced[$ref_sec]);
                    foreach ($ref_sec_values as $ref_id => $ref_values) {
                        $ref_values = get_object_vars($ref_values);
                        ksort($ref_values);
                        $referenced[$ref_sec]->{$ref_id} = $ref_values;
                    }
                }
            }
            ksort($referenced);
            $json->referenced = json_decode(json_encode($referenced), FALSE);
        }
        if (!empty($json->citations)) {
            $citations = get_object_vars($json->citations);
            // Citations must appear in a fixed order but the some citation
            // values can be sorted for easier comparison.
            foreach ($citations as $bib_id => $citation) {
                $citation = get_object_vars($citation);
                // Preserve order of authors but sort the author values.
                if (!empty($citation['authors'])) {
                    foreach ($citation['authors'] as $author_pos => $author) {
                        $author = get_object_vars($author);
                        ksort($author);
                        $authors[$author_pos] = $author;
                    }
                    ksort($citation['authors']);
                }
                ksort($citation);
                $citations[$bib_id] = $citation;
            }
            $json->citations = json_decode(json_encode($citations), FALSE);
        }
        if (!empty($json->fragments)) {
            $json->fragments = $prepare_fragments($json->fragments);
        }
        // Preserve the order of related articles but sort the values within a
        // related article object.
        if (!empty($json->{'related-articles'})) {
            foreach ($json->{'related-articles'} as $rel_pos => $rel) {
                $rel = get_object_vars($rel);
                ksort($rel);
                $json->{'related-articles'}[$rel_pos] = $rel;
            }
        }

        $json = get_object_vars($json);
        ksort($json);
        return json_decode(json_encode($json), FALSE);
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
            $output = $nodeList->item(0)->nodeValue;
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
}
