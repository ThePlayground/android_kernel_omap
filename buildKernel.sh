#!/bin/bash

# Copyright (C) 2011 Twisted Playground

# This script is designed to compliment .bash_profile code to automate the build process by adding a typical shell command such as:
# function buildKernel { echo "Mecha, Sholes, Release?"; read device; if [ "$device" == "mecha" ]; then  cd /Volumes/android/android-tzb_ics4.0.1/kernel/leanKernel-tbolt-ics;  ./buildlean.sh 1 $device; fi; if [ "$device" == "sholes" ]; then  cd /Volumes/android/android-tzb_ics4.0.1/kernel/android_kernel_omap;  ./buildKernel.sh 1 $device; fi; if [ "$device" == "release" ]; then echo "Mecha, Sholes?"; read profile; if [ "$profile" == "mecha" ]; then  cd /Volumes/android/android-tzb_ics4.0.1/kernel/leanKernel-tbolt-ics;  ./buildlean.sh 1 $device; fi; if [ "$profile" == "sholes" ]; then  cd /Volumes/android/android-tzb_ics4.0.1/kernel/android_kernel_omap;  ./buildKernel.sh 1 $device; fi; fi; }
# This script is designed by Twisted Playground for use on MacOSX 10.7 but can be modified for other distributions of Mac and Linux

PROPER=`echo $2 | sed 's/\([a-z]\)\([a-zA-Z0-9]*\)/\u\1\2/g'`

HANDLE=TwistedZero
BUILDDIR=/Volumes/android/android-tzb_ics4.0.1
KERNELSPEC=android_kernel_omap
ANDROIDREPO=/Volumes/android/Twisted-Playground
DROIDGITHUB=TwistedUmbrella/Twisted-Playground.git
SHOLESREPO=github-aosp_source/android_device_moto_sholes
SHOLESGITHUB=TwistedPlayground/android_device_moto_sholes.git
ICSREPO=github-aosp_source/android_system_core

make clean -j$CPU_JOB_NUM

CPU_JOB_NUM=16
TOOLCHAIN_PREFIX=arm-none-eabi-

make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX

find . -name "*.ko" | xargs ${TOOLCHAIN_PREFIX}strip --strip-unneeded

if [ "$2" == "sholes" ]; then

echo "adding to build"

if [ ! -e ../../../$SHOLESREPO/kernel ]; then
mkdir ../../../$SHOLESREPO/kernel
fi
if [ ! -e ../../../$SHOLESREPO/kernel/lib ]; then
mkdir ../../../$SHOLESREPO/kernel/lib
fi
if [ ! -e ../../../$SHOLESREPO/kernel/lib/modules ]; then
mkdir ../../../$SHOLESREPO/kernel/lib/modules
fi

cp -R arch/arm/boot/zImage ../../../$SHOLESREPO/kernel/kernel
for j in $(find . -name "*.ko"); do
cp "${j}" ../../../$SHOLESREPO/kernel/lib/modules
done
cd $BUILDDIR/system/wlan/ti/wilink_6_1/platforms/os/linux
make clean -j$CPU_JOB_NUM
export HOST_PLATFORM=zoom2
export KERNEL_DIR=$BUILDDIR/kernel/$KERNELSPEC
make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX
cd $BUILDDIR/kernel/$KERNELSPEC
cp -R $BUILDDIR/system/wlan/ti/wilink_6_1/stad/build/linux/tiwlan_drv.ko ../../../$SHOLESREPO/kernel/lib/modules

if [ -e ../../../$SHOLESREPO/kernel/kernel ]; then
cd ../../../$SHOLESREPO
git commit -a -m "Automated Kernel Update - ${PROPER}"
git push git@github.com:$SHOLESGITHUB HEAD:ics
fi

else

rm -fr tmpdir
mkdir tmpdir
cp arch/arm/boot/zImage tmpdir/
for j in $(find . -name "*.ko"); do
    cp "${j}" tmpdir/
done
cd $BUILDDIR/system/wlan/ti/wilink_6_1/platforms/os/linux
make clean -j$CPU_JOB_NUM
export HOST_PLATFORM=zoom2
export KERNEL_DIR=$BUILDDIR/kernel/$KERNELSPEC
make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX
cd $BUILDDIR/kernel/$KERNELSPEC
cp -R $BUILDDIR/system/wlan/ti/wilink_6_1/stad/build/linux/tiwlan_drv.ko tmpdir
cp -a anykernel.tpl tmpdir/anykernel
mkdir -p tmpdir/anykernel/kernel
mkdir -p tmpdir/anykernel/system/lib/modules
cp tmpdir/zImage tmpdir/anykernel/kernel
for j in tmpdir/*.ko; do
    cp "${j}" tmpdir/anykernel/system/lib/modules/
done

echo "making zip file"
cd tmpdir/anykernel
zip -r "TwistedZero_deprimedKernel_ICS.zip" *
cp -R TwistedZero_deprimedKernel_ICS.zip $ANDROIDREPO/Kernel
cd ../../
rm -fr tmpdir
cd $ANDROIDREPO
git checkout gh-pages
git commit -a -m "Automated Sholes Kernel Build - Patch"
git push git@github.com:TwistedUmbrella/Twisted-Playground.git HEAD:ics

fi

cd $BUILDDIR/kernel/$KERNELSPEC