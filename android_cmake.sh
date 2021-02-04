#!/bin/bash
#source /home/adi/android/android_toolchain.sh
#export ANDROID_NDK=$HOME/Android/Sdk/ndk-bundle
#export ANDROID_API=28
#CMAKE="echo"
echo DEV_PREFIX = $DEV_PREFIX

################ HACK .. REMOVE ALL LIBRARIES FROM
# ~/android/sdk/ndk/21.3.6528147/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/x86_64-linux-android
# so CMAKE TARGETS ~/android/sdk/ndk/21.3.6528147/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/x86_64-linux-android/$API_VERSION
### FIGURE OUT HOW TO CHANGE THIS FROM CMAKE

$CMAKE \
	-B${@: -1}/build \
	-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
	-DCMAKE_BUILD_TYPE:String=Debug \
	-DANDROID_STL:STRING=c++_shared \
	-DANDROID_SDK:PATH=/home/adi/android/sdk/ \
	-DCMAKE_SYSTEM_NAME=Android \
	-DANDROID_NDK=$ANDROID_NDK \
	-DANDROID_PLATFORM=android-$API \
	-DANDROID_ABI:STRING=$ABI \
	-DANDROID_TOOLCHAIN_NAME=$TARGET \
	-DCMAKE_FIND_ROOT_PATH:PATH=$QT_INSTALL_PREFIX \
	-DCMAKE_LIBRARY_PATH=$DEV_PREFIX \
	-DCMAKE_INSTALL_PREFIX=$DEV_PREFIX \
	-DCMAKE_STAGING_PREFIX=$DEV_PREFIX \
	-DCMAKE_C_FLAGS=$CFLAGS \
	-DCMAKE_SHARED_LINKER_FLAGS=$LDFLAGS \
	$@

	#-DANDROID_TOOLCHAIN_NAME=$TARGET \
#QT CMAKE
#-GNinja
#-DCMAKE_BUILD_TYPE:String=Debug
#-DQT_QMAKE_EXECUTABLE:STRING=%{Qt:qmakeExecutable}
#-DCMAKE_PREFIX_PATH:STRING=%{Qt:QT_INSTALL_PREFIX}
#-DCMAKE_C_COMPILER:STRING=%{Compiler:Executable:C}
#-DCMAKE_CXX_COMPILER:STRING=%{Compiler:Executable:Cxx}
#-DANDROID_NATIVE_API_LEVEL:STRING=16
#-DANDROID_NDK:PATH=/home/adi/android/sdk/ndk/21.3.6528147
#-DCMAKE_TOOLCHAIN_FILE:PATH=/home/adi/android/sdk/ndk/21.3.6528147/build/cmake/android.toolchain.cmake
#-DANDROID_ABI:STRING=armeabi-v7a
#-DANDROID_STL:STRING=c++_shared
#-DCMAKE_FIND_ROOT_PATH:PATH=%{Qt:QT_INSTALL_PREFIX}
#-DANDROID_SDK:PATH=/home/adi/android/sdk/

#-DCMAKE_INSTALL_PREFIX=$SYSROOT \
#	-DCMAKE_PREFIX_PATH="$SYSROOT" \
#	-DCMAKE_INCLUDE_PATH=$SYSROOT/include/libxml2 \
#	-DCMAKE_LIBRARY=$SYSROOT/lib \

	#-DANDROID_PLATFORM=android-$ANDROID_API \
#	-DCMAKE_SYSROOT=$SYSROOT \
