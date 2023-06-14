#!/bin/bash

set -eu

cd /srv/feuerwehrsport-statistik/shared/dump-backup
pg_dump $1 "$2" > dump.sql
/home/feuerwehrsport-statistik/.local/bin/pg_dump_splitsort dump.sql
rm dump.sql
git add . > /dev/null
git commit -am "Backup $(date +'%Y-%m-%d')" > /dev/null
git push -q
