#!/bin/bash

set -eu

CONNECT="-h localhost -U feuerwehrsport-statistik"
DB="feuerwehrsport-statistik"
TESTDB="feuerwehrsport-statistik-test"

dropdb $CONNECT $TESTDB
sleep 1
createdb $CONNECT -O $DB $TESTDB
sleep 1
pg_dump -d $DB $CONNECT --schema-only | psql $CONNECT $TESTDB
sleep 1
pg_dump -d $DB $CONNECT --data-only -t schema_migrations -t ar_internal_metadata | psql $CONNECT $TESTDB
sleep 1
echo "UPDATE ar_internal_metadata SET value = 'test';" | psql $CONNECT $TESTDB