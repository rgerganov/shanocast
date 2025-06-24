#!/bin/bash

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Change to root directory
cd "$ROOT_DIR"

# Use INTERFACE env var if set, otherwise prompt for input
if [ -z "$INTERFACE" ]; then
  # Show available network interfaces
  echo "Available network interfaces:"
  ip -o addr show | grep -v "lo" | awk '{print $2}' | uniq | sort

  echo ""
  echo "Choose a network interface from the list above (default: enp42s0):"
  read -r interface

  # Set default if empty
  if [ -z "$interface" ]; then
    interface="enp42s0"
  fi
else
  interface="$INTERFACE"
  echo "Using network interface from environment variable: $interface"
fi

echo "Starting shanocast with interface: $interface"

# Check if the container already exists
if docker ps -a --format '{{.Names}}' | grep -q "^shanocast$"; then
  echo "Removing existing shanocast container..."
  docker rm -f shanocast
fi

# Ensure XDG_RUNTIME_DIR is set
if [ -z "$XDG_RUNTIME_DIR" ]; then
  export XDG_RUNTIME_DIR="/run/user/$(id -u)"
fi

# Run the container with display and audio support
docker run --name shanocast \
  --network host \
  -e DISPLAY="$DISPLAY" \
  -e PULSE_SERVER="unix:${XDG_RUNTIME_DIR}/pulse/native" \
  -e XDG_RUNTIME_DIR="/tmp/runtime-dir" \
  -e WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "${XDG_RUNTIME_DIR}/pulse:/tmp/runtime-dir/pulse" \
  -v /dev/dri:/dev/dri \
  -v /dev/snd:/dev/snd \
  --device /dev/snd \
  --cap-add NET_BIND_SERVICE \
  --cap-add NET_ADMIN \
  --privileged \
  --group-add audio \
  --group-add video \
  -d beardedtek/shanocast:latest "$interface"

echo "Shanocast is running! You should be able to see it as a casting device in Chrome."
echo "To view logs: docker logs -f shanocast"
echo "To stop: docker stop shanocast" 