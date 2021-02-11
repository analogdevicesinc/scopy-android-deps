#!/bin/bash
set -xe
source ./android_toolchain.sh $1

BUILD_FOLDER=./build_$ABI

build_with_cmake() {
	cp $SCRIPT_HOME_DIR/android_cmake.sh .
	rm -rf $BUILD_FOLDER
	mkdir -p $BUILD_FOLDER
	echo $PWD
	./android_cmake.sh $@ -DCMAKE_VERBOSE_MAKEFILE=ON .
	cd $BUILD_FOLDER
	make -j$JOBS
	make -j$JOBS install
}

reset_build_env() {
	rm -rf $WORKDIR
	mkdir -p $WORKDIR
	cd $WORKDIR
}

build_libiconv() {

	pushd $WORKDIR
	rm -rf libiconv-1.15
	tar xvf $DEPS_SRC_PATH/libiconv-1.15.tar.gz
	cd libiconv-1.15
	cp $SCRIPT_HOME_DIR/android_configure.sh .
	./android_configure.sh --enable-static=no --enable-shared=yes
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
	rm -rf $BUILD_FOLDER
	mkdir -p $BUILD_FOLDER
	echo $PWD
	./android_cmake.sh -B$BUILD_FOLDER -DLIBXML2_WITH_LZMA=OFF -DLIBXML2_WITH_PYTHON=OFF -DCMAKE_VERBOSE_MAKEFILE=ON .
	cd $BUILD_FOLDER
	make -j$JOBS
	make -j$JOBS install
	popd
}

build_libiio() {
	pushd $WORKDIR
	rm -rf libiio
	git clone https://github.com/analogdevicesinc/libiio
	cd libiio
	cp $SCRIPT_HOME_DIR/android_cmake.sh -DHAVE_DNS_SD=OFF
	rm -rf $BUILD_FOLDER
	mkdir -p $BUILD_FOLDER
	echo $PWD
	./android_cmake.sh -B$BUILD_FOLDER -DCMAKE_VERBOSE_MAKEFILE=ON .
	cd $BUILD_FOLDER
	make -j$JOBS
	make -j$JOBS install
	popd
}

build_libad9361 () {
	pushd $WORKDIR
	rm -rf libad9361-iio
	git clone --depth=1 https://github.com/analogdevicesinc/libad9361-iio
	cd libad9361-iio
	build_with_cmake
	popd
}

build_libm2k() {
	pushd $WORKDIR
	rm -rf libm2k
	git clone --depth=1 https://github.com/analogdevicesinc/libm2k --branch master
	cd libm2k
	cp $SCRIPT_HOME_DIR/android_cmake.sh .
	rm -rf $BUILD_FOLDER
	mkdir -p $BUILD_FOLDER
	echo $PWD
	./android_cmake.sh -B$BUILD_FOLDER -DENABLE_PYTHON=OFF -DCMAKE_VERBOSE_MAKEFILE=ON .
	cd $BUILD_FOLDER
	make -j$JOBS
	make -j$JOBS install
	popd

}

build_gr-iio() {

	pushd $WORKDIR
	rm -rf gr-iio
	git clone --depth=1 https://github.com/analogdevicesinc/gr-iio --branch upgrade-3.8
	cd gr-iio
	cp $SCRIPT_HOME_DIR/android_cmake.sh .
	rm -rf $BUILD_FOLDER
	mkdir -p $BUILD_FOLDER
	echo $PWD
	./android_cmake.sh -B$BUILD_FOLDER -DCMAKE_VERBOSE_MAKEFILE=ON .
	cd $BUILD_FOLDER
	make -j$JOBS
	make -j$JOBS install
	popd

}

build_gr-m2k() {

	pushd $WORKDIR
	rm -rf gr-m2k
	git clone --depth=1 https://github.com/analogdevicesinc/gr-m2k --branch master
	cd gr-m2k
	cp $SCRIPT_HOME_DIR/android_cmake.sh .
	rm -rf $BUILD_FOLDER
	mkdir -p $BUILD_FOLDER
	echo $PWD
	./android_cmake.sh -B$BUILD_FOLDER -DCMAKE_VERBOSE_MAKEFILE=ON .
	cd $BUILD_FOLDER
	make -j$JOBS
	make -j$JOBS install
	popd

}

