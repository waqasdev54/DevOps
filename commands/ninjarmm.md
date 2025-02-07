# **Ninja RPM Package Installation and Usage Guide**

## **1. Overview**
This document provides a step-by-step guide to installing the **Ninja** package on a Linux server using an `.rpm` package stored on a Windows file server. The guide covers:
- Downloading the package from the Windows file server.
- Transferring the package to a Linux server using `scp`.
- Installing the package using the `rpm` command.
- Understanding the usage of Ninja.

## **2. Prerequisites**
- Access to a Windows file server where the `.rpm` package is stored.
- A Linux server with `scp` and `rpm` installed.
- Network connectivity between the Windows file server and Linux server.

## **3. Steps for Installation**

### **Step 1: Download the RPM Package from the Windows File Server**
If the Windows file server is accessible , you can access it through a network share:
1. Navigate to the file server link ,shared directory containing the Ninja RPM package.
2. downlaod the `.rpm` package to your local system (if necessary).


### **Step 2: Transfer the RPM Package to the Linux Server using SCP**
Use `scp` (Secure Copy Protocol) to transfer the package from Windows to the Linux server.

On a Windows machine (using PowerShell or Command Prompt with OpenSSH installed):
```powershell
scp C:\Users\YourUser\Downloads\ninja-package.rpm user@linux-server:/tmp/
```

On a Linux/Mac system:
```bash
scp ninja-package.rpm user@linux-server:/tmp/
```

### **Step 3: Install the RPM Package on the Linux Server**
1. SSH into the Linux server:
   ```bash
   ssh user@linux-server
   ```
2. Navigate to the directory where the package was copied:
   ```bash
   cd /tmp
   ```
3. Install the package using `rpm`:
   ```bash
   sudo rpm -i ninja-package.rpm
   ```
4. Verify the installation:
   ```bash
   rpm -q ninja
   ```
   If the package is installed correctly, it will return the installed package version.

Check the status:
```bash
systemctl status ninja-agent.service
```

## **4. Usage of Ninja**
The **Ninja** package could be one of the following, depending on your use case:

### **1. Ninja Build System (ninja-build)**
- **Purpose:** A fast build system commonly used in large-scale software development projects.
- **Usage Example:**
  ```bash
  ninja -C build-directory
  ```
- **Integration:** Often used with `CMake` (`cmake -G Ninja`).

### **2. NinjaRMM Agent (Remote Monitoring & Management Tool)**
- **Purpose:** A remote monitoring tool for IT infrastructure.
- **Service Management:**
  ```bash
  systemctl start ninjarmm-agent.service
  systemctl enable ninjarmm-agent.service
  ```
- **Log Checking:**
  ```bash
  journalctl -u ninjarmm-agent.service --no-pager | tail -50
  ```
- **Uninstallation:**
  ```bash
  sudo /opt/NinjaRMMAgent/installer/uninstall.sh
  ```

## **5. Troubleshooting**
### **1. RPM Installation Issues**
If you encounter dependency issues while installing the package:
```bash
sudo yum install -y ninja-package.rpm
```
Or use `dnf` (on newer systems):
```bash
sudo dnf install -y ninja-package.rpm
```

### **2. SCP Connection Issues**
- Ensure SSH is enabled on the Linux server: `sudo systemctl start sshd`
- Check firewall settings: `sudo firewall-cmd --list-all`
- Try using `sftp` as an alternative.
