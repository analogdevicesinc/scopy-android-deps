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

if(ANDROID)
    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
    if (ANDROID_ABI STREQUAL "armeabi-v7a")
	set(ANDROID_EXTRA_LIBS
	    ${CMAKE_CURRENT_SOURCE_DIR}/path/to/libcrypto.so
	    ${CMAKE_CURRENT_SOURCE_DIR}/path/to/libssl.so)
    endif()
endif()

find_package(QT NAMES Qt6 Qt5 COMPONENTS Widgets Svg REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Widgets Svg REQUIRED)

if(ANDROID)
	find_package(Qt5AndroidExtras REQUIRED)
endif()
#message(1)
find_library(IIO_LIBRARIES NAMES libiio iio REQUIRED)
#find_library(USB_LIBRARIES NAMES libusb usb REQUIRED)
find_library(LIBUSB_LIBRARIES NAMES usb-1.0 usb)

find_path(IIO_INCLUDE_DIR iio.h)
#message(11 ${IIO_INCLUDE_DIR})

#message(${CMAKE_STAGING_PREFIX})
#set(CMAKE_FIND_USE_CMAKE_SYSTEM_PATH ON)

message(123 ${CMAKE_SYSTEM_PREFIX_PATH})
#set(CMAKE_STAGING_PREFIX ${CMAKE_STAGING_PREFIX})
#set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH};${CMAKE_STAGING_PREFIX})
#set(CMAKE_MODULE_PATH ${CMAKE_STAGING_PREFIX})
message(123 ${CMAKE_STAGING_PREFIX})

message(123 ${CMAKE_PREFIX_PATH})

set(CMAKE_FIND_DEBUG_MODE TRUE)
find_package(libm2k REQUIRED PATH_SUFFIXES lib/cmake/libm2k)
set(CMAKE_FIND_DEBUG_MODE FALSE)


IF(NOT DEFINED BOOST_ROOT)
    SET(BOOST_ROOT "${CMAKE_INSTALL_PREFIX}")
ENDIF()


set(Boost_COMPILER "")
set(Boost_ARCHITECTURE "")

find_package(Boost COMPONENTS system filesystem thread chrono REQUIRED)
find_package(Gnuradio "3.8" REQUIRED COMPONENTS runtime analog blocks fft filter volk pmt )

link_directories(
	${Boost_LIBRARY_DIRS}
	${GNURADIO_RUNTIME_LIBRARY_DIRS}
	)
set(CMAKE_FIND_DEBUG_MODE TRUE)
find_package(gnuradio-iio REQUIRED PATH_SUFFIXES iio)
set(CMAKE_FIND_DEBUG_MODE FALSE)

find_library(QWT_LIBRARIES REQUIRED NAMES qwt qwt_${ANDROID_ABI})

message(${PKG_CONFIG_EXECUTABLE})
#pkg_check_modules(Qt5Svg REQUIRED Qt5Svg_x86_64)
message(aa ${Qt5Svg_LIBRARIES})
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_FIND_DEBUG_MODE ON)
set(ENV{PKG_CONFIG_PATH} /home/adi/android/scopy-android-deps/deps_build_x86_64-linux-android/out/lib/pkgconfig)
message($ENV{PKG_CONFIG_PATH})
#pkg_check_modules(qwt REQUIRED Qt5Qwt6)

pkg_check_modules(GLIB REQUIRED glib-2.0)
pkg_check_modules(GLIBMM REQUIRED glibmm-2.4)
pkg_check_modules(SIGCPP REQUIRED sigc++-2.0)
pkg_check_modules(LIBSIGROK_DECODE REQUIRED libsigrokdecode)

#message(SEARCH ${CMAKE_PREFIX_PATH})
#pkg_check_modules(Qt5Qwt6 REQUIRED Qt5Qwt6)

pkg_get_variable(LIBSIGROK_DECODERS_DIR libsigrokdecode decodersdir)
message(${LIBSIGROK_DECODERS_DIR})

set(CMAKE_FIND_DEBUG_MODE OFF)
message(${ANDROID_PACKAGE_SOURCE_DIR} aaa)

include_directories(${IIO_INCLUDE_DIR}
		${QWT_INCLUDE_DIRS}
		${LIBSIGROK_DECODE_INCLUDE_DIRS}
		${Qt5AndroidExtras_INCLUDE_DIRS}
		${GLIBMM_INCLUDE_DIRS})

