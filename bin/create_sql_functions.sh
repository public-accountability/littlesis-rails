#!/bin/sh
set -e

psql "postgresql://littlesis:littlesis@127.0.01/littlesis_test" < lib/sql/network_map_link.sql
psql "postgresql://littlesis:littlesis@127.0.01/littlesis_test" < lib/sql/recent_entity_edits.sql
