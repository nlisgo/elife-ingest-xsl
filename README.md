Ensure xsltproc is installed.

The xsl templates have been adapted from [jats-conversion](https://github.com/PeerJ/jats-conversion)

```
git clone git@github.com:elifesciences/elife-citation-exports.git
cd elife-citation-exports
```

```
xsltproc src/jats-to-bibtex.xsl tests/fixtures/jats/00288.xml
xsltproc src/jats-to-ris.xsl tests/fixtures/jats/00288.xml
```

```
phpunit --verbose -c tests/phpunit.xml
```
