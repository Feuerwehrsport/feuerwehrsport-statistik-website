#!/bin/bash
DB="fws-statistik"
DROP_SQL=$(echo "select 'drop table if exists \"' || tablename || '\" cascade;' rom pg_tables where schemaname = 'public';" | psql -t -h localhost -U $DB $DB)
echo $DROP_SQL | psql -t -h localhost -U "$DB" "$DB"
ssh "$DB@warnow" -C pg_dump -c -U "$DB" "$DB" | psql -h localhost -U "$DB" "$DB"
