#!/bin/bash

# Post eif format json to elife website API.
# use ctrl-c to quit.

# @author: Nathan Lisgo <n.lisgo@elifesciences.org>

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

SOURCEFOLDER="$SCRIPTPATH/../tests/tmp"
POSTURL=""

#########################
# The command line help #
#########################
display_help() {
    echo "Usage: $(basename "$0") [-h] [-s <source folder>] [-p <post url>]"
    echo
    echo "   -s  set the source folder (default: $SOURCEFOLDER)"
    echo "   -p  set the post url"
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
      -p | --post)
          POSTURL="$2"
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

prepare_source_eif() {
    if [ -z "$POSTURL" ]; then
        echo "You must set a post url!!"
        printf "\n"
        display_help
        exit 0
    fi
    if [ ! -d $SOURCEFOLDER ]; then
        echo "Generating sample xslt eif format json ..."
        $SCRIPTPATH/generate_xslt_output.php
    fi
}

post_eif_format() {
    for file in $SOURCEFOLDER/*.json; do
        filename="${file##*/}"
        echo "POST'ing $filename ..."
        time curl -v -X POST -d @$file $POSTURL --header "Content-Type:application/json" 2>&1 | grep 'HTTP/1.1 '
        printf "\n\n"
    done
}

control_c() {
    echo "interrupt caught, exiting. this script can be run multiple times ..."
    exit $?
}

trap control_c SIGINT

prepare_source_eif
time post_eif_format