#!/bin/bash

# Set up a slave base image. This only installs enough that the machine can be
# packaged into a vagrant box, it leaves out almost everything needed to
# actually run a jenkins slave to keep image size down.

set -e

BASE=$(dirname $0)
REMOTE_FLAGS=--tty
VAGRANT_PUB=
JENKINS_PRI=
SSH_FLAGS=
HOST=
SLAVE_ID=

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
          SSH_FLAGS="$SSH_FLAGS -p${!OPTIND}"
          REMOTE_FLAGS="$REMOTE_FLAGS --port $PORT"
          OPTIND=$(($OPTIND + 1))
          ;;
        vagrant-public-key)
          VAGRANT_PUB="${!OPTIND}"
          OPTIND=$(($OPTIND + 1))
          ;;
        jenkins-private-key)
          JENKINS_PRI="${!OPTIND}"
          OPTIND=$(($OPTIND + 1))
          ;;
        id)
          SLAVE_ID="${!OPTIND}"
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

if [ -z "$SLAVE_ID" ]; then
  echo "No --id specified"
  exit 1
fi

if [ -z "$VAGRANT_PUB" ]; then
  echo "No --vagrant-public-key specified"
  exit 1
fi

if [ ! -f "$VAGRANT_PUB" ]; then
  echo "Public key $VAGRANT_PUB doesn't exist"
  exit 1
fi

if [ -z "$JENKINS_PRI" ]; then
  echo "No --jenkins-private-key specified"
  exit 1
fi

if [ ! -f "$JENKINS_PRI" ]; then
  echo "Private key $JENKINS_PRI doesn't exist"
  exit 1
fi

SECRET_CRYPT="$BASE/../slave/$SLAVE_ID.secret.crypt"
if [ ! -f $SECRET_CRYPT ]; then
  echo "Couldn't find slave secret $SECRET_CRYPT"
  exit 1
fi

# If a jenkins key is given we extract the secret from the slave files.
SECRET=$(cat $SECRET_CRYPT | base64 -d | openssl rsautl -decrypt -inkey $JENKINS_PRI)

if [ -z "$HOST" ]; then
  echo "No --host specified"
  exit 1
fi

ssh-copy-id -i $VAGRANT_PUB $SSH_FLAGS vagrant@$HOST

$BASE/run-script-remote.sh                                                     \
  $REMOTE_FLAGS                                                                \
  --user vagrant                                                               \
  --script $BASE/helpers/vagrant-prime-slave-base-image.sh                     \
  --flags "--id $SLAVE_ID --secret $SECRET"
