cmake_minimum_required(VERSION 3.5)

project(qtTest LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_FIND_DEBUG_MODE OFF)
# QtCreator supports the following variables for Android, which are identical to qmake Android variables.
# Check https://doc.qt.io/qt/deployment-android.html for more information.
# They need to be set before the find_package( ...) calls below.

#if(ANDROID)
#    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
#    if (ANDROID_ABI STREQUAL "armeabi-v7a")
#        set(ANDROID_EXTRA_LIBS
#            ${CMAKE_CURRENT_SOURCE_DIR}/path/to/libcrypto.so
#            ${CMAKE_CURRENT_SOURCE_DIR}/path/to/libssl.so)
#    endif()
#endif()

find_package(QT NAMES Qt6 Qt5 COMPONENTS Widgets REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Widgets REQUIRED)

#message(1)
find_library(IIO_LIBRARIES NAMES libiio iio REQUIRED)
find_path(IIO_INCLUDE_DIR iio.h)
#message(11 ${IIO_INCLUDE_DIR})

#message(${CMAKE_STAGING_PREFIX})
#set(CMAKE_FIND_USE_CMAKE_SYSTEM_PATH ON)

#message(123 ${CMAKE_SYSTEM_PREFIX_PATH})
#set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH};${CMAKE_STAGING_PREFIX})
#set(CMAKE_MODULE_PATH ${CMAKE_STAGING_PREFIX}/lib/cmake)
#message(123 ${CMAKE_PREFIX_PATH})
find_package(libm2k REQUIRED)


IF(NOT DEFINED BOOST_ROOT)
    SET(BOOST_ROOT "${CMAKE_INSTALL_PREFIX}")
ENDIF()


set(Boost_COMPILER "")
set(Boost_ARCHITECTURE "")

find_package(Boost COMPONENTS system filesystem thread chrono REQUIRED)
find_package(Gnuradio "3.8" REQUIRED COMPONENTS runtime analog blocks fft filter volk pmt )

#find_library(QWT_LIBRARIES REQUIRED NAMES qwt_${ANDROID_ABI})

message(${PKG_CONFIG_EXECUTABLE})
#pkg_check_modules(Qt5Svg REQUIRED Qt5Svg_x86_64)
message(aa ${Qt5Svg_LIBRARIES})
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_FIND_DEBUG_MODE ON)
set(ENV{PKG_CONFIG_PATH} /home/adi/android/scopy-android-deps/deps_build_x86_64-linux-android/out/lib/pkgconfig)
message($ENV{PKG_CONFIG_PATH})
pkg_check_modules(qwt REQUIRED Qt5Qwt6)

set(CMAKE_FIND_DEBUG_MODE OFF)

include_directories(${IIO_INCLUDE_DIR})

set(PROJECT_SOURCES
        main.cpp
        mainwindow.cpp
        mainwindow.h
        mainwindow.ui
)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(qtTest
        ${PROJECT_SOURCES}
    )
else()
    if(ANDROID)
        add_library(qtTest SHARED
            ${PROJECT_SOURCES}
        )
    else()
        add_executable(qtTest
            ${PROJECT_SOURCES}
        )
    endif()
endif()

configure_file(config.h.cmakein config.h @ONLY)
message(111 ${pkgcfg_lib_qwt_qwt_${ANDROID_ABI}})

target_link_libraries(qtTest PRIVATE Qt${QT_VERSION_MAJOR}::Widgets ${IIO_LIBRARIES}
			libm2k::libm2k
			gnuradio::gnuradio-runtime
					gnuradio::gnuradio-analog
					gnuradio::gnuradio-blocks
					gnuradio::gnuradio-fft
					gnuradio::gnuradio-filter
					${pkgcfg_lib_qwt_qwt_${ANDROID_ABI}}
			)

message(STATUS " !!! YOU MUST Copy all ${CMAKE_STAGING_PREFIX}/lib/*.so to build/android-build/libs/<your arch>/ to deploy correctly !!! ")
