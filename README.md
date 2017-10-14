The xsl templates for the citation formats have been adapted from examples provided in [jats-conversion](https://github.com/PeerJ/jats-conversion)

```
git clone git@github.com:elifesciences/elife-ingest-xsl.git
cd elife-ingest-xsl
```

Install dependencies:

```
composer install
```

The PHP Tidy library is also required. The version depends on the version of PHP it's to run against. For example on OSX using PHP 7.0.x this may be installed via homebrew with:
 ```
 brew install homebrew/php/php70-tidy 
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

Run PHPUnit tests on example citation formats:
```
./bin/phpunit
```

You can filter by a specific method in ```/tests/simpleTest.php```, for example:
```
./bin/phpunit --filter=testJatsToHtmlDecisionLetter
```

Apply xsl templates to another JATS XML file:
```
cat [JATS XML file] | ./scripts/convert_xml.php -t 'bib'
cat [JATS XML file] | ./scripts/convert_xml.php -t 'ris'
cat [JATS XML file] | ./scripts/convert_xml.php -t 'html'
```

It is possible to use ```./scripts/convert_xml.php -t html``` to target specific portions of the markup.

Here are a few examples:

Retrieve the abstract section:
```
cat [JATS XML file] | ./scripts/convert_xml.php -t 'html' -m 'getAbstract'
```
other methods that can be called are: getDigest, getAuthorResponse etc.


Retrieve a fragment doi section:
```
cat [JATS XML file] | ./scripts/convert_xml.php -t 'html' -m 'getDoi' -a '10.7554/eLife.00288.026'
```

Retrieve markup by xpath query against the source:
```
cat [JATS XML file] | ./scripts/convert_xml.php -t 'html' -m 'getSection' -a '[xpath-query]'
```

Retrieve markup by xpath query against the html:
```
cat [JATS XML file] | ./scripts/convert_xml.php -t 'html' -m 'getHtmlXpath' -a '[method]|[argument]|[xpath-query]'
```
for example to retrieve the first p element of the fragment doi 10.7554/eLife.00288.042 for article 00288:
```
cat tests/fixtures/jats/00288-v1-vor.xml | ./scripts/convert_xml.php -t 'html' -m 'getHtmlXpath' -a 'getDoi|10.7554/eLife.00288.042|//p[1]'
```
or to get the the div with class="elife-article-author-response-doi" in the author response:
```
cat tests/fixtures/jats/00288-v1-vor.xml | ./scripts/convert_xml.php -t 'html' -m 'getHtmlXpath' -a 'getAuthorResponse||//div[@class="elife-article-author-response-doi"]'
```


To process all of the elife articles then do the following:
```
git clone git@github.com:elifesciences/elife-articles.git
./scripts/generate_xslt_output.sh -s elife-articles -d elife-articles-processed
```

To get a quick idea of what the main article page will look like you can run the following script:
```
cat [JATS XML file] | ./scripts/draft_template.php > ~/draft_article.html
```
then open the html file in your browser.
for example:
```
cat tests/fixtures/jats/00288-v1-vor.xml | ./scripts/draft_template.php > ~/00288.html
open ~/00288.html
```

Useful resources:

* http://truben.no/latex/bibtex
* https://code.google.com/p/bibtex-check/
