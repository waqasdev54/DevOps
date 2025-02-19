#!/bin/bash

# List of servers
servers=(
    "server1.example.com"
    "server2.example.com"
    # Add more servers as needed
)

# SSH credentials
ssh_user="your_ssh_user"
ssh_password="your_password"

# Loop through each server
for server in "${servers[@]}"; do
    echo "Connecting to $server..."

    # SSH into the server using sshpass
    sshpass -p "$ssh_password" ssh -o StrictHostKeyChecking=no "$ssh_user@$server" << 'EOF'
        # Switch to root user
        echo "$ssh_password" | sudo -S -i

        # Navigate to /tmp directory
        cd /tmp

        # Check Oracle Linux version
        os_version=$(grep -oE '[0-9]+' /etc/oracle-release | head -1)

        # Determine the appropriate package based on OS version
        if [[ "$os_version" == "7" ]]; then
            package="falcon-sensor-7.20.0-1234.el7.x86_64.rpm"  # Replace with your actual el7 package filename
        elif [[ "$os_version" == "8" ]]; then
            package="falcon-sensor-7.20.0-1234.el8.x86_64.rpm"  # Replace with your actual el8 package filename
        else
            echo "Unsupported Oracle Linux version: $os_version"
            exit 1
        fi

        # Install the package using yum
        yum install -y "/tmp/$package"

        # Verify installation
        if yum list installed | grep -q 'falcon-sensor'; then
            echo "Falcon Sensor installed successfully on $server."
        else
            echo "Failed to install Falcon Sensor on $server."
            exit 1
        fi

        # Run the 'cat crowdstrike' command (replace with the actual command from your screenshot)
        # For example:
        # cat /opt/CrowdStrike/falconctl -g --cid
        # Replace the above line with the actual command you intend to run

        # Check if the falcon-sensor service is running
        if systemctl is-active --quiet falcon-sensor; then
            echo "Falcon Sensor service is running on $server."
        else
            echo "Falcon Sensor service is NOT running on $server. Attempting to start..."
            systemctl start falcon-sensor
            if systemctl is-active --quiet falcon-sensor; then
                echo "Falcon Sensor service started successfully on $server."
            else
                echo "Failed to start Falcon Sensor service on $server."
            fi
        fi
    EOF

    echo "Completed tasks on $server."
done
