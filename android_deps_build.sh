#!/bin/bash
set -xe
source ./android_toolchain.sh $1 $2
source gnuradio-android/include_dependencies.sh

reset_build_env() {
	rm -rf $WORKDIR
	mkdir -p $WORKDIR
	cd $WORKDIR
}

build_libm2k() {
	pushd $SCRIPT_HOME_DIR/libm2k
	git clean -xdf

	build_with_cmake -DENABLE_PYTHON=OFF
	
	popd
}

build_gr-m2k() {
	pushd $SCRIPT_HOME_DIR/gr-m2k
	git clean -xdf

	build_with_cmake
	
	popd
}

build_gr-scopy() {
	pushd $SCRIPT_HOME_DIR/gr-scopy
	git clean -xdf

	build_with_cmake
	
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

	patch -p1 src/src.pro $SCRIPT_HOME_DIR/qwt_android.patch

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

build_glib() {
	pushd $WORKDIR
	rm -rf glib-2.58.3
	tar xvf $DEPS_SRC_PATH/glib-2.58.3.tar.xz

	#CPPFLAGS=/path/to/standalone/include LDFLAGS=/path/to/standalone/lib ./configure \
	#--prefix=/path/to/standalone --bindir=$AS_BIN --build=i686-pc-linux-gnu --host=arm-linux-androideabi \
	#--cache-file=android.cache
	cd glib-2.58.3

echo "glib_cv_stack_grows=no
glib_cv_uscore=no
ac_cv_func_posix_getpwuid_r=no
ac_cv_func_posix_getgrgid_r=no " > android.cache

	NOCONFIGURE=1 ./autogen.sh

	LDFLAGS="$LDFLAGS_COMMON -lffi -lz"
	android_configure --cache-file=android.cache --with-libiconv=gnu --disable-dtrace --disable-xattr --disable-systemtap --with-pcre=internal --enable-libmount=no

	popd
}

build_glibmm() {
	echo "### Building glibmm - 2.58.1"
	pushd $WORKDIR
	tar xvf $DEPS_SRC_PATH/glibmm-2.58.1.tar.xz
	cd glibmm-2.58.1

	LDFLAGS="$LDFLAGS_COMMON -lffi -lz"
	android_configure

	popd
}

build_sigcpp() {
	echo "### Building libsigc++ -2.10.0"
	pushd $WORKDIR
	tar xvf $DEPS_SRC_PATH/libsigc++-2.10.0.tar.xz
	cd libsigc++-2.10.0

	android_configure

	popd
}

build_libsigrokdecode() {
	pushd $SCRIPT_HOME_DIR/libsigrokdecode
	git clean -xdf

	NOCONFIGURE=1 ./autogen.sh
	android_configure

	popd
}

build_python() {
	pushd $WORKDIR
	rm -rf Python-3.8.7
	tar xvf $DEPS_SRC_PATH/Python-3.8.7.tgz
	cd Python-3.8.7
	echo "ac_cv_file__dev_ptmx=no
	ac_cv_file__dev_ptc=no " > config.site

	cp $BUILD_ROOT/android_configure.sh .
	CONFIG_SITE=config.site ./android_configure.sh --disable-ipv6
	make -j$JOBS LDFLAGS="$LDFLAGS -lintl -liconv"
	make -j$JOBS install

	popd

}


build_libtinyiiod() {
	pushd $SCRIPT_HOME_DIR/libtinyiiod
	git clean -xdf

	cp $BUILD_ROOT/android_cmake.sh .
	cp $SCRIPT_HOME_DIR/android_deploy_qt.sh .

	./android_cmake.sh .
	cd build_$ABI
	make -j$JOBS
	make -j$JOBS install
	cd ..

	popd
}

reset_build_env
download_dependencies
build_libiconv
build_libffi
build_gettext
build_libiconv # HANDLE CIRCULAR DEP
build_glib
build_sigcpp
build_glibmm
build_libxml2
build_boost
move_boost_libs
build_libzmq
build_fftw
build_libgmp
build_libusb
build_libiio
build_libad9361
build_libm2k
build_volk
build_gnuradio
build_gr-iio
build_gr-scopy
build_gr-m2k
build_qwt
move_qwt_libs
build_python
build_libsigrokdecode
build_libtinyiiod
