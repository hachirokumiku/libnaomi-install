#!/bin/bash

# Update package list and install essential packages
echo "Updating package list and installing essential tools..."
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    curl \
    git \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-dev \
    libffi-dev \
    libssl-dev \
    gcc \
    g++ \
    make \
    wget \
    unzip \
    libncurses5-dev \
    zlib1g-dev \
    libreadline-dev \
    libbz2-dev \
    liblzma-dev \
    libsqlite3-dev \
    libyaml-dev \
    libgdbm-dev \
    libncursesw5-dev \
    tk-dev \
    libdb-dev \
    libpcap-dev \
    libusb-1.0-0-dev \
    libboost-all-dev \
    qt5-qmake \
    qtbase5-dev \
    libfreetype6-dev \
    libpng-dev \
    libjpeg-dev \
    libtiff-dev \
    libcurl4-openssl-dev \
    python3-tk

# Install Python3 pip
echo "Installing pip for Python3..."
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py
rm get-pip.py

# Install libnaomi dependencies (sh4 toolchain, etc.)
echo "Installing libnaomi dependencies..."

# Install toolchain for SH4
sudo apt-get install -y \
    gcc-sh4-linux-gnu \
    binutils-sh4-linux-gnu \
    g++-sh4-linux-gnu \
    libc6-sh4-cross \
    libncurses5-dev

# Install libnaomi (from the official repository)
echo "Cloning libnaomi repository..."
git clone --recursive https://github.com/DragonMinded/libnaomi.git /opt/libnaomi

# Install Python dependencies for libnaomi
echo "Installing Python dependencies for libnaomi..."
sudo pip3 install -r /opt/libnaomi/requirements.txt

# Install DragonMinded's netboot tool
echo "Installing netboot by DragonMinded..."
git clone https://github.com/DragonMinded/netboot.git /opt/netboot
cd /opt/netboot
make
cd ~

# Compile libnaomi examples
echo "Compiling libnaomi examples..."
cd /opt/libnaomi
make examples

# Install Tkinter (for GUI functionality)
echo "Installing Tkinter for GUI..."
sudo apt-get install -y python3-tk

# Create a GUI for uploading examples to Naomi
echo "Setting up Python GUI for example selection and uploading..."
cat << 'EOF' > /opt/libnaomi-upload-gui.py
import tkinter as tk
from tkinter import messagebox
import os
import subprocess

class ExampleUploader(tk.Frame):
    def __init__(self, root):
        super().__init__(root)
        self.root = root
        self.root.title("LibNaomi Example Uploader")
        
        self.create_widgets()
    
    def create_widgets(self):
        # List all available examples
        self.examples = [f for f in os.listdir("/opt/libnaomi/examples") if os.path.isdir(f)]
        
        self.example_var = tk.StringVar(self.root)
        self.example_var.set(self.examples[0])
        
        # Dropdown menu for selecting example
        self.dropdown = tk.OptionMenu(self.root, self.example_var, *self.examples)
        self.dropdown.pack(pady=10)

        # Upload button
        self.upload_button = tk.Button(self.root, text="Upload to Naomi", command=self.upload_example)
        self.upload_button.pack(pady=10)

    def upload_example(self):
        selected_example = self.example_var.get()
        # Construct the command to upload the example
        command = f"./upload_to_naomi.sh {selected_example}"
        try:
            subprocess.run(command, shell=True, check=True)
            messagebox.showinfo("Success", f"Example '{selected_example}' uploaded to Naomi.")
        except subprocess.CalledProcessError:
            messagebox.showerror("Error", f"Failed to upload '{selected_example}' to Naomi.")

def run_gui():
    root = tk.Tk()
    app = ExampleUploader(root)
    app.pack(padx=10, pady=10)
    root.mainloop()

if __name__ == "__main__":
    run_gui()
EOF

# Give execute permissions to the Python GUI
chmod +x /opt/libnaomi-upload-gui.py

# Create an upload script for example
echo "Creating upload script..."
cat << 'EOF' > /opt/upload_to_naomi.sh
#!/bin/bash

EXAMPLE=$1
NAOMI_IP="10.0.0.51" # Modify this with the actual IP address of the Naomi device

# Upload the example using netboot or other method
if [ -z "$EXAMPLE" ]; then
    echo "Please provide an example name."
    exit 1
fi

echo "Uploading $EXAMPLE to Naomi at $NAOMI_IP..."
# Assuming netboot is set up for this upload method
ssh user@$NAOMI_IP "cd /opt/netboot; ./upload_example.sh $EXAMPLE"
EOF

# Make the upload script executable
chmod +x /opt/upload_to_naomi.sh

# Installation completed
echo "LibNaomi and all dependencies are successfully installed."
echo "You can run the example uploader GUI with the command: python3 /opt/libnaomi-upload-gui.py"
