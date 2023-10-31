#!/bin/bash
set -xe
source ./android_toolchain.sh $1 $2
source gnuradio-android/include_dependencies.sh

reset_build_env() {
	rm -rf $WORKDIR
	mkdir -p $WORKDIR
	cd $WORKDIR
}

create_build_status_file() {
	touch $BUILD_STATUS_FILE
	echo "NDK - $NDK_VERSION" >> $BUILD_STATUS_FILE
	echo "ANDROID API - $API" >> $BUILD_STATUS_FILE
	echo "ABI - $ABI" >> $BUILD_STATUS_FILE
	echo "JDK - $JDK" >> $BUILD_STATUS_FILE
	echo "Qt - $QT_VERSION_STRING" >> $BUILD_STATUS_FILE
	pushd $SCRIPT_HOME_DIR
	echo "scopy-android-deps - $(git rev-parse --short HEAD)" >> $BUILD_STATUS_FILE
	pushd $BUILD_ROOT
	echo "gnuradio-android - $(git rev-parse --short HEAD)" >> $BUILD_STATUS_FILE
}

build_libm2k() {
	pushd $SCRIPT_HOME_DIR/libm2k
	git clean -xdf
	export CURRENT_BUILD=libm2k

	build_with_cmake -DENABLE_PYTHON=OFF -DENABLE_TOOLS=ON

	popd
}

build_gr-m2k() {
	pushd $SCRIPT_HOME_DIR/gr-m2k
	git clean -xdf
	export CURRENT_BUILD=gr-m2k

	build_with_cmake -DWITH_PYTHON=OFF

	popd
}

build_gr-scopy() {
	pushd $SCRIPT_HOME_DIR/gr-scopy
	git clean -xdf
	export CURRENT_BUILD=gr-scopy

	build_with_cmake -DWITH_PYTHON=OFF

	popd
}

build_qwt() {
	pushd $SCRIPT_HOME_DIR/qwt
	git clean -xdf
	export CURRENT_BUILD=qwt

	$QMAKE ANDROID_ABIS="$ABI" ANDROID_MIN_SDK_VERSION=$API ANDROID_API_VERSION=$API INCLUDEPATH=$DEV_PREFIX/include LIBS=-L$DEV_PREFIX/lib qwt.pro
	make -j$JOBS
	strip
	make -j$JOBS INSTALL_ROOT=$DEV_PREFIX install
	clean
	popd

}

