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
	wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/16.0.2%2B7/d4a915d82b4c4fbb9bde534da945d746/jdk-16.0.2_linux-x64_bin.tar.gz
	tar xvf jdk-16.0.2_linux-x64_bin.tar.gz
}

download_deps
install_jdk
