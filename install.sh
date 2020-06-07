#!/usr/bin/env bash

if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR! This script must be run as root."
  exit 1
fi

if ! which pihole &>/dev/null; then
  echo "ERROR! Can't find pihole."
  exit 1
fi

if [ ! -d "/etc/pihole" ]; then
  echo "ERROR! Directory /etc/pihole does not exist."
  exit 1
fi

if [ ! -f "/etc/pihole/gravity.db" ]; then
  echo "ERROR! Pi-hole database /etc/pihole/gravity.db does not exist."
  exit 1
fi

for i in adlists.list.default pi-hole-adlists.service pi-hole-adlists.sh pi-hole-adlists.timer; do
  if [ ! -f "$i" ]; then
    echo "ERROR! At least one file is missing:"
    echo "       $i"
    exit 1
  fi
done

if [ ! -f "/etc/pihole/adlists.list.default" ]; then
  cp -v adlists.list.default /etc/pihole/
  chown -v $(stat -c "%U:%G" /etc/pihole/) /etc/pihole/adlists.list.default
fi
cp -v pi-hole-adlists.service /etc/systemd/system/
cp -v pi-hole-adlists.timer /etc/systemd/system/
cp -v pi-hole-adlists.sh /usr/local/sbin/

systemctl enable pi-hole-adlists.timer
systemctl start pi-hole-adlists.timer

exit 0
