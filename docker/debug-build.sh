#!/bin/bash

# Exit on error
set -e

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Change to root directory
cd "$ROOT_DIR"

echo "Creating debug container..."
docker run --rm -it \
  -v "$(pwd):/build" \
  -w /build \
  --name shanocast_debug \
  fedora:42 bash -c "
    echo '=== Installing build dependencies ==='
    dnf -y update && dnf -y install \
      gcc-c++ \
      ninja-build \
      gn \
      git \
      python3 \
      python3-pip \
      pkg-config \
      ffmpeg-free-devel \
      libavcodec-free-devel \
      libavformat-free-devel \
      libavutil-free-devel \
      libswscale-free-devel \
      SDL2-devel \
      which \
      make \
      cmake \
      curl \
      patch

    echo '=== Checking FFmpeg headers ==='
    find /usr -name 'avcodec.h' | grep -i ffmpeg
    pkg-config --cflags libavcodec
    pkg-config --libs libavcodec
    echo 'FFmpeg include path:'
    pkg-config --variable=includedir libavcodec
    
    echo '=== Creating FFmpeg symlinks ==='
    mkdir -p /usr/local/include
    ln -sf /usr/include/ffmpeg/libavcodec /usr/local/include/
    ln -sf /usr/include/ffmpeg/libavformat /usr/local/include/
    ln -sf /usr/include/ffmpeg/libavutil /usr/local/include/
    ln -sf /usr/include/ffmpeg/libswscale /usr/local/include/
    
    echo '=== Testing FFmpeg include path ==='
    cat > test_ffmpeg.c << EOF
    #include <libavcodec/avcodec.h>
    int main() { return 0; }
    EOF
    gcc -c test_ffmpeg.c -o test_ffmpeg.o -I/usr/local/include && echo 'Include works with -I/usr/local/include!'
    
    echo '=== Checking SDL2 headers ==='
    find /usr -name 'SDL.h' | grep -i sdl2
    pkg-config --cflags sdl2
    pkg-config --libs sdl2
    
    echo '=== Cloning and patching openscreen ==='
    if [ ! -d 'openscreen' ]; then
      git clone --recurse-submodules https://chromium.googlesource.com/openscreen.git
      cd openscreen
      git checkout 934f2462ad01c407a596641dbc611df49e2017b4
      patch -p1 < /build/shanocast.patch
    else
      echo 'Using existing openscreen directory'
      cd openscreen
    fi
    
    echo '=== Fixing compiler warnings ==='
    sed -i '127s/.*/using FileUniquePtr = std::unique_ptr<FILE, int(*)(FILE*)>;/' cast/receiver/channel/static_credentials.cc
    sed -i '226s/int domain;/int domain = 0;/' platform/impl/stream_socket_posix.cc
    sed -i '106s/int domain;/int domain = 0;/' platform/impl/udp_socket_posix.cc
    
    echo '=== Generating build files ==='
    gn gen out/Default --args=\"is_debug=false use_custom_libcxx=false treat_warnings_as_errors=false have_ffmpeg=true have_libsdl2=true cast_allow_developer_certificate=true is_clang=false\"
    
    echo '=== Adding FFmpeg include paths and disabling warnings ==='
    sed -i 's/-I..\\/..\"/-I..\\/..\" \"-I\\/usr\\/local\\/include\"/' out/Default/toolchain.ninja
    sed -i 's/-Werror/-Werror -Wno-ignored-attributes -Wno-maybe-uninitialized/' out/Default/toolchain.ninja
    
    echo '=== Starting interactive shell ==='
    echo 'You can now explore the environment and test the build manually'
    echo 'To build, run: cd openscreen && ninja -C out/Default cast_receiver'
    echo 'Type \"exit\" when done'
    bash
  " 