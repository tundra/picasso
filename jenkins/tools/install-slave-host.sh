#!/bin/bash

# Set up a machine to be a jenkins slave.

. $(dirname $0)/helpers/common.sh

REMOTE_FLAGS=
RSYNC_PRI=
VAGRANT_PRI=
SCP_FLAGS=
HOST=
BOX=

while [ $# -gt 0 ]; do
  case "$1" in
    --host)
      HOST="$2"
      REMOTE_FLAGS="$REMOTE_FLAGS --host $2"
      shift 2
      ;;
    --port)
      SCP_FLAGS="-P $2"
      REMOTE_FLAGS="$REMOTE_FLAGS --port $2"
      shift 2
      ;;
    --rsync-private-key)
      RSYNC_PRI="$2"
      shift 2
      ;;
    --vagrant-private-key)
      VAGRANT_PRI="$2"
      shift 2
      ;;
    --box)
      BOX="$2"
      shift 2
      ;;
    *)
      die "Unknown option $1"
      ;;
  esac
done

check_set --host "$HOST"
check_set --box "$BOX"
check_set --rsync-private-key "$RSYNC_PRI"
check_set --vagrant-private-key "$VAGRANT_PRI"

# Copy the private keys to the machine.
scp $SCP_FLAGS $RSYNC_PRI picasso@$HOST:rsync_id_rsa
scp $SCP_FLAGS $VAGRANT_PRI picasso@$HOST:vagrant_id_rsa

# Run the install script.
$BASE/run-script-remote.sh                                                     \
  $REMOTE_FLAGS                                                                \
  --user picasso                                                               \
  --script $BASE/helpers/common.sh                                             \
  --script $BASE/helpers/picasso-install-slave-host.sh                         \
  --tty                                                                        \
  --flags "--box $BOX"