build_gr-scopy() {
	pushd $WORKDIR
	rm -rf gr-scopy
	git clone --depth=1 https://github.com/analogdevicesinc/gr-scopy --branch master
	cd gr-scopy
	cp $SCRIPT_HOME_DIR/android_cmake.sh .
	rm -rf $BUILD_FOLDER
	mkdir -p $BUILD_FOLDER
	echo $PWD
	./android_cmake.sh -B$BUILD_FOLDER -DCMAKE_VERBOSE_MAKEFILE=ON .
	cd $BUILD_FOLDER
	make -j$JOBS
	make -j$JOBS install
	popd

}

build_qwt() {
	pushd $WORKDIR
	QWT_NAME=qwt-code
	svn checkout svn://svn.code.sf.net/p/qwt/code/branches/qwt-6.1-multiaxes $QWT_NAME
	cd $QWT_NAME

	sed -i "s/^QWT_CONFIG\\s*+=\\s*QwtMathML$/#/g" qwtconfig.pri
	sed -i "s/^QWT_CONFIG\\s*+=\\s*QwtDesigner$/#/g" qwtconfig.pri
	sed -i "s/^QWT_CONFIG\\s*+=\\s*QwtExamples$/#/g" qwtconfig.pri
	sed -i "s/^QWT_CONFIG\\s*+=\\s*QwtPlayground$/#/g" qwtconfig.pri
	sed -i "s/^QWT_CONFIG\\s*+=\\s*QwtTests$/#/g" qwtconfig.pri

	# Fix prefix
	sed -i "s/^\\s*QWT_INSTALL_PREFIX.*$/QWT_INSTALL_PREFIX=\"\"/g" qwtconfig.pri

	$QMAKE ANDROID_ABIS="$ABI" ANDROID_MIN_SDK_VERSION=$API ANDROID_API_VERSION=$API INCLUDEPATH=$DEV_PREFIX/include LIBS=-L$DEV_PREFIX/lib qwt.pro
	make -j$JOBS INSTALL_ROOT=$DEV_PREFIX install

	popd
	# qwtpolar is now part of qwt

}

