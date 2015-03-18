#!/bin/bash

set -e

BASE=$(dirname $0)
SLAVE_ID=
JENKINS_PRI=
SECRET=

while getopts ":-:" OPTCHAR; do
  case "$OPTCHAR" in
    -)
      case "$OPTARG" in
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

# Fetch the slave jar if it's not here already.
if [ ! -f slave.jar ]; then
  wget http://ci.t.undra.org/jnlpJars/slave.jar
fi

java                                                                           \
  -jar slave.jar                                                               \
  -jnlpUrl http://ci.t.undra.org/computer/$SLAVE_ID/slave-agent.jnlp           \
  -secret $SECRET
