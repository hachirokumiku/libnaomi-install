#!/bin/bash

# Set environment variables for paths
NAOMI_DIR="/opt/toolchains/naomi"
REPO_DIR="$PWD"  # Assuming you run the script from the root of the repository

# Create and set up the /opt/toolchains/naomi directory
echo "Setting up /opt/toolchains/naomi..."
sudo mkdir -p $NAOMI_DIR
sudo cp -r setup/* $NAOMI_DIR
sudo chown -R $USER:$USER $NAOMI_DIR
cd $NAOMI_DIR

# Run the necessary build steps
echo "Running ./download.sh to download toolchain sources..."
./download.sh || { echo "Download failed"; exit 1; }

echo "Running ./unpack.sh to unpack toolchain..."
./unpack.sh || { echo "Unpack failed"; exit 1; }

echo "Running make to build toolchain..."
make || { echo "Build failed"; exit 1; }

echo "Running make gdb for SH-4..."
make gdb || { echo "GDB build failed"; exit 1; }

echo "Running ./cleanup.sh to clean up..."
./cleanup.sh || { echo "Cleanup failed"; exit 1; }

# Source the environment setup script
echo "Setting up environment..."
source $NAOMI_DIR/env.sh

# Set up the Python virtual environment
echo "Setting up Python virtualenv..."
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies (if required)
echo "Installing Python dependencies..."
pip install -r requirements.txt || { echo "Python dependencies installation failed"; exit 1; }

# Build libnaomi and the other system libraries
echo "Building libnaomi and system libraries..."
make || { echo "Make failed"; exit 1; }

# Install 3rd-party libraries if necessary
echo "Installing 3rd-party libraries..."
make -C 3rdparty install || { echo "3rd-party libraries installation failed"; exit 1; }

# Clean and rebuild with 3rd-party support
echo "Cleaning and rebuilding with 3rd-party support..."
make clean || { echo "Clean failed"; exit 1; }
make || { echo "Rebuild failed"; exit 1; }

# Success message
echo "Setup complete! Naomi toolchain and dependencies are ready to use."
echo "Don't forget to source /opt/toolchains/naomi/env.sh whenever you wish to use the toolchain."
