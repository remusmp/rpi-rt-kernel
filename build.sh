#!/bin/sh

OUTPUT=$(sfdisk -lJ ${RASPIOS})
BOOT_START=$(echo $OUTPUT | jq -r '.partitiontable.partitions[0].start')
BOOT_SIZE=$(echo $OUTPUT | jq -r '.partitiontable.partitions[0].size')
EXT4_START=$(echo $OUTPUT | jq -r '.partitiontable.partitions[1].start')

mount -t ext4 -o loop,offset=$(($EXT4_START*512)) ${RASPIOS} /raspios/mnt/disk
mount -t vfat -o loop,offset=$(($BOOT_START*512)),sizelimit=$(($BOOT_SIZE*512)) ${RASPIOS} /raspios/mnt/boot/firmware

cd /rpi-kernel/linux/
make INSTALL_MOD_PATH=/raspios/mnt/disk modules_install
make INSTALL_DTBS_PATH=/raspios/mnt/boot/firmware dtbs_install
cd -

if [ "$ARCH" = "arm64" ]; then
    echo "arm_64bit=1" >> /raspios/config.txt
    cp /rpi-kernel/linux/arch/arm64/boot/Image.gz /raspios/mnt/boot/firmware/$KERNEL\_rt.img
    cp /rpi-kernel/linux/arch/arm64/boot/dts/broadcom/*.dtb /raspios/mnt/boot/firmware/
    cp /rpi-kernel/linux/arch/arm64/boot/dts/overlays/*.dtb* /raspios/mnt/boot/firmware/overlays/
    cp /rpi-kernel/linux/arch/arm64/boot/dts/overlays/README /raspios/mnt/boot/firmware/overlays/
elif [ "$ARCH" = "arm" ]; then
    echo "arm_64bit=0" >> /raspios/config.txt
    cp /rpi-kernel/linux/arch/arm/boot/zImage /raspios/mnt/boot/firmware/$KERNEL\_rt.img
    cp /rpi-kernel/linux/arch/arm/boot/dts/broadcom/*.dtb /raspios/mnt/boot/firmware/
    cp /rpi-kernel/linux/arch/arm/boot/dts/overlays/*.dtb* /raspios/mnt/boot/firmware/overlays/
    cp /rpi-kernel/linux/arch/arm/boot/dts/overlays/README /raspios/mnt/boot/firmware/overlays/
fi

echo "kernel=${KERNEL}_rt.img" >> /raspios/config.txt
cp /raspios/config.txt /raspios/mnt/boot/firmware/
cp /raspios/userconf /raspios/mnt/boot/firmware/
touch /raspios/mnt/boot/firmware/ssh

umount /raspios/mnt/disk
umount /raspios/mnt/boot/firmware

mkdir build
zip build/${RASPIOS}-${TARGET}.zip ${RASPIOS}
