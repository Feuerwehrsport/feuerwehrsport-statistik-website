#!/bin/bash

set -eu

cd ~/feuerwehrsport-statistik-website-dump
pg_dump --exclude-table-data "$1" "$2" > dump.sql
git commit -am "Backup $(date +'%Y-%m-%d')" > /dev/null
git push > /dev/null 2>&1