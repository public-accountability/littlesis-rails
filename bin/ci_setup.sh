#!/bin/sh
set -e

cp config/database.ci.yml config/database.yml
cp config/lilsis.yml.sample config/lilsis.yml
cp config/secrets.yml.sample config/secrets.yml
mkdir -p tmp tmp/rspec tmp/small/ tmp/profile tmp/large/ tmp/original/
