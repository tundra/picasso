#!/bin/bash

set -x -e

SECRET=
SLAVE_ID=

while getopts ":-:" OPTCHAR; do
  case "$OPTCHAR" in
    -)
      case "$OPTARG" in
        id)
          SLAVE_ID="${!OPTIND}"
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

if [ -z "$SECRET" ]; then
  echo "No --secret specified"
  exit 1
fi

cd /home/vagrant

# Store the jenkins configuration for later use.
echo -jnlpUrl http://ci.t.undra.org/computer/$SLAVE_ID/slave-agent.jnlp -secret $SECRET > jenkins-flags.txt
chmod 600 jenkins-flags.txt

# These are just the packages we need to make the base box. We'll install the
# rest later.
PACKAGES="""
git
default-jre
runit
python-pip
"""

# Install required packages.
sudo apt-get update
for PACKAGE in $PACKAGES; do
  sudo apt-get install -y $PACKAGE
done

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
