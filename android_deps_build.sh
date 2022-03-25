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

	build_with_cmake -DWITH_PYTHON=OFF

	popd
}

build_gr-scopy() {
	pushd $SCRIPT_HOME_DIR/gr-scopy
	git clean -xdf

	build_with_cmake -DWITH_PYTHON=OFF

	popd
}

build_qwt() {
	pushd $SCRIPT_HOME_DIR/qwt
	git clean -xdf

	$QMAKE ANDROID_ABIS="$ABI" ANDROID_MIN_SDK_VERSION=$API ANDROID_API_VERSION=$API INCLUDEPATH=$DEV_PREFIX/include LIBS=-L$DEV_PREFIX/lib qwt.pro
	make -j$JOBS
	make -j$JOBS INSTALL_ROOT=$DEV_PREFIX install
	popd

}

move_qwt_libs (){
	cp -R $DEV_PREFIX/usr/local/* $DEV_PREFIX/
	cp -R $DEV_PREFIX/libs/$ABI/* $DEV_PREFIX/lib # another hack
}

move_boost_libs() {
	cp -R $DEV_PREFIX/$ABI/* $DEV_PREFIX
}

build_glib() {
	pushd $SCRIPT_HOME_DIR/glib
	git clean -xdf

	#CPPFLAGS=/path/to/standalone/include LDFLAGS=/path/to/standalone/lib ./configure \
	#--prefix=/path/to/standalone --bindir=$AS_BIN --build=i686-pc-linux-gnu --host=arm-linux-androideabi \
	#--cache-file=android.cache

echo "glib_cv_stack_grows=no
glib_cv_uscore=no
ac_cv_func_posix_getpwuid_r=no
ac_cv_func_posix_getgrgid_r=no " > android.cache

	NOCONFIGURE=yes ./autogen.sh

	LDFLAGS="$LDFLAGS_COMMON -lffi -lz"
	android_configure --cache-file=android.cache --with-libiconv=gnu --disable-dtrace --disable-xattr --disable-systemtap --with-pcre=internal --enable-libmount=no

	popd
}

build_glibmm() {
	echo "### Building glibmm - 2.58.1"
	pushd $SCRIPT_HOME_DIR/glibmm
	git clean -xdf

	LDFLAGS="$LDFLAGS_COMMON -lffi -lz"
	android_configure --disable-documentation

	popd
}

build_sigcpp() {
	echo "### Building libsigc++ -2.10.0"
	pushd $SCRIPT_HOME_DIR/libsigcplusplus
	git clean -xdf

	NOCONFIGURE=yes	./autogen.sh
	android_configure --disable-documentation

	popd
}

build_libsigrokdecode() {
	pushd $SCRIPT_HOME_DIR/libsigrokdecode
	git clean -xdf

	NOCONFIGURE=yes ./autogen.sh
	android_configure

	popd
}

build_python() {
	pushd $SCRIPT_HOME_DIR/python

	# Python should be cross-built with the same version that is available on host, if nothing is available, it should be built with the script ./build_host_python
	git clean -xdf
	autoreconf
	cp $BUILD_ROOT/android_configure.sh .
	ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no ac_cv_func_pipe2=no ac_cv_func_fdatasync=no ac_cv_func_killpg=no ac_cv_func_waitid=no ac_cv_func_sigaltstack=no ./android_configure.sh  --build=x86_64-linux-gnu --disable-ipv6
	sed -i "s/^#zlib/zlib/g" Modules/Setup
	sed -i "s/^#math/math/g" Modules/Setup
	sed -i "s/^#time/time/g" Modules/Setup
	sed -i "s/^#_struct/_struct/g" Modules/Setup

	if [ $ABI == "arm64-v8a" ]; then
		LINTL=-lintl
	fi

	make -j$JOBS LDFLAGS="$LDFLAGS $LINTL -liconv -lz -lm"  install
	rm -rf $DEV_PREFIX/lib/python3.8/test

	popd

}

build_gr-iio3.8() {
        pushd ${SCRIPT_HOME_DIR}/gr-iio-3.8
        git clean -xdf

	build_with_cmake -DWITH_PYTHON=OFF

        popd
}

build_log4cpp() {

	pushd ${SCRIPT_HOME_DIR}/log4cpp
	git clean -xdf
	build_with_cmake
	popd

}

build_gnuradio3.8() {
	pushd ${SCRIPT_HOME_DIR}/gnuradio-3.8
	git clean -xdf

	rm -rf build
	mkdir build
	cd build

	echo "$LDFLAGS_COMMON"

	build_with_cmake  \
	  -DPYTHON_EXECUTABLE=/usr/bin/python3 \
	  -DENABLE_INTERNAL_VOLK=OFF \
	  -DBOOST_ROOT=${PREFIX} \
	  -DBoost_COMPILER=-clang \
	  -DBoost_USE_STATIC_LIBS=ON \
	  -DBoost_ARCHITECTURE=-a32 \
	  -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
	  -DENABLE_DOXYGEN=OFF \
	  -DENABLE_SPHINX=OFF \
	  -DENABLE_PYTHON=OFF \
	  -DENABLE_TESTING=OFF \
	  -DENABLE_GR_FEC=OFF \
	  -DENABLE_GR_AUDIO=OFF \
	  -DENABLE_GR_DTV=OFF \
	  -DENABLE_GR_CHANNELS=OFF \
	  -DENABLE_GR_VOCODER=OFF \
	  -DENABLE_GR_TRELLIS=OFF \
	  -DENABLE_GR_WAVELET=OFF \
	  -DENABLE_GR_CTRLPORT=OFF \
	  -DENABLE_CTRLPORT_THRIFT=OFF \
	  -DCMAKE_VERBOSE_MAKEFILE=ON \
	   ../
	make -j ${JOBS}
	make install
	popd
}
build_libtinyiiod() {
	pushd $SCRIPT_HOME_DIR/libtinyiiod
	git clean -xdf

	cp $BUILD_ROOT/android_cmake.sh .
	cp $SCRIPT_HOME_DIR/android_deploy_qt.sh .

	build_with_cmake

	popd
}
build_qadvanceddocking() {
	pushd $SCRIPT_HOME_DIR/qadvanceddocking
	git clean -xdf
	cp $BUILD_ROOT/android_cmake.sh .
	cp $SCRIPT_HOME_DIR/android_deploy_qt.sh .

	build_with_cmake
	popd
}

reset_build_env
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
#build_libzmq
build_fftw
build_libgmp
build_libusb
build_libiio
build_libad9361
build_libm2k
build_volk
#build_log4cpp # not used
build_gnuradio3.8
build_gr-iio3.8
build_gr-scopy
build_gr-m2k
build_qwt
move_qwt_libs
#build_qadvanceddocking
build_python
build_libsigrokdecode
build_libtinyiiod
