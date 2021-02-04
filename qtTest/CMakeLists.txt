cmake_minimum_required(VERSION 3.5)

project(qtTest LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

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

target_link_libraries(qtTest PRIVATE Qt${QT_VERSION_MAJOR}::Widgets ${IIO_LIBRARIES} libm2k::libm2k)

message(STATUS " !!! YOU MUST Copy all ${CMAKE_STAGING_PREFIX}/lib/*.so to build/android-build/libs/<your arch>/ to deploy correctly !!! ")
