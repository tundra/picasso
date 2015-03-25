#!/bin/sh

set -e -x

OWNER=vagrant
LOG=/var/log/jenkins-slave/

test -d "$LOG" || mkdir -p -m 2750 "$LOG" && chown $OWNER "$LOG"
cd $LOG
exec chpst -u $OWNER svlogd "$LOG"
