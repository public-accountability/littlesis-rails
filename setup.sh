#!/bin/bash

git submodule init
git submodule update
cp config/database.yml.sample config/database.yml
cp config/lilsis.yml.sample config/lilsis.yml
