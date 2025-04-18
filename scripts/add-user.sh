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

  sshpass -p "$PASSWORD" ssh -t -o StrictHostKeyChecking=no "$USERNAME@$server" bash <<EOF
    set -e

    # Create ansible user if it doesn't exist
    if ! id ansible >/dev/null 2>&1; then
      sudo useradd -m ansible
      echo "Created ansible user"
    fi

    # Set password
    echo "ansible:$ANSIBLE_PASSWORD" | sudo chpasswd

    # Add to sudoers
    echo "ansible ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ansible >/dev/null
    sudo chmod 440 /etc/sudoers.d/ansible

    # Setup SSH
    sudo -u ansible mkdir -p /home/ansible/.ssh
    echo "$PUBLIC_KEY" | sudo tee /home/ansible/.ssh/authorized_keys >/dev/null
    sudo chmod 700 /home/ansible/.ssh
    sudo chmod 600 /home/ansible/.ssh/authorized_keys
    sudo chown -R ansible:ansible /home/ansible/.ssh

    echo "Ansible user setup completed successfully on $server"
EOF

  if [ $? -eq 0 ]; then
    echo "✅ Completed setup on $server"
  else
    echo "❌ Failed to configure $server"
  fi
  echo "--------------------------"
done

echo "All servers processed!"
