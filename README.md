# Void Linux on Pine64 A64/A64+ (non-LTS)

Build scripts for creating void linux images for Pine64 A64/A64+ (non-LTS) boards.

**This is currently a hack.** I'm extracting the A64/A64+ (non-LTS) kernel + uboot from pre-built Arch Linux images by [Anarsoul](https://github.com/anarsoul/linux-build/releases) and using the pre-built ROOTFS for aarch64 provided by [Void Linux](https://alpha.de.repo.voidlinux.org/live/current/).

It should be easy to adpot the scripts to make similar images for the Sopine module, A64/A64+ LTS boards, and the Pinebook.

## Usage

Transfer either the glibc or the musl based image depending upon your preference to a micro-SD card and boot up. 

## Build Instructions

You have to be root on the machine where you want to run these scripts as they use the `losetup` command which requires root access. You also need `wget`, `xz`, `bash`.

Use `mk-void-image.sh` for 'glibc' based image and `mk-void-musl-image.sh` for 'musl' based image. The scripts will download Anarsoul's Arch Linux image and Void Linux's ROOTFS, so you need an internet connection.

The scripts are not foolproof and will fail at first error. Depending upon where it fails you may have to do some manual clean up before being able to re-run.

## DISCLAIMER

I am not officially involved with either Pine64 or Void Linux. I'm just a happy void user who wants to run it on Pine64 boards. You can cause serious damage to your equipment using these scripts and/or the images built using these scripts, and I'm not responsible if you do.

## TODOs

- \[ ] Make proper void packages for Pine64 kernel & uboot.
- \[ ] Use `void-mklive` repo to create a Pine64 Platform FS.
- \[ ] Make images for Pinebook, Sopine, and A64/A64+ (LTS) boards.
- \[ ] Make images for Rock64, RockPro64, and PineH64 boards.
- \[ ] Submit Changes to void-linux upstream for proper support of Pine64 boards.
