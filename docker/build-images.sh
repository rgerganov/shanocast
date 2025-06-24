#!/bin/bash

# Exit on error
set -e

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Change to root directory
cd "$ROOT_DIR"

echo "Building base image (beardedtek/shanocast-builder:base)..."
docker build -t beardedtek/shanocast-builder:base -f docker/Dockerfile.base .

echo "Building shanocast image (beardedtek/shanocast:latest)..."
docker build -t beardedtek/shanocast:latest -f docker/Dockerfile .

echo "Done! Images built successfully:"
echo "  - beardedtek/shanocast-builder:base"
echo "  - beardedtek/shanocast:latest"
echo
echo "You can run shanocast with: docker run --network host beardedtek/shanocast:latest <network_interface>" 