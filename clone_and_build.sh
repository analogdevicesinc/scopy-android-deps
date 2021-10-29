#!/bin/sh
export BRANCH=androiddecoders
wget https://raw.githubusercontent.com/analogdevicesinc/scopy/$BRANCH/CI/appveyor/build_scopy_apk.sh
chmod +x ./build_scopy_apk.sh
./build_scopy_apk.sh
