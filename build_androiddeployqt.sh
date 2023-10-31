#!/bin/bash
set -xe
source build_system_setup.sh

git clone https://github.com/qt/qtbase $SCRIPT_HOME_DIR/qtbase --branch v5.15.2
pushd qtbase/src/tools/androiddeployqt

git reset --hard
git clean -xdf
sed -i 's/-needed-libs/--needed-libs/g' main.cpp
$QT_INSTALL_PREFIX_NO_POSTFIX/bin/qmake .
make
cp $SCRIPT_HOME_DIR/qtbase/bin/androiddeployqt $QT_INSTALL_PREFIX_NO_POSTFIX/bin/androiddeployqt
popd
rm -rf $SCRIPT_HOME_DIR/qtbase