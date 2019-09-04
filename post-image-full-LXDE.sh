#!/usr/bin/env bash

set -e # Exit on first error

ARCH=$(uname -m)

if [ ! "$ARCH" == "aarch64" ];then
  echo "ERROR: This script is meant to be run on an aarch64 based board"
  exit 255
fi

xbps-install -S
xbps-install -y dbus cgmanager ConsoleKit2 lxde \
  gnome-keyring udisks2 firefox-esr \
  lightdm lightdm-gtk3-greeter \
  alsa-utils alsa-tools pulseaudio


mkdir -p /etc/polkit-1/rules.d

cp /opt/files/etc/asound.state /etc/.
cp /opt/files/etc/polkit-1/rules.d/81-blueman.rules /etc/polkit-1/rules.d/.

enableService() {
  local service=${1:-dummy}
  [[ -L "/etc/runit/runsvdir/default/${service}" ]] || \
    ln -s /etc/sv/${service} /etc/runit/runsvdir/default/
}
enableService cgmanager
enableService consolekit
enableService dbus
enableService alsa
enableService lightdm

