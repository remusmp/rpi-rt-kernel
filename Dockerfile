FROM ubuntu:20.04

ENV TZ=Europe/Copenhagen
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get install -y git make gcc bison flex libssl-dev bc ncurses-dev kmod
RUN apt-get install -y crossbuild-essential-arm64

WORKDIR /rpi-kernel
RUN git clone https://github.com/raspberrypi/linux.git -b rpi-5.10.y --depth=1
RUN mkdir rt-kernel

WORKDIR /rpi-kernel/linux/
# ADD arch/Kconfig arch/

ENV KERNEL=kernel8
ENV ARCH=arm64
ENV CROSS_COMPILE=aarch64-linux-gnu-
RUN make bcm2711_defconfig

ADD .config ./
RUN make Image modules dtbs

RUN mkdir /raspios
WORKDIR /raspios
RUN apt -y install wget zip unzip fdisk
RUN wget https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip
RUN unzip 2021-05-07-raspios-buster-armhf-lite.zip && rm 2021-05-07-raspios-buster-armhf-lite.zip
RUN mkdir /raspios/mnt && mkdir /raspios/mnt/disk && mkdir /raspios/mnt/boot
ADD build.sh ./
ADD config.txt ./
