#!/bin/bash

# Starts a jenkins build slave. To run, the slave must have an id and a secret
# that matches that id. You can either pass the jenkins private key and the
# secret will be extracted automatically, or alternatively pass a secret
# explicitly. You can also run remotely by passing a host/port/user and the
# secret will be extracted here (on this machine) and passed to the target
# machine where it'll be used to run the slave.

set -e

BASE=$(dirname $0)
SLAVE_ID=
JENKINS_PRI=
SECRET=
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
          REMOTE_FLAGS="$REMOTE_FLAGS --port ${!OPTIND}"
          OPTIND=$(($OPTIND + 1))
          ;;
        user)
          REMOTE_FLAGS="$REMOTE_FLAGS --user ${!OPTIND}"
          OPTIND=$(($OPTIND + 1))
          ;;
        id)
          SLAVE_ID="${!OPTIND}"
          OPTIND=$(($OPTIND + 1))
          ;;
        jenkins-private-key)
          JENKINS_PRI="${!OPTIND}"
          OPTIND=$(($OPTIND + 1))
          ;;
        secret)
          SECRET="${!OPTIND}"
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

if [ ! -z "$JENKINS_PRI" ]; then
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
elif [ -z "$SECRET" ]; then
  echo "No --jenkins-private-key or --secret specified"
  exit 1
fi

if [ ! -z "$REMOTE_FLAGS" ]; then
  $BASE/run-script-remote.sh $REMOTE_FLAGS --script $BASE/run-slave.sh --flags "--id $SLAVE_ID --secret $SECRET"

else
  # There are no remote flags so we run locally.

  # Fetch the slave jar if it's not here already.
  if [ ! -f slave.jar ]; then
    wget http://ci.t.undra.org/jnlpJars/slave.jar
  fi

  # Start the slave agent.
  java                                                                           \
    -jar slave.jar                                                               \
    -jnlpUrl http://ci.t.undra.org/computer/$SLAVE_ID/slave-agent.jnlp           \
    -secret $SECRET
fi