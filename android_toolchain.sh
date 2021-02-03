#!/bin/sh

#need at least 28 for glob
export API=28
export NDK_VERSION=21.3.6528147
##export TARGET=aarch64-linux-android
#export TARGET=armv7a-linux-androideabi

############# x86_64 ###########
export TARGET_BINUTILS=x86_64-linux-android
export ABI=x86_64
export TARGET_PREFIX=x86_64-linux-android
#export TARGET=x86_64-none-linux-android$API
#################################

######## x86 - i686 ############
#export TARGET_PREFIX=i686-linux-android
#export ABI=x86
#export TARGET_BINUTILS=i686-linux-android
#export TARGET=x86_64-none-linux-android$API
#################################

export SCRIPT_HOME_DIR=$PWD
export WORKDIR=$SCRIPT_HOME_DIR/dep_build_$TARGET_PREFIX
export DEPS_SRC_PATH=$SCRIPT_HOME_DIR/deps_src
export JOBS=9

export ANDROID_NDK=$HOME/android/sdk/ndk/$NDK_VERSION
export TOOLCHAIN=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64
export CMAKE=/home/adi/Qt/Tools/CMake/bin/cmake
export QT_INSTALL_PREFIX=/home/adi/Qt/5.15.2/android

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
#export LD=$TOOLCHAIN/bin/${TARGET_BINUTILS}-ld.gold
#export LD=$TOOLCHAIN/bin/ld.lld
#$LD
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib

# This is just an empty directory where I want the built objects to be installed
export DEV_PREFIX=$WORKDIR/out

# Don't mix up .pc files from your host and build target
export PKG_CONFIG_PATH=${DEV_PREFIX}/lib/pkgconfig

# You can clone the full Android sources to get bionic if you want.. I didn't
# want to so I just got linker.h from here: http://gitorious.org/0xdroid/bionic
# Note that this was only required to build boehm-gc with dynamic linking support.
# -target $TARGET_TRIPLE
export CFLAGS="-fPIE -fPIC --sysroot=${SYSROOT} -I${SYSROOT}/include -I${SYSROOT}/usr/include -I${TOOLCHAIN}/include -I${DEV_PREFIX} ${CFLAGS}"
export CPPFLAGS="${CFLAGS}"
export LDFLAGS="${LDFLAGS} -pie -L${SYSROOT}/usr/lib/$TARGET/$API -L${TOOLCHAIN}/lib -L${DEV_PREFIX}"
#export LDFLAGS="${LDFLAGS} -pie -L${SYSROOT}/usr/lib/$TARGET/$API -L${SYSROOT}/usr/lib -L${TOOLCHAIN}/lib -L${DEV_PREFIX}"

