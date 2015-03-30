#!/bin/bash

# Main script for setting up a jenkins master on a clean machine. Well, when I
# say clean I mean: you better have ssh keys set up or you'll find yourself
# entering passwords a *lot*.

. $(dirname $0)/helpers/common.sh

REMOTE_FLAGS=
ACCESS_PUB=
JENKINS_PRI=
HOST=
REMOTE_USER=picasso

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
    --access-public-key)
      ACCESS_PUB="$2"
      shift 2
      ;;
    --jenkins-private-key)
      JENKINS_PRI="$2"
      shift 2
      ;;
    *)
      die "Unknown option $1"
      ;;
  esac
done

check_set --access-public-key "$ACCESS_PUB"
check_set --jenkins-private-key "$JENKINS_PRI"
check_file_exists "$ACCESS_PUB"
check_file_exists "$JENKINS_PRI"

# Copy the jenkins identity to a temporary location such that it can be copied
# on by the install script.
scp $SCP_FLAGS $JENKINS_PRI $REMOTE_USER@$HOST:jenkins_id_rsa

# Prime the master, creating user jenkins etc.
$BASE/run-script-remote.sh                                                     \
  $REMOTE_FLAGS                                                                \
  --tty                                                                        \
  --user $REMOTE_USER                                                          \
  --script $BASE/helpers/common.sh                                             \
  --script $BASE/helpers/picasso-install-master.sh
