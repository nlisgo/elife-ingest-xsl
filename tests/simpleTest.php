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
    }

    public function testJatsToBibtex()
    {
        $cits = glob($this->bib_folder . "*.bib");
        $compares = [];

        foreach ($cits as $cit) {
            $file = basename($cit);
            $compares[] = [
              file_get_contents($this->temp_folder . $file),
              file_get_contents($cit),
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
              file_get_contents($this->temp_folder . $file),
              file_get_contents($cit),
            ];
        }

        foreach ($compares as $compare) {
            $this->assertEquals($compare[0], $compare[1]);
        }
    }
}
