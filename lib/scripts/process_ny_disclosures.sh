#!/bin/bash
set -eu

if test -z $1
then
    echo 'Missing required argument: path to ALL_REPORTS.out'
    exit 1
fi


SCRIPT_DIR=$(readlink -f $(dirname $0))

cat $1 |
    iconv -c -f ISO-8859-1 -t UTF-8//IGNORE |
    tr -d '\000' | 
    sed 's/\"\"/\\N/g' |
    ruby ${SCRIPT_DIR}/clean_ny_disclosures 1> ./good_disclosures.csv 2> ./bad_rows.csv
