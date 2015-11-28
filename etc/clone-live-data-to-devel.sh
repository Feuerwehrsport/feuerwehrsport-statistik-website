#!/bin/bash
DB="fws-statistik"
DROP_SQL=$(echo "select 'DROP TABLE IF EXISTS \"' || tablename || '\" CASCADE;' FROM pg_tables WHERE schemaname = 'public';" | psql -t -h localhost -U $DB $DB)
echo $DROP_SQL | psql -t -h localhost -U "$DB" "$DB"
ssh "$DB@warnow" -C pg_dump -c -U "$DB" "$DB" | psql -h localhost -U "$DB" "$DB"
