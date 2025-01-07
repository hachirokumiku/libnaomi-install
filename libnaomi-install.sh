#!/bin/bash

# Ensure the script is run with superuser privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Update package list
echo "Updating package list..."
sudo apt-get update

# Install necessary dependencies
echo "Installing dependencies..."
sudo apt-get install -y \
  build-essential \
  git \
  cmake \
  libcurl4-openssl-dev \
  libssl-dev \
  zlib1g-dev \
  binutils-sh4-linux-gnu \
  gcc-sh4-linux-gnu \
  g++-sh4-linux-gnu \
  make \
  curl \
  wget \
  python3-tk \
  python3-pip

# Install additional Python packages (for Tkinter)
pip3 install tk

# Clone the libnaomi repository
echo "Cloning libnaomi repository..."
cd /opt
sudo git clone https://github.com/hachirokumiku/libnaomi.git

# Set up environment variables (if applicable)
echo "Setting up environment variables..."
echo 'export PATH=$PATH:/opt/libnaomi/bin' >> ~/.bashrc
echo 'export LIBNAOMI_DIR=/opt/libnaomi' >> ~/.bashrc
source ~/.bashrc

# Build libnaomi (if required)
echo "Building libnaomi..."
cd /opt/libnaomi
sudo make

# Completion message
echo "libnaomi and toolchain installation complete!"
echo "You may need to log out and back in or restart your terminal for changes to take effect."

# Start GUI-based ROM loader
python3 << 'EOF'
import tkinter as tk
from tkinter import filedialog, messagebox
import subprocess
import os

class LibNaomiGUI(tk.Tk):
    def __init__(self):
        super().__init__()

        self.title("LibNaomi ROM Loader")
        self.geometry("500x300")

        self.label = tk.Label(self, text="Select a ROM file to load", font=("Helvetica", 14))
        self.label.pack(pady=20)

        # Precompiled examples
        self.example_button = tk.Button(self, text="Select Precompiled Example", command=self.select_example)
        self.example_button.pack(pady=10)

        # File selection for custom ROMs
        self.file_button = tk.Button(self, text="Select Custom ROM", command=self.select_custom_rom)
        self.file_button.pack(pady=10)

        # Quit button
        self.quit_button = tk.Button(self, text="Quit", command=self.quit)
        self.quit_button.pack(pady=20)

    def select_example(self):
        # Load a list of precompiled example ROMs
        examples_path = "/opt/libnaomi/examples"
        if not os.path.exists(examples_path):
            messagebox.showerror("Error", "Example ROMs not found.")
            return
        
        examples = [f for f in os.listdir(examples_path) if f.endswith('.rom')]
        if not examples:
            messagebox.showerror("Error", "No precompiled example ROMs found.")
            return

        example = filedialog.askopenfilename(
            initialdir=examples_path,
            title="Select Example ROM",
            filetypes=[("ROM files", "*.rom")]
        )

        if example:
            self.load_rom(example)

    def select_custom_rom(self):
        # Let the user choose a custom ROM
        file_path = filedialog.askopenfilename(
            title="Select a ROM file",
            filetypes=[("ROM files", "*.rom")]
        )

        if file_path:
            self.load_rom(file_path)

    def load_rom(self, rom_path):
        # Simulate the ROM loading process
        messagebox.showinfo("Loading ROM", f"Loading ROM: {rom_path}")
        # Here you would add the logic for processing the ROM
        # For example, calling a script or command to load and run the ROM
        try:
            subprocess.run(["/opt/libnaomi/load_rom.sh", rom_path], check=True)
            messagebox.showinfo("Success", "ROM loaded successfully!")
        except subprocess.CalledProcessError as e:
            messagebox.showerror("Error", f"Error loading ROM: {str(e)}")


# Run the GUI application
if __name__ == "__main__":
    app = LibNaomiGUI()
    app.mainloop()

EOF

echo "GUI-based ROM loader started!"
