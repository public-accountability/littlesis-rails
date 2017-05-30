#!/bin/bash

set -eu

cat ALL_REPORTS.out  |
    iconv -c -f ISO-8859-1 -t UTF-8//IGNORE |
    tr -d '\000' | 
    sed 's/\"\"/\\N/g' |
    ruby clean_ny_disclosures 1> good_disclosures.csv 2> bad_rows.csv


# cat ALL_REPORTS.out |
#     dos2unix |
#     sed 's/|/\//g' |
#     sed 's/,\"/,|/g' |
#     sed 's/\",/|,/g' |
#     sed 's/^\"/|/g' |
#     sed 's/\"$/|/g' |
#     sed 's/||/\\N/g' |
#     sed 's/\x0//g' |
#     ruby clean_ny_disclosures 1> good_disclosures.csv 2> bad_rows.csv
