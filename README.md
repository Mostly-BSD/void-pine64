# Void Linux Images for Pine64

## DISCLAIMER

I am not officially involved with either Pine64 or Void Linux. I'm just a happy void user who wants to run it on Pine64 boards. You can cause serious damage to your equipment using these scripts and/or the images built using these scripts, and I'm not responsible if you do.

## Features

- Kernel: 5.2.11 w/ patches for Pine64 devices
- U-boot: 2019.07 w/ ARM Trusted Firmware (ATF) 2.1

## Images

Currently, images are available for the following devices.

- [A64/A64+](https://wiki.pine64.org/index.php/PINE_A64_Main_Page)
- [A64-lts](https://wiki.pine64.org/index.php/PINE_A64-LTS/SOPine_Main_Page)
- [Sopine](https://wiki.pine64.org/index.php/PINE_A64-LTS/SOPine_Main_Page)
- [Pinebook](https://wiki.pine64.org/index.php/1080P_Pinebook_Main_Page)
- [H64](https://wiki.pine64.org/index.php/PINE_H64_Main_Page)

All images are built with the [musl](https://wiki.voidlinux.org/Musl) lib for performance reasons. Currently the open-source [Lima/Panfrost](https://linux-sunxi.org/Mali_Open_Source_Driver) drivers which enable 2D/3D acceleration in X, OpenGL etc. are not enabled. This is due to the fact that they are under heavy development and not stable enough for daily use.

In future I'll try and build images for the Rock64, RockPro64, Pinetab, and PinebookPro devices as well. 

## Usage

Download an image appropriate to your device type (A64/A64-lts/Sopine/Pinebook/H64). For each device type there are 5 possible images to choose from.

- `void-pine64-musl-<DEVICE>-<DATE>.img.xz`: Base image w/o X server.
- `void-pine64-musl-<DEVICE>-<DATE>-X11.img.xz`: Base image w/ X server.
- `void-pine64-musl-<DEVICE>-<DATE>-LXDE.img.xz`: Base image w/ LXDE Desktop environment.
- `void-pine64-musl-<DEVICE>-<DATE>-LXQT.img.xz`: Base image w/ LXQT Desktop environment.
- `void-pine64-musl-<DEVICE>-<DATE>-MATE.img.xz`: Base image w/ MATE Desktop environment.

Un-compress the `.xz` file using the `xz` or the `pixz` command. Transfer the `.img` file to an SD card or eMMC module using `dd` or `etcher`. Finally boot your device and Njoy!

**NOTE**: The images are all 4GB in size when uncompressed. When you transfer them to a SD card or an eMMC module of higher capacity you should resize the root partition. If you don't know how to do this, a search engine is your friend.

## Build Instructions

See [BUILD.md](BUILD.md) file to build the images yourself.

## TODOs

- \[x] Make proper void packages for Pine64 kernel & uboot.
- \[x] Make images for Pinebook, Sopine, H64, A64/A64+, and A64-lts.
- \[ ] Build libGL(Mesa) with support for Lima/Panfrost drivers.
- \[ ] Make images for Rock64, RockPro64, PineTab, PinebookPro.
- \[ ] Submit Changes to void-linux upstream for proper support of Pine64 boards.
