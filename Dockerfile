FROM ubuntu:20.04

# Build arguments
ARG android_sdk_version
ARG android_build_tools_version
ARG nodejs_version

ARG user_name='user'
ARG user_id='1000'
ARG group_name='mount'
ARG group_id='1000'

# Update package repositories and install packages
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
    adb \
    curl \
    git \
    libglu1-mesa \
    openjdk-8-jdk \
    unzip \
    usbutils \
    xz-utils \
    wget \
    zip \
    gnupg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and Yarn
RUN curl "https://deb.nodesource.com/setup_${nodejs_version}.x" | bash
RUN curl -sS 'https://dl.yarnpkg.com/debian/pubkey.gpg' | apt-key add -
RUN echo 'deb https://dl.yarnpkg.com/debian/ stable main' | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
    nodejs \
    yarn

# Create non-system user
RUN addgroup --gid "${group_id}" "${group_name}" \
    && useradd \
    --create-home \
    --shell /bin/bash \
    --uid "${user_id}" \
    --gid "${group_id}" \
    "${user_name}" \
    && usermod -aG plugdev "${user_name}"

# Set non-system user
USER "${user_name}"
ENV HOME="/home/${user_name}"

# Change workdir
WORKDIR "${HOME}"

# Prepare Android SDK directory structure
RUN mkdir -p Android/sdk \
    && mkdir -p .android \
    && touch .android/repositories.cfg

# Android SDK env variables
ENV ANDROID_SDK_ROOT "${HOME}/Android/sdk"

# Download Android SDK tools
RUN wget -O sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip \
    --no-verbose \
    --show-progress \
    --progress=bar:force \
    && unzip sdk-tools.zip \
    && rm sdk-tools.zip \
    && mv tools "${ANDROID_SDK_ROOT}/tools"

# Install Android SDK tools
RUN cd "${ANDROID_SDK_ROOT}/tools/bin" \
    && yes | ./sdkmanager --licenses \
    && ./sdkmanager \
        "build-tools;${android_build_tools_version}" \
        'patcher;v4' \
        'platform-tools' \
        "platforms;android-${android_sdk_version}" \
        "sources;android-${android_sdk_version}"

# Add Android SDK tools to PATH
ENV PATH "${PATH}:${ANDROID_SDK_ROOT}/platform-tools"

# Add yarn bin to PATH
ENV PATH "${PATH}:${HOME}/.yarn/bin"

# Install npm libraries with Yarn
RUN yarn global add \
    react-native-cli \
    npx