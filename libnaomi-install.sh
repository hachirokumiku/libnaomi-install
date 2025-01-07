#!/bin/bash

# Check if running as root (for installing packages)
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Update package list and install dependencies
echo "Updating package list and installing dependencies..."
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
    python3-tk \
    netcat \
    unzip

# Install SH4 cross-compilation toolchain
echo "Installing SH4 toolchain..."
apt install -y \
    gcc-sh4-linux-gnu \
    binutils-sh4-linux-gnu \
    libc6-dev-sh4-cross \
    libgcc1-sh4-cross \
    libstdc++6-sh4-cross

# Clone libnaomi repository
echo "Cloning libnaomi repository..."
cd /opt
if [ ! -d "libnaomi" ]; then
    git clone https://github.com/DragonMinded/libnaomi.git
else
    echo "libnaomi already exists, skipping clone."
fi

cd libnaomi
echo "Installing libnaomi..."
./install.sh

# Clone netboot repository from DragonMinded
echo "Cloning DragonMinded's Netboot repository..."
cd /opt
if [ ! -d "netboot" ]; then
    git clone https://github.com/DragonMinded/netboot.git
else
    echo "Netboot already exists, skipping clone."
fi

cd netboot
echo "Compiling DragonMinded's Netboot..."
make

# Set up Netboot on the Naomi
echo "Setting up Netboot on the Naomi..."
echo "Please ensure your Naomi is set up to accept netboot connections on port 5000."

# Start Netboot server for uploading examples
echo "Starting Netboot server..."
cd /opt/netboot
nohup ./netbootd &

# Compile all examples
echo "Compiling all examples..."
cd /opt/libnaomi/examples
for example in */; do
    if [ -d "$example" ]; then
        echo "Building example $example"
        cd $example
        make
        cd ..
    fi
done

# Check if the examples compiled successfully
echo "Checking if examples were built..."
for example in */; do
    if [ -d "$example" ] && [ -f "$example/$(basename $example).bin" ]; then
        echo "$example built successfully!"
    else
        echo "$example failed to build!"
    fi
done

# GUI for selecting example to upload via Netboot
echo "Launching GUI to select example..."

python3 <<'EOF'
import os
import tkinter as tk
from tkinter import messagebox, simpledialog
import subprocess

# List all compiled example binaries
examples_dir = '/opt/libnaomi/examples'
example_list = [f for f in os.listdir(examples_dir) if os.path.isdir(os.path.join(examples_dir, f))]

# Tkinter window setup
root = tk.Tk()
root.title("Naomi Example Uploader")

# Label
label = tk.Label(root, text="Select an example to upload to Naomi:")
label.pack(pady=10)

# Listbox for example selection
example_listbox = tk.Listbox(root, height=10, width=50)
for example in example_list:
    example_listbox.insert(tk.END, example)
example_listbox.pack(pady=10)

# Entry for IP address input
ip_label = tk.Label(root, text="Enter Naomi IP address:")
ip_label.pack(pady=5)

ip_entry = tk.Entry(root, width=50)
ip_entry.pack(pady=5)

# Function to handle upload via netboot
def upload_example():
    selected_example = example_listbox.get(tk.ACTIVE)
    naomi_ip = ip_entry.get()

    if not selected_example or not naomi_ip:
        messagebox.showerror("Error", "Please select an example and enter an IP address.")
        return

    example_path = os.path.join(examples_dir, selected_example, f"{selected_example}.bin")
    
    if not os.path.exists(example_path):
        messagebox.showerror("Error", "The selected example does not exist or failed to compile.")
        return

    # Netboot upload via DragonMinded's method
    netboot_command = f"nc {naomi_ip} 5000 < {example_path}"
    
    try:
        subprocess.run(netboot_command, shell=True, check=True)
        messagebox.showinfo("Success", f"Successfully uploaded {selected_example} to Naomi at {naomi_ip} via Netboot!")
    except subprocess.CalledProcessError:
        messagebox.showerror("Error", "Failed to upload the example via Netboot. Please check the Naomi connection and the IP address.")

# Upload button
upload_button = tk.Button(root, text="Upload Example via Netboot", command=upload_example)
upload_button.pack(pady=20)

# Run the Tkinter event loop
root.mainloop()
EOF

echo "Done! You can now select the example to upload using the GUI."
