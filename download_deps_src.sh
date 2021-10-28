#!/bin/bash

source ./build_system_setup.sh $1

download_deps() {
	rm -rf $DEPS_SRC_PATH
	mkdir -p $DEPS_SRC_PATH
	pushd $DEPS_SRC_PATH

	wget https://download.gnome.org/sources/glib/2.58/glib-2.58.3.tar.xz
	wget http://ftp.acc.umu.se/pub/gnome/sources/glibmm/2.58/glibmm-2.58.1.tar.xz
	wget http://ftp.acc.umu.se/pub/GNOME/sources/libsigc++/2.10/libsigc++-2.10.0.tar.xz
	wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz

	popd
}

install_jdk() {
	cd $HOME
	wget https://download.java.net/openjdk/jdk17/ri/openjdk-17+35_linux-x64_bin.tar.gz
	tar xvf openjdk-17+35_linux-x64_bin.tar.gz
}

download_deps
install_jdk
