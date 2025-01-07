#!/bin/bash

# Make sure the script is being run with sudo or as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 
    exit 1
fi

# Update and install basic packages
echo "Updating system and installing basic packages..."
apt update
apt install -y \
    build-essential \
    gcc \
    g++ \
    curl \
    git \
    make \
    automake \
    libtool \
    python3 \
    python3-pip \
    python3-venv \
    unzip \
    wget \
    sudo

# Install SH4 cross-compilation toolchain
echo "Installing SH4 toolchain..."
apt install -y \
    gcc-sh4-linux-gnu \
    binutils-sh4-linux-gnu \
    libc6-dev-sh4-cross \
    libgcc1-sh4-cross \
    libstdc++6-sh4-cross

# Check if toolchain is installed successfully
if ! command -v sh4-linux-gnu-gcc &> /dev/null
then
    echo "SH4 toolchain installation failed. Please check your package manager settings."
    exit 1
fi

echo "SH4 toolchain installed successfully!"

# Install additional dependencies for libnaomi
echo "Installing dependencies for libnaomi..."
apt install -y \
    libncurses-dev \
    libfreetype6-dev \
    libpng-dev \
    libjpeg-dev \
    libz-dev

# Install the toolchain if necessary
echo "Installing toolchain if not already installed..."
cd /opt/toolchains
if [ ! -d "libnaomi" ]; then
    echo "Cloning libnaomi repository..."
    git clone https://github.com/DragonMinded/libnaomi.git
fi

# Go into the repository directory
cd libnaomi

# Install libnaomi dependencies
echo "Installing libnaomi dependencies..."
./install.sh

# Build advancedpvrtest example
echo "Building advancedpvrtest example..."
cd examples/advancedpvrtest
make

# Check if the build was successful
if [ -f "advancedpvrtest.bin" ]; then
    echo "Build successful!"
else
    echo "Build failed!"
    exit 1
fi

# Upload to Naomi (set your IP and path accordingly)
NAOMI_IP="10.0.0.51"
NAOMI_PORT="21" # Example: Use port 21 for FTP, adjust if necessary
FTP_USER="your_ftp_username"
FTP_PASS="your_ftp_password"
echo "Uploading to Naomi..."

# Upload the compiled binary using FTP (or any other method)
curl -T advancedpvrtest.bin ftp://$FTP_USER:$FTP_PASS@$NAOMI_IP:$NAOMI_PORT/

echo "Upload complete!"

# Finish message
echo "All steps completed. Naomi development environment setup and upload finished!"
