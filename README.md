# Introduction

Raspbian lite with fully preemptive real-time kernel 5.10. This repo follows the official methodology to cross compile the kernel as explained here `https://www.raspberrypi.com/documentation/computers/linux_kernel.html`.

In addition to building the kernel, this repo also offers a raspbian lite sd card image with the built kernel ready to be used on a raspberry pi.

# User Guide

## How to build the `sdcard` image

Clone this repository and run `make`. It will create a folder `build` with a zipped sdcard image.

## How to customize the kernel image

Run `make custom`. You will get a shell to a container. Then run:
```
cd /rpi-rt-kernel/linux
make menuconfig
```

After you have done any customization to the kernel, a new `.config` file is created, which needs to be copied out of the container. Run the following command in a separate terminal and replace the `.config` file from this repo with the one you are extracting from the running container:
```
docker cp your-container:/rpi-rt-kernel/linux/.config .config
```

Exit the container and run `make` again to get a new sdcard image.

# TO DO

Please check the issues tab for TO DOs.
