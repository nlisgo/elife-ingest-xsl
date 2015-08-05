#!/bin/bash

# Prepare citation styles derived from elife article XML.
# use ctrl-c to quit.

# @author: Nathan Lisgo <n.lisgo@elifesciences.org>

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

SOURCEFOLDER="$SCRIPTPATH/tests/fixtures/jats"
DESTFOLDER="$SCRIPTPATH/tests/tmp"

#########################
# The command line help #
#########################
display_help() {
    echo "Usage: $(basename "$0") [-h] [-s <source folder>] [-d <destination folder>]"
    echo
    echo "   -s  set the source folder (default: $SOURCEFOLDER)"
    echo "   -d  set the destination folder (default: $DESTFOLDER)"
    exit 1
}

################################
# Check if parameters options  #
# are given on the commandline #
################################
while true;
do
    case "$1" in
      -h | --help)
          display_help
          exit 0
          ;;
      -s | --source)
          SOURCEFOLDER="$2"
           shift 2
           ;;
      -d | --destination)
          DESTFOLDER="$2"
           shift 2
           ;;
      -*)
          echo "Error: Unknown option: $1" >&2
          ## or call function display_help
          exit 1
          ;;
      *)  # No more options
          break
          ;;
    esac
done

generate_citation_formats() {
    # create clean tmp folder
    if [ -d $DESTFOLDER ]; then
        rm -Rf $DESTFOLDER
    fi
    mkdir $DESTFOLDER

    # for each jats xml file create a citation format of each type
    for file in $SOURCEFOLDER/*.xml; do
        filename="${file##*/}"
        echo "Generating citation formats for $filename ..."
        xsltproc $SCRIPTPATH/src/jats-to-bibtex.xsl $SOURCEFOLDER/$filename > $DESTFOLDER/${filename%.*}.bib
        xsltproc $SCRIPTPATH/src/jats-to-ris.xsl $SOURCEFOLDER/$filename > $DESTFOLDER/${filename%.*}.ris
    done
}

time generate_citation_formats