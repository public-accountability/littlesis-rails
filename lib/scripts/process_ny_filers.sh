#!/bin/bash

cat COMMCAND.txt |
    iconv -f ISO-8859-1 -t UTF-8 |
    sed 's/\"\"/\\N/g' |
    sed 's/\x0//g' > COMMCAND.csv
