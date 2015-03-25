#!/bin/sh -x

ABSELF=$(readlink $0)
BASE=$(dirname $ABSELF)
OWNER=vagrant

cd /home/$OWNER/
exec 2>&1
exec chpst -u $OWNER $BASE/run-slave.sh
