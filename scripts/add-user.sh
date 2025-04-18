#!/bin/bash
set -euo pipefail

USERNAME="your_ssh_username"
PASSWORD="your_ssh_password"
ANSIBLE_PASSWORD="your_ansible_password"
PUBLIC_KEY='ssh-rsa YOUR_PUBLIC_KEY_HERE user@host'

SERVERS=(
  "10.51.2.14"
  # …
)

for server in "${SERVERS[@]}"; do
  echo "→ Configuring $server…"

  sshpass -p "$PASSWORD" ssh -tt -o StrictHostKeyChecking=no \
    "$USERNAME@$server" \
    "echo '$PASSWORD' | sudo -S bash -c \"
      # 1) create ansible if missing
      if ! id ansible &>/dev/null; then
        useradd -m ansible
      fi

      # 2) set its password
      echo 'ansible:$ANSIBLE_PASSWORD' | chpasswd

      # 3) give it NOPASSWD sudo
      echo 'ansible ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/ansible
      chmod 440 /etc/sudoers.d/ansible

      # 4) drop in your SSH key
      install -d -m 700 -o ansible -g ansible /home/ansible/.ssh
      echo '$PUBLIC_KEY' > /home/ansible/.ssh/authorized_keys
      chmod 600 /home/ansible/.ssh/authorized_keys
    \""

  if [ $? -eq 0 ]; then
    echo "✔  $server done"
  else
    echo "✘  $server failed"
  fi
  echo "---------------------------"
done

echo "All servers processed!"
