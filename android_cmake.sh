#!/bin/bash
#source /home/adi/android/android_toolchain.sh
#export ANDROID_NDK=$HOME/Android/Sdk/ndk-bundle
#export ANDROID_API=28
#CMAKE="echo"
#echo DEV_PREFIX = $DEV_PREFIX

################ HACK .. REMOVE ALL LIBRARIES FROM
# ~/android/sdk/ndk/21.3.6528147/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/x86_64-linux-android
# so CMAKE TARGETS ~/android/sdk/ndk/21.3.6528147/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/x86_64-linux-android/$API_VERSION
#
# libunwind.a still needs to be in the search path - it's not part of the API version
# only for armeabi-v7a
#
### FIGURE OUT HOW TO CHANGE THIS FROM CMAKE

########## HACK2 .. Change gradle version in qt from /home/adi/Qt/5.15.2/android/src/3rdparty/gradle/gradle/wrapper/gradle-wrapper.properties
# from distributionUrl=https\://services.gradle.org/distributions/gradle(whatever_version_smaller_than 6.3).zip
# to distributionUrl=https\://services.gradle.org/distributions/gradle-6.3-all.zip
###############################################################################################################################################

$CMAKE \
	-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
	-DCMAKE_BUILD_TYPE:String=Debug \
	-DANDROID_STL:STRING=c++_shared \
	-DANDROID_SDK:PATH=$ANDROID_SDK \
	-DCMAKE_SYSTEM_NAME=Android \
	-DANDROID_NDK=$ANDROID_NDK \
	-DANDROID_PLATFORM=android-$API \
	-DANDROID_ABI:STRING=$ABI \
	-DANDROID_TOOLCHAIN_NAME=$TARGET \
	-DCMAKE_FIND_ROOT_PATH:PATH=$QT_INSTALL_PREFIX \
	-DCMAKE_LIBRARY_PATH=$DEV_PREFIX \
	-DCMAKE_INSTALL_PREFIX=$DEV_PREFIX \
	-DCMAKE_STAGING_PREFIX=$DEV_PREFIX \
	-DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
	-DCMAKE_SHARED_LINKER_FLAGS="${LDFLAGS}" \
	-DCMAKE_PREFIX_PATH=$DEV_PREFIX/lib/cmake \
	-DANDROID_ARM_NEON=ON\
	-DANDROID_LD=lld \
	$QTFLAGS \
	$@

#	-DCMAKE_C_FLAGS=$CFLAGS \
#	-DCMAKE_CPP_FLAGS=$CPPFLAGS \

#	-DCMAKE_SHARED_LINKER_FLAGS=$LDFLAGS \
