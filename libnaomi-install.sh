import tkinter as tk
from tkinter import messagebox
import subprocess
import os
import sys

class InstallerApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Libnaomi & NetBoot Installer")
        self.root.geometry("400x300")
        
        # Create a label and buttons
        self.label = tk.Label(root, text="Install Libnaomi, NetBoot, and Dependencies", font=("Arial", 14))
        self.label.pack(pady=20)

        self.install_button = tk.Button(root, text="Start Installation", command=self.start_installation, width=20, height=2, bg="green")
        self.install_button.pack(pady=20)

        self.status_label = tk.Label(root, text="Status: Waiting for action", font=("Arial", 10), fg="blue")
        self.status_label.pack(pady=10)

    def start_installation(self):
        # Update status message
        self.status_label.config(text="Status: Installation in progress...", fg="orange")
        
        # Ensure that Python and Tkinter are installed
        if not self.check_python_and_tkinter():
            self.status_label.config(text="Status: Missing Python/Tkinter", fg="red")
            messagebox.showerror("Error", "Python 3 or Tkinter is missing. Installing now...")
            self.install_python_and_tkinter()

        # Call the installation script
        try:
            result = self.run_install_script()
            if result:
                self.status_label.config(text="Status: Installation Complete!", fg="green")
                messagebox.showinfo("Success", "Installation finished successfully!")
            else:
                self.status_label.config(text="Status: Installation Failed", fg="red")
                messagebox.showerror("Error", "Installation failed. Check the console for details.")
        except Exception as e:
            self.status_label.config(text="Status: Error Occurred", fg="red")
            messagebox.showerror("Error", f"Error during installation: {str(e)}")

    def check_python_and_tkinter(self):
        """ Check if Python 3 and Tkinter are installed """
        try:
            # Check if Python 3 is available
            subprocess.run(["python3", "--version"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            # Check if Tkinter is available
            subprocess.run(["python3", "-m", "tkinter"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            return True
        except subprocess.CalledProcessError:
            return False

    def install_python_and_tkinter(self):
        """ Install Python 3 and Tkinter if they are not installed """
        try:
            subprocess.run(["sudo", "apt-get", "update"], check=True)
            subprocess.run(["sudo", "apt-get", "install", "-y", "python3", "python3-tk"], check=True)
        except subprocess.CalledProcessError as e:
            messagebox.showerror("Error", f"Failed to install Python 3 or Tkinter: {str(e)}")

    def run_install_script(self):
        # The installation script from GitHub
        script_url = "https://raw.githubusercontent.com/hachirokumiku/libnaomi-install/refs/heads/main/libnaomi-install.sh"
        
        # Temporary script filename
        script_file = "/tmp/install_all.sh"

        # Download the script
        try:
            subprocess.run(["curl", "-SL", script_url, "-o", script_file], check=True)
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f"Failed to download script: {e}")

        # Make the script executable
        os.chmod(script_file, 0o755)

        # Run the script
        try:
            subprocess.run([script_file], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            return True
        except subprocess.CalledProcessError as e:
            print(f"Installation failed: {e.stderr.decode()}")
            return False


if __name__ == "__main__":
    # Create the main Tkinter window
    root = tk.Tk()

    # Instantiate the application class
    app = InstallerApp(root)

    # Start the Tkinter main loop
    root.mainloop()
