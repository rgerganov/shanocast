#!/bin/bash

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Change to root directory
cd "$ROOT_DIR"

# Extract the binary from the container if it doesn't exist
if [ ! -f "./shanocast" ]; then
  echo "Extracting shanocast binary from container..."
  docker create --name temp_container beardedtek/shanocast:latest
  docker cp temp_container:/app/shanocast ./shanocast
  docker rm temp_container
fi

# Make it executable
chmod +x ./shanocast

# Get the network interface
if [ -z "$1" ]; then
  echo "Available network interfaces:"
  ip -o addr show | grep -v "lo" | awk '{print $2}' | uniq | sort
  echo ""
  echo "Please provide a network interface (e.g. ./docker/debug-run.sh enp42s0)"
  exit 1
fi

interface="$1"
echo "Running shanocast with interface: $interface"

# Run with sudo to allow binding to privileged ports
sudo ./shanocast "$interface" 