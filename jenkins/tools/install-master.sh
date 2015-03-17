#!/bin/bash

# Main script for setting up a jenkins master on a clean machine. Well, when I
# say clean I mean: you better have ssh keys set up or you'll find yourself
# entering passwords a *lot*.

set -e

BASE=$(dirname $0)
REMOTE_FLAGS=
ACCESS_PUB=
JENKINS_PRI=
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
        access-public-key)
          ACCESS_PUB="${!OPTIND}"
          OPTIND=$(($OPTIND + 1))
          ;;
        jenkins-private-key)
          JENKINS_PRI="${!OPTIND}"
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

if [ -z "$ACCESS_PUB" ]; then
  echo "No --access-public-key specified"
  exit 1
fi

if [ ! -f "$ACCESS_PUB" ]; then
  echo "Public key $ACCESS_PUB doesn't exist"
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

# Prime the master, creating user jenkins etc.
$BASE/run-script-remote.sh $REMOTE_FLAGS --user root --script $BASE/helpers/root-prime-master.sh

# Add the public key to the jenkins user.
cat $ACCESS_PUB | $BASE/run-script-remote.sh $REMOTE_FLAGS --user root --script $BASE/helpers/root-install-key.sh

# Copy the jenkins identity to the machine such that it can "be" jenkins.
scp -P$PORT $JENKINS_PRI jenkins@$HOST:/home/jenkins/jenkins/home/keys/id_rsa.jenkins

# Finally, start jenkins running.
$BASE/run-script-remote.sh $REMOTE_FLAGS --user root --script $BASE/helpers/root-start-jenkins.sh
