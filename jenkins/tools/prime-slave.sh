#!/bin/bash

# Main script for setting up a jenkins master on a clean machine. Well, when I
# say clean I mean: you better have ssh keys set up or you'll find yourself
# entering passwords a *lot*.

set -e

BASE=$(dirname $0)
REMOTE_FLAGS=
VAGRANT_PUB=
PORT=22
HOST=

while getopts ":-:" OPTCHAR; do
  case "$OPTCHAR" in
    -)
      case "$OPTARG" in
        host)
          HOST="${!OPTIND}"
          REMOTE_FLAGS="$REMOTE_FLAGS --host $HOST"
          OPTIND=$(($OPTIND + 1))
          ;;
        port)
          PORT="${!OPTIND}"
          REMOTE_FLAGS="$REMOTE_FLAGS --port $PORT"
          OPTIND=$(($OPTIND + 1))
          ;;
        vagrant-public-key)
          VAGRANT_PUB="${!OPTIND}"
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

if [ -z "$VAGRANT_PUB" ]; then
  echo "No --vagrant-public-key specified"
  exit 1
fi

if [ ! -f "$VAGRANT_PUB" ]; then
  echo "Public key $VAGRANT_PUB doesn't exist"
  exit 1
fi

if [ -z "$HOST" ]; then
  echo "No --host specified"
  exit 1
fi

ssh-copy-id -i $VAGRANT_PUB -p $PORT vagrant@$HOST

$BASE/run-script-remote.sh $REMOTE_FLAGS --user vagrant --script $BASE/helpers/vagrant-prime-slave.sh
