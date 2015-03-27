#!/bin/bash

# Set up a slave base image. This only installs enough that the machine can be
# packaged into a vagrant box, it leaves out almost everything needed to
# actually run a jenkins slave to keep image size down.

. $(dirname $0)/helpers/common.sh

REMOTE_FLAGS=--tty
VAGRANT_PUB=
SSH_FLAGS=
HOST=

while [ $# -gt 0 ]; do
  case "$1" in
    --host)
      HOST="$2"
      REMOTE_FLAGS="$REMOTE_FLAGS --host $2"
      shift 2
      ;;
    --port)
      SSH_FLAGS="$SSH_FLAGS -p$2"
      REMOTE_FLAGS="$REMOTE_FLAGS --port $2"
      shift 2
      ;;
    --vagrant-public-key)
      VAGRANT_PUB="$2"
      shift 2
      ;;
    *)
      die "Unknown option $1"
      ;;
  esac
done

check_set --vagrant-public-key "$VAGRANT_PUB"
check_set --host "$HOST"
check_file_exists "$VAGRANT_PUB"

ssh-copy-id -i $VAGRANT_PUB $SSH_FLAGS vagrant@$HOST

$BASE/run-script-remote.sh                                                     \
  $REMOTE_FLAGS                                                                \
  --user vagrant                                                               \
  --script $BASE/helpers/common.sh                                             \
  --script $BASE/helpers/vagrant-prime-slave-base-image.sh
