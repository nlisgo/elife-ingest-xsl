#!/bin/bash

# Prepare citation styles derived from elife article XML.
# use ctrl-c to quit.

# @author: Nathan Lisgo <n.lisgo@elifesciences.org>

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

generate_citation_formats() {
    # create clean tmp folder
    if [ -d $SCRIPTPATH/tmp ]; then
        rm -Rf $SCRIPTPATH/tmp
    fi
    mkdir $SCRIPTPATH/tmp

    # for each jats xml file create a citation format of each type
    for file in $SCRIPTPATH/fixtures/jats/*.xml; do
        filename="${file##*/}"
        echo "Generating citation formats for $filename ${filename%.*} ..."
        xsltproc $SCRIPTPATH/../src/jats-to-bibtex.xsl $SCRIPTPATH/fixtures/jats/$filename > $SCRIPTPATH/tmp/${filename%.*}.bib
        xsltproc $SCRIPTPATH/../src/jats-to-ris.xsl $SCRIPTPATH/fixtures/jats/$filename > $SCRIPTPATH/tmp/${filename%.*}.ris
    done
}

control_c() {
    echo "interrupt caught, exiting. this script can be run multiple times ..."
    exit $?
}

trap control_c SIGINT

time generate_citation_formats