#!/usr/bin/env bash

set -e # Exit on first error

IMAGE_NAME=${1}

if [ -z "$IMAGE_NAME" -o ! -f "$IMAGE_NAME" ]; then
  echo "ERROR: Image file '$IMAGE_NAME' not found!"
  exit 255
fi

umount /dev/loop0p3 >&/dev/null || :
losetup -d /dev/loop0 >&/dev/null || :
losetup -P /dev/loop0 $IMAGE_NAME
mkdir -p sdcard/root
mount  /dev/loop0p3 ./sdcard/root

PROOT_NO_SECCOMP=1 TERM=xterm-256color proot -q qemu-aarch64-static \
	-b ./files:/opt/files \
	-b ../../void-linux/void-packages/hostdir/binpkgs/pine64:/opt/pine64 \
	-S ./sdcard/root /bin/bash 

# Tear Down
umount sdcard/root
rm -rf sdcard
losetup -d /dev/loop0
