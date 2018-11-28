# Void Linux on Pine64 A64/A64+ (non-LTS)

Build scripts for creating void linux images for Pine64 A64/A64+ boards.

This is for the A64/A64+ (non-LTS) boards, but you can easily adopt it for pinebook or sopine by changing the Arch Linux image to appropriate board in the script. If you have pre-built kernel and uboot for A64-LTS then you can build images for A64-LTS too.

This is currently a hack. I'm extracting the Pine64 kernel + uboot from pre-built Arch Linux images by [Anarsoul](https://github.com/anarsoul/linux-build/releases), and mashing them with pre-built ROOTFS for aarch64 provided by Void Linux.

## Usage

You have to be root on the machine where you want to run these scripts as they use `losetup` command which requires root access. You also need `wget`, `xz`, `bash`.

Use `mk-void-image.sh` for 'glibc' based image and `mk-void-musl-image.sh` for 'musl' based image. The scripts will download Anarsoul's Arch Linux image and Void Linux's ROOTFS, so you need an internet connection.

The scripts are not foolproof and will fail at first error. Depending upon where it fails you may have to do some manual clean up before being able to re-run.

## DISCLAIMER

I am not officially involved with either Pine64 or Void Linux. I'm just a happy void user who wants to run it on Pine64 boards. You can cause serious damage to your equipment using these scripts and/or the images built using these scripts, and I'm not responsible if you do.
