#!/bin/bash

check_user root

apt_install """
ufw
git
"""

# Create and configure the picasso user.
if ! user_exists picasso; then
  echo Use a strong password
  adduser picasso
  gpasswd -a picasso sudo

  # Set up ssh keys.
  as_user picasso "mkdir -p ~picasso/.ssh && chmod 700 ~picasso/.ssh"
  as_user picasso touch ~picasso/.ssh/authorized_keys
  cat ~/.ssh/authorized_keys > ~picasso/.ssh/authorized_keys
  as_user picasso chmod 644 ~picasso/.ssh/authorized_keys
fi

# Change ssh configuration
replace_line /etc/ssh/sshd_config "Port 22" "Port 374"
replace_line /etc/ssh/sshd_config "PermitRootLogin yes" "PermitRootLogin no"
service ssh restart

ufw allow 374/tcp
ufw default deny incoming
ufw enable
ufw status
