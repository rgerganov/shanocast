FROM beardedtek/shanocast-builder:base AS builder

# Fix compiler warnings and create FFmpeg include symlinks
RUN cd openscreen && \
    # Fix the ignored-attributes warning by directly modifying the file
    sed -i '127s/.*/using FileUniquePtr = std::unique_ptr<FILE, int(*)(FILE*)>;/' cast/receiver/channel/static_credentials.cc && \
    # Fix uninitialized variable warnings in socket code
    sed -i '226s/int domain;/int domain = 0;/' platform/impl/stream_socket_posix.cc && \
    sed -i '106s/int domain;/int domain = 0;/' platform/impl/udp_socket_posix.cc && \
    # Create complete symlinks for FFmpeg headers
    mkdir -p /usr/local/include && \
    ln -sf /usr/include/ffmpeg/libavcodec /usr/local/include/ && \
    ln -sf /usr/include/ffmpeg/libavformat /usr/local/include/ && \
    ln -sf /usr/include/ffmpeg/libavutil /usr/local/include/ && \
    ln -sf /usr/include/ffmpeg/libswscale /usr/local/include/

# Build binary
RUN cd openscreen && \
    # Apply necessary compiler flags and build settings
    gn gen out/Default --args="is_debug=false use_custom_libcxx=false treat_warnings_as_errors=false have_ffmpeg=true have_libsdl2=true cast_allow_developer_certificate=true is_clang=false" && \
    # Add FFmpeg include paths and disable specific warnings
    sed -i 's/-I..\/..\"/-I..\/..\"/g' out/Default/toolchain.ninja && \
    sed -i 's/-I..\/..\"/\"-I..\/..\" \"-I\/usr\/local\/include\"/' out/Default/toolchain.ninja && \
    sed -i 's/-Werror/-Werror -Wno-ignored-attributes -Wno-maybe-uninitialized/' out/Default/toolchain.ninja && \
    # Build with ninja
    ninja -C out/Default cast_receiver && \
    cp out/Default/cast_receiver /build/shanocast

# Create a smaller runtime image
FROM fedora:42

# Install runtime dependencies
RUN dnf -y update && dnf -y install \
    ffmpeg-free \
    SDL2 \
    mesa-dri-drivers \
    mesa-libGL \
    libva \
    libvdpau \
    pulseaudio-libs \
    alsa-lib \
    avahi \
    avahi-tools \
    nss-mdns \
    iproute

# Create app directory
WORKDIR /app

# Copy binary from builder stage
COPY --from=builder /build/shanocast /app/

# Set the entrypoint
ENTRYPOINT ["/app/shanocast"] 