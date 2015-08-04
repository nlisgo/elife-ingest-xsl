Ensure xsltproc is installed

```
git clone git@github.com:elifesciences/elife-citation-exports.git
cd elife-citation-exports
```

```
xsltproc src/jats-to-bibtex.xsl tests/fixtures/jats/00288.xml
xsltproc src/jats-to-ris.xsl tests/fixtures/jats/00288.xml
```
