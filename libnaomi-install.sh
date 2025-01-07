#!/bin/bash

# Set variables
NAOMI_TOOLCHAIN_DIR="/opt/toolchains"
LIBNAOMI_DIR="$NAOMI_TOOLCHAIN_DIR/libnaomi"
GITHUB_REPO="https://github.com/DragonMinded/libnaomi.git"
DEPENDENCIES=("build-essential" "git" "gcc" "g++" "make" "clang" "python3" "python3-pip" "libncurses-dev" "gawk" "libc6-dev" "bison" "flex" "libssl-dev" "libelf-dev" "libfl-dev" "libcurl4-openssl-dev")

# Step 1: Update and install system dependencies
echo "Updating package list and installing dependencies..."
sudo apt-get update -y
for dep in "${DEPENDENCIES[@]}"; do
    sudo apt-get install -y "$dep"
done

# Step 2: Install required tools for building the toolchain
echo "Installing required build tools..."
sudo apt-get install -y gcc g++ clang make git

# Step 3: Create the toolchains directory if it doesn't exist
echo "Creating toolchain directory at $NAOMI_TOOLCHAIN_DIR..."
sudo mkdir -p "$NAOMI_TOOLCHAIN_DIR"

# Step 4: Clone the libnaomi repository
echo "Cloning libnaomi repository from GitHub..."
cd "$NAOMI_TOOLCHAIN_DIR"
git clone "$GITHUB_REPO"

# Step 5: Build the toolchain and setup libnaomi
echo "Running setup script for libnaomi..."
cd "$LIBNAOMI_DIR/setup"
./setup.sh

# Step 6: Build the toolchain and related libraries
echo "Building libnaomi toolchain..."
cd "$LIBNAOMI_DIR"
make toolchain

# Step 7: Clean up and finish
echo "Cleaning up..."
cd "$NAOMI_TOOLCHAIN_DIR"
rm -rf "$LIBNAOMI_DIR"  # Optionally clean up after build

# Success message
echo "libnaomi and toolchains have been successfully installed!"

# Optional: Instructions to upload to Naomi using netboot (modify IP if needed)
echo "To upload your build to Naomi, use the following command with netboot:"
echo "netboot <NAOMI_IP> <path_to_your_binary>"

# Done!
echo "Installation complete!"
