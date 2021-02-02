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

}
build_libiconv() {

	pushd $WORKDIR
	tar xvf $DEPS_SRC_PATH/libiconv-1.15.tar.gz
	cd libiconv-1.15
	cp $SCRIPT_HOME_DIR/android_configure.sh .
	./android_configure.sh
	make -j$JOBS DESTDIR=$WORKDIR/dev install
	make -j$JOBS install
	popd
}


rm -rf $WORKDIR
mkdir $WORKDIR
cd $WORKDIR

#download_deps
build_libiconv
