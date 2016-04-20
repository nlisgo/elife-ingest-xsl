#!/usr/bin/env bash
set -e # all commands must pass

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

composer install --prefer-dist --no-interaction
npm install --prefix $SCRIPTPATH/vendor/elife/elife-eif-schema
npm install --prefix $SCRIPTPATH/vendor/elife/pattern-library
cd $SCRIPTPATH/vendor/elife/pattern-library
gulp
