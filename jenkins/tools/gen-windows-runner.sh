#!/bin/bash

# Set up a machine to be a jenkins slave.

. $(dirname $0)/helpers/common.sh

REMOTE_FLAGS=
JENKINS_PRI=
SLAVE_ID=
USER=vagrant
OUT=run-jenkins-slave.bat
VARS=

while [ $# -gt 0 ]; do
  case "$1" in
    --jenkins-private-key)
      JENKINS_PRI="$2"
      shift 2
      ;;
    --id)
      SLAVE_ID="$2"
      shift 2
      ;;
    --vars)
      VARS="$2"
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
check_set --vars "$VARS"
check_file_exists "$JENKINS_PRI"
check_file_exists "$SECRET_CRYPT"

# If a jenkins key is given we extract the secret from the slave files.
SECRET=$(cat $SECRET_CRYPT | base64 -d | openssl rsautl -decrypt -inkey $JENKINS_PRI)

rm -f $OUT

if [ "$VARS" == "32" ]; then
  VCVARS="\"C:\\Program Files\\Microsoft Visual Studio 10.0\\VC\\bin\\vcvars32.bat\""
elif [ "$VARS" == "64" ]; then
  VCVARS="\"C:\\Program Files (x64)\\Microsoft Visual Studio 10.0\\VC\\vcvarsall.bat\" amd64"
else
  die "Unknown --vars $VARS, should be either 32 or 64"
fi

echo """
call $VCVARS
cd C:\\Users\\vagrant\\Jenkins
start /b cmd /c \"java -jar slave.jar -jnlpUrl http://ci.t.undra.org/computer/$SLAVE_ID/slave-agent.jnlp -secret $SECRET\"
"""
