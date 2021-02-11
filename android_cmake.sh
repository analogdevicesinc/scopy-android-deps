#!/bin/bash
#source /home/adi/android/android_toolchain.sh
#export ANDROID_NDK=$HOME/Android/Sdk/ndk-bundle
#export ANDROID_API=28
#CMAKE="echo"
#echo DEV_PREFIX = $DEV_PREFIX

################ HACK .. REMOVE ALL LIBRARIES FROM
# ~/android/sdk/ndk/21.3.6528147/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/x86_64-linux-android
# so CMAKE TARGETS ~/android/sdk/ndk/21.3.6528147/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/x86_64-linux-android/$API_VERSION
#
# libunwind.a still needs to be in the search path - it's not part of the API version
# only for armeabi-v7a
#
### FIGURE OUT HOW TO CHANGE THIS FROM CMAKE

########## HACK2 .. Change gradle version in qt from /home/adi/Qt/5.15.2/android/src/3rdparty/gradle/gradle/wrapper/gradle-wrapper.properties
# from distributionUrl=https\://services.gradle.org/distributions/gradle(whatever_version_smaller_than 6.3).zip
# to distributionUrl=https\://services.gradle.org/distributions/gradle-6.3-all.zip
###############################################################################################################################################


############## HACK 3 #######
# qwt does not build correctly for some reason, after compiling, you need to relink with proper soname attribute - there is probably
# a proper fix someway but here is what i did
# after building, go to qwt-code/src
# and run this -
#/home/adi/android/sdk/ndk/21.3.6528147/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++ -target $ABI-linux-android21 -fno-limit-debug-info -Wl,-soname,libqwt_$ABI.so -Wl,--build-id=sha1 -Wl,--no-undefined -Wl,-z,noexecstack -shared -o libqwt_$ABI.so obj/qwt.o obj/qwt_abstract_scale_draw.o obj/qwt_bezier.o obj/qwt_clipper.o obj/qwt_color_map.o obj/qwt_column_symbol.o obj/qwt_date.o obj/qwt_date_scale_draw.o obj/qwt_date_scale_engine.o obj/qwt_dyngrid_layout.o obj/qwt_event_pattern.o obj/qwt_graphic.o obj/qwt_interval.o obj/qwt_interval_symbol.o obj/qwt_math.o obj/qwt_magnifier.o obj/qwt_null_paintdevice.o obj/qwt_painter.o obj/qwt_painter_command.o obj/qwt_panner.o obj/qwt_picker.o obj/qwt_picker_machine.o obj/qwt_pixel_matrix.o obj/qwt_point_3d.o obj/qwt_point_polar.o obj/qwt_round_scale_draw.o obj/qwt_scale_div.o obj/qwt_scale_draw.o obj/qwt_scale_map.o obj/qwt_scale_engine.o obj/qwt_spline.o obj/qwt_spline_basis.o obj/qwt_spline_parametrization.o obj/qwt_spline_local.o obj/qwt_spline_cubic.o obj/qwt_spline_pleasing.o obj/qwt_symbol.o obj/qwt_system_clock.o obj/qwt_text_engine.o obj/qwt_text_label.o obj/qwt_text.o obj/qwt_transform.o obj/qwt_widget_overlay.o obj/qwt_axis_id.o obj/qwt_curve_fitter.o obj/qwt_spline_curve_fitter.o obj/qwt_weeding_curve_fitter.o obj/qwt_abstract_legend.o obj/qwt_legend.o obj/qwt_legend_data.o obj/qwt_legend_label.o obj/qwt_plot.o obj/qwt_plot_renderer.o obj/qwt_plot_xml.o obj/qwt_plot_axis.o obj/qwt_plot_curve.o obj/qwt_plot_dict.o obj/qwt_plot_directpainter.o obj/qwt_plot_graphicitem.o obj/qwt_plot_grid.o obj/qwt_plot_histogram.o obj/qwt_plot_item.o obj/qwt_plot_abstract_barchart.o obj/qwt_plot_barchart.o obj/qwt_plot_multi_barchart.o obj/qwt_plot_intervalcurve.o obj/qwt_plot_zoneitem.o obj/qwt_plot_tradingcurve.o obj/qwt_plot_spectrogram.o obj/qwt_plot_spectrocurve.o obj/qwt_plot_scaleitem.o obj/qwt_plot_legenditem.o obj/qwt_plot_seriesitem.o obj/qwt_plot_shapeitem.o obj/qwt_plot_vectorfield.o obj/qwt_plot_marker.o obj/qwt_plot_textlabel.o obj/qwt_plot_layout.o obj/qwt_plot_canvas.o obj/qwt_plot_panner.o obj/qwt_plot_rasteritem.o obj/qwt_plot_picker.o obj/qwt_plot_zoomer.o obj/qwt_plot_magnifier.o obj/qwt_plot_rescaler.o obj/qwt_point_mapper.o obj/qwt_raster_data.o obj/qwt_matrix_raster_data.o obj/qwt_vectorfield_symbol.o obj/qwt_sampling_thread.o obj/qwt_series_data.o obj/qwt_point_data.o obj/qwt_scale_widget.o obj/qwt_plot_glcanvas.o obj/qwt_plot_opengl_canvas.o obj/qwt_plot_svgitem.o obj/qwt_polar_canvas.o obj/qwt_polar_curve.o obj/qwt_polar_fitter.o obj/qwt_polar_grid.o obj/qwt_polar_item.o obj/qwt_polar_itemdict.o obj/qwt_polar_layout.o obj/qwt_polar_magnifier.o obj/qwt_polar_marker.o obj/qwt_polar_panner.o obj/qwt_polar_picker.o obj/qwt_polar_plot.o obj/qwt_polar_renderer.o obj/qwt_polar_spectrogram.o obj/qwt_abstract_slider.o obj/qwt_abstract_scale.o obj/qwt_arrow_button.o obj/qwt_analog_clock.o obj/qwt_compass.o obj/qwt_compass_rose.o obj/qwt_counter.o obj/qwt_dial.o obj/qwt_dial_needle.o obj/qwt_knob.o obj/qwt_slider.o obj/qwt_thermo.o obj/qwt_wheel.o  -L/home/adi/android/scopy-android-deps/deps_build_$ABI-linux-android/out/lib /home/adi/Qt/5.15.2/android/lib/libQt5PrintSupport_$ABI.so /home/adi/Qt/5.15.2/android/lib/libQt5Svg_$ABI.so /home/adi/Qt/5.15.2/android/lib/libQt5OpenGL_$ABI.so /home/adi/Qt/5.15.2/android/lib/libQt5Widgets_$ABI.so /home/adi/Qt/5.15.2/android/lib/libQt5Gui_$ABI.so /home/adi/Qt/5.15.2/android/lib/libQt5Concurrent_$ABI.so /home/adi/Qt/5.15.2/android/lib/libQt5Core_.so -lGLESv2   -llog -lz -lm -ldl -lc
# and then copy the library to the desired location ..
# cp libqwt_$ABI $blabla/out/lib
# the original qmake file runs the same when linking but with -soname,libqwt.so.6.4
# which would be ok, but when linking the library libqwt_x86_64.so(for example) it cannot find libqwt.so.6.4
# ... there probably is a better fix for this


