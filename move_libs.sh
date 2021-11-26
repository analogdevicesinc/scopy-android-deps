#!/bin/bash
set -xe
source ./android_toolchain.sh $1 $2

rm_libs() {
        pushd $ANDROID_SDK_ROOT/ndk/$NDK_VERSION/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/x86_64-linux-android
        rm -f *.so

        if [ $ABI = "armeabi-v7a" ]; then
                find . ! -name 'libunwind.a' -type f -exec rm -f {} +
        else
                rm -f *.a
        fi
	popd
}
create_strip_symlink() {
#needed in NDK r23
pushd $ANDROID_SDK_ROOT/ndk/$NDK_VERSION/toolchains/llvm/prebuild/linux-x86_64/bin
mv aarch64-linux-android-strip aarch64-linux-android-strip2 || true
ln -s llvm-strip aarch64-linux-android-strip
popd
}

rm_libs
#create_strip_symlink

