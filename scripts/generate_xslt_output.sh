#!/bin/bash

# Prepare xslt output derived from elife article XML.
# use ctrl-c to quit.

# @author: Nathan Lisgo <n.lisgo@elifesciences.org>

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

SOURCEFOLDER="$SCRIPTPATH/../tests/fixtures/jats"
DESTFOLDER="$SCRIPTPATH/../tests/tmp"
FORMATSTR="all"

#########################
# The command line help #
#########################
display_help() {
    echo "Usage: $(basename "$0") [-h] [-s <source folder>] [-d <destination folder>] [-f <format>]"
    echo
    echo "   -s  set the source folder (default: $SOURCEFOLDER)"
    echo "   -d  set the destination folder (default: $DESTFOLDER)"
    echo "   -f  set the format (default: $FORMATSTR)"
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
          SOURCEFOLDER="$PWD/$2"
           shift 2
           ;;
      -d | --destination)
          DESTFOLDER="$PWD/$2"
           shift 2
           ;;
      -f | --format)
          FORMATSTR="$2"
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

generate_xslt_output() {
    # create clean tmp folder
    if [ -d $DESTFOLDER ]; then
        rm -Rf $DESTFOLDER
    fi
    mkdir $DESTFOLDER

    if [ "$FORMATSTR" = "all" ]; then
        FORMATSTR="eif,pl-references,bib,ris,html"
    fi

    IFS=,
    FORMATS=($FORMATSTR)

    # for each jats xml file create a citation format of each type
    for file in $SOURCEFOLDER/*.xml; do
        filename="${file##*/}"
        arguments="${filename%.*}"
        if [[ "${filename%.*}" != *-dev ]]; then
            for FORMAT in "${FORMATS[@]}"; do
                if [ "$FORMAT" = "pl-references" ]; then
                    arguments="$DESTFOLDER|/|${filename%.*}"
                fi
                echo "Generating xslt output for $filename in the $FORMAT format ..."
                cat $SOURCEFOLDER/$filename | $SCRIPTPATH/convert_jats.php -m $(format_method $FORMAT) -t $FORMAT -a "$arguments" > $DESTFOLDER/${filename%.*}.$(format_ext $FORMAT)
            done
        fi
    done
}

control_c() {
    echo "interrupt caught, exiting. this script can be run multiple times ..."
    exit $?
}

format_method() {
    local in=$1; shift
    local method="getOutput"
    if [ "$in" = "pl-references" ]; then
        method="getOutputWithAssets"
    fi
    echo $method
}

format_ext() {
    local in=$1; shift
    local ext="txt"
    if [ "$in" = "eif" ]; then
        ext="json"
    elif [ "$in" = "pl-references" ]; then
        ext="pl-references.html"
    elif [ -n $in ]; then
        ext=$in
    fi
    echo $ext
}

trap control_c SIGINT

time generate_xslt_output