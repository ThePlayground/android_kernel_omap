#!/bin/bash

# Copyright (C) 2011 Twisted Playground

# This script is designed to compliment .bash_profile code to automate the build process by adding a typical shell command such as:
# function buildKernel { echo "Ace, Mecha, Sholes, Release?"; read device; cd /Volumes/android/android-tzb_ics4.0.1/kernel;  ./buildChosenKernel.sh $device; }
# This script is designed by Twisted Playground for use on MacOSX 10.7 but can be modified for other distributions of Mac and Linux

PROPER=`echo $2 | sed 's/\([a-z]\)\([a-zA-Z0-9]*\)/\u\1\2/g'`

HANDLE=TwistedZero
TIWIFIDIR=/Volumes/android/github-aosp_source/system_wlan_ti
KERNELSPEC=/Volumes/android/android_kernel_omap
ANDROIDREPO=/Volumes/android/Twisted-Playground
DROIDGITHUB=TwistedUmbrella/Twisted-Playground.git
SHOLESREPO=/Volumes/android/github-aosp_source/android_device_moto_sholes
SHOLESGITHUB=TwistedPlayground/android_device_moto_sholes.git
zipfile=$HANDLE"_deprimedKernel_ICS.zip"

CPU_JOB_NUM=16
TOOLCHAIN_PREFIX=$TOOLCHAINDIR/arm-eabi-

echo "Config Name? "
ls config
read configfile
cp -R config/$configfile .config

make clean -j$CPU_JOB_NUM

make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX

find . -name "*.ko" | xargs ${TOOLCHAIN_PREFIX}strip --strip-unneeded

if [ -e arch/arm/boot/zImage ]; then

cp .config arch/arm/configs/icsholes_defconfig

if [ "$1" == "1" ]; then

echo "adding to build"

cp -R arch/arm/boot/zImage $SHOLESREPO/prebuilt/root/kernel
rm -r $SHOLESREPO/prebuilt/system/lib/modules/*
for j in $(find . -name "*.ko"); do
cp "${j}" $SHOLESREPO/prebuilt/system/lib/modules
done

cd $TIWIFIDIR/wilink_6_1/platforms/os/linux
make clean -j$CPU_JOB_NUM
export HOST_PLATFORM=zoom2
export KERNEL_DIR=$KERNELSPEC
make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX
cd $KERNELSPEC
cp -R $TIWIFIDIR/wilink_6_1/stad/build/linux/tiwlan_drv.ko $SHOLESREPO/kernel/lib/modules

cd $TIWIFIDIR/WiLink_AP/platforms/os/linux
make clean -j$CPU_JOB_NUM
export HOST_PLATFORM=zoom2
export KERNEL_DIR=$KERNELSPEC
make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX
cd $KERNELSPEC
cp -R $TIWIFIDIR/WiLink_AP/stad/build/linux/tiap_drv.ko $SHOLESREPO/kernel/lib/modules

cd $SHOLESREPO
git commit -a -m "Automated Kernel Update - ${PROPER}"
git push git@github.com:$SHOOTGITHUB HEAD:ics

else

if [ ! -e zip.aosp/system/lib ]; then
mkdir zip.aosp/system/lib
fi
if [ ! -e zip.aosp/system/lib/modules ]; then
mkdir zip.aosp/system/lib/modules
else
rm -r zip.aosp/system/lib/modules
mkdir zip.aosp/system/lib/modules
fi

for j in $(find . -name "*.ko"); do
cp -R "${j}" zip.aosp/system/lib/modules
done
cp -R arch/arm/boot/zImage mkboot.aosp

cd $TIWIFIDIR/wilink_6_1/platforms/os/linux
make clean -j$CPU_JOB_NUM
export HOST_PLATFORM=zoom2
export KERNEL_DIR=$KERNELSPEC
make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX
cd $KERNELSPEC
cp -R $TIWIFIDIR/wilink_6_1/stad/build/linux/tiwlan_drv.ko zip.aosp/system/lib/modules

cd $TIWIFIDIR/WiLink_AP/platforms/os/linux
make clean -j$CPU_JOB_NUM
export HOST_PLATFORM=zoom2
export KERNEL_DIR=$KERNELSPEC
make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX
cd $KERNELSPEC
cp -R $TIWIFIDIR/WiLink_AP/stad/build/linux/tiap_drv.ko zip.aosp/system/lib/modules

cd mkboot.aosp
echo "making boot image"
./img.sh

echo "making zip file"
cp -R boot.img ../zip.aosp
cd ../zip.aosp
rm *.zip
zip -r $zipfile *
cp -R $KERNELSPEC/zip.aosp/$zipfile $ANDROIDREPO/Kernel/$zipfile
cd $ANDROIDREPO
git checkout gh-pages
git commit -a -m "Automated Patch Kernel Build - ${PROPER}"
git push git@github.com:$DROIDGITHUB HEAD:ics -f

fi

fi

cd $KERNELSPEC