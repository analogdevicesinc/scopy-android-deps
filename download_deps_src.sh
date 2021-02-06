#!/bin/bash
set -e
source android_toolchain.sh

download_deps() {
	mkdir -p $DEPS_SRC_PATH
	cd $DEPS_SRC_PATH
	wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz
}

download_deps
