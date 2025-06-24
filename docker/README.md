# Shanocast Docker Build

This directory contains files to build Shanocast using Docker with a Fedora 42 base image.

## Two-Stage Build Process

The build process is split into two stages:

1. **Base Builder Image**: Contains the environment setup and patched openscreen repository
2. **Final Image**: Builds the shanocast binary and creates a minimal runtime container

## Building with Docker

To build both Docker images:

```bash
./build-images.sh
```

This will create two Docker images:
- `beardedtek/shanocast-builder:base` - The base builder image with the patched openscreen repository
- `beardedtek/shanocast:latest` - The final runtime image with the shanocast binary

You can also build them separately:

```bash
# Build only the base image
docker build -t beardedtek/shanocast-builder:base -f Dockerfile.base .

# Build the final image (requires the base image)
docker build -t beardedtek/shanocast:latest .
```

## Running with Docker

You can run the container directly with Docker:

```bash
# Replace 'eth0' with your network interface name
docker run --network host beardedtek/shanocast:latest eth0
```

Or using Docker Compose:

```bash
# Edit docker-compose.yml to set your network interface if needed
docker-compose up -d
```

You can also use the provided run script, which will prompt you for a network interface:

```bash
./run-shanocast.sh
```

## Configuration

The Shanocast binary requires a network interface name as an argument. By default, the docker-compose.yml file is configured to use 'eth0'.

### Network Interface Configuration

There are several ways to specify the network interface:

1. **Docker Run Command**: Pass the interface name as an argument
   ```bash
   docker run --network host beardedtek/shanocast:latest enp42s0
   ```

2. **Docker Compose**: Edit the `command` field in docker-compose.yml
   ```yaml
   command: enp42s0  # Replace with your network interface
   ```

3. **Environment Variable**: Set the INTERFACE environment variable
   ```bash
   INTERFACE=enp42s0 docker-compose up -d
   ```
   or
   ```bash
   export INTERFACE=enp42s0
   docker-compose up -d
   ```

4. **Run Script**: The run-shanocast.sh script will prompt for an interface if not specified

Common network interface names:
- `eth0`, `enp0s3`: Ethernet interfaces
- `wlan0`, `wlp2s0`: WiFi interfaces
- `lo`: Loopback interface (for local testing)

## Extracting the Binary

If you want to extract the binary from the Docker container to run it directly on your host system:

```bash
./extract-binary.sh
```

Note that the extracted binary will require the appropriate runtime dependencies (ffmpeg-free and SDL2) to be installed on the host system.

## Display and Audio Support

The docker-compose.yml file includes configuration for accessing the host's display and audio devices, allowing shanocast to render video and play audio directly on your system.

## Development

If you need to modify the shanocast patch or build process:

1. Edit the `shanocast.patch` file
2. Rebuild the base image: `docker build -t beardedtek/shanocast-builder:base -f Dockerfile.base .`
3. Rebuild the final image: `docker build -t beardedtek/shanocast:latest .`

## Troubleshooting

1. If you encounter networking issues, make sure you're using the correct network interface name.
2. The container must run with host networking (`--network host`) to properly discover and advertise the Chromecast service.
3. To see available network interfaces on your system, run:
   ```bash
   ip addr
   ```
4. For display issues, try running `xhost +local:` on the host before starting the container.
5. For audio issues, check if your user is in the `audio` group: `groups $USER`

## Usage

Once running, open Google Chrome on a device on the same network, and Shanocast should be listed as an available casting device. 