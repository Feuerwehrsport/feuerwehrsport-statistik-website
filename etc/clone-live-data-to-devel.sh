#!/bin/bash
DB="fws-statistik"
HOST="warnow"

DROP_SQL=$(echo "select 'DROP TABLE IF EXISTS \"' || tablename || '\" CASCADE;' FROM pg_tables WHERE schemaname = 'public';" | psql -t -h localhost -U $DB $DB)
echo $DROP_SQL | psql -t -h localhost -U "$DB" "$DB"
ssh "$DB@$HOST" -C pg_dump -c -U "$DB" "$DB" | psql -h localhost -U "$DB" "$DB"


rsync -axz --info=progress2 -v --exclude="tmp/" --exclude="wettkampf_manager/" --partial "$DB@$HOST:/srv/$DB/shared/uploads/" ./public/uploads/

rails r "AdminUser.first.update_attributes(password: 'Admin123')"