FROM ubuntu:24.04

ENV LINUX_KERNEL_VERSION=6.6
ENV LINUX_KERNEL_BRANCH=stable_20240529
ENV LINUX_KERNEL_RT_PATCH=patch-6.6.30-rt30

ENV TZ=Europe/Copenhagen
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get install -y git make gcc bison flex libssl-dev bc ncurses-dev kmod \
    crossbuild-essential-arm64 crossbuild-essential-armhf \
    wget zip unzip fdisk nano curl xz-utils jq

WORKDIR /rpi-kernel
RUN git clone https://github.com/raspberrypi/linux.git -b ${LINUX_KERNEL_BRANCH} --depth=1
WORKDIR /rpi-kernel/linux
RUN curl https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/${LINUX_KERNEL_VERSION}/older/${LINUX_KERNEL_RT_PATCH}.patch.gz --output ${LINUX_KERNEL_RT_PATCH}.patch.gz && \
    gzip -cd /rpi-kernel/linux/${LINUX_KERNEL_RT_PATCH}.patch.gz | patch -p1 --verbose

ARG RASPIOS
ARG DEFCONFIG
ARG KERNEL
ARG CROSS_COMPILE
ARG ARCH
ARG TARGET

ENV RASPIOS=${RASPIOS}
ENV KERNEL=${KERNEL}
ENV ARCH=${ARCH}
ENV TARGET=${TARGET}

# print the args
RUN echo ${RASPIOS} ${DEFCONFIG} ${KERNEL} ${CROSS_COMPILE} ${ARCH}

RUN make ${DEFCONFIG}
RUN ./scripts/config --disable CONFIG_VIRTUALIZATION
RUN ./scripts/config --enable CONFIG_PREEMPT_RT
RUN ./scripts/config --disable CONFIG_RCU_EXPERT
RUN ./scripts/config --enable CONFIG_RCU_BOOST
RUN [ "$ARCH" = "arm" ] && ./scripts/config --enable CONFIG_SMP || true
RUN [ "$ARCH" = "arm" ] && ./scripts/config --disable CONFIG_BROKEN_ON_SMP || true
RUN ./scripts/config --set-val CONFIG_RCU_BOOST_DELAY 500

RUN [ "$ARCH" = "arm64" ] && make -j6 Image.gz modules dtbs
RUN [ "$ARCH" = "arm" ] && make -j6 zImage modules dtbs || true

RUN echo "using raspberry pi image ${RASPIOS}"
WORKDIR /raspios

RUN export DATE=$(curl -s https://downloads.raspberrypi.org/${RASPIOS}/images/ | sed -n "s:.*${RASPIOS}-\(.*\)/</a>.*:\1:p" | tail -1) && \
    export RASPIOS_IMAGE_NAME=$(curl -s https://downloads.raspberrypi.org/${RASPIOS}/images/${RASPIOS}-${DATE}/ | sed -n "s:.*<a href=\"\(.*img\).xz\">.*:\1:p" | tail -1) && \
    echo "Downloading ${RASPIOS_IMAGE_NAME}.xz" && \
    curl https://downloads.raspberrypi.org/${RASPIOS}/images/${RASPIOS}-${DATE}/${RASPIOS_IMAGE_NAME}.xz --output ${RASPIOS}.xz && \
    xz -d ${RASPIOS}.xz

RUN mkdir /raspios/mnt && mkdir /raspios/mnt/disk && mkdir /raspios/mnt/boot && mkdir /raspios/mnt/boot/firmware
ADD build.sh ./build.sh
ADD config.txt ./
ADD userconf ./
