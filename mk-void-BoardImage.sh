#!/usr/bin/env bash

set -e # Exit on first error
set -x # Echo each command

PINE64_BOARD=${1:-A64}
case "$PINE64_BOARD" in
  A64|sopine|pinebook|H64|A64-lts)
    :
    ;;
  *)
    echo "ERROR: Board '$PINE64_BOARD' not supported!"
    exit 255
    ;;
esac

# Default PlatformFS ver. is 20190905
VOID_PINE64_BASE_IMAGE="${2:-void-pine64-musl-20200405.img}"

if [ ! -r "$VOID_PINE64_BASE_IMAGE" ]; then
  echo "ERROR: Base Image '$VOID_PINE64_BASE_IMAGE' not found!"
  exit 255
fi

# This will be our void image 
IMAGE_NAME="$(echo $VOID_PINE64_BASE_IMAGE | sed 's/\(-[^-]\+\.img\)/-'${PINE64_BOARD}'\1/')"
echo "Creating Board image file '$IMAGE_NAME'"
cp $VOID_PINE64_BASE_IMAGE $IMAGE_NAME

case "$PINE64_BOARD" in
  A64)
    BOOTLOADER="u-boot-sunxi-with-spl-pine64.bin"
    ;;
  sopine)
    BOOTLOADER="u-boot-sunxi-with-spl-sopine.bin"
    ;;
  pinebook)
    BOOTLOADER="u-boot-sunxi-with-spl-pinebook.bin"
    ;;
  H64)
    BOOTLOADER="u-boot-sunxi-with-spl-pine-h64.bin"
    ;;
  A64-lts)
    BOOTLOADER="u-boot-sunxi-with-spl-pine64-lts.bin"
    ;;
esac

if [ ! -f "$BOOTLOADER" ]; then #TODO correct path
  echo "U-boot for $PINE64_BOARD board - $BOOTLOADER not found!"
  exit 255
fi

LOOP_DEVICE=`losetup -f`
echo "Using $LOOP_DEVICE as a loop device"
losetup -P ${LOOP_DEVICE} $IMAGE_NAME
sleep 2

# u-boot 
dd if=$BOOTLOADER of=${LOOP_DEVICE} bs=8k seek=1

# Just to be sure
sleep 2
sync
sleep 2

losetup -d ${LOOP_DEVICE}

echo "All Done!"
