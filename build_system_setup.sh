#!/bin/bash

############### SYSTEM SPECIFIC DEFINES ############
export USER_DIR=$1
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export CMAKE=$HOME/Qt/Tools/CMake/bin/cmake
export QT_INSTALL_PREFIX=$HOME/Qt/5.15.2/android
export JDK=/usr/lib/jvm/java-17-openjdk-amd64
export JAVA_HOME=$JDK
export PATH=$JAVA_HOME/bin:$PATH
export SCRIPT_HOME_DIR=$HOME/src/scopy-android-deps
export DEPS_SRC_PATH=$SCRIPT_HOME_DIR/downloads
export BUILD_ROOT=$SCRIPT_HOME_DIR/gnuradio-android
