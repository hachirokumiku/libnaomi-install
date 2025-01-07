#!/bin/bash

# Update package list and install required packages
echo "Updating and installing required packages..."
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    cmake \
    python3-pip \
    python3-tk \
    g++ \
    gcc \
    make \
    curl \
    git \
    binutils \
    clang \
    python3-venv \
    python3-setuptools \
    python3-dev \
    libffi-dev \
    libssl-dev \
    libpng-dev \
    zlib1g-dev \
    automake \
    libtool \
    libncurses5-dev \
    libncursesw5-dev \
    libx11-dev \
    libreadline-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libpcap-dev \
    pkg-config \
    flex \
    bison \
    gawk \
    wget

# Install SH4 Toolchain (assuming Ubuntu or Debian-based distribution)
echo "Installing SH4 Toolchain..."
sudo apt-get install -y sh4-linux-gnu-binutils sh4-linux-gnu-gcc

# Clone libnaomi repository
echo "Cloning libnaomi repository..."
cd ~
git clone https://github.com/hachirokumiku/libnaomi.git
cd libnaomi
git submodule update --init --recursive

# Install Python dependencies for libnaomi
echo "Installing Python dependencies for libnaomi..."
pip3 install -r requirements.txt

# Clone DragonMinded NetBoot repository
echo "Cloning DragonMinded NetBoot repository..."
cd ~
git clone https://github.com/DragonMinded/netboot.git
cd netboot

# Build NetBoot (assuming it's a simple Makefile-based build)
echo "Building DragonMinded NetBoot..."
make

# Set up environment variables or configurations if required (e.g., IP address or network configurations for NetBoot)
echo "Configuring NetBoot..."
# You may need to add specific IP address settings or configuration details here

# Compile examples for libnaomi (assuming examples exist in the repository)
echo "Compiling examples for libnaomi..."
cd ~/libnaomi
make examples

# Display completion message
echo "Installation of libnaomi, NetBoot, and all dependencies is complete!"
