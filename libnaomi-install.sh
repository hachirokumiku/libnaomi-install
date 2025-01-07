#!/bin/bash

# Function to check if the script is run with superuser privileges
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root (or with sudo)."
        exit 1
    fi
}

# Function to uninstall Libnaomi and toolchain
uninstall_libnaomi() {
    echo "Uninstalling Libnaomi and associated toolchain..."

    # Remove toolchain binaries
    rm -rf /usr/local/bin/sh4-linux-gnu-*
    
    # Remove any installed libraries
    rm -rf /usr/local/lib/libnaomi*

    # Remove the source code directory if exists
    rm -rf /opt/libnaomi
    
    # Optionally remove dependency packages installed
    apt-get purge -y build-essential binutils gcc g++ cmake

    # Clean up residuals
    apt-get autoremove -y
    apt-get clean
    echo "Libnaomi and toolchain uninstalled successfully."
}

# Function to install dependencies
install_dependencies() {
    echo "Installing dependencies..."
    apt-get update
    apt-get install -y \
        build-essential \
        binutils \
        gcc \
        g++ \
        cmake \
        git \
        wget \
        unzip \
        python3 \
        python3-pip
    echo "Dependencies installed successfully."
}

# Function to install the Libnaomi and toolchain
install_libnaomi() {
    echo "Installing Libnaomi and toolchain..."

    # Clone the Libnaomi repository
    git clone https://github.com/hachirokumiku/libnaomi.git /opt/libnaomi
    cd /opt/libnaomi

    # Compile Libnaomi
    mkdir -p build
    cd build
    cmake ..
    make

    # Install the toolchain
    wget https://github.com/yanagilab/sh4-linux-toolchain/releases/download/v1.0.0/sh4-linux-gnu.tar.gz
    tar -xzvf sh4-linux-gnu.tar.gz -C /usr/local/

    # Verify installation
    if [ -f "/usr/local/bin/sh4-linux-gnu-gcc" ]; then
        echo "Libnaomi and toolchain installed successfully."
    else
        echo "Error installing Libnaomi or toolchain."
        exit 1
    fi
}

# Function to reinstall Libnaomi and dependencies
reinstall_libnaomi_and_dependencies() {
    echo "Reinstalling Libnaomi and dependencies..."

    # Uninstall the current version if any
    uninstall_libnaomi

    # Install dependencies
    install_dependencies

    # Install Libnaomi and toolchain
    install_libnaomi
}

# Main function to handle options
main() {
    check_root

    PS3="Choose an option: "
    select option in "Uninstall Libnaomi and Toolchain" "Reinstall Libnaomi and Toolchain" "Reinstall Dependencies" "Exit"; do
        case $option in
            "Uninstall Libnaomi and Toolchain")
                uninstall_libnaomi
                ;;
            "Reinstall Libnaomi and Toolchain")
                reinstall_libnaomi_and_dependencies
                ;;
            "Reinstall Dependencies")
                install_dependencies
                ;;
            "Exit")
                break
                ;;
            *)
                echo "Invalid option. Please try again."
                ;;
        esac
    done
}

# Run the main function
main
