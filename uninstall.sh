#!/usr/bin/env bash

if [ $(id -u) -ne 0 ]; then
  echo "ERROR! This script must be run as root."
  exit 1
fi

if [ -f /etc/systemd/system/pi-hole-adlists.timer ]; then
  systemctl disable pi-hole-adlists.timer
  systemctl stop pi-hole-adlists.timer
  rm -v /etc/systemd/system/pi-hole-adlists.timer
fi

if [ -f /etc/systemd/system/pi-hole-adlists.service ]; then
  rm -v /etc/systemd/system/pi-hole-adlists.service
fi

if [ -f /usr/local/sbin/pi-hole-adlists.sh ]; then
  rm -v /usr/local/sbin/pi-hole-adlists.sh
fi

if [ -f /usr/local/bin/pi-hole-adlists.sh ]; then
  rm -v /usr/local/bin/pi-hole-adlists.sh
fi
