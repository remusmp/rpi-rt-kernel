# Introduction

Raspbian lite with fully preemptive real-time kernel. This repo follows the official methodology to cross compile the kernel as explained here `https://www.raspberrypi.com/documentation/computers/linux_kernel.html`.

In addition to building the kernel, this repo also offers a raspbian lite sd card image with the built kernel ready to be used on a raspberry pi.

The fully preempt rt model is enabled inside `Dockerfile` using `./scripts/config --enable`. The fully preempt rt model can be enabled only if virtualization is disabled.

# User Guide

## How to build the `sdcard` image

Clone this repository and run `make`. It will create a folder `build` with a zipped sdcard image. Default values:
- linux kernel version 5.10 (you may change it inside `Dockerfile`)
- the latest rt patch is downloaded from `https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/`
- the latest raspbian image is downloaded from `https://downloads.raspberrypi.org/raspios_lite_armhf/images/`

## How to customize the kernel image

Run `make custom`. You will get a shell to a container. Then run:
```
cd /rpi-rt-kernel/linux
make menuconfig
```
