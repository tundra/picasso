#!/bin/bash

check_user picasso

function as_jenkins {
  as_user jenkins "$*"
}

# Add the jenkins package repo.
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
as_root "echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list"
sudo apt-get update

# Install apt packages.
apt_install --sudo """
git
jenkins
unzip
"""

# Set the jenkins password. Use the generated strong password. We're going to
# need this to log into the web interface which uses LDAP for authentication.
echo Use the generated strong password.
sudo passwd jenkins

# Remap such that traffic to :80 goes to :8080. That way they both work which is
# nice.
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to 8080

# Allow the jenkins ports through the firewall.
sudo ufw allow 80/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 45678/tcp
sudo ufw status

# Check out the jenkins project under the jenkins user.
if [ ! -d ~jenkins/picasso ]; then
  as_jenkins git clone https://github.com/tundra/picasso.git ~jenkins/picasso
fi

# Create the keys directory if it doesn't already exist.
JENKINS_HOME=/var/lib/jenkins/picasso/jenkins/home
JENKINS_KEYS=$JENKINS_HOME/keys
JENKINS_KEY=$JENKINS_KEYS/jenkins_id_rsa
if [ ! -d $JENKINS_KEYS ]; then
  as_jenkins mkdir -p $JENKINS_KEYS
fi

sudo mv ~/jenkins_id_rsa $JENKINS_KEY
sudo chown jenkins $JENKINS_KEY

# Set the jenkins home dir to be within the picasso source.
replace_line --sudo /etc/default/jenkins "JENKINS_HOME=/var/lib/jenkins" "JENKINS_HOME=$JENKINS_HOME"

# Go to the jenkins home since the secret paths are relative to that.
cd $JENKINS_HOME

# Secrets stashed in encrypted form in the git repo. Make new secrets by using
#
#   openssl rsa -in keys/id_rsa.jenkins -pubout > id_rsa.pub.pem
#   cat $SECRET | openssl rsautl -encrypt -pubin -inkey id_rsa.pub.pem | base64 > $SECRET.crypt
SECRETS="""
secrets/jenkins.slaves.JnlpSlaveAgentProtocol.secret
secrets/master.key
"""

for SECRET in $SECRETS; do
  as_jenkins "cat $SECRET.crypt | base64 -d | openssl rsautl -decrypt -inkey $JENKINS_KEY > $SECRET"
  sudo chmod 644 $SECRET
done

# Start the jenkins server.
sudo /etc/init.d/jenkins start

# If necessary, extract the command-line interface from the war.
CLI=$JENKINS_HOME/jenkins-cli.jar
if [ ! -f $CLI ]; then
  WAR=/usr/share/jenkins/jenkins.war
  SRC=WEB-INF/jenkins-cli.jar
  as_root "unzip -p $WAR $SRC > $CLI"
  sudo chown jenkins $CLI
fi

# Give the server a bit of time to become available, otherwise the cli will
# most likely fail.
sleep 60

# Install required plugins.

PLUGINS="""
git
ghprb
xshell
conditional-buildstep
"""

SERVER_URL=http://localhost:8080
for PLUGIN in $PLUGINS; do
  as_jenkins java -jar $CLI -i $JENKINS_KEY -s $SERVER_URL install-plugin $PLUGIN
done

# Restart so the installs take effect.
as_jenkins java -jar $CLI -i $JENKINS_KEY -s $SERVER_URL restart