move_qwt_libs (){
	cp -R $DEV_PREFIX/usr/local/* $DEV_PREFIX/
	cp -R $DEV_PREFIX/libs/$ABI/* $DEV_PREFIX/lib # another hack
	cp -R $QT_INSTALL_PREFIX/lib/libQt5PrintSupport*.so $DEV_PREFIX/lib
}

move_boost_libs() {
	cp -R $DEV_PREFIX/$ABI/* $DEV_PREFIX
}


meson_flag_list()
{
	while (( "$#" )); do
		echo -n "'$1'";
		if [ $# -gt 1 ]; then
			echo -n ",";
		fi
		shift
	done
}

build_glib() {
	pushd $SCRIPT_HOME_DIR/glib
	git clean -xdf
	export CURRENT_BUILD=glib
echo "
[host_machine]
system = 'android'
cpu_family = '$ABI'
cpu = '$ABI'
endian = 'little'

[properties]
pkg_config_libdir = '$DEV_PREFIX/lib/pkgconfig'
sys_root = '$SYSROOT'

[binaries]
c = '$CC'
cpp = '$CC'
cxx = '$CXX'
ar = '$AR'
as = '$AS'
ld = '$LD'
nm = '$NM'
strip = '$STRIPLINK'
pkgconfig = '$(which pkg-config)'

[built-in options]
c_std = 'c17'
prefix = '$DEV_PREFIX'
c_args = [$(meson_flag_list $CFLAGS)]
cpp_args = [$(meson_flag_list $CPPFLAGS)]
c_link_args = [$(meson_flag_list $LDFLAGS)]
pkg_config_path = '$DEV_PREFIX/lib/pkgconfig'
default_library = 'shared'
" > cross_file.txt

	pip3 install meson
	mkdir -p $SCRIPT_HOME_DIR/glib/build
	~/.local/bin/meson setup --cross-file cross_file.txt build
	cd $SCRIPT_HOME_DIR/glib/build
	~/.local/bin/meson compile
	strip
	~/.local/bin/meson install
	cd $SCRIPT_HOME_DIR/glib
	clean
	popd
}

build_sigcpp() {
	echo "### Building libsigc++ -2.10.0"
	pushd $SCRIPT_HOME_DIR/libsigcplusplus
	git clean -xdf
	export CURRENT_BUILD=sigcpp

	NOCONFIGURE=yes	./autogen.sh
	android_configure --disable-documentation
	popd
}

build_libsigrokdecode() {
	pushd $SCRIPT_HOME_DIR/libsigrokdecode
	git clean -xdf
	export CURRENT_BUILD=libsigrokdecode

	NOCONFIGURE=yes ./autogen.sh
	android_configure
	popd
}

build_python() {
	pushd $SCRIPT_HOME_DIR/python

	# Python should be cross-built with the same version that is available on host, if nothing is available, it should be built with the script ./build_host_python
	git clean -xdf
	export CURRENT_BUILD=python
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

build_log4cpp() {

	pushd ${SCRIPT_HOME_DIR}/log4cpp
	git clean -xdf
	export CURRENT_BUILD=log4cpp
	build_with_cmake
	popd

}

build_spdlog() {
	pushd ${SCRIPT_HOME_DIR}/spdlog
	git clean -xdf
	export CURRENT_BUILD=spdlog

	rm -rf build
	mkdir build
	cd build
	build_with_cmake  \
	-DSPDLOG_BUILD_SHARED=ON \
	../
	popd

}

build_libsndfile() {

	pushd ${SCRIPT_HOME_DIR}/libsndfile
	git clean -xdf
	export CURRENT_BUILD=libsndfile

	rm -rf build
	mkdir build
	cd build

	echo "$LDFLAGS_COMMON"

	build_with_cmake ../
}
build_gnuradio3.10() {
	pushd ${SCRIPT_HOME_DIR}/gnuradio-3.10
	git clean -xdf
	export CURRENT_BUILD=gnuradio3.10

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
	  -DBoost_ARCHITECTURE=-a64 \
	  -DCMAKE_FIND_ROOT_PATH=${PREFIX} \
	  -DENABLE_DOXYGEN=OFF \
	  -DENABLE_DEFAULT=OFF \
	  -DENABLE_GNURADIO_RUNTIME=ON \
	  -DENABLE_GR_ANALOG=ON \
	  -DENABLE_GR_BLOCKS=ON \
	  -DENABLE_GR_FFT=ON \
	  -DENABLE_GR_FILTER=ON \
	  -DENABLE_GR_IIO=ON \
 	   ../
	popd
}
build_libtinyiiod() {
	pushd $SCRIPT_HOME_DIR/libtinyiiod
	git clean -xdf
	export CURRENT_BUILD=libtinyiiod

	cp $BUILD_ROOT/android_cmake.sh .
	cp $SCRIPT_HOME_DIR/android_deploy_qt.sh .

	build_with_cmake

	popd
}
build_qadvanceddocking() {
	pushd $SCRIPT_HOME_DIR/qadvanceddocking
	git clean -xdf
	export CURRENT_BUILD=qtadvanceddocking

	cp $BUILD_ROOT/android_cmake.sh .
	cp $SCRIPT_HOME_DIR/android_deploy_qt.sh .

	build_with_cmake
	popd
}

reset_build_env
create_build_status_file
build_libiconv
build_libffi
build_gettext
build_libiconv # HANDLE CIRCULAR DEP
build_glib
build_sigcpp
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
build_spdlog
build_volk
#build_log4cpp # not used
build_libsndfile
build_gnuradio3.10
build_gr-scopy
build_gr-m2k
build_qwt
move_qwt_libs
#build_qadvanceddocking
build_python
build_libsigrokdecode
build_libtinyiiod
