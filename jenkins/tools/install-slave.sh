#!/bin/bash

# Set up a machine to be a jenkins slave.

set -x -e

BASE=$(dirname $0)
REMOTE_FLAGS=

while getopts ":-:" OPTCHAR; do
  case "$OPTCHAR" in
    -)
      case "$OPTARG" in
        host)
          REMOTE_FLAGS="$REMOTE_FLAGS --host ${!OPTIND}"
          OPTIND=$(($OPTIND + 1))
          ;;
        port)
          SSH_FLAGS="$SSH_FLAGS -p${!OPTIND}"
          REMOTE_FLAGS="$REMOTE_FLAGS --port $PORT"
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

$BASE/run-script-remote.sh                                                     \
  $REMOTE_FLAGS                                                                \
  --user vagrant                                                               \
  --script $BASE/helpers/vagrant-install-slave.sh
