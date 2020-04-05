#!/usr/bin/env bash

set -e # Exit on first error
#set -x # Echo each command


VOID_PINE64_PLATFORMFS_FILE="${1}"

if [ -z "$VOID_PINE64_PLATFORMFS_FILE" -o ! -r "$VOID_PINE64_PLATFORMFS_FILE" ]; then
  echo "ERROR: Platform FS '$VOID_PINE64_PLATFORMFS_FILE' not found!"
  exit 255
fi

# PlatformFS Version
VOID_PINE64_PLATFORMFS_VERSION="$(echo $VOID_PINE64_PLATFORMFS_FILE | egrep -o '[0-9]{8}')"
MUSL="$(echo $VOID_PINE64_PLATFORMFS_FILE | egrep -o '\-musl')"

# This will be our void image 
IMAGE_NAME="void-pine64${MUSL}-${VOID_PINE64_PLATFORMFS_VERSION}.img"

IMAGE_SIZE=4096M # 4 GB
PART_POSITION=20480 # K
FAT_SIZE=100 #M
SWAP_SIZE=1024 # M

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
LOOP_DEVICE=`losetup -f`
echo "Using $LOOP_DEVICE as a loop device"
losetup -P ${LOOP_DEVICE} $IMAGE_NAME
sleep 2
mkfs.vfat ${LOOP_DEVICE}p1
sleep 2
mkswap ${LOOP_DEVICE}p2
sleep 2
mkfs.ext4 -L rootfs ${LOOP_DEVICE}p3
sleep 2

# Extract ROOTFS
echo "Extracting RootFS"
mkdir -p sdcard/root
mount  ${LOOP_DEVICE}p3 ./sdcard/root
# Extract void ROOTFS
tar -C sdcard/root -Jpxf ${VOID_PINE64_PLATFORMFS_FILE}
sleep 2

# Setup /etc/fstab
echo "Setting up /etc/fstab"
SWAP_UUID=$(blkid --output=udev ${LOOP_DEVICE}p2 |grep _UUID= |cut -d= -f2)
echo 'UUID='${SWAP_UUID}'	swap	swap	defaults	0	0' >> sdcard/root/etc/fstab
ROOTFS_UUID=$(blkid --output=udev ${LOOP_DEVICE}p3 |grep _UUID= |cut -d= -f2)
echo 'UUID='${ROOTFS_UUID}'	/	ext4	defaults,rw,noatime	0	1' >> sdcard/root/etc/fstab

# Start some services by default
echo "Setting up sshd, ntpd, dhcpcd, and agetty-ttys0 to start on boot"
[[ -L "sdcard/root/etc/runit/runsvdir/default/sshd" ]] || \
  ln -s /etc/sv/sshd sdcard/root/etc/runit/runsvdir/default/

[[ -L "sdcard/root/etc/runit/runsvdir/default/ntpd" ]] || \
  ln -s /etc/sv/ntpd sdcard/root/etc/runit/runsvdir/default/

[[ -L "sdcard/root/etc/runit/runsvdir/default/dhcpcd" ]] || \
  ln -s /etc/sv/dhcpcd sdcard/root/etc/runit/runsvdir/default/

[[ -L "sdcard/root/etc/runit/runsvdir/default/agetty-ttyS0" ]] || \
  ln -s /etc/sv/agetty-ttyS0 sdcard/root/etc/runit/runsvdir/default/

# Stop unneeded tty services
touch sdcard/root/etc/sv/agetty-tty{2,3,4,5,6}/down

echo "Copying pine64 packages to the image"
VOID_ARCH_REPO=${VOID_ARCH_REPO:-/opt/github_repos/void-linux/void-packages/hostdir/binpkgs/pine64}
if [ -d "${VOID_ARCH_REPO}" ]; then
  cp -a ${VOID_ARCH_REPO} sdcard/root/opt/pine64-repo
  chown root:root sdcard/root/opt/pine64-repo
fi

# Just to be sure
sleep 2
sync
sleep 2

# Some finishing touches
echo "Executing post install script"
rm -f ./sdcard/root/boot/initramfs*
cp post-image-pico.sh /tmp/.
chmod +x /tmp/post-image-pico.sh
PROOT_NO_SECCOMP=1 TERM=xterm-256color proot -q qemu-aarch64-static -S ./sdcard/root /tmp/post-image-pico.sh
rm -f /tmp/post-image-pico.sh

# Tear Down
echo "Remove temp folders/files/mounts"
umount sdcard/root
rm -rf sdcard
losetup -d ${LOOP_DEVICE}

echo "All Done!"
