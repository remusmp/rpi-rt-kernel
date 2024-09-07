# Introduction

Raspbian lite with fully preemptive real-time kernel. This repo follows the official methodology to cross compile the kernel as explained here `https://www.raspberrypi.com/documentation/computers/linux_kernel.html`.

In addition to building the kernel, this repo also offers a raspbian lite sd card image with the built kernel ready to be used on a raspberry pi.

The fully preempt rt model is enabled inside `Dockerfile` using `./scripts/config --enable`. The fully preempt rt model can be enabled only if virtualization is disabled.

# User Guide

## How to build the `sdcard` image

Clone this repository and run `make [platform]` where `platform` is either:
- 64 bits: `Pi5`, `Pi4`, `PiCM4`, `Pi400`, `Pi3`, `PiCM3`, `PiZero2`
- 32 bits: `Pi1`, `PiZero`, `PiCM1`, `Pi2`, `Pi3-32`, `PiCM3-32`, `PiZero2-32`, `Pi4-32`, `Pi400-32`, `PiCM4-32`

The `make` command creates a folder named `build` with a zipped sdcard image containing a raspbian OS image with real-time patched kernel version 6.6.

You may change the kernel version inside the `Dockerfile`. If you change the kernel version you need to find a compatible RT patch and perhaps also adjust the branch name that needs to be `git` cloned.

## How to burn the image to an SD card

First you need to figure out where the SD card is mounted. Either check `dmesg` right after you plugged in the SD card or check changes to `/dev/` before and after plugging in the SD card. I'm using a USB adapter for an SD card and I can access it at `/dev/sda` (just an example). Do not assume that you can access the SD card at the same location.

Next unzip the image from the `build` subfolder and then use `dd` to write the image to the SD card. Make sure you figured out the correct location of the SD card in `/dev/` (very important). 

Here is an example of how to `dd` the card image:
```
sudo dd if=build/2022-01-28-raspios-bullseye-arm64-lite.img of=/dev/sdcard status=progress
```

Please replace `/dev/sdcard` in the above example with the right location of your SD card.

## How to test if the RT patch was successfully applied

Once you wrote the image to the SD card, place the card into the raspberry pi. Power the pi and ssh into it (ssh is enabled by default). Run `uname -a` and it should print `SMP` and `PREEMPT_RT`, indicating that the RT patch is applied to the kernel:
```
pi@raspberrypi:~ $ uname -a
Linux raspberrypi 5.10.95-rt61-rc1-v8+ #1 SMP PREEMPT_RT Mon Mar 28 13:28:11 CEST 2022 aarch64 GNU/Linux
```
For Raspberry Pi processors that have only 1 core, such as the Pi Zero W, The SMP flag (Symetrical multiprocessing) is deactivated because it needs at least 2 cores to work.

You may benchmark the real-time capabilities of the pi by running `rt-tests`. Install `rt-tests`:
```
sudo apt update
sudo apt install rt-tests
```

Here is an example of benchmarking latency:
```
pi@raspberrypi:~ $ sudo cyclictest --histogram=US
WARN: cyclictest was not built with the numa option
# /dev/cpu_dma_latency set to 0us
policy: other/other: loadavg: 0.53 0.62 0.39 2/166 1463          

T: 0 ( 1463) P: 0 I:1000 C:  16114 Min:     11 Act:   42 Avg:   66 Max:     459
```
which shows a maximum latency of `459us` (roughly half a millisecond). Values vary depending on CPU load.

Please note that cyclictest does not put any load on the cpu, the results are useless if the test is not done while your RT application runs, or while an equivalent stress-test is running. You might want to read the cyclictest documentation [here](https://wiki.linuxfoundation.org/realtime/documentation/howto/tools/cyclictest/start) to learn how to build your tests.

## How to customize the kernel image

Run `make custom`. You will get a shell to a container. Then run:
```
cd /rpi-rt-kernel/linux
make menuconfig
```

## Default login

Username `pi` password `raspberry`

## Tested Images

`Pi5`, `Pi4`, `PiCM4`

If you manage to test the images on other platforms please let me know and I will include them to the above list. Thank you!
