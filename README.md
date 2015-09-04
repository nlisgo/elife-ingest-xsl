Ensure xsltproc is installed.

The xsl templates for the citation formats have been adapted from examples provided in [jats-conversion](https://github.com/PeerJ/jats-conversion)

```
git clone git@github.com:elifesciences/elife-ingest-xsl.git
cd elife-ingest-xsl
```

Generate example template output formats:
```
./generation_xslt_output.sh
```

Usage guidance for this script is:
```
Usage: generation_xslt_output.sh [-h] [-s <source folder>] [-d <destination folder>] [-o <xsltproc options>]
```

The default source folder is tests/fixtures/jats.
The default destination folder is tests/tmp.
The default xsltproc options are --novalid. (See: http://xmlsoft.org/XSLT/xsltproc.html)

If you want to validate the XML against the DTD at the same time then you can simply set the -o parameter to ''

```
./generation_xslt_output.sh -o ''
```

Note that this will take considerably more time to process.

Review the output of example citation formats in the destination folder.

Run PHPUnit tests on example citation formats
```
phpunit --verbose -c tests/phpunit.xml
```

Apply xsl templates to another JATS XML file:

```
xsltproc src/jats-to-bibtex.xsl [JATS XML file]
xsltproc src/jats-to-ris.xsl [JATS XML file]
xsltproc src/jats-to-html.xsl [JATS XML file]
```

To process all of the elife articles then do the following:
```
git clone git@github.com:elifesciences/elife-articles.git
./generation_xslt_output.sh -s elife-articles -d elife-articles-processed
```


Useful resources:

* http://truben.no/latex/bibtex
* https://code.google.com/p/bibtex-check/
* http://xmlsoft.org/XSLT/xsltproc.html
