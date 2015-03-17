#!/bin/bash

set -v -e

if [[ $EUID -ne 0 ]]; then
  echo "Must be run by root"
  exit 1
fi

# Start the jenkins server.
/etc/init.d/jenkins start

# If necessary, extract the command-line interface from the war.
CLI=~/jenkins-cli.jar
if [ ! -f $CLI ]; then
  WAR=/usr/share/jenkins/jenkins.war
  SRC=WEB-INF/jenkins-cli.jar
  unzip -p $WAR $SRC > $CLI
fi

# Give the server a bit of time to become available, otherwise the cli will
# fail in some creative way.
sleep 60

# Install the packages, authenticating using the jenkins key that was copied
# during priming.
SERVER_URL=http://localhost:8080
KEY=~jenkins/keys/id_rsa.jenkins
java -jar $CLI -i $KEY -s $SERVER_URL install-plugin git
java -jar $CLI -i $KEY -s $SERVER_URL install-plugin ghprb
java -jar $CLI -i $KEY -s $SERVER_URL restart
