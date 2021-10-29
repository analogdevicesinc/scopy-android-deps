#!/bin/bash

source ./build_system_setup.sh $1

recurse_submodules() {
pushd $SCRIPT_HOME_DIR
git submodule update --init gnuradio-android/
git submodule update --init gr-m2k/
git submodule update --init gr-scopy/
git submodule update --init libm2k/
git submodule update --init libsigrokdecode/
git submodule update --init --recursive gr-iio-3.8/
git submodule update --init --recursive gnuradio-3.8/
git submodule update --init --recursive glibmm/
git submodule update --init --recursive python/
git submodule update --init --recursive libsigcplusplus/
git submodule update --init --recursive glib/
git submodule update --init --recursive qwt/
git submodule update --init --recursive libtinyiiod/

cd $SCRIPT_HOME_DIR/gnuradio-android
git submodule update --init --recursive Boost-for-Android/
git submodule update --init libxml2/
git submodule update --init --recursive libiio/
git submodule update --init libad9361-iio/
git submodule update --init --recursive libiconv/
git submodule update --init --recursive gettext/
git submodule update --init --recursive fftw/
git submodule update --init --recursive libgmp/
git submodule update --init --recursive libusb/
git submodule update --init --recursive libzmq/
git submodule update --init --recursive volk/ 
git submodule update --init --recursive libffi/

popd
}

download_deps() {
	rm -rf $DEPS_SRC_PATH
	mkdir -p $DEPS_SRC_PATH
	pushd $DEPS_SRC_PATH

#	wget https://download.gnome.org/sources/glib/2.58/glib-2.58.3.tar.xz
#	wget http://ftp.acc.umu.se/pub/gnome/sources/glibmm/2.58/glibmm-2.58.1.tar.xz
#	wget http://ftp.acc.umu.se/pub/GNOME/sources/libsigc++/2.10/libsigc++-2.10.0.tar.xz

	popd
}

install_jdk() {
	cd $HOME
	sudo apt-get -y install openjdk-17-jdk
#	wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/16.0.2%2B7/d4a915d82b4c4fbb9bde534da945d746/jdk-16.0.2_linux-x64_bin.tar.gz
#	tar xvf jdk-16.0.2_linux-x64_bin.tar.gz
}

recurse_submodules
#download_deps
#install_jdk
