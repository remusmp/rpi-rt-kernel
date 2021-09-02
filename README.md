# Introduction

Raspbian with fully preemptive real-time kernel 5.10.

# How to build the `sdcard` image

Clone this repository and run `make`. It will create a folder `build` with a zipped sdcard image.

# How to customize the kernel image

Run `make custom`. You will get a shell to a container. Then run:
```
cd /rpi-rt-kernel/linux
make menuconfig
```

After exiting a `.config` file is created, which needs to be copied out of the container:
```
docker cp your-container:/rpi-rt-kernel/linux/.config .config
```

Exit the container and run `make` again to get a new sdcard image.
