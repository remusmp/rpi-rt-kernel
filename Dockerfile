# set PLATFORM32 to something not null if you're building for older platforms, i.e. Pi 1, Pi Zero, Pi Zero W and Pi CM1
# do not define PLATFORM32 or set it to null if you're building for newer platforms, i.e. Pi 3, Pi 3+, Pi 4, Pi 400, Pi Zero 2 W, Pi CM3, Pi CM3+, Pi CM4
FROM ubuntu:24.04

ARG PLATFORM32
ARG RASPIOS_IMAGE_NAME

ENV LINUX_KERNEL_VERSION=6.6
ENV LINUX_KERNEL_BRANCH=rpi-${LINUX_KERNEL_VERSION}.y
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
RUN curl https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/${LINUX_KERNEL_VERSION}/older/${PATCH}.patch.gz --output ${PATCH}.patch.gz && \
    gzip -cd /rpi-kernel/linux/${PATCH}.patch.gz | patch -p1 --verbose

# if PLATFORM32 has been defined then set KERNEL=kernel else set KERNEL=kernel8 (arm64)
ENV KERNEL=${PLATFORM32:+kernel}
ENV KERNEL=${KERNEL:-kernel8}

# if PLATFORM32 has been defined then set ARCH=arm else set ARCH=arm64
ENV ARCH=${PLATFORM32:+arm}
ENV ARCH=${ARCH:-arm64}

# if PLATFORM32 has been defined then set CROSS_COMPILE=arm-linux-gnueabihf- else set CROSS_COMPILE=aarch64-linux-gnu-
ENV CROSS_COMPILE=${PLATFORM32:+arm-linux-gnueabihf-}
ENV CROSS_COMPILE=${CROSS_COMPILE:-aarch64-linux-gnu-}

# print the above env variables
RUN echo ${KERNEL} ${ARCH} ${CROSS_COMPILE}

RUN [ "$ARCH" = "arm" ] && make bcmrpi_defconfig || make bcm2711_defconfig
RUN ./scripts/config --disable CONFIG_VIRTUALIZATION
RUN ./scripts/config --enable CONFIG_PREEMPT_RT
RUN ./scripts/config --disable CONFIG_RCU_EXPERT
RUN ./scripts/config --enable CONFIG_RCU_BOOST
RUN [ "$ARCH" = "arm" ] && ./scripts/config --enable CONFIG_SMP || true
RUN [ "$ARCH" = "arm" ] && ./scripts/config --disable CONFIG_BROKEN_ON_SMP || true
RUN ./scripts/config --set-val CONFIG_RCU_BOOST_DELAY 500

RUN make -j4 Image modules dtbs

RUN echo "using raspberry pi image ${RASPIOS_IMAGE_NAME}"
WORKDIR /raspios

RUN export DATE=$(curl -s https://downloads.raspberrypi.org/${RASPIOS_IMAGE_NAME}/images/ | sed -n "s:.*${RASPIOS_IMAGE_NAME}-\(.*\)/</a>.*:\1:p" | tail -1) && \
    export RASPIOS=$(curl -s https://downloads.raspberrypi.org/${RASPIOS_IMAGE_NAME}/images/${RASPIOS_IMAGE_NAME}-${DATE}/ | sed -n "s:.*<a href=\"\(.*\).xz\">.*:\1:p" | tail -1) && \
    echo "Downloading ${RASPIOS}.xz" && \
    curl https://downloads.raspberrypi.org/${RASPIOS_IMAGE_NAME}/images/${RASPIOS_IMAGE_NAME}-${DATE}/${RASPIOS}.xz --output ${RASPIOS}.xz && \
    xz -d ${RASPIOS}.xz

RUN mkdir /raspios/mnt && mkdir /raspios/mnt/disk && mkdir /raspios/mnt/boot
ADD build.sh ./build.sh
ADD config.txt ./
