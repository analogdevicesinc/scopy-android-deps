#!/bin/sh

# I put all my dev stuff in here
export DEV_PREFIX=$HOME/android

#need at least 28 for glob
export ANDROID_API=28
export CMAKE=/home/adi/Qt/Tools/CMake/bin/cmake
# Don't forget to adjust this to your NDK path
export ANDROID_NDK=$HOME/Android/Sdk/ndk-bundle
#export ANDROID_NDK=$HOME/Android/Sdk/ndk/21.1.6352462
#export ANDROID_NDK=$HOME/Android/Sdk/ndk/22.0.7026061

#TARGET=arm-linux-androideabi
#ARCH=aarch64
ARCH=i686
TARGET=$ARCH-linux-android
#export CROSS_COMPILER=armv7a-linux-androideabi$ANDROID_API-
#export CROSS_COMPILER=
export CROSS_COMPILER=$ARCH-linux-android$ANDROID_API-
export CROSS_COMPILE_BIN=$TARGET

# I chose the gcc-4.7 toolchain - works fine for me!
export ANDROID_PREFIX=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64

# Apparently android-8 works fine, there are other versions, look them up
export SYSROOT=$ANDROID_PREFIX/sysroot
#export SYSROOT=$DEV_PREFIX/sysroot

export CROSS_C_PATH=${ANDROID_PREFIX}/bin/${CROSS_COMPILER}
export CROSS_B_PATH=${ANDROID_PREFIX}/bin/${CROSS_COMPILE_BIN}

# Non-exhaustive lists of compiler + binutils
# Depending on what you compile, you might need more binutils than that
export CPP="${CROSS_C_PATH}clang -E"
export AR=${CROSS_B_PATH}-ar
export AS=${CROSS_B_PATH}-as
export NM=${CROSS_B_PATH}-nm
export CC=${CROSS_C_PATH}clang
export CXX=${CROSS_C_PATH}clang++
export LD=${CROSS_B_PATH}-ld.gold
export RANLIB=${CROSS_B_PATH}-ranlib

# This is just an empty directory where I want the built objects to be installed
export PREFIX=${SYSROOT}/usr/local

# Don't mix up .pc files from your host and build target
export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig

# You can clone the full Android sources to get bionic if you want.. I didn't
# want to so I just got linker.h from here: http://gitorious.org/0xdroid/bionic
# Note that this was only required to build boehm-gc with dynamic linking support.
export CFLAGS="${CFLAGS} --sysroot=${SYSROOT} -I${SYSROOT}/include -I${SYSROOT}/usr/include -I${ANDROID_PREFIX}/include -I${DEV_PREFIX}/android/bionic"
export CPPFLAGS="${CFLAGS}"
export LDFLAGS="${LDFLAGS} -L${SYSROOT}/lib -L${SYSROOT}/usr/lib/$TARGET/$ANDROID_API -L${SYSROOT}/usr/lib -L${ANDROID_PREFIX}/lib"

