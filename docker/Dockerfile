#docker build -t analogdevices/scopy-build:android --build-arg QT_USER=<your_user> --build-arg QT_PASSWORD=<your_password> .
FROM ubuntu:20.04

ARG USER=runner

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -y git vim wget unzip sudo xserver-xorg openjdk-11-jre cmake libtool build-essential pkg-config autogen bison flex texinfo python-dev python-mako python-six swig3.0 python3-mako python3-numpy gettext libglib2.0-dev texinfo subversion libxkbcommon-x11-0 libxcb-xinerama0 libqt5gui5 libncurses5 autoconf-archive mm-common

RUN groupadd -g 1000 -r $USER
RUN useradd -u 1000 -g 1000 --create-home -r $USER

#Change password
RUN echo "$USER:$USER" | chpasswd

#Make sudo passwordless
RUN echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-$USER
RUN usermod -aG sudo $USER
RUN usermod -aG plugdev $USER

USER $USER

RUN mkdir -p /home/$USER/src
WORKDIR /home/$USER/src

WORKDIR /home/$USER/src
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip
RUN unzip commandlinetools-linux-6200805_latest.zip

RUN mkdir -p /home/$USER/Android/Sdk
ENV ANDROID_HOME /home/$USER/Android/Sdk
WORKDIR /home/$USER/src/tools/bin

RUN yes | ./sdkmanager --sdk_root=${ANDROID_HOME} --licenses
RUN yes | ./sdkmanager --sdk_root=${ANDROID_HOME} "platforms;android-26"
RUN yes | ./sdkmanager --sdk_root=${ANDROID_HOME} "platforms;android-28"
RUN yes | ./sdkmanager --sdk_root=${ANDROID_HOME} "ndk;21.3.6528147"
RUN yes | ./sdkmanager --sdk_root=${ANDROID_HOME} "platform-tools"
RUN yes | ./sdkmanager --sdk_root=${ANDROID_HOME} "build-tools;28.0.3"
RUN yes | ./sdkmanager --sdk_root=${ANDROID_HOME} "build-tools;30.0.3"
RUN yes | ./sdkmanager --sdk_root=${ANDROID_HOME} "cmdline-tools;latest"

RUN sudo ln -s /home/$USER/Android/Sdk/platform-tools/adb /usr/local/bin/adb

RUN wget https://download.qt.io/official_releases/online_installers/qt-unified-linux-x64-online.run
RUN chmod +x qt-unified-linux-x64-online.run

ARG QT_USER
ARG QT_PASSWORD

RUN ./qt-unified-linux-x64-online.run install --ao --al --aa DownloadError=Retry -c -m $QT_USER --pw $QT_PASSWORD qt.qt5.5152.android qt.tools.cmake
RUN sudo apt remove qtchooser

RUN sudo ln -s /home/$USER/Qt/Tools/QtCreator/bin/qtcreator.sh /usr/local/bin/qtcreator

WORKDIR /home/$USER/src
RUN echo 20
RUN git clone https://github.com/analogdevicesinc/scopy-android-deps.git --branch master

WORKDIR /home/$USER/src/scopy-android-deps
RUN ./move_libs.sh aarch64 $USER
RUN ./move_libs.sh arm $USER
RUN ./rename_gradle.sh $USER
RUN ./download_deps_src.sh

WORKDIR /home/$USER/src/scopy-android-deps
ENV ANDROID_TOOLCHAIN_LOCATION=/home/$USER/src/scopy-android-deps
RUN ./android_deps_build.sh aarch64 $USER
RUN ./android_deps_build.sh arm $USER
