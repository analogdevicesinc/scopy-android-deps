#!/bin/bash
set -xe

if [ $# -ne 1 ]; then
        ARG1=build_$ABI
else
        ARG1=$1
fi


echo Copying .so libraries to ./android-build/libs/$ABI
cp $DEV_PREFIX/lib/*.so ./android/libs/$ABI
cp $QT_INSTALL_PREFIX/lib/libQt5*_$ABI.so $ARG1/android-build/libs/$ABI
cp -R $DEV_PREFIX/lib/python3.8 ./android/assets/
cp -R $DEV_PREFIX/share/libsigrokdecode ./android/assets/
$ANDROID_QT_DEPLOY --input $ARG1/android_deployment_settings.json --output $ARG1/android-build --android-platform android-$API --jdk $JDK --gradle --verbose
