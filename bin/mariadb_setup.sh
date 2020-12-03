#!/bin/sh
set -e

mysql_exec () {
    mysql -P 3306 -h 127.0.0.1 --user=root --password=root -e "$1"
}

mysql_exec 'CREATE DATABASE littlesis_test;'
mysql_exec "GRANT all privileges on littlesis_test.* to 'littlesis'@'%' identified by 'littlesis';"
mysql_exec "flush privileges;"
