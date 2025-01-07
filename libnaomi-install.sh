#!/bin/bash

# Update system packages and install common dependencies
echo "Updating system and installing common dependencies..."
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y \
    build-essential \
    python3 python3-pip python3-setuptools python3-dev \
    git \
    curl \
    cmake \
    wget \
    gcc \
    g++ \
    make \
    autoconf \
    automake \
    libtool \
    libssl-dev \
    libreadline-dev \
    libncurses5-dev \
    zlib1g-dev \
    flex \
    bison \
    texinfo \
    gawk \
    libncurses-dev \
    libsdl2-dev \
    pkg-config \
    python3-venv \
    libpython3-dev \
    ssh \
    libglib2.0-dev \
    libfreetype6-dev \
    clang \
    lldb \
    gdb \
    libcurl4-openssl-dev \
    liblzma-dev \
    libzstd-dev \
    ca-certificates \
    libboost-all-dev

# Ensure Python 3 is set as default
echo "Setting up Python 3 and pip3..."
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Install pipenv if not installed
if ! command -v pipenv &> /dev/null; then
    echo "Installing pipenv..."
    sudo pip install pipenv
fi

# Install additional Python dependencies for the toolchain
echo "Installing additional Python dependencies..."
pipenv install --dev

# Install SH4 cross-compilation toolchain (SH4 toolchain)
echo "Installing SH4 cross-compilation toolchain..."
sudo apt install -y \
    gcc-sh4-linux-gnu \
    binutils-sh4-linux-gnu \
    g++-sh4-linux-gnu

# Clone libnaomi repository
echo "Cloning libnaomi repository..."
git clone https://github.com/hachirokumiku/libnaomi.git /opt/libnaomi

# Install dependencies from libnaomi
echo "Installing dependencies from libnaomi..."
cd /opt/libnaomi
./install.sh

# Install the Netboot environment (DragonMinded's netboot)
echo "Setting up DragonMinded Netboot..."
git clone https://github.com/DragonMinded/netboot.git /opt/netboot
cd /opt/netboot
make

# Set up libnaomi examples
echo "Setting up examples..."
cd /opt/libnaomi/examples
make all

# Ensure all dependencies for examples are compiled
echo "Compiling libnaomi examples..."
make

# Check if the example binaries were created successfully
echo "Checking if examples were successfully built..."
if [[ -f /opt/libnaomi/examples/advancedpvrtest/advancedpvrtest.elf ]]; then
    echo "Examples compiled successfully!"
else
    echo "There was an issue compiling the examples!"
    exit 1
fi

# Set up Python virtual environment
echo "Setting up Python virtual environment..."
cd /opt/libnaomi
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Final message
echo "libnaomi, toolchains, dependencies, and examples are successfully installed and compiled!"

# Prompt user for IP address for netboot (or use default if not provided)
read -p "Enter the IP address for DragonMinded Netboot (default 10.0.0.51): " NETBOOT_IP
NETBOOT_IP=${NETBOOT_IP:-10.0.0.51}

echo "Uploading example to Naomi device at $NETBOOT_IP..."
./upload_to_naomi.sh "$NETBOOT_IP"

echo "All done! You should now be able to upload and run examples on your Naomi device via DragonMinded Netboot."

# Exit
exit 0
