#!/bin/bash
set -e
source android_toolchain.sh

download_deps() {
	mkdir -p $DEPS_SRC_PATH
	cd $DEPS_SRC_PATH
	wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz
	git clone --depth=1 https://gitlab.gnome.org/GNOME/libxml2
	git clone --depth=1 https://github.com/analogdevicesinc/libiio
	wget https://sourceforge.net/projects/boost/files/boost/1.72.0/boost_1_72_0.tar.gz
}

download_deps
