import os
import subprocess
import tkinter as tk
from tkinter import filedialog, messagebox
import shutil
import sys

# Function to create and activate a virtual environment
def create_venv():
    venv_dir = 'libnaomi_venv'
    if not os.path.exists(venv_dir):
        try:
            subprocess.check_call([sys.executable, '-m', 'venv', venv_dir])
        except subprocess.CalledProcessError as e:
            messagebox.showerror("Error", f"Failed to create virtual environment: {e}")
            return False
    # Activate the virtual environment
    activate_script = os.path.join(venv_dir, 'bin', 'activate_this.py')
    try:
        exec(open(activate_script).read(), {'__file__': activate_script})
    except Exception as e:
        messagebox.showerror("Error", f"Failed to activate virtual environment: {e}")
        return False
    return True

# Install Python dependencies within the virtual environment
def install_python_dependencies():
    try:
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'tk'])
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Error", f"Failed to install Python dependencies: {e}")
        return False
    return True

# Install system dependencies
def install_dependencies():
    try:
        subprocess.check_call(['sudo', 'apt', 'update'])
        subprocess.check_call(['sudo', 'apt', 'install', '-y', 'git', 'build-essential', 'libusb-1.0-0-dev', 'libncurses5-dev'])
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Error", f"Failed to install system dependencies: {e}")
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
        if create_venv():
            messagebox.showinfo("Success", "Virtual environment created and activated successfully.")
            if install_dependencies():
                messagebox.showinfo("Success", "System dependencies installed successfully.")
                if install_python_dependencies():
                    messagebox.showinfo("Success", "Python dependencies installed successfully.")
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
                                messagebox.showerror("Error", "No ROM file selected.")
                        else:
                            messagebox.showerror("Error", "Failed to set up Netboot.")
                    else:
                        messagebox.showerror("Error", "Failed to compile Libnaomi.")
                else:
                    messagebox.showerror("Error", "Failed to install Python dependencies.")
            else:
                messagebox.showerror("Error", "Failed to install system dependencies.")
        else:
            messagebox.showerror("Error", "Failed to create or activate virtual environment.")
    
    install_button = tk.Button(root, text="Install Libnaomi & Netboot", command=install_action)
    install_button.pack(pady=20)

    # Exit button
    exit_button = tk.Button(root, text="Exit", command=root.quit)
    exit_button.pack(pady=10)

    root.mainloop()

if __name__ == "__main__":
    install_gui()
