#!/bin/bash

# Exit on error
set -e

echo "Building shanocast Docker images..."
./build-images.sh

echo "Creating temporary container..."
docker create --name temp_shanocast beardedtek/shanocast:latest

echo "Extracting binary..."
mkdir -p ../bin
docker cp temp_shanocast:/app/shanocast ../bin/shanocast

echo "Removing temporary container..."
docker rm temp_shanocast

echo "Done! Binary is available at: $(pwd)/shanocast"
echo "You can run it with: ./shanocast <network_interface>"
echo ""
echo "Note: This binary requires ffmpeg-free and SDL2 to be installed on your system."
echo "On Fedora: sudo dnf install ffmpeg-free SDL2" 