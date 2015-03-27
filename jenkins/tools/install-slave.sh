#!/bin/bash

# Set up a machine to be a jenkins slave.

. $(dirname $0)/helpers/common.sh

REMOTE_FLAGS=
JENKINS_PRI=
SLAVE_ID=
USER=vagrant

while [ $# -gt 0 ]; do
  case "$1" in
    --user)
      USER="$2"
      shift 2
      ;;
    --host)
      REMOTE_FLAGS="$REMOTE_FLAGS --host $2"
      shift 2
      ;;
    --port)
      REMOTE_FLAGS="$REMOTE_FLAGS --port $2"
      shift 2
      ;;
    --jenkins-private-key)
      JENKINS_PRI="$2"
      shift 2
      ;;
    --id)
      SLAVE_ID="$2"
      shift 2
      ;;
    *)
      die "Unknown option $1"
      ;;
  esac
done

SECRET_CRYPT="$BASE/../slave/$SLAVE_ID.secret.crypt"

check_set --id "$SLAVE_ID"
check_set --jenkins-private-key "$JENKINS_PRI"
check_file_exists "$JENKINS_PRI"
check_file_exists "$SECRET_CRYPT"

# If a jenkins key is given we extract the secret from the slave files.
SECRET=$(cat $SECRET_CRYPT | base64 -d | openssl rsautl -decrypt -inkey $JENKINS_PRI)

$BASE/run-script-remote.sh                                                     \
  $REMOTE_FLAGS                                                                \
  --user "$USER"                                                               \
  --script $BASE/helpers/common.sh                                             \
  --script $BASE/helpers/vagrant-install-slave.sh                              \
  --flags "--id $SLAVE_ID --secret $SECRET"
