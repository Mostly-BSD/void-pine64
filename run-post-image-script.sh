#!/usr/bin/env bash

set -e # Exit on first error

IMAGE_NAME=${1}

if [ -z "$IMAGE_NAME" -o ! -f "$IMAGE_NAME" ]; then
  echo "ERROR: Image file '$IMAGE_NAME' not found!"
  exit 255
fi

SCRIPT_NAME=${2}

if [ -z "$SCRIPT_NAME" -o ! -f "$SCRIPT_NAME" ]; then
  echo "ERROR: Post-install script '$SCRIPT_NAME' not found!"
  exit 255
fi

LOOP_DEVICE=`losetup -f`
losetup -P ${LOOP_DEVICE} $IMAGE_NAME
mkdir -p sdcard/root
mount  ${LOOP_DEVICE}p3 ./sdcard/root

cp ${SCRIPT_NAME} /tmp/.
chmod +x /tmp/${SCRIPT_NAME}
PROOT_NO_SECCOMP=1 TERM=xterm-256color proot -q qemu-aarch64-static \
	-b ./files:/opt/files \
	-b ../../void-linux/void-packages/hostdir/binpkgs/pine64:/opt/pine64 \
	-S ./sdcard/root /tmp/${SCRIPT_NAME}
rm -f /tmp/${SCRIPT_NAME}

# Tear Down
umount sdcard/root
rm -rf sdcard
losetup -d ${LOOP_DEVICE}
