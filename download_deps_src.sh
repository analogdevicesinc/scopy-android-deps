#!/bin/bash

source ./build_system_setup.sh $1

download_deps() {
	rm -rf $DEPS_SRC_PATH
	mkdir -p $DEPS_SRC_PATH
	pushd $DEPS_SRC_PATH

	wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz
	wget https://github.com/libffi/libffi/releases/download/v3.3/libffi-3.3.tar.gz
	wget https://ftp.gnu.org/pub/gnu/gettext/gettext-0.21.tar.gz
	wget https://download.gnome.org/sources/glib/2.58/glib-2.58.3.tar.xz
	wget http://ftp.acc.umu.se/pub/gnome/sources/glibmm/2.58/glibmm-2.58.1.tar.xz
	wget http://ftp.acc.umu.se/pub/GNOME/sources/libsigc++/2.10/libsigc++-2.10.0.tar.xz
	wget https://www.python.org/ftp/python/3.8.7/Python-3.8.7.tgz

	popd
}

download_deps
