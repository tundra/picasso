#!/bin/bash

# Sets up a digitalocean instance. Run this before doing anything else.

. $(dirname $0)/helpers/common.sh

REMOTE_FLAGS=


while [ $# -gt 0 ]; do
  case "$1" in
    --host)
      REMOTE_FLAGS="$REMOTE_FLAGS --host $2"
      shift 2
      ;;
    *)
      die "Unknown option $1"
      ;;
  esac
done

# Run the priming script.
$BASE/run-script-remote.sh                                                     \
  $REMOTE_FLAGS                                                                \
  --user root                                                                  \
  --port 22                                                                    \
  --script $BASE/helpers/common.sh                                             \
  --script $BASE/helpers/root-prime-digitalocean.sh
