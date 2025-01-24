#!/bin/bash

# Step 1: Create BES directory if it does not exist
if [ ! -d "/etc/pct/BESClient" ]; then
    mkdir -p /etc/pct/BESClient
    chmod 0755 /etc/pct/BESClient
    echo "Directory /etc/pct/BESClient created."
else
    echo "Directory /etc/pct/BESClient already exists."
fi

# Step 2: Check if the actionsite.afxm file exists
if [ ! -f "/etc/pct/BESClient/actionsite.afxm" ]; then
    # Step 3: Download the file if it does not exist
    curl -o /etc/pct/BESClient/actionsite.afxm -L "http://ls-rhast01.loc.arvest.com/pulp/isos/Arvest/Library/custom/netsys-files/netsys-files/macthead.afxm"
    chmod 0755 /etc/pct/BESClient/actionsite.afxm
    echo "File /etc/pct/BESClient/actionsite.afxm downloaded and permissions set."
else
    echo "File /etc/pct/BESClient/actionsite.afxm already exists."
fi

# Step 4: Detect RHEL version
if [ -f /etc/os-release ]; then
    RHEL_VERSION=$(awk -F= '/^VERSION_ID/ {print $2}' /etc/os-release | tr -d '"')
else
    echo "Cannot determine RHEL version. Exiting."
    exit 1
fi

# Step 5: Install BESClient and start the service based on RHEL version
if [ "$RHEL_VERSION" -le 6 ]; then
    yum install -y BESAgent.x86_64
    chkconfig besclient on
    service besclient restart
    echo "BESClient installed and started for RHEL 6 or lower."
elif [ "$RHEL_VERSION" -eq 7 ]; then
    yum install -y BESAgent.x86_64
    systemctl enable besclient.service
    systemctl restart besclient.service
    echo "BESClient installed and started for RHEL 7."
elif [ "$RHEL_VERSION" -ge 8 ]; then
    dnf install -y BESAgent.x86_64
    systemctl enable besclient.service
    systemctl restart besclient.service
    echo "BESClient installed and started for RHEL 8 or higher."
else
    echo "Unsupported RHEL version: $RHEL_VERSION"
    exit 1
fi

echo "Script execution completed."
