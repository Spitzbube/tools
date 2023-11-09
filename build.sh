#!/bin/sh

S=`pwd`
NCPUS=`cat /proc/cpuinfo | grep processor | wc -l`

build_image() {
   make -C ${S} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- mb86hxx_defconfig
   make -C ${S} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j${NCPUS}
   mkimage -A arm -O linux -T kernel -C none -a 0x20008000 -e 0x20008000 -n "Linux kernel" -d arch/arm/boot/zImage /srv/tftp/mb86h60/uImage
   cp arch/arm/boot/dts/mb86hxx.dtb  /srv/tftp/mb86h60/mb86hxx.dtb
}

build_image
