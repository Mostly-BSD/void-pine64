#!/usr/bin/env bash

set -e # Exit on first error

ARCH=$(uname -m)

if [ ! "$ARCH" == "aarch64" ];then
  echo "ERROR: This script is meant to be run on an aarch64 based board"
  exit 255
fi

xbps-install -S
xbps-install -y fcron at socklog socklog-void iptables ncurses-term htop sudo

groupadd -r sudo

cp /opt/files/etc/iptables/*.rules /etc/iptables/.

# Enable services

enableService() {
  local service=${1:-dummy}
  [[ -L "/etc/runit/runsvdir/default/${service}" ]] || \
    ln -s /etc/sv/${service} /etc/runit/runsvdir/default/
}

enableService crond
enableService at
enableService iptables
enableService socklog-unix
enableService nanoklogd
