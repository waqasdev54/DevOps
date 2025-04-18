#!/bin/bash

# Define variables
USERNAME="your_ssh_username"
PASSWORD="your_ssh_password"
ANSIBLE_PASSWORD="your_ansible_password"  # Password for ansible user
PUBLIC_KEY="your_public_key_content"  # The public key to add to authorized_keys

# Define list of servers
SERVERS=(
  "server1.example.com"
  "server2.example.com"
  "192.168.1.100"
  # Add more servers as needed
)

# Loop through the servers
for server in "${SERVERS[@]}"
do
  echo "Processing server: $server"
  
  # SSH into the server and execute commands
  sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USERNAME@$server" << EOF
    # Create ansible user if it doesn't exist
    useradd ansible
    
    # Set password for ansible user non-interactively
    echo "ansible:$ANSIBLE_PASSWORD" | chpasswd
    
    # Create sudoers file directly without vim
    echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible
    
    # Set proper permissions on sudoers file
    chmod 440 /etc/sudoers.d/ansible
    
    # Add the public key to authorized_keys
    mkdir -p /home/ansible/.ssh
    echo "$PUBLIC_KEY" > /home/ansible/.ssh/authorized_keys
    chmod 600 /home/ansible/.ssh/authorized_keys
    chown -R ansible:ansible /home/ansible/.ssh
EOF

  echo "Completed setup on $server"
  echo "--------------------------"

done

echo "All servers processed!"
