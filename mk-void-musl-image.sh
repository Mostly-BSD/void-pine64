#!/usr/bin/env bash

set -e # Exit on first error
set -x # Echo each command

# Change to match latest values
ARCH_IMAGE_VERSION="20181104"
VOID_ROOTFS_VERSION="20181111"

# We will use anarsoul's Arch Linux image to extract kernel + uboot
ARCH_IMAGE_NAME="archlinux-xfce-pine64-${ARCH_IMAGE_VERSION}.img"
ARCH_IMAGE_URL="https://github.com/anarsoul/linux-build/releases/download/${ARCH_IMAGE_VERSION}/${ARCH_IMAGE_NAME}.xz"

if [ ! -f "$ARCH_IMAGE_NAME" ]; then
  echo "Downloading Arch Linux Image"
  wget "$ARCH_IMAGE_URL" 
  echo "Extracting Arch Linux Image"
  xz --decompress ${ARCH_IMAGE_NAME}.xz
fi

# We'll use aarch64 ROOTFS supplied by Void Linux
VOID_ROOTFS_NAME="void-aarch64-musl-ROOTFS-${VOID_ROOTFS_VERSION}.tar.xz"
VOID_ROOTFS_URL="https://alpha.de.repo.voidlinux.org/live/current/${VOID_ROOTFS_NAME}"

if [ ! -f "$VOID_ROOTFS_NAME" ]; then
  echo "Downloading Void Linux ROOTFS"
  wget "$VOID_ROOTFS_URL" 
fi

# This will be our void image 
IMAGE_NAME="${1:-void-aarch64-musl-pine-A64plus.img}"
BOOTLOADER="u-boot-sunxi-with-spl-pine64.bin"
IMAGE_SIZE=4096M # 4 GB
PART_POSITION=20480 # K
FAT_SIZE=100 #M
SWAP_SIZE=1024 # M

losetup -d /dev/loop1 >&/dev/null || :
losetup -d /dev/loop0 >&/dev/null || :

# We're going to copy Uboot + Kernel from Arch image
losetup -P /dev/loop1 ${ARCH_IMAGE_NAME}
mkdir -p arch/root
mount /dev/loop1p3 arch/root

rm -f $IMAGE_NAME
fallocate -l $IMAGE_SIZE $IMAGE_NAME
sleep 2

# Setup 3 partitions
# First a useless 100MB FAT partition coz I think bootloader wants one
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
mkdir -p sdcard/{boot,root}
#mount -t vfat /dev/loop0p1 ./sdcard/boot # Not Needed
mount  /dev/loop0p3 ./sdcard/root
# Extract void ROOTFS
tar -C sdcard/root -Jpxf ${VOID_ROOTFS_NAME}
sleep 2

# Copy Kernel + Uboot from Arch Image to Void image
rm -rf sdcard/root/boot
cp -a arch/root/boot sdcard/root/.
cp -a arch/root/lib/modules sdcard/root/lib/.
cp -a arch/root/lib/firmware sdcard/root/lib/.
cp -a arch/root/usr/src sdcard/root/usr/.
sleep 2
sync

# Setup /etc/fstab
#BOOT_UUID=$(blkid --output=udev /dev/loop0p1 |grep _UUID= |cut -d= -f2) # Not Needed
ROOTFS_UUID=$(blkid --output=udev /dev/loop0p3 |grep _UUID= |cut -d= -f2)
echo 'UUID='${ROOTFS_UUID}'	/	ext4	defaults,rw,noatime	0	1' >> sdcard/root/etc/fstab
#echo 'UUID='${BOOT_UUID}'	/boot	vfat	defaults,rw,noatime	0	0' >> sdcard/root/etc/fstab # Not Needed

# Start some services by default
ln -s /etc/sv/sshd sdcard/root/etc/runit/runsvdir/default/
ln -s /etc/sv/ntpd sdcard/root/etc/runit/runsvdir/default/
ln -s /etc/sv/dhcpcd sdcard/root/etc/runit/runsvdir/default/
ln -s /etc/sv/agetty-ttyS0 sdcard/root/etc/runit/runsvdir/default/


# UBoot
dd if=arch/root/boot/$BOOTLOADER of=/dev/loop0 bs=8k seek=1

# Just to be sure
sleep 2
sync
sleep 2

# Tear Down
umount sdcard/root
#umount sdcard/boot
rm -rf sdcard
losetup -d /dev/loop0

umount arch/root
rm -rf arch
losetup -d /dev/loop1
