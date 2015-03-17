#!/bin/bash

set -v -e

if [[ $EUID -ne 0 ]]; then
  echo "Must be run by root"
  exit 1
fi

# Secrets stashed in encrypted form in the git repo. Make new secrets by using
#
#   openssl rsa -in keys/id_rsa.jenkins -pubout > id_rsa.pub.pem
#   cat $SECRET | openssl rsautl -encrypt -pubin -inkey id_rsa.pub.pem | base64 > $SECRET.crypt
SECRETS="""
secret.key
secrets/jenkins.slaves.JnlpSlaveAgentProtocol.secret
"""

# Decrypt the jenkins secret key. We want the same one every time since the
# executor secrets depend on it.
cd ~jenkins
for SECRET in $SECRETS; do
  su jenkins -c "cat $SECRET.crypt | base64 -d | openssl rsautl -decrypt -inkey keys/id_rsa.jenkins > $SECRET"
  chmod 644 $SECRET
done

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
