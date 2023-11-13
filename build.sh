#!/bin/sh

ARCH=arm
CROSS_COMPILE=arm-linux-gnueabihf-
KERNEL_SRC=`pwd`/kernel
#FAPI_SRC=`pwd`/fapi/FAPI/fapi_driver
#FAPEXK_SRC=`pwd`/fapi/FAPexK/fapex_driver/fapex
FAPI_SRC=`pwd`/fapi
NCPUS=`cat /proc/cpuinfo | grep processor | wc -l`

build_image() {
   make -C ${KERNEL_SRC} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mb86hxx_defconfig
   make -C ${KERNEL_SRC} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -j${NCPUS}
   make -C ${KERNEL_SRC} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=${KERNEL_SRC}/usr/initramfs/modules modules_install
   mkimage -A arm -O linux -T kernel -C none -a 0x20008000 -e 0x20008000 -n "Linux kernel" -d ${KERNEL_SRC}/arch/arm/boot/zImage /srv/tftp/mb86h60/uImage
   cp ${KERNEL_SRC}/arch/arm/boot/dts/mb86hxx.dtb /srv/tftp/mb86h60/mb86hxx.dtb
}

build_fapi_drivers() {
#   make -C ${KERNEL_SRC} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} M=${FAPI_SRC} clean
   make -C ${KERNEL_SRC} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} M=${FAPI_SRC}
   make -C ${KERNEL_SRC} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} M=${FAPI_SRC} INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=${KERNEL_SRC}/usr/initramfs/modules modules_install
}

build_fapex_drivers() {
   make -C ${KERNEL_SRC} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} M=${FAPEXK_SRC}
   make -C ${KERNEL_SRC} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} M=${FAPEXK_SRC} INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=${KERNEL_SRC}/usr/initramfs/modules modules_install
}

build_initramfs() {
   cd ${KERNEL_SRC}
   usr/gen_initramfs.sh usr/initramfs_list usr/initramfs/modules/ -o usr/initramfs_data.cpio
   gzip -f usr/initramfs_data.cpio
   mkimage -A arm -O linux -T ramdisk -C none -a 0x23000000 -n "ramdisk" -d usr/initramfs_data.cpio.gz /srv/tftp/mb86h60/uRamdisk
}

build_image
build_fapi_drivers
#build_fapex_drivers
build_initramfs

