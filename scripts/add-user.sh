#!/bin/bash

# Define variables
USERNAME="your_ssh_username"
PASSWORD="your_ssh_password"
ANSIBLE_PASSWORD="your_ansible_password"

# Define list of servers
SERVERS=(
  "10.51.2.14"
  # Add more servers as needed
)

# The public key you want to add to authorized_keys
PUBLIC_KEY="ssh-rsa YOUR_PUBLIC_KEY_HERE user@host"

# Loop through the servers
for server in "${SERVERS[@]}"
do
  echo "Processing server: $server"
  
  # SSH into the server and execute commands as root/with sudo
  sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USERNAME@$server" << EOF
    # Create ansible user - using sudo
    sudo useradd ansible
    
    # Set password for ansible user non-interactively
    echo "ansible:$ANSIBLE_PASSWORD" | sudo chpasswd
    
    # Create sudoers file directly - using sudo with tee
    echo "ansible ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ansible > /dev/null
    
    # Set proper permissions on sudoers file
    sudo chmod 440 /etc/sudoers.d/ansible
    
    # Create .ssh directory if it doesn't exist
    sudo mkdir -p /home/ansible/.ssh
    
    # Create or update authorized_keys file
    echo "$PUBLIC_KEY" | sudo tee /home/ansible/.ssh/authorized_keys > /dev/null
    
    # Set proper permissions
    sudo chmod 700 /home/ansible/.ssh
    sudo chmod 600 /home/ansible/.ssh/authorized_keys
    
    # Set proper ownership
    sudo chown -R ansible:ansible /home/ansible/.ssh
    
    echo "Ansible user setup completed on \$(hostname)"
EOF

  if [ $? -eq 0 ]; then
    echo "Completed setup on $server"
  else
    echo "Failed to configure $server"
  fi
  echo "--------------------------"

done

echo "All servers processed!"
