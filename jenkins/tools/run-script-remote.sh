#!/bin/bash

# Given a shell script, runs it on the specified machine.

set -e

HOST=
PORT=22
SCRIPT=
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
          PORT="${!OPTIND}"
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

set -v

# This spills the script in /tmp/ which may become a problem at some point. But
# fixing it would make this even more intricate which is the last thing we need
# so look into that only if it does become a problem.
TMPFILE=/tmp/remote-script-$RANDOM.sh
scp -P$PORT $SCRIPT $USER_PREFIX$HOST:$TMPFILE
ssh -p$PORT $USER_PREFIX$HOST "bash $TMPFILE"
