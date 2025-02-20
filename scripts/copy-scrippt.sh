#!/bin/bash

# Define variables
USERNAME="your_ssh_user"
PASSWORD="your_ssh_password"
SCRIPT_PATH="your_script.sh"
SERVERS=("server1" "server2" "server3")  # Add your server IPs or hostnames

# Loop through each server
for SERVER in "${SERVERS[@]}"; do
    echo "Copying script to $SERVER..."
    
    # Copy script to /tmp using sshpass and scp, handling connection failure
    sshpass -p "$PASSWORD" scp -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$SCRIPT_PATH" "$USERNAME@$SERVER:/tmp/" 2>/dev/null

    # Check if SCP command was successful
    if [ $? -eq 0 ]; then
        echo "Script copied successfully to $SERVER:/tmp/"
    else
        echo "Failed to connect to $SERVER. Skipping..."
        continue
    fi
done