file(GLOB PROJECT_SOURCES  *.c *.cpp *.h *.ui *.cc *.hpp logicanalyzer/*.cpp logicanalyzer/*.hpp logicanalyzer/binding/*.cpp logicanalyzer/binding/*.hpp logicanalyzer/prop/*.cpp)

#set(PROJECT_SOURCES
#        main.cpp
#        mainwindow.cpp
#        mainwindow.h
#        mainwindow.ui
#	iiomanager.cpp
#	iiomanager.h
#	logging_categories.cpp
#	logging_categories.h
#	fft_block.cpp
#	fft_block.hpp
#	TimeDomainDisplayPlot.cc
#	TimeDomainDisplayPlot.h
#	FftDisplayPlot.cc
#	FftDisplayPlot.h
#	scope_sink_f.h
#	scope_sink_f_impl.cc
#	scope_sink_f_impl.h
#	DisplayPlot.cc
#	DisplayPlot.h
#	trigger_mode.h
#	stream_to_vector_overlap.h
#	stream_to_vector_overlap_impl.cc
#	stream_to_vector_overlap_impl.h
#	utils.h
#	osc_adjuster.cpp
#	osc_adjuster.hpp
#	plot_utils.cpp
#	plot_utils.hpp
#	extendingplotzoomer.cpp
#	extendingplotzoomer.h
#	limitedplotzoomer.cpp
#	limitedplotzoomer.h
#	printableplot.cpp
#	printableplot.h
#	spectrumUpdateEvents.cc
#	spectrumUpdateEvents.h
#	spectrum_marker.cpp
#	spectrum_marker.hpp
#	osc_scale_engine.cpp
#	osc_scale_engine.h
#	smoothcurvefitter.cpp
#	smoothcurvefitter.h
#	average.cpp
#	average.h
#	oscilloscope_plot.cpp
#	oscilloscope_plot.hpp
#	symbol.cpp
#	symbol.h
#	symbol_controller.cpp
#	symbol_controller.h
#	marker_controller.cpp
#	marker_controller.h
#	handlesareaextension.cpp
#	handlesareaextension.h
#	handles_area.cpp
#	handles_area.hpp
#	plot_line_handle.cpp
#	plot_line_handle.h
#	cursor_readouts.cpp
#	cursor_readouts.h
#	customanimation.cpp
#	customanimation.h
#	customplotpositionbutton.cpp
#	customplotpositionbutton.h
#	coloredQWidget.cpp
#	coloredQWidget.hpp
#	graticule.cpp
#	graticule.h
#)

FILE(GLOB M2KSCOPE_RESOURCES resources/resources.qrc)
qt5_add_resources(m2kscope_RESOURCES ${M2KSCOPE_RESOURCES})


if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(qtTest
        ${PROJECT_SOURCES}
	${m2kscope_RESOURCES}
    )
else()
    if(ANDROID)
        add_library(qtTest SHARED
            ${PROJECT_SOURCES}
	    ${m2kscope_RESOURCES}
        )
    else()
        add_executable(qtTest
            ${PROJECT_SOURCES}
	    ${m2kscope_RESOURCES}
        )
    endif()
endif()

add_definitions(-DQT_NO_KEYWORDS)


configure_file(config.h.cmakein config.h @ONLY)
message(111 ${pkgcfg_lib_qwt_qwt_${ANDROID_ABI}})

message(1112 ${QWT_LIBRARIES})

target_link_libraries(qtTest PRIVATE
					Qt${QT_VERSION_MAJOR}::Widgets
					Qt${QT_VERSION_MAJOR}::Svg
					${IIO_LIBRARIES}
					${LIBUSB_LIBRARIES}
					${Boost_LIBRARIES}
					${Qt5AndroidExtras_LIBRARIES}
					libm2k::libm2k
					gnuradio::gnuradio-runtime
					gnuradio::gnuradio-analog
					gnuradio::gnuradio-blocks
					gnuradio::gnuradio-fft
					gnuradio::gnuradio-filter
					gnuradio::gnuradio-iio
					${pkgcfg_lib_qwt_qwt_${ANDROID_ABI}}
					${QWT_LIBRARIES}
					${GLIB_LIBRARIES}
					${GLIBMM_LIBRARIES}
					${LIBSIGROK_DECODE_LIBRARIES}
			)

message(STATUS " !!! YOU MUST Copy all ${CMAKE_STAGING_PREFIX}/lib/*.so to build/android-build/libs/<your arch>/ to deploy correctly !!! ")
