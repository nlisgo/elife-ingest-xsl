Ensure xsltproc is installed.

The xsl templates have been adapted from [jats-conversion](https://github.com/PeerJ/jats-conversion)

```
git clone git@github.com:elifesciences/elife-citation-exports.git
cd elife-citation-exports
```

Generate example citation formats:
```
./tests/generation_citation_formats.sh
```

Review the output of example citation formats in:
```
tests/tmp/
```

Run PHPUnit tests on example citation formats
```
phpunit --verbose -c tests/phpunit.xml
```

Apply xsl templates to another JATS XML file:

```
xsltproc src/jats-to-bibtex.xsl [JATS XML file]
xsltproc src/jats-to-ris.xsl [JATS XML file]
```

Useful resources:

* http://truben.no/latex/bibtex
* https://code.google.com/p/bibtex-check/
