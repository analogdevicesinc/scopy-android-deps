#!/bin/bash
set -xe
source ./android_toolchain.sh $1 $2

rm_libs() {
        cd $ANDROID_SDK_ROOT/ndk/$NDK_VERSION/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/x86_64-linux-android
        rm -f *.so

        if [ $ABI = "armeabi-v7a" ]; then
                find . ! -name 'libunwind.a' -type f -exec rm -f {} +
        else
                rm -f *.a
        fi
}

rm_libs
