#!/bin/bash

set -eu

cd ~/feuerwehrsport-statistik-website-dump
pg_dump $1 "$2" > dump.sql
~/pgtricks/pgtricks/pg_dump_splitsort.py dump.sql
rm dump.sql
git commit -am "Backup $(date +'%Y-%m-%d')" > /dev/null
git push > /dev/null 2>&1