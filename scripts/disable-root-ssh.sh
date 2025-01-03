#!/bin/bash

# Script to disable root SSH login
# This script should be run with sudo privileges

# Backup the original sshd_config file
echo "Creating backup of sshd_config..."
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d)

# Disable root login by modifying sshd_config
echo "Disabling root SSH login..."
sudo sed -i 's/^#*PermitRootLogin.*$/PermitRootLogin no/' /etc/ssh/sshd_config

# Verify the change was made
echo "Verifying configuration..."
if grep -q "^PermitRootLogin no" /etc/ssh/sshd_config; then
    echo "Root SSH login has been disabled successfully"
else
    echo "Error: Failed to disable root SSH login"
    exit 1
fi

# Restart SSH service to apply changes
echo "Restarting SSH service..."
if command -v systemctl &> /dev/null; then
    sudo systemctl restart sshd
elif command -v service &> /dev/null; then
    sudo service sshd restart
else
    echo "Error: Could not restart SSH service"
    exit 1
fi

echo "Script completed successfully"
