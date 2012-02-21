#!/bin/bash

make clean -j$CPU_JOB_NUM

CPU_JOB_NUM=16
TOOLCHAIN_PREFIX=arm-none-eabi-

make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX


	# create an output directory
	rm -fr tmpdir
	mkdir tmpdir

	# copy the kernel image
	cp arch/arm/boot/zImage tmpdir/
	# copy all of the modules to that directory
	for j in $(find . -name "*.ko"); do
		cp "${j}" tmpdir/
	done

	cp ../tiwlan_drv.ko "tmpdir/"

	# now we begin to build our anykernel

	# copy the anykernel stuff
	cp -a anykernel.tpl tmpdir/anykernel
	# ensure needed directories are there
	mkdir -p tmpdir/anykernel/kernel
	mkdir -p tmpdir/anykernel/system/lib/modules
	# put the kernel in the right spot
	cp tmpdir/zImage tmpdir/anykernel/kernel
	# copy all of our modules
	for j in tmpdir/*.ko; do
		cp "${j}" tmpdir/anykernel/system/lib/modules/
	done

	# zip the file
	cd tmpdir/anykernel
	zip -r "TwistedZero_droidKernel_deprimed_ICS.zip" *
    cp TwistedZero_droidKernel_deprimed_ICS.zip ../../
	cd "../../"

	# wipe out the tmp directory
	rm -fr tmpdir
