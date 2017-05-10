#!/bin/bash

set -eu

cat ALL_REPORTS.out  |
    iconv -f ISO-8859-1 -t UTF-8 |
    sed 's/\"\"/\\N/g' |
    sed 's/\x0//g' |
    ./clean_ny_disclosures 1> good_disclosures.csv 2> bad_rows.csv
