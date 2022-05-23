#!/bin/bash

############### SYSTEM SPECIFIC DEFINES ############
export USER_DIR=$1
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export CMAKE=$HOME/Qt/Tools/CMake/bin/cmake
export QT_VERSION_STRING=6.3.0
export QT_INSTALL_PREFIX_NO_POSTFIX=$HOME/Qt/$QT_VERSION_STRING/android
#export JDK=/usr/lib/jvm/java-17-openjdk-amd64
export JDK=$HOME/jdk-14
#export JDK=/usr/lib/jvm/java-11-openjdk-amd64
export JAVA_HOME=$JDK
export PATH=$JAVA_HOME/bin:$PATH
export PYTHON_VERSION=3.8.10
export SCRIPT_HOME_DIR=$HOME/src/scopy-android-deps
export DEPS_SRC_PATH=$SCRIPT_HOME_DIR/downloads
export BUILD_ROOT=$SCRIPT_HOME_DIR/gnuradio-android
#export BUILD_TYPE=Release
export BUILD_TYPE=Debug
#export BUILD_TYPE=RelWithDebInfo
