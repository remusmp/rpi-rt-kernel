FROM ubuntu:20.04

ENV LINUX_KERNEL_VERSION=5.10
ENV LINUX_KERNEL_BRANCH=rpi-${LINUX_KERNEL_VERSION}.y

ENV TZ=Europe/Copenhagen
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get install -y git make gcc bison flex libssl-dev bc ncurses-dev kmod
RUN apt-get install -y crossbuild-essential-arm64
RUN apt-get install -y wget zip unzip fdisk nano curl xz-utils

WORKDIR /rpi-kernel
RUN git clone https://github.com/raspberrypi/linux.git -b ${LINUX_KERNEL_BRANCH} --depth=1
WORKDIR /rpi-kernel/linux
RUN export PATCH=$(curl -s https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/${LINUX_KERNEL_VERSION}/ | sed -n 's:.*<a href="\(.*\).patch.gz">.*:\1:p' | tail -1) && \
    echo "Downloading patch ${PATCH}" && \
    curl https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/${LINUX_KERNEL_VERSION}/${PATCH}.patch.gz --output ${PATCH}.patch.gz && \
    gzip -cd /rpi-kernel/linux/${PATCH}.patch.gz | patch -p1 --verbose

ENV KERNEL=kernel8
ENV ARCH=arm64
ENV CROSS_COMPILE=aarch64-linux-gnu-

RUN make bcm2711_defconfig
RUN ./scripts/config --disable CONFIG_VIRTUALIZATION
RUN ./scripts/config --enable CONFIG_PREEMPT_RT
RUN ./scripts/config --disable CONFIG_RCU_EXPERT
RUN ./scripts/config --enable CONFIG_RCU_BOOST
RUN ./scripts/config --set-val CONFIG_RCU_BOOST_DELAY 500

RUN make Image modules dtbs

WORKDIR /raspios
RUN apt -y install
RUN export DATE=$(curl -s https://downloads.raspberrypi.org/raspios_lite_arm64/images/ | sed -n 's:.*raspios_lite_arm64-\(.*\)/</a>.*:\1:p' | tail -1) && \
    export RASPIOS=$(curl -s https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-${DATE}/ | sed -n 's:.*<a href="\(.*\).xz">.*:\1:p' | tail -1) && \
    echo "Downloading ${RASPIOS}.xz" && \
    curl https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-${DATE}/${RASPIOS}.xz --output ${RASPIOS}.xz && \
    xz -d ${RASPIOS}.xz

RUN mkdir /raspios/mnt && mkdir /raspios/mnt/disk && mkdir /raspios/mnt/boot
ADD build.sh ./
ADD config.txt ./
