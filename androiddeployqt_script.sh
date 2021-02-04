#!/bin/bash
cd build
echo Copying .so libraries to ./android-build/libs/$ABI
cp $DEV_PREFIX/lib/*.so android-build/libs/$ABI
$ANDROID_QT_DEPLOY --input android_deployment_settings.json --output android-build --android-platform android-$API --jdk $JDK --gradle --verbose
