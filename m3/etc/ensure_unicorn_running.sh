#!/bin/bash

set -u

PROJECT="$1"

INIT_JOB=/etc/init.d/unicorn_$PROJECT
PID_FILE=/srv/$PROJECT/shared/pids/unicorn.pid

function running_test {
  test -s "$PID_FILE" && kill -0 `cat $PID_FILE`
}

if ! running_test ; then
  sleep 31
  if ! running_test ; then
    echo "Unicorn $PROJECT on `hostname` was down. Will restart it!" >&2
    $INIT_JOB restart
  fi
fi
