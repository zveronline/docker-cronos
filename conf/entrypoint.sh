#!/bin/bash
set -e

set_root_passwd() {
  echo "root:$ROOT_PASS" | chpasswd
}

# Set root password from the commandline
set_root_passwd
if [[ $NOPRIVUSER == True && ! -f /etc/usercreated ]]
then
addgroup -g $NOPRIVUSER_GID $NOPRIVUSER_NAME
adduser -D -u $NOPRIVUSER_UID $NOPRIVUSER_NAME -G $NOPRIVUSER_NAME -s /bin/bash
echo "$NOPRIVUSER_NAME:$NOPRIVUSER_PASS" | chpasswd
touch /etc/usercreated
fi
if [ ! -d /opt/webmin* ]
then
  wget http://prdownloads.sourceforge.net/webadmin/webmin-$WEBMIN_VERSION.tar.gz
  tar xvfz webmin-*.tar.gz -C /opt/
  rm -f webmin-*.tar.gz
  /usr/bin/expect -f /install.exp $WEBMIN_USERNAME $WEBMIN_PASSWORD $WEBMIN_VERSION
  /etc/webmin/stop
fi
if [ ! -f /etc/ssh/ssh_host_rsa_key ]
then
  ssh-keygen -A
fi
if [ ! -f /root/.ssh/id_rsa ]
then
  ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -P ""
fi
if [ ! -f /etc/ssh/sshd_config ]
then
  cp /etc/sshd_config /etc/ssh/
fi
if [ ! -d /var/log/cron ]
then
  mkdir -p /var/log/cron && touch /var/log/cron/cron.log && ln -s /etc/crontabs /var/spool/cron/ && ln -s /etc/periodic /var/spool/cron/
fi
exec "$@"
