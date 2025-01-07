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
    sudo \
    cmake \
    libncurses-dev \
    libfreetype6-dev \
    libpng-dev \
    libjpeg-dev \
    libz-dev \
    ftp

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

# Install libnaomi dependencies
echo "Installing libnaomi dependencies..."
cd /opt/toolchains
if [ ! -d "libnaomi" ]; then
    echo "Cloning libnaomi repository..."
    git clone https://github.com/DragonMinded/libnaomi.git
else
    echo "libnaomi repository already exists, skipping clone."
fi

# Install libnaomi from the repository
cd libnaomi
echo "Installing libnaomi..."
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

# FTP upload configuration
NAOMI_IP="10.0.0.51"
NAOMI_FTP_USER="your_ftp_username" # Replace with your FTP username
NAOMI_FTP_PASS="your_ftp_password" # Replace with your FTP password
NAOMI_UPLOAD_DIR="/home/root/netboot"  # Update with your desired upload directory on Naomi

# Upload advancedpvrtest.bin to Naomi via FTP
echo "Uploading advancedpvrtest.bin to Naomi..."
ftp -n $NAOMI_IP <<END_SCRIPT
quote USER $NAOMI_FTP_USER
quote PASS $NAOMI_FTP_PASS
binary
cd $NAOMI_UPLOAD_DIR
put advancedpvrtest.bin
bye
END_SCRIPT

echo "Upload complete!"

# Clone NetBoot from DragonMinded's repository
echo "Cloning NetBoot repository..."
cd /opt
if [ ! -d "naomi-netboot" ]; then
    git clone https://github.com/DragonMinded/naomi-netboot.git
else
    echo "Naomi-NetBoot repository already exists, skipping clone."
fi

# Install NetBoot dependencies
cd naomi-netboot
echo "Installing dependencies for NetBoot..."
make

# Check if NetBoot setup was successful
if [ -f "netboot.elf" ]; then
    echo "NetBoot setup successful!"
else
    echo "NetBoot setup failed!"
    exit 1
fi

# Copy the compiled `advancedpvrtest.bin` to the NetBoot folder
echo "Copying advancedpvrtest.bin to NetBoot directory..."
cp /opt/toolchains/libnaomi/examples/advancedpvrtest/advancedpvrtest.bin /opt/naomi-netboot/

# Final instructions for using NetBoot
echo "NetBoot setup is complete."
echo "You can now boot your Naomi system using NetBoot at IP address 10.0.0.51."
echo "The advancedpvrtest.bin file is ready to be loaded via NetBoot."

