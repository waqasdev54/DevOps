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
  
  # Use -t to force pseudo-terminal allocation for sudo
  sshpass -p "$PASSWORD" ssh -t -o StrictHostKeyChecking=no "$USERNAME@$server" "
    # Run everything as a single sudo command to avoid multiple password prompts
    sudo bash -c '
      # Create ansible user
      useradd ansible
      if ! id ansible > /dev/null 2>&1; then
        echo \"Failed to create ansible user\"
        exit 1
      fi
      
      # Set password for ansible user
      echo \"ansible:$ANSIBLE_PASSWORD\" | chpasswd
      
      # Create sudoers file
      echo \"ansible ALL=(ALL) NOPASSWD: ALL\" > /etc/sudoers.d/ansible
      
      # Set proper permissions on sudoers file
      chmod 440 /etc/sudoers.d/ansible
      
      # Create .ssh directory
      mkdir -p /home/ansible/.ssh
      
      # Add the public key to authorized_keys
      echo \"$PUBLIC_KEY\" > /home/ansible/.ssh/authorized_keys
      
      # Set proper permissions
      chmod 700 /home/ansible/.ssh
      chmod 600 /home/ansible/.ssh/authorized_keys
      
      # Set proper ownership
      chown -R ansible:ansible /home/ansible/.ssh
      
      # Verify user was created correctly
      if id ansible > /dev/null 2>&1; then
        echo \"Ansible user setup completed successfully\"
      else
        echo \"Failed to verify ansible user creation\"
        exit 1
      fi
    '
  "

  if [ $? -eq 0 ]; then
    echo "Completed setup on $server"
  else
    echo "Failed to configure $server"
  fi
  echo "--------------------------"

done

echo "All servers processed!"
