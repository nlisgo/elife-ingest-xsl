The xsl templates for the citation formats have been adapted from examples provided in [jats-conversion](https://github.com/PeerJ/jats-conversion)

```
git clone git@github.com:elifesciences/elife-ingest-xsl.git
cd elife-ingest-xsl
```

Install dependencies with composer:

```
composer install
```

Generate example template output formats:
```
./scripts/generate_xslt_output.sh
```

Usage guidance for this script is:
```
Usage: generate_xslt_output.sh [-h] [-s <source folder>] [-d <destination folder>]
```

The default source folder is tests/fixtures/jats.
The default destination folder is tests/tmp.

Review the output of example citation formats in the destination folder.

Run PHPUnit tests on example citation formats
```
./bin/phpunit --verbose -c tests/phpunit.xml
```

Apply xsl templates to another JATS XML file:

```
cat [JATS XML file] | ./scripts/convert_xml.php -t bib
cat [JATS XML file] | ./scripts/convert_xml.php -t ris
cat [JATS XML file] | ./scripts/convert_xml.php -t html
```

To process all of the elife articles then do the following:
```
git clone git@github.com:elifesciences/elife-articles.git
./scripts/generate_xslt_output.sh -s elife-articles -d elife-articles-processed
```


Useful resources:

* http://truben.no/latex/bibtex
* https://code.google.com/p/bibtex-check/
