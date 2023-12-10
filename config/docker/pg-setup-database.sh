#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE ROLE littlesis; ALTER ROLE littlesis WITH NOSUPERUSER CREATEDB LOGIN PASSWORD 'themanbehindthemanbehindthethrone';
	CREATE DATABASE littlesis WITH owner = littlesis;
	CREATE DATABASE littlesis_test WITH owner = littlesis;
EOSQL
