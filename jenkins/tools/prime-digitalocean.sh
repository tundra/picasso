#!/bin/bash

# Sets up a digitalocean instance. Run this before doing anything else.

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

# Run the priming script.
$BASE/run-script-remote.sh $REMOTE_FLAGS --user root --port 22 --script $BASE/helpers/root-prime-digitalocean.sh
