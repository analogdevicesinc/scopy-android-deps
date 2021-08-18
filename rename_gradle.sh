#!/bin/bash
set -xe
source ./build_system_setup.sh $1

rename_gradle() {
        cd $QT_INSTALL_PREFIX/src/3rdparty/gradle/gradle/wrapper
        sed -i "s|https\\\:\/\/services\.gradle\.org\/distributions\/gradle.*\.zip|https\://services.gradle.org/distributions/gradle-6.3-all.zip|g" gradle-wrapper.properties
}

rename_gradle
