#!/bin/sh

# Add ssh user & password
if [ -z "/$SSHUSER" ] || [ -z "/$SSHPASS" ]; then
  exit 1
fi
adduser -h /home/$SSHUSER -s /bin/sh -D $SSHUSER
echo -n adb:$SSHPASS | chpasswd

# Start ssh as daemon service
ssh-keygen -A
if [ -z "$(ls -A ssh)" ]; then
  cp -rf /etc/ssh/ssh_* ssh/. >/dev/null 2>&1
fi
chmod 600 ssh/ssh_*  >/dev/null 2>&1
cp -rf ssh/ssh_* /etc/ssh/. >/dev/null 2>&1
/usr/sbin/sshd

# Start adb as daemon service
platform-tools/adb -a -P 5037 server

# Run ws-scrcpy
node ws-scrcpy/dist/index.js
