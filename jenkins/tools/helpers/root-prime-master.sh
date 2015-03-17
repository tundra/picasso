#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
  echo "Must be run by root"
  exit 1
fi

# Add the jenkins package repo.
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list
apt-get update

# Install packages.
apt-get install -y git
apt-get install -y jenkins
apt-get install -y unzip

# Set the jenkins password. Use the generated strong password. We're going to
# need this to log into the web interface which uses LDAP for authentication.
echo Use the generated strong password.
passwd jenkins

# Remap such that traffic to :80 goes to :8080. That way they both work which is
# nice.
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to 8080

# Check out the jenkins project under the jenkins user.
if [ ! -f /home/jenkins ]; then
  mkdir -p /home/jenkins
  chown jenkins /home/jenkins
  cd /home/jenkins
  su jenkins -c "git clone https://github.com/tundra/jenkins.git"
  su jenkins -c "mkdir -p jenkins/home/keys"
fi

# Get rid of the generated jenkins home, remap it to the github project. We have
# to test explicitly in the condition for it being a symlink since -d follows
# symlinks.
if [ -d /var/lib/jenkins -a ! -h /var/lib/jenkins ]; then
  rmdir /var/lib/jenkins
  ln -s /home/jenkins/jenkins/home /var/lib/jenkins
fi
