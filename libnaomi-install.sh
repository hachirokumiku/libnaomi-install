import os
import subprocess
import tkinter as tk
from tkinter import filedialog, messagebox
import shutil

# Installation function
def install_dependencies():
    try:
        # Install system dependencies
        subprocess.check_call(['sudo', 'apt', 'update'])
        subprocess.check_call(['sudo', 'apt', 'install', '-y', 'git', 'build-essential', 'libusb-1.0-0-dev', 'libncurses5-dev'])
        subprocess.check_call(['pip3', 'install', 'tk'])
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Error", f"Failed to install dependencies: {e}")
        return False
    return True

# Clone and compile Libnaomi
def clone_and_compile_libnaomi():
    try:
        subprocess.check_call(['git', 'clone', 'https://github.com/dragonminded/libnaomi.git'])
        os.chdir('libnaomi')
        subprocess.check_call(['make'])
        os.chdir('..')
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Error", f"Failed to compile Libnaomi: {e}")
        return False
    return True

# Clone and setup Netboot
def setup_netboot():
    try:
        subprocess.check_call(['git', 'clone', 'https://github.com/dragonminded/netboot.git'])
        os.chdir('netboot')
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Error", f"Failed to clone Netboot: {e}")
        return False
    return True

# Choose ROM file (example or .bin)
def choose_rom_file():
    file_path = filedialog.askopenfilename(title="Select ROM File", filetypes=(("ROM files", "*.bin"), ("All files", "*.*")))
    return file_path

# Copy ROM to boot directory
def copy_rom(file_path):
    try:
        bootrom_dir = 'netboot/bootroms'
        if not os.path.exists(bootrom_dir):
            os.makedirs(bootrom_dir)
        shutil.copy(file_path, bootrom_dir)
    except Exception as e:
        messagebox.showerror("Error", f"Failed to copy ROM: {e}")
        return False
    return True

# Run Netboot
def run_netboot():
    try:
        subprocess.check_call(['./netboot.sh'])
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Error", f"Failed to run Netboot: {e}")
        return False
    return True

# GUI for installation
def install_gui():
    root = tk.Tk()
    root.title("Libnaomi & Netboot Setup")

    # Install button
    def install_action():
        if install_dependencies():
            messagebox.showinfo("Success", "Dependencies installed successfully.")
            if clone_and_compile_libnaomi():
                messagebox.showinfo("Success", "Libnaomi compiled successfully.")
                if setup_netboot():
                    messagebox.showinfo("Success", "Netboot set up successfully.")
                    rom_file = choose_rom_file()
                    if rom_file:
                        if copy_rom(rom_file):
                            messagebox.showinfo("Success", "ROM copied successfully.")
                            if run_netboot():
                                messagebox.showinfo("Success", "Netboot running with selected ROM.")
                        else:
                            messagebox.showerror("Error", "Failed to copy ROM.")
                else:
                    messagebox.showerror("Error", "Failed to set up Netboot.")
            else:
                messagebox.showerror("Error", "Failed to compile Libnaomi.")
        else:
            messagebox.showerror("Error", "Failed to install dependencies.")
    
    install_button = tk.Button(root, text="Install Libnaomi & Netboot", command=install_action)
    install_button.pack(pady=20)

    # Exit button
    exit_button = tk.Button(root, text="Exit", command=root.quit)
    exit_button.pack(pady=10)

    root.mainloop()

if __name__ == "__main__":
    install_gui()
