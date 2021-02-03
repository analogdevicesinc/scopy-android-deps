#!/bin/bash
set -e
source ./android_toolchain.sh

build_libiconv() {

	pushd $WORKDIR
	rm -rf libiconv-1.15
	tar xvf $DEPS_SRC_PATH/libiconv-1.15.tar.gz
	cd libiconv-1.15
	cp $SCRIPT_HOME_DIR/android_configure.sh .
	./android_configure.sh --enable-static=yes --enable-shared=yes
	make -j$JOBS
	make -j$JOBS install
	popd
}

build_libxml2() {
	pushd $WORKDIR
	rm -rf libxml2
	git clone --depth=1 https://gitlab.gnome.org/GNOME/libxml2
	cd libxml2
	cp $SCRIPT_HOME_DIR/android_cmake.sh .
	rm -rf build
	mkdir -p build
	echo $PWD
	./android_cmake.sh -DLIBXML2_WITH_LZMA=OFF -DLIBXML2_WITH_PYTHON=OFF -DCMAKE_VERBOSE_MAKEFILE=ON .
	cd build
	make -j$JOBS
	make -j$JOBS install
	popd
}

build_libiio() {
	pushd $WORKDIR
	rm -rf libiio
	git clone --depth=1 https://github.com/analogdevicesinc/libiio
	cd libiio
	cp $SCRIPT_HOME_DIR/android_cmake.sh .
	rm -rf build
	mkdir -p build
	echo $PWD
	./android_cmake.sh --debug-find -DCMAKE_VERBOSE_MAKEFILE=ON .
	cd build
	make -j$JOBS
	make -j$JOBS install
	popd
}


rm -rf $WORKDIR
mkdir -p $WORKDIR
cd $WORKDIR

build_libiconv
build_libxml2
build_libiio
