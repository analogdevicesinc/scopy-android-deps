#!/bin/bash

############### SYSTEM SPECIFIC DEFINES ############
export ANDROID_SDK=$HOME/android/sdk
export CMAKE=/home/adi/Qt/Tools/CMake/bin/cmake
export QT_INSTALL_PREFIX=/home/adi/Qt/5.15.2/android
export JDK=/home/adi/jdk-15.0.2
export NDK_VERSION=21.3.6528147
export API=28 # need ABI at least 28 for glob from my tests
export JOBS=9
export SCRIPT_HOME_DIR=/home/adi/android/scopy-android-deps

############ aarch64 #########
#export ABI=arm64-v8a
#export TARGET_PREFIX=aarch64-linux-android
#export TARGET_BINUTILS=aarch64-linux-android
#############################

############# armv7a ##########
#export ABI=armeabi-v7a
#export TARGET_PREFIX=armv7a-linux-androideabi
#export TARGET_BINUTILS=arm-linux-androideabi
###############################

############# x86_64 ###########
#export TARGET_BINUTILS=x86_64-linux-android
#export ABI=x86_64
#export TARGET_PREFIX=x86_64-linux-android
#################################

######## x86 - i686 ############
export TARGET_PREFIX=i686-linux-android
export ABI=x86
export TARGET_BINUTILS=i686-linux-android
#################################

echo $TARGET_PREFIX

export WORKDIR=$SCRIPT_HOME_DIR/deps_build_$TARGET_PREFIX
export DEPS_SRC_PATH=$SCRIPT_HOME_DIR/deps_src
echo SCRIPT_HOME_DIR $SCRIPT_HOME_DIR

# This is just an empty directory where I want the built objects to be installed
export DEV_PREFIX=$WORKDIR/out
# Don't mix up .pc files from your host and build target
export PKG_CONFIG_PATH=${DEV_PREFIX}/lib/pkgconfig

export ANDROID_NDK=$ANDROID_SDK/ndk/$NDK_VERSION
export TOOLCHAIN=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64
export QMAKE=$QT_INSTALL_PREFIX/bin/qmake
export ANDROID_QT_DEPLOY=$QT_INSTALL_PREFIX/bin/androiddeployqt

# Apparently android-8 works fine, there are other versions, look them up
export SYSROOT=$TOOLCHAIN/sysroot

# Non-exhaustive lists of compiler + binutils
# Depending on what you compile, you might need more binutils than that
#export CC=$TOOLCHAIN/bin/clang
export CC=$TOOLCHAIN/bin/$TARGET_PREFIX$API-clang
#export CXX=$TOOLCHAIN/bin/clang++
export CXX=$TOOLCHAIN/bin/$TARGET_PREFIX$API-clang++
export CPP="$CC -E"
export AR=$TOOLCHAIN/bin/llvm-ar
export AS=${CC}
export NM=$TOOLCHAIN/bin/nm
export LD=$TOOLCHAIN/bin/${TARGET_BINUTILS}-ld.gold
#export LD=$TOOLCHAIN/bin/ld.lld
#$LD
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib

# You can clone the full Android sources to get bionic if you want.. I didn't
# want to so I just got linker.h from here: http://gitorious.org/0xdroid/bionic
# Note that this was only required to build boehm-gc with dynamic linking support.
# -target $TARGET_TRIPLE
export CFLAGS="-fPIE -fPIC --sysroot=${SYSROOT} -I${SYSROOT}/include -I${SYSROOT}/usr/include -I${TOOLCHAIN}/include -I${DEV_PREFIX} ${CFLAGS}"
export CPPFLAGS="-fexceptions -frtti ${CFLAGS} "
export LDFLAGS="${LDFLAGS} -pie -L${SYSROOT}/usr/lib/$TARGET/$API -L${TOOLCHAIN}/lib -L${DEV_PREFIX} -L${DEV_PREFIX}/lib"
#export LDFLAGS="${LDFLAGS} -pie -L${SYSROOT}/usr/lib/$TARGET/$API -L${SYSROOT}/usr/lib -L${TOOLCHAIN}/lib -L${DEV_PREFIX} -l"

source $SCRIPT_HOME_DIR/android_qt_initial_cmake_params.in
