#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
     CREATE ROLE littlesis WITH LOGIN CREATEDB PASSWORD 'themanbehindthemanbehindthethrone';
     GRANT pg_read_server_files TO littlesis;
     CREATE DATABASE littlesis WITH OWNER littlesis
EOSQL
