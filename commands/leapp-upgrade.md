Below is a comprehensive GitHub `README.md` file that documents the process to fix Leapp upgrade issues encountered when upgrading from Oracle Linux 7 to Oracle Linux 8. This guide is based on common errors identified in terminal logs and screenshots, including package conflicts, repository issues, SELinux directory creation failures, and post-upgrade SSH connectivity problems. It provides step-by-step instructions and troubleshooting tips to ensure a successful upgrade.

---

# Leapp Upgrade Troubleshooting Guide: Oracle Linux 7 to Oracle Linux 8

This guide provides a detailed process to resolve common issues encountered during an in-place upgrade from **Oracle Linux 7** to **Oracle Linux 8** using the `leapp` tool. It addresses errors such as package conflicts, repository misconfigurations, SELinux-related failures, and SSH connectivity issues post-upgrade, based on real-world error logs.

---

## Table of Contents
1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Common Leapp Upgrade Issues and Fixes](#common-leapp-upgrade-issues-and-fixes)
   - [Package Conflicts](#package-conflicts)
   - [Repository Issues](#repository-issues)
   - [SELinux Directory Creation Failure](#selinux-directory-creation-failure)
   - [Post-Upgrade SSH Connectivity Issues](#post-upgrade-ssh-connectivity-issues)
4. [Troubleshooting Tips](#troubleshooting-tips)
5. [Conclusion](#conclusion)
6. [Additional Resources](#additional-resources)

---

## Introduction

[Leapp](https://leapp.readthedocs.io/en/latest/) is an open-source tool designed for in-place upgrades of Red Hat-based systems, including Oracle Linux. It automates the transition from Oracle Linux 7 to Oracle Linux 8 by managing package updates, repository changes, and system configurations. However, the upgrade process can fail due to issues like package conflicts, missing dependencies, or system-specific errors. This guide outlines how to identify and fix these problems to successfully complete the upgrade.

---

## Prerequisites

Before initiating the Leapp upgrade, ensure the following:

- **Backup Your System**: Create a full backup of critical data and configurations to avoid data loss.
- **Update Oracle Linux 7**: Ensure your current system is up-to-date:
  ```bash
  sudo yum update -y
  ```
- **Install Leapp**: Install the Leapp tool and the Oracle Linux 8 upgrade package:
  ```bash
  sudo yum install -y leapp-upgrade-el7toel8
  ```
- **Enable Required Repositories**: Activate the `ol7_leapp` repository:
  ```bash
  sudo yum-config-manager --enable ol7_leapp
  ```
- **Check Disk Space**: Verify sufficient space in `/var` for temporary files (at least 10 GB recommended).

---

## Common Leapp Upgrade Issues and Fixes

### Package Conflicts

Package conflicts occur when existing packages on Oracle Linux 7 clash with those required for Oracle Linux 8, particularly with Python-related packages.

#### Symptoms
- Errors in logs like:
  ```
  file /usr/lib/python3.6/site-packages/docutils/__init__.py conflicts between attempted installs of python3-docutils-0.14-1.el7.noarch and python3-docutils-0.14-1.el8.noarch
  ```
  ```
  file /usr/lib/python3.6/site-packages/__pycache__/_six.cpython-36.opt-1.pyc from install of python3-six-1.11.0-8.el8.noarch conflicts with file from package python36-six-1.14.0-3.el7.noarch
  ```
- Conflicts involving packages like `python36-docutils`, `python36-certifi`, or `python36-six`.

#### Solution
1. **Identify Conflicting Packages**:
   - List installed packages causing conflicts:
     ```bash
     rpm -qa | grep python36
     ```
2. **Remove Conflicting Packages**:
   - Uninstall problematic packages:
     ```bash
     #Removing All package once
     rpm -qa | grep python36 | xargs sudo rpm -e --nodeps
     rpm -qa | grep python36 | xargs sudo rpm -e
     rpm -qa | grep python36 | xargs -I {} sudo rpm -e --nodeps -vv {}
     sudo yum remove python36-docutils python36-certifi python36-six -y
     ```
3. **Clean Yum Cache**:
   - Remove stale cache data:
     ```bash
     sudo yum clean all
     sudo rm -rf /var/cache/yum/*
     sudo yum makecache
     ```
4. **Retry Leapp Preupgrade**:
   - Run the preupgrade check:
     ```bash
     sudo leapp preupgrade --debug
     ```

---

### Repository Issues

Leapp relies on access to Oracle Linux 8 repositories. Misconfigured or unavailable repositories can halt the upgrade process.

#### Symptoms
- Errors such as:
  ```
  Cannot download get package: 1:1.2-8.2.0.el8.x86_64: 4 rpm: All mirrors were tried
  ```
  ```
  Packages marked by Leapp for install not found in repositories metadata: python3-javapackages rpcgen python3-pyxdg
  ```

#### Solution
1. **Verify Network Connectivity**:
   - Test access to Oracle repositories:
     ```bash
     curl -I https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/
     ```
2. **Enable Oracle Linux 8 Repositories**:
   - Configure required repositories:
     ```bash
     sudo yum-config-manager --enable ol8_baseos_latest ol8_appstream ol8_UEKR6
     ```
3. **Check Proxy Settings**:
   - If using a proxy, ensure `/etc/dnf/dnf.conf` is correctly configured:
     ```
     [main]
     proxy=http://<proxy-address>:<port>
     ```
   - For target system compatibility, create a Leapp-specific config:
     ```bash
     sudo mkdir -p /etc/leapp/files
     sudo cp /etc/dnf/dnf.conf /etc/leapp/files/dnf.conf
     ```
4. **Install Missing Packages Manually**:
   - Install required packages if missing:
     ```bash
     sudo yum install python3-dnf libgpg-error -y
     ```

---

### SELinux Directory Creation Failure

Leapp may fail to create directories due to a read-only file system or SELinux restrictions.

#### Symptoms
- Errors like:
  ```
  Failed to create directory /var/lib/leapp/el8userspace/sys/fs/selinux: Read-only file system
  ```
  ```
  Failed to create directory /var/lib/leapp/scratch/mounts/root_/system_overlay/
  ```

#### Solution
1. **Check Mount Status**:
   - Verify if `/var/lib/leapp` is read-only:
     ```bash
     mount | grep /var/lib/leapp
     ```
   - Remount as read-write if needed:
     ```bash
     sudo mount -o remount,rw /var/lib/leapp
     ```
2. **Set Directory Permissions**:
   - Create and adjust permissions:
     ```bash
     sudo mkdir -p /var/lib/leapp/el8userspace
     sudo chmod 755 /var/lib/leapp/el8userspace
     ```
3. **Temporarily Disable SELinux**:
   - Set SELinux to permissive mode:
     ```bash
     sudo setenforce 0
     ```
   - Re-run the upgrade, then re-enable SELinux:
     ```bash
     sudo setenforce 1
     ```

---

### Post-Upgrade SSH Connectivity Issues

After the upgrade, SSH may fail due to service misconfiguration, firewall settings, or SELinux policies.

#### Symptoms
- "Connection refused" or "Port 22 closed" errors when attempting to connect via SSH.

#### Solution
1. **Check SSH Service**:
   - Verify SSH status:
     ```bash
     sudo systemctl status sshd
     ```
   - Start the service if stopped:
     ```bash
     sudo systemctl start sshd
     ```
2. **Update Firewall Rules**:
   - Ensure port 22 is open:
     ```bash
     sudo firewall-cmd --permanent --add-port=22/tcp
     sudo firewall-cmd --reload
     ```
3. **Adjust SELinux Policies**:
   - Test with SELinux in permissive mode:
     ```bash
     sudo setenforce 0
     ```
   - If successful, update SELinux port settings:
     ```bash
     sudo semanage port -a -t ssh_port_t -p tcp 22
     sudo setenforce 1
     ```
4. **Reinstall SSH (if needed)**:
   - Reinstall the SSH server:
     ```bash
     sudo dnf reinstall openssh-server
     ```

---

## Troubleshooting Tips

- **Review Logs**: Check detailed error messages in:
  - `/var/log/leapp/leapp-report.txt`
  - `/var/log/leapp/leapp-upgrade.log`
- **Run Leapp in Debug Mode**: Get verbose output:
  ```bash
  sudo leapp preupgrade --debug
  ```
- **Resolve Host/Machine ID Conflicts**:
  - Regenerate the machine ID if identical to the host ID:
    ```bash
    sudo rm /etc/machine-id
    sudo systemd-machine-id-setup
    ```
- **Handle GRUB Errors**:
  - If GRUB configuration fails, verify `/etc/grub2.cfg` syntax and rebuild:
    ```bash
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    ```
**- Search**
```
awk '/^\[.*\]/ {if (found) print entry; entry=$0; found=0} /inhibitor/ {found=1} {entry=entry "\n" $0} END {if (found) print entry}' /path/to/logfile
```
---

## Conclusion

Upgrading from Oracle Linux 7 to Oracle Linux 8 with Leapp can be challenging due to package conflicts, repository issues, and system configuration errors. By following the steps in this guide—resolving conflicts, configuring repositories, addressing SELinux issues, and fixing post-upgrade problems—you can achieve a successful upgrade. Always back up your system and consult logs for specific errors.

---

## Additional Resources

- [Oracle Linux 8 Leapp Upgrade Guide](https://docs.oracle.com/en/operating-systems/oracle-linux/8/leapp/)
- [dev docs](https://dev.to/project42/upgrading-oracle-linux-7-to-8-with-leapp-18dh)
- [Leapp Official Documentation](https://leapp.readthedocs.io/en/latest/)
- [Oracle Linux Yum Repository](https://yum.oracle.com/)
- [SELinux Troubleshooting Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/using_selinux/troubleshooting-problems-related-to-selinux_using-selinux)

---
