#!/bin/bash

# Set up a machine to be a jenkins slave.

. $(dirname $0)/helpers/common.sh

REMOTE_FLAGS=
JENKINS_PRI=
SLAVE_ID=
USER=vagrant
OUT=run-jenkins-slave.bat
MSVS_YEAR=
MSVS_ARCH_WIDTH=

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
    --msvs-year)
      MSVS_YEAR="$2"
      shift 2
      ;;
    --msvs-arch-width)
      MSVS_ARCH_WIDTH="$2"
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
check_set --msvs-year "$MSVS_YEAR"
check_set --msvs-arch-width "$MSVS_ARCH_WIDTH"
check_file_exists "$JENKINS_PRI"
check_file_exists "$SECRET_CRYPT"

# If a jenkins key is given we extract the secret from the slave files.
SECRET=$(cat $SECRET_CRYPT | base64 -d | openssl rsautl -decrypt -inkey $JENKINS_PRI)

# year/vs-version/api-version
MSVS_INFO="""
2010/10.0/7.0
2012/11.0/7.1
2013/12.0/8.1
2015/14.0/8.1
"""

rm -f $OUT

MSVS_VERSION=
for INFO in $MSVS_INFO; do
  YEAR=$(echo "$INFO" | cut -f1 -d/)
  if [ "$YEAR" == "$MSVS_YEAR" ]; then
    MSVS_VERSION=$(echo "$INFO" | cut -f2 -d/)
  fi
done

if [ -z "$MSVS_VERSION" ]; then
  die "Unknown MSVS year $MSVS_YEAR"
fi

if [ "$MSVS_ARCH_WIDTH" == "32" ]; then
  VCVARS="\"C:\\Program Files\\Microsoft Visual Studio $MSVS_VERSION\\VC\\bin\\vcvars32.bat\""
else
  VCVARS="\"C:\\Program Files\\Microsoft SDKs\\Windows\\v7.1\\Bin\\SetEnv.Cmd\" /x64"
fi

echo """
call $VCVARS
cd C:\\Users\\vagrant\\Jenkins
start /b cmd /c \"java -jar slave.jar -jnlpUrl http://ci.t.undra.org/computer/$SLAVE_ID/slave-agent.jnlp -secret $SECRET\"
"""
