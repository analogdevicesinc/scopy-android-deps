#docker build -t analogdevices/scopy-build:android --build-arg QT_USER=<your_user> --build-arg QT_PASSWORD=<your_password> .
FROM ubuntu:20.04

ARG USER=runner
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Bucharest

# Set timezone and install dependencies
RUN set -ex && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
        autoconf-archive \
        autogen \
        bison \
        build-essential \
        cmake \
        flex \
        gettext \
        git \
        libglib2.0-dev \
        libncurses5 \
        libqt5gui5 \
        libtool \
        libxcb-xinerama0 \
        libxkbcommon-x11-0 \
        mm-common\
        ninja-build \
        openjdk-17-jre \
        pip \
        pkg-config \
        python-dev \
        python-mako \
        python-six \
        python3-mako \
        python3-numpy \
        subversion \
        sudo \
        swig3.0 \
        texinfo \
        texinfo \
        unzip \
        vim \
        wget \
        xserver-xorg;

# Create user and group
RUN set -ex && \
    groupadd -g 1000 -r $USER && \
    useradd -u 1000 -g 1000 --create-home -r $USER && \
    # Change password
    echo "$USER:$USER" | chpasswd && \
    # Make sudo passwordless
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-$USER && \
    usermod -aG sudo $USER && \
    usermod -aG plugdev $USER

USER $USER
WORKDIR /home/$USER/src

# Download and set up Android SDK command line tools
ARG ANDROID_SDK_TOOLS_ZIP=commandlinetools-linux-6200805_latest.zip
RUN set -ex && \
    wget https://dl.google.com/android/repository/$ANDROID_SDK_TOOLS_ZIP && \
    unzip $ANDROID_SDK_TOOLS_ZIP && \
    rm $ANDROID_SDK_TOOLS_ZIP 

# Set up Android SDK environment
RUN mkdir -p /home/$USER/Android/Sdk
ENV ANDROID_HOME=/home/$USER/Android/Sdk
WORKDIR /home/$USER/src/tools/bin

# Install Android SDK tools
RUN set -ex && \
    yes | ./sdkmanager --sdk_root=${ANDROID_HOME} --licenses && \
    yes | ./sdkmanager --sdk_root=${ANDROID_HOME} "platforms;android-30" && \
    yes | ./sdkmanager --sdk_root=${ANDROID_HOME} "ndk;25.2.9519653" && \
    yes | ./sdkmanager --sdk_root=${ANDROID_HOME} "platform-tools" && \
    yes | ./sdkmanager --sdk_root=${ANDROID_HOME} "build-tools;33.0.1" && \
    yes | ./sdkmanager --sdk_root=${ANDROID_HOME} "cmdline-tools;latest" && \
    # Symlink adb binary
    sudo ln -s /home/$USER/Android/Sdk/platform-tools/adb /usr/local/bin/adb

# Download and install Qt
ARG QT_USER
ARG QT_PASSWORD
RUN set -ex && \
    wget https://download.qt.io/official_releases/online_installers/qt-unified-linux-x64-online.run && \
    chmod +x qt-unified-linux-x64-online.run && \
    ./qt-unified-linux-x64-online.run install --ao --al --aa DownloadError=Retry -c -m $QT_USER --pw $QT_PASSWORD qt.qt5.5152.android qt.tools.cmake && \
    rm qt-unified-linux-x64-online.run && \
    sudo apt remove -y qtchooser && \
    # Symlink Qt Creator binary
    sudo ln -s /home/$USER/Qt/Tools/QtCreator/bin/qtcreator.sh /usr/local/bin/qtcreator

# Clone and build Scopy Android dependencies
WORKDIR /home/$USER/src
ARG REPO_LINK=https://github.com/analogdevicesinc/scopy-android-deps.git
ARG REPO_BRANCH=Scopy-1.5.0
RUN git clone "${REPO_LINK}" --branch "${REPO_BRANCH}" --recursive

WORKDIR /home/$USER/src/scopy-android-deps
RUN ./build_androiddeployqt.sh

ENV ANDROID_TOOLCHAIN_LOCATION=/home/$USER/src/scopy-android-deps
RUN ./android_deps_build.sh aarch64 $USER