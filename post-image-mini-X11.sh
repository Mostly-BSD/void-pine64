#!/usr/bin/env bash

set -e # Exit on first error

ARCH=$(uname -m)

if [ ! "$ARCH" == "aarch64" ];then
  echo "ERROR: This script is meant to be run on an aarch64 based board"
  exit 255
fi

xbps-install -S
xbps-install -y  \
  xorg-minimal xorg-fonts xorg-apps xterm \
	xlsfonts rxvt-unicode xf86-video-fbdev mesa-demos

mkdir -p /etc/X11

cp /opt/files/etc/X11/xorg.conf.d/modesetting.conf  /etc/X11/xorg.conf