move_qwt_libs (){
	cp -R $DEV_PREFIX/libs/$ABI/* $DEV_PREFIX/lib # another hack
}

move_boost_libs() {
	cp -R $DEV_PREFIX/$ABI/* $DEV_PREFIX
}

source gnuradio-android/build.sh

build_libffi() {
	pushd $WORKDIR
	rm -rf libffi-3.3
	wget https://github.com/libffi/libffi/releases/download/v3.3/libffi-3.3.tar.gz
	tar xvf libffi-3.3.tar.gz
	cd libffi-3.3
	cp $SCRIPT_HOME_DIR/android_configure.sh .
	./android_configure.sh --cache-file=android.cache
	make -j$JOBS
	make -j$JOBS install
	popd
}
build_gettext() {
	pushd $WORKDIR
	rm -rf gettext-0.21
	wget https://ftp.gnu.org/pub/gnu/gettext/gettext-0.21.tar.gz
	tar xvf gettext-0.21.tar.gz
	cd gettext-0.21
	#./gitsub.sh pull
	#NOCONFIGURE=1 ./autogen.sh
	cp $SCRIPT_HOME_DIR/android_configure.sh .
	./android_configure.sh --cache-file=android.cache
	make -j$JOBS
	make -j$JOBS install
	popd
}

build_glib() {
	pushd $WORKDIR
	rm -rf glib-2.58.3
	#git clone https://git.gnome.org/browse/glib
	wget https://download.gnome.org/sources/glib/2.58/glib-2.58.3.tar.xz
	tar xvf glib-2.58.3.tar.xz


#CPPFLAGS=/path/to/standalone/include LDFLAGS=/path/to/standalone/lib ./configure \
#--prefix=/path/to/standalone --bindir=$AS_BIN --build=i686-pc-linux-gnu --host=arm-linux-androideabi \
#--cache-file=android.cache
	cd glib-2.58.3

echo "glib_cv_stack_grows=no
glib_cv_uscore=no
ac_cv_func_posix_getpwuid_r=no
ac_cv_func_posix_getgrgid_r=no " > android.cache

	NOCONFIGURE=1 ./autogen.sh
	cp $SCRIPT_HOME_DIR/android_configure.sh .
	./android_configure.sh --cache-file=android.cache --with-libiconv=gnu --disable-dtrace --disable-xattr --disable-systemtap --with-pcre=internal --enable-libmount=no
	make -j$JOBS LDFLAGS="$LDFLAGS -lffi -lz"
	make -j$JOBS install
	popd
}

build_glibmm() {
	echo "### Building glibmm - 2.58.1"
	pushd $WORKDIR
	wget http://ftp.acc.umu.se/pub/gnome/sources/glibmm/2.58/glibmm-2.58.1.tar.xz
	tar xvf glibmm-2.58.1.tar.xz
	cd glibmm-2.58.1
	cp $SCRIPT_HOME_DIR/android_configure.sh .
	./android_configure.sh
	make -j$JOBS LDFLAGS="$LDFLAGS -lffi -lz"
	make -j$JOBS install
	popd
}

build_sigcpp() {
	echo "### Building libsigc++ -2.10.0"
	pushd $WORKDIR
	wget http://ftp.acc.umu.se/pub/GNOME/sources/libsigc++/2.10/libsigc++-2.10.0.tar.xz
	tar xvf libsigc++-2.10.0.tar.xz
	cd libsigc++-2.10.0
	cp $SCRIPT_HOME_DIR/android_configure.sh .
	./android_configure.sh
	make -j$JOBS
	make -j$JOBS install
	popd
}

build_libsigrokdecode() {

	pushd $WORKDIR
	git clone --depth 1 https://github.com/sigrokproject/libsigrokdecode.git
	cd ${WORKDIR}/libsigrokdecode
	cp $SCRIPT_HOME_DIR/android_configure.sh .

	NOCONFIGURE=1 ./autogen.sh
	./android_configure.sh
	make -j$JOBS
	make -j$JOBS install
	popd

}
build_python() {
	pushd $WORKDIR
	rm -rf Python-3.8.7
	wget https://www.python.org/ftp/python/3.8.7/Python-3.8.7.tgz
	tar xvf Python-3.8.7.tgz
	cd Python-3.8.7
	echo "ac_cv_file__dev_ptmx=no
ac_cv_file__dev_ptc=no " > config.site
	cp $SCRIPT_HOME_DIR/android_configure.sh .
	CONFIG_SITE=config.site ./android_configure.sh --disable-ipv6
	make -j$JOBS LDFLAGS="$LDFLAGS -lintl -liconv"
	make -j$JOBS install
	popd

}


build_libtinyiiod() {

	pushd $WORKDIR
	rm -rf scopy
	git clone https://github.com/analogdevicesinc/libtinyiiod.git --branch master
	cd ${WORKDIR}/libtinyiiod
	rm -rf build*
	cp $SCRIPT_HOME_DIR/android_cmake.sh .
	cp $SCRIPT_HOME_DIR/android_deploy_qt.sh .

	./android_cmake.sh .
	cd build_$ABI
	make -j$JOBS
	make -j$JOBS install
	cd ..
	popd
}
build_scopy() {

	pushd $WORKDIR
	rm -rf scopy
	git clone https://github.com/adisuciu/scopy.git --branch android
	cd ${WORKDIR}/scopy
	rm -rf build*
	cp $SCRIPT_HOME_DIR/android_cmake.sh .
	cp $SCRIPT_HOME_DIR/android_deploy_qt.sh .

	./android_cmake.sh .
	cd build_$ABI
	make -j$JOBS
	make -j$JOBS install
	cd ..
	./android_deploy_qt.sh
	popd
}

#reset_build_env
#build_libiconv
#build_libffi
#build_gettext
#build_libiconv # HANDLE CIRCULAR DEP
#build_glib
#build_sigcpp
#build_glibmm
#build_libxml2
#build_boost
#move_boost_libs
#build_libzmq
#build_fftw
#build_libgmp
build_libusb # THIS IS BUGGED I THINK
build_libiio
build_libad9361
build_libm2k
#build_volk
#build_gnuradio
build_gr-iio
#build_gr-scopy
build_gr-m2k
#build_qwt
#move_qwt_libs
#build_python
#build_libsigrokdecode
#build_libtinyiiod
#build_scopy
