#!/bin/bash

# Given a shell script, runs it on the specified machine.

. $(dirname $0)/helpers/common.sh

HOST=
EXTRA_SSH_FLAGS=
BASE_SSH_FLAGS=
SCRIPTS=
FLAGS=
USER_PREFIX=

while [ $# -gt 0 ]; do
  case "$1" in
    --host)
      HOST="$2"
      shift 2
      ;;
    --port)
      BASE_SSH_FLAGS="$BASE_SSH_FLAGS -p$2"
      shift 2
      ;;
    --user)
      USER_PREFIX="$2@"
      shift 2
      ;;
    --script)
      SCRIPTS="$SCRIPTS $2"
      shift 2
      ;;
    --flags)
      FLAGS="$2"
      shift 2
      ;;
    --tty)
      EXTRA_SSH_FLAGS="$EXTRA_SSH_FLAGS -t"
      shift 1
      ;;
    *)
      die "Unknown option $1"
      ;;
  esac
done

check_set --host "$HOST"
check_set --script "$SCRIPTS"

# This spills the script in /tmp/ which may become a problem at some point. But
# fixing it would make this even more intricate which is the last thing we need
# so look into that only if it does become a problem.
TMPFILE=/tmp/remote-script-$RANDOM.sh

cat $SCRIPTS | ssh $BASE_SSH_FLAGS $USER_PREFIX$HOST "cat > $TMPFILE"
ssh $BASE_SSH_FLAGS $EXTRA_SSH_FLAGS $USER_PREFIX$HOST "bash $TMPFILE $FLAGS"