#CMAKE=echo
$CMAKE \
	-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake \
	-DCMAKE_BUILD_TYPE:String=Debug \
	-DANDROID_STL:STRING=c++_shared \
	-DANDROID_SDK:PATH=$ANDROID_SDK_ROOT \
	-DCMAKE_SYSTEM_NAME=Android \
	-DANDROID_NDK=$ANDROID_NDK_ROOT \
	-DANDROID_PLATFORM=android-$API \
	-DANDROID_ABI:STRING=$ABI \
	-DANDROID_TOOLCHAIN=clang \
	-DCMAKE_FIND_ROOT_PATH:PATH=$QT_INSTALL_PREFIX \
	-DCMAKE_LIBRARY_PATH=$DEV_PREFIX \
	-DCMAKE_INSTALL_PREFIX=$DEV_PREFIX \
	-DCMAKE_STAGING_PREFIX=$DEV_PREFIX \
	-DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
	-DCMAKE_SHARED_LINKER_FLAGS="${LDFLAGS}" \
	-DANDROID_ARM_NEON=ON \
	-DANDROID_LD=lld \
	-DQT_QMAKE_EXECUTABLE:STRING=$QMAKE \
	-DCMAKE_PREFIX_PATH:STRING=$QT_INSTALL_PREFIX\;$DEV_PREFIX/lib/cmake \
	-DCMAKE_C_COMPILER:STRING=$CC \
	-DCMAKE_CXX_COMPILER:STRING=$CXX \
	-DANDROID_NATIVE_API_LEVEL:STRING=$API \
	-Bbuild_$ABI \
	$@
