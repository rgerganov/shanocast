#!/bin/bash

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to script directory
cd "$SCRIPT_DIR"

# Use INTERFACE env var if set, otherwise prompt for input
if [ -z "$INTERFACE" ]; then
  # Show available network interfaces
  echo "Available network interfaces:"
  ip -o addr show | grep -v "lo" | awk '{print $2}' | uniq | sort

  echo ""
  echo "Choose a network interface from the list above (default: enp42s0):"
  read -r INTERFACE

  # Set default if empty
  if [ -z "$INTERFACE" ]; then
    INTERFACE="enp42s0"
  fi
else
  echo "Using network interface from environment variable: $INTERFACE"
fi

echo "Starting shanocast with interface: $INTERFACE"

# Export the INTERFACE variable for docker-compose
export INTERFACE

# Run docker-compose
docker-compose up -d

echo "Shanocast is running! You should be able to see it as a casting device in Chrome."
echo "To view logs: docker logs -f shanocast"
echo "To stop: docker-compose down" 