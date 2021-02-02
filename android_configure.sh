#!/bin/bash
source /home/adi/android/android_toolchain.sh
./configure --build=x86_64-unknown-linux-gnu --host=$ARCH --with-sysroot=${SYSROOT} --prefix=${PREFIX} --enable-shared=yes --enable-static=yes "$@"
