#!/bin/bash

set -u

PROJECT="$1"

DELAYED_JOB=/usr/local/bin/$PROJECT.delayed_job
PID_FILE=/srv/$PROJECT/shared/pids/delayed_job.pid

function running_test {
  test -s "$PID_FILE" && kill -0 `cat $PID_FILE`
}

if ! running_test ; then
  sleep 55
  if ! running_test ; then
    echo "Delayed Job on `hostname` was down. Will restart it!" >2
    $DELAYED_JOB restart
  fi
fi
