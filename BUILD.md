# Build Instructions.
The images are build from a x86_64 host machine running Void Linux w/ `glibc` using a cross-compiler for `aarch64-musl`.


### Step 1: Build Pine64 Packages.

The various Pine64 packages are not yet submitted to the upstream void-linux repository, so you'll need to checkout my fork.

```sh 

git clone https://www.github.com/Linux-BSD/void-packages
cd void-packages
git checkout -b pine64 origin/pine64

# Bootstrap x86_64-musl.
./xbps-src -m masterdir-x86_64-musl binary-bootstrap x86_64-musl

# Set below to your <max cpu cores> -1
export CPU_CORES=8

./xbps-src -j${CPU_CORES} -m masterdir-x86_64-musl -a aarch64-musl pkg pine64-uboot

./xbps-src -j${CPU_CORES} -m masterdir-x86_64-musl -a aarch64-musl pkg pine64-kernel

./xbps-src -j${CPU_CORES} -m masterdir-x86_64-musl -a aarch64-musl pkg pine64-dkms

./xbps-src -j${CPU_CORES} -m masterdir-x86_64-musl -a aarch64-musl pkg pine64-rtl8723cs-dkms

./xbps-src -j${CPU_CORES} -m masterdir-x86_64-musl -a aarch64-musl pkg pine64-rtl8723bt-firmware

./xbps-src -j${CPU_CORES} -m masterdir-x86_64-musl -a aarch64-musl pkg pine64-base

# Sign local repository
# See https://github.com/void-linux/void-packages/blob/master/README.md#sharing-and-signing-your-local-repositories for details.

XBPS_ARCH=aarch64-musl xbps-rindex -a hostdir/binpkgs/pine64/*.xbp

XBPS_ARCH=aarch64-musl xbps-rindex -v --sign --signedby '<Your-Name>' --privkey ~/.ssh/id_rsa.pem hostdir/binpkgs/pine64

XBPS_ARCH=aarch64-musl xbps-rindex -v -S --signedby '<Your-Name>' --privkey ~/.ssh/id_rsa.pem hostdir/binpkgs/pine64/*.xbps

cd ..
```

### Step 2: Build Pine64 PlatformFS

```sh

git clone https://www.github.com/Linux-BSD/void-mklive
cd void-mklive
git checkout -b pine64 origin/pine64

sudo ./mkrootfs.sh aarch64-musl

sudo ./mkplatformfs.sh -r ../void-packages/hostdir/binpkgs/pine64 pine64-musl ./void-aarch64-musl-ROOTFS-<DATE>.tar.xz

cd ..
```

### Step 3: Build Images for various Pine64 boards/devices.

You also need `bash`, `sudo`, `xz`, `losetup` and `proot` installed on your host machine.

The scripts are not foolproof and will fail at first error. Depending upon where it fails you may have to do some manual clean up before being able to re-run.

`<BOARD>` can be either of `A64`, `A64-lts`, `Sopine`, `pinebook`, or `H64`.

```sh

git clone https://www.github.com/Linux-BSD/void-pine64
cd void-pine64
git checkout -b void-packages origin/void-packages

# SYmbolic link to the PlatformFS built in previous step
ln -s ../void-mklive/void-pine64-musl-PLATFORMFS-<DATE>.tar.xz

sudo ./mk-void-image.sh <BOARD>-musl <DATE>

sudo ./run-post-image-script.sh void-pine64-musl-<BOARD>-<DATE>.img post-image-micro.sh

sudo ./run-post-image-script.sh void-pine64-musl-<BOARD>-<DATE>.img post-image-mini-Xonly.sh

sudo ./run-post-image-script.sh void-pine64-musl-<BOARD>-<DATE>.img post-image-(LXDE|LXQT|MATE).sh
```