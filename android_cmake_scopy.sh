#!/bin/bash
set -x

	#-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake \
	#-DQT_HOST_PATH=/home/adi/Qt/6.3.0/gcc_64 \
$CMAKE \
	-DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE\
	-DCMAKE_BUILD_TYPE:String=$BUILD_TYPE \
	-DANDROID_STL:STRING=c++_shared \
	-DANDROID_SDK_ROOT:PATH=$ANDROID_SDK_ROOT \
	-DCMAKE_SYSTEM_NAME=Android \
	-DANDROID_NDK=$ANDROID_NDK_ROOT \
	-DANDROID_NDK_ROOT=$ANDROID_NDK_ROOT\
	-DANDROID_PLATFORM=android-$API \
	-DANDROID_ABI:STRING=$ABI \
	-DANDROID_TOOLCHAIN=clang \
	-DCMAKE_FIND_ROOT_PATH:PATH=$QT_INSTALL_PREFIX \
	-DCMAKE_LIBRARY_PATH=$DEV_PREFIX \
	-DCMAKE_INSTALL_PREFIX=$DEV_PREFIX \
	-DCMAKE_STAGING_PREFIX=$DEV_PREFIX \
	-DCMAKE_C_FLAGS="${C_FLAGS}" \
	-DCMAKE_CPP_FLAGS="${CPP_FLAGS}" \
	-DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS_COMMON}" \
	-DCMAKE_SHARED_LINKER_FLAGS="${LDFLAGS_COMMON}" \
	-DANDROID_ARM_NEON=ON \
	-DANDROID_LD=lld \
	-DQT_QMAKE_EXECUTABLE:STRING=$QMAKE \
	-DCMAKE_PREFIX_PATH:STRING=$QT_INSTALL_PREFIX/lib/cmake\;$DEV_PREFIX/lib/cmake \
	-DCMAKE_C_COMPILER:STRING=$CC \
	-DCMAKE_CXX_COMPILER:STRING=$CXX \
	-DANDROID_NATIVE_API_LEVEL:STRING=$API \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-B${BUILDDIR} \
	$@
