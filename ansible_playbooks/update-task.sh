#!/bin/bash

# SSH credentials
SSH_USER="abcxyz"
SSH_PASSWORD="your_password_here"

# Target server (replace with the server's IP or hostname)
TARGET_SERVER="target_server_ip_or_hostname"

# Helper function to run commands on the remote server via SSH
run_remote_cmd() {
    sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no "$SSH_USER@$TARGET_SERVER" "$1"
}

# Create BES directory if it doesn't exist
run_remote_cmd "mkdir -p /etc/pct/BESClient && chmod 0755 /etc/pct/BESClient"

# Check if actionsite.afxm file exists
FILE_CHECK=$(run_remote_cmd "[ -f /etc/pct/BESClient/actionsite.afxm ] && echo 'exists' || echo 'not_exists'")

if [ "$FILE_CHECK" == "not_exists" ]; then
    # Download the file if it doesn't exist
    run_remote_cmd "curl -o /etc/pct/BESClient/actionsite.afxm -L 'http://ls-rhast01.loc.arvest.com/pulp/isos/Arvest/Library/custom/netsys-files/netsys-files/macthead.afxm' && chmod 0755 /etc/pct/BESClient/actionsite.afxm"
fi

# Detect RHEL version
RHEL_VERSION=$(run_remote_cmd "awk -F= '/^VERSION_ID/ {print \$2}' /etc/os-release | tr -d '\"'")

# Install BESClient and start the service based on RHEL version
if [ "$RHEL_VERSION" -le 6 ]; then
    run_remote_cmd "yum install -y BESAgent.x86_64 && chkconfig besclient on && service besclient restart"
elif [ "$RHEL_VERSION" -eq 7 ]; then
    run_remote_cmd "yum install -y BESAgent.x86_64 && systemctl enable besclient.service && systemctl restart besclient.service"
elif [ "$RHEL_VERSION" -ge 8 ]; then
    run_remote_cmd "dnf install -y BESAgent.x86_64 && systemctl enable besclient.service && systemctl restart besclient.service"
else
    echo "Unsupported RHEL version: $RHEL_VERSION"
    exit 1
fi

echo "Script executed successfully."
