#!/bin/bash

set -eu

cat ALL_REPORTS.out |
    dos2unix |
    sed 's/|/\//g' |
    sed 's/,\"/,|/g' |
    sed 's/\",/|,/g' |
    sed 's/^\"/|/g' |
    sed 's/\"$/|/g' |
    sed 's/||/\\N/g' |
    sed 's/\x0//g' |
    ruby clean_ny_disclosures 1> good_disclosures.csv 2> bad_rows.csv
