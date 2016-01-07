#!/usr/bin/env bash
set -e # all commands must pass

npm install -g bower
bower install
npm install --prefix ./bower_components/elife-eif-schema/

composer install --prefer-dist --no-interaction
