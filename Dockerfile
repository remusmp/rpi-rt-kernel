FROM ubuntu:20.04

ENV TZ=Europe/Amsterdam
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set versions you want to use below:
ARG majorVersion="5.10"
ARG patchFileVersion="patch-5.10.87-rt59.patch.gz"
ARG imageFile="2021-10-30-raspios-bullseye-armhf-lite.zip"
ARG currentFileLocation="raspios_lite_armhf-2021-11-08"

#
# Don't change stuff below unless something is broken
#
ARG cloneVersion="rpi-$majorVersion.y"
ARG imageBaseURL="https://downloads.raspberrypi.org/raspios_lite_armhf/images"
ARG patchFileLocation="https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/$majorVersion/"
ARG patchVersionLocation="echo ../$patchVersion"
ARG patchPathFilename=$patchFileLocation$patchFileVersion
ARG imagePathFileLocation=$imageBaseURL/$currentFileLocation/$imageFile

RUN apt-get update
RUN apt-get install -y git make gcc bison flex libssl-dev bc ncurses-dev kmod
RUN apt-get install -y crossbuild-essential-arm64
RUN apt-get install -y wget zip unzip fdisk nano

WORKDIR /rpi-kernel
RUN git clone https://github.com/raspberrypi/linux.git -b $cloneVersion --depth=1
RUN wget $patchPathFilename

WORKDIR /rpi-kernel/linux/
ENV KERNEL=kernel8
ENV ARCH=arm64
ENV CROSS_COMPILE=aarch64-linux-gnu-

RUN gzip -cd $patchVersionLocation | patch -p1 --verbose
RUN make bcm2711_defconfig

ADD .config ./
RUN make Image modules dtbs

WORKDIR /raspios
RUN apt -y install
RUN wget $imagePathFileLocation
RUN unzip $imageFile && rm $imageFile
RUN mkdir /raspios/mnt && mkdir /raspios/mnt/disk && mkdir /raspios/mnt/boot
ADD build.sh ./
ADD config.txt ./
