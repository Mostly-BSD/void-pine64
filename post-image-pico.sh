#!/usr/bin/env bash

ARCH=$(uname -m)

if [ ! "$ARCH" == "aarch64" ];then
  echo "ERROR: This script is meant to be run on an aarch64 based board"
  exit 255
fi

grep -q chrony /etc/passwd
if [ $? -ne 0 ]; then
  xbps-reconfigure -f chrony
fi

if [ ! -f /boot/initramfs-linux.img ]; then
  xbps-reconfigure -f pine64-kernel
fi

