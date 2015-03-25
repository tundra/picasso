#!/bin/bash

# Given a shell script, runs it on the specified machine.

set -e

HOST=
SSH_FLAGS=
SCP_FLAGS=
SCRIPT=
FLAGS=
USER_PREFIX=

while getopts ":-:" OPTCHAR; do
  case "$OPTCHAR" in
    -)
      case "$OPTARG" in
        host)
          HOST="${!OPTIND}"
          OPTIND=$(($OPTIND + 1))
          ;;
        port)
          SSH_FLAGS="$SSH_FLAGS -p${!OPTIND}"
          SCP_FLAGS="$SCP_FLAGS -P${!OPTIND}"
          OPTIND=$(($OPTIND + 1))
          ;;
        user)
          USER_PREFIX="${!OPTIND}@"
          OPTIND=$(($OPTIND + 1))
          ;;
        script)
          SCRIPT="${!OPTIND}"
          OPTIND=$(($OPTIND + 1))
          ;;
        flags)
          FLAGS="${!OPTIND}"
          OPTIND=$(($OPTIND + 1))
          ;;
        tty)
          SSH_FLAGS="$SSH_FLAGS -t"
          ;;
        *)
          echo "Unknown option --$OPTARG"
          exit 1
          ;;
      esac
      ;;
    *)
      echo "Unknown option -$OPTARG"
      exit 1
      ;;
  esac
done

if [ -z "$HOST" ]; then
  echo "No --host specified"
  exit 1
fi

if [ -z "$SCRIPT" ]; then
  echo "No --script specified"
  exit 1
fi

if [ ! -f "$SCRIPT" ]; then
  echo "Script $SCRIPT doesn't exist"
  exit 1
fi

# This spills the script in /tmp/ which may become a problem at some point. But
# fixing it would make this even more intricate which is the last thing we need
# so look into that only if it does become a problem.
TMPFILE=/tmp/remote-script-$RANDOM.sh

set -v

scp $SCP_FLAGS $SCRIPT $USER_PREFIX$HOST:$TMPFILE
ssh $SSH_FLAGS $USER_PREFIX$HOST "bash $TMPFILE $FLAGS"
