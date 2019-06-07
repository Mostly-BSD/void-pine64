#!/usr/bin/env bash

set -e # Exit on first error
set -x # Echo each command

PINE64_BOARD=${1:-A64}
case "$PINE64_BOARD" in
  A64|sopine|pinebook|H64|A64-lts)
    :
    ;;
  A64-musl|sopine-musl|pinebook-musl|H64-musl|A64-lts-musl)
    PINE64_BOARD="${PINE64_BOARD%-musl}"
    MUSL="-musl"
    ;;
  *)
    echo "ERROR: Board '$PINE64_BOARD' not supported!"
    exit 255
    ;;
esac

# Change to match latest values
VOID_PINE64_PLATFORMFS_VERSION="20190607"

# Use locally built Platform/Root FS if available else fallback to void supplied Root FS.
VOID_PINE64_PLATFORMFS_FILE="void-pine64${MUSL}-PLATFORMFS-${VOID_PINE64_PLATFORMFS_VERSION}.tar.xz"

if [ ! -r "$VOID_PINE64_PLATFORMFS_FILE" ]; then
  echo "ERROR: Platform FS '$VOID_PINE64_PLATFORMFS_FILE' not found!"
  exit 255
fi

# This will be our void image 
IMAGE_NAME="void-pine64${MUSL}-${PINE64_BOARD}-${VOID_PINE64_PLATFORMFS_VERSION}.img"

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

IMAGE_SIZE=4096M # 4 GB
PART_POSITION=20480 # K
FAT_SIZE=100 #M
SWAP_SIZE=1024 # M

umount /dev/loop0p3 >&/dev/null || :
losetup -d /dev/loop0 >&/dev/null || :


rm -f $IMAGE_NAME
fallocate -l $IMAGE_SIZE $IMAGE_NAME
sleep 2

# Setup 3 partitions
# First a 100MB FAT partition to store u-boot env if needed.
# Second a 1GB Swap
# Third a ~3GB root
cat << EOF | fdisk $IMAGE_NAME
o
n
p
1
$((PART_POSITION*2))
+${FAT_SIZE}M
t
c
n
p
2
$((PART_POSITION*2+FAT_SIZE*1024*2))
+${SWAP_SIZE}M
t
2
82
n
p
3
$((PART_POSITION*2+FAT_SIZE*1024*2+SWAP_SIZE*1024*2))

t
3
83
a
3
w
EOF
sleep 2

# Use /dev/loop henceforth
losetup -P /dev/loop0 $IMAGE_NAME
sleep 2
mkfs.vfat /dev/loop0p1
sleep 2
mkswap /dev/loop0p2
sleep 2
mkfs.ext4 -L rootfs /dev/loop0p3
sleep 2

# Extract ROOTFS
mkdir -p sdcard/root
mount  /dev/loop0p3 ./sdcard/root
# Extract void ROOTFS
tar -C sdcard/root -Jpxf ${VOID_PINE64_PLATFORMFS_FILE}
sleep 2

# Setup /etc/fstab
SWAP_UUID=$(blkid --output=udev /dev/loop0p2 |grep _UUID= |cut -d= -f2)
echo 'UUID='${SWAP_UUID}'	swap	swap	defaults	0	0' >> sdcard/root/etc/fstab
ROOTFS_UUID=$(blkid --output=udev /dev/loop0p3 |grep _UUID= |cut -d= -f2)
echo 'UUID='${ROOTFS_UUID}'	/	ext4	defaults,rw,noatime	0	1' >> sdcard/root/etc/fstab

# Start some services by default
[[ -L "sdcard/root/etc/runit/runsvdir/default/sshd" ]] || ln -s /etc/sv/sshd sdcard/root/etc/runit/runsvdir/default/
[[ -L "sdcard/root/etc/runit/runsvdir/default/ntpd" ]] || ln -s /etc/sv/ntpd sdcard/root/etc/runit/runsvdir/default/
[[ -L "sdcard/root/etc/runit/runsvdir/default/dhcpcd" ]] || ln -s /etc/sv/dhcpcd sdcard/root/etc/runit/runsvdir/default/
[[ -L "sdcard/root/etc/runit/runsvdir/default/agetty-ttyS0" ]] || ln -s /etc/sv/agetty-ttyS0 sdcard/root/etc/runit/runsvdir/default/


# u-boot 
dd if=sdcard/root/boot/$BOOTLOADER of=/dev/loop0 bs=8k seek=1

# Just to be sure
sleep 2
sync
sleep 2

# Tear Down
umount sdcard/root
#umount sdcard/boot
rm -rf sdcard
losetup -d /dev/loop0
