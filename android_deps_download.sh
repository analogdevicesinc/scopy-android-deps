#!/bin/bash
set -e
source android_toolchain.sh

SCRIPT_HOME_DIR=$PWD
WORKDIR=$SCRIPT_HOME_DIR/dep_build_$ARCH
DEPS_SRC_PATH=$SCRIPT_HOME_DIR/deps_src
JOBS=9


download_deps() {
	mkdir -p $DEPS_SRC_PATH
	cd $DEPS_SRC_PATH
	wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz
	git clone --depth=1 https://gitlab.gnome.org/GNOME/libxml2
	git clone --depth=1 https://github.com/analogdevicesinc/libiio

}

download_deps
