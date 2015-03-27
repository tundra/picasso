#!/bin/bash

SECRET=
SLAVE_ID=

while [ $# -gt 0 ]; do
  case "$1" in
    --id)
      SLAVE_ID="$2"
      shift 2
      ;;
    --secret)
      SECRET="$2"
      shift 2
      ;;
    *)
      die "Unknown option $1"
      ;;
  esac
done

check_set --id "$SLAVE_ID"
check_set --secret "$SECRET"

cd /home/vagrant

# Store the jenkins configuration for later use.
FLAGS_FILE=jenkins-flags.txt
echo -jnlpUrl http://ci.t.undra.org/computer/$SLAVE_ID/slave-agent.jnlp -secret $SECRET > $FLAGS_FILE
chmod 600 $FLAGS_FILE

# These are just the packages we need to make the base box. We'll install the
# rest later.
apt_install --sudo """
git
default-jre
runit
python-pip
"""

# Fetch the slave jar if it's not here already.
if [ ! -f slave.jar ]; then
  wget http://ci.t.undra.org/jnlpJars/slave.jar
fi

# Create then jenkins homedir.
JENKINS_HOME=/var/lib/jenkins
if [ ! -d $JENKINS_HOME ]; then
  sudo mkdir -p $JENKINS_HOME
  sudo chown vagrant $JENKINS_HOME
fi

# Fetch picasso
if [ ! -d picasso ]; then
  git clone http://github.com/tundra/picasso
fi

# Install as runit service.
JENKINS_SV=/etc/service/jenkins
if [ ! -d $JENKINS_SV ]; then
  HELPERS=/home/vagrant/picasso/jenkins/tools/helpers
  sudo mkdir -p $JENKINS_SV/log
  sudo ln -s $HELPERS/sv-run-slave.sh $JENKINS_SV/run
  sudo ln -s $HELPERS/sv-log-slave.sh $JENKINS_SV/log/run
fi
