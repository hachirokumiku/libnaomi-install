#!/bin/bash

# Check for SH4 toolchain installation
if ! command -v sh4-linux-gnu-gcc &>/dev/null; then
  echo "SH4 toolchain not found. Please install it before proceeding."
  exit 1
fi

# Check for missing tools (ml and mshlelf)
if ! command -v ml &>/dev/null; then
  echo "'ml' tool not found. Attempting to install..."
  sudo apt-get install sh4-linux-gnu-binutils || {
    echo "Failed to install sh4-linux-gnu-binutils. Please install manually.";
    exit 1;
  }
fi

if ! command -v mshlelf &>/dev/null; then
  echo "'mshlelf' tool not found. Please ensure that the SH4 toolchain is set up correctly."
  exit 1
fi

# Ensure build directory exists
if [ ! -d "build" ]; then
  mkdir build
fi

# Clone libnaomi repository
echo "Cloning libnaomi repository..."
git clone https://github.com/DragonMinded/libnaomi.git || {
  echo "Failed to clone libnaomi repository.";
  exit 1;
}

# Move to libnaomi directory
cd libnaomi || {
  echo "Failed to enter libnaomi directory.";
  exit 1;
}

# Build the advancedpvrtest example
echo "Building advancedpvrtest..."
make || {
  echo "Build failed. Exiting.";
  exit 1;
}

# Upload to Naomi
NAOMI_IP="10.0.0.51"
NAOMI_FILE="advancedpvrtest.bin"

echo "Uploading file to Naomi at $NAOMI_IP..."
if ! curl -T build/naomi.bin "http://$NAOMI_IP/$NAOMI_FILE"; then
  echo "Failed to upload file to Naomi at $NAOMI_IP."
  exit 1
fi

echo "Installation and upload complete."
