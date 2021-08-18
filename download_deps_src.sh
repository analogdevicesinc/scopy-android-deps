#!/bin/bash

download_deps() {
	mkdir -p $DEPS_SRC_PATH
	pushd $DEPS_SRC_PATH
	wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz
	popd
}

download_deps
