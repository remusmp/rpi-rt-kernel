#!/bin/sh

mount -t ext4 -o loop,offset=$((532480*512)) 2021-05-07-raspios-buster-armhf-lite.img /raspios/mnt/disk
mount -t vfat -o loop,offset=$((8192*512)),sizelimit=$((524288*512)) 2021-05-07-raspios-buster-armhf-lite.img /raspios/mnt/boot

cd /rpi-kernel/linux/
make INSTALL_MOD_PATH=/raspios/mnt/disk modules_install
make INSTALL_DTBS_PATH=/raspios/mnt/boot dtbs_install
cd -

cp /rpi-kernel/linux/arch/arm64/boot/Image /raspios/mnt/boot/$KERNEL\_rt.img
cp /rpi-kernel/linux/arch/arm64/boot/dts/broadcom/*.dtb /raspios/mnt/boot/
cp /rpi-kernel/linux/arch/arm64/boot/dts/overlays/*.dtb* /raspios/mnt/boot/overlays/
cp /rpi-kernel/linux/arch/arm64/boot/dts/overlays/README /raspios/mnt/boot/overlays/

cp /raspios/config.txt /raspios/mnt/boot/
touch /raspios/mnt/boot/ssh

umount /raspios/mnt/disk
umount /raspios/mnt/boot

zip 2021-05-07-raspios-buster-armhf-lite.zip 2021-05-07-raspios-buster-armhf-lite.img
