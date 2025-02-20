#!/bin/sh

# Add ssh user & password
if [ -z "/$SSHUSER" ] || [ -z "/$SSHPASS" ]; then
  exit 1
fi
adduser -h /home/$SSHUSER -s /bin/sh -D $SSHUSER
echo -n adb:$SSHPASS | chpasswd

# Set ssh key
ssh-keygen -A
if [ -z "$(ls -A ssh)" ]; then
  cp -rf /etc/ssh/ssh_* ssh/. >/dev/null 2>&1
fi
chmod 600 ssh/ssh_*  >/dev/null 2>&1
cp -rf ssh/ssh_* /etc/ssh/. >/dev/null 2>&1

# Start supervisord
supervisord -n -c /etc/supervisord.conf
