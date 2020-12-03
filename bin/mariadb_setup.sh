#!/bin/sh
set -e

mysql_exec () {
    mysql --user=littlesis --password=littlesis -e "$1"
}

mysql_exec 'CREATE DATABASE littlesis;'
mysql_exec 'CREATE DATABASE littlesis_test;'
mysql_exec "GRANT all privileges on littlesis.* to 'littlesis'@'%' identified by 'littlesis';"
mysql_exec "GRANT all privileges on littlesis_test.* to 'littlesis'@'%' identified by 'littlesis';"
mysql_exec -e "flush privileges;"
