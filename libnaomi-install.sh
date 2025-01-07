import tkinter as tk
from tkinter import messagebox, filedialog
import subprocess
import os
import shutil

class LibNaomiInstallerApp:
    def __init__(self, root):
        self.root = root
        self.root.title("LibNaomi Installer")
        self.root.geometry("400x300")
        
        # Initialize frames for different sections
        self.create_initial_frame()
        
    def create_initial_frame(self):
        self.clear_frame()
        
        # Title
        label = tk.Label(self.root, text="LibNaomi Installer", font=("Arial", 18))
        label.pack(pady=20)

        # Buttons to guide user
        install_btn = tk.Button(self.root, text="Install Dependencies & Toolchains", command=self.install_dependencies)
        install_btn.pack(pady=10)

        build_btn = tk.Button(self.root, text="Build Examples", command=self.build_examples)
        build_btn.pack(pady=10)

        select_btn = tk.Button(self.root, text="Upload Example to Naomi", command=self.upload_example)
        select_btn.pack(pady=10)
        
    def clear_frame(self):
        for widget in self.root.winfo_children():
            widget.destroy()
    
    def install_dependencies(self):
        self.clear_frame()
        
        message = tk.Label(self.root, text="Installing dependencies and toolchains...\nPlease wait...", font=("Arial", 12))
        message.pack(pady=50)
        
        self.root.update_idletasks()  # Allow the GUI to update
        
        # Running the installation steps
        subprocess.run(["bash", "install_libnaomi.sh"], check=True)
        
        messagebox.showinfo("Success", "Dependencies and toolchains installed successfully.")
        self.create_initial_frame()
    
    def build_examples(self):
        self.clear_frame()
        
        message = tk.Label(self.root, text="Building all examples...\nPlease wait...", font=("Arial", 12))
        message.pack(pady=50)
        
        self.root.update_idletasks()  # Allow the GUI to update
        
        # Run build command
        subprocess.run(["make", "-C", "/opt/libnaomi/examples"], check=True)
        
        messagebox.showinfo("Success", "Examples built successfully.")
        self.create_initial_frame()
    
    def upload_example(self):
        self.clear_frame()
        
        # Allow user to select the example directory
        file_path = filedialog.askdirectory(title="Select Example to Upload")
        
        if not file_path:
            messagebox.showwarning("No Selection", "No example selected.")
            self.create_initial_frame()
            return
        
        ip_address = tk.simpledialog.askstring("IP Address", "Enter Naomi IP address:")
        
        if ip_address:
            message = tk.Label(self.root, text=f"Uploading example to Naomi at {ip_address}...\nPlease wait...", font=("Arial", 12))
            message.pack(pady=50)
            
            self.root.update_idletasks()
            
            # Run the upload command via netboot
            subprocess.run(["netboot_upload_command", "--ip", ip_address, "--file", file_path], check=True)
            
            messagebox.showinfo("Success", f"Example uploaded successfully to {ip_address}.")
        else:
            messagebox.showwarning("Invalid IP", "Invalid IP address entered.")
        
        self.create_initial_frame()


if __name__ == "__main__":
    root = tk.Tk()
    app = LibNaomiInstallerApp(root)
    root.mainloop()
