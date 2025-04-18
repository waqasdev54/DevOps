#!/bin/bash
set -eo pipefail

# your normal vars
USERNAME="your_ssh_username"
PASSWORD="your_ssh_password"
ANSIBLE_PASSWORD="your_ansible_password"

SERVERS=(
  "10.51.2.14"
  # …
)

PUBLIC_KEY="ssh-rsa YOUR_PUBLIC_KEY_HERE user@host"

for server in "${SERVERS[@]}"; do
  echo "→ Processing $server…"

  sshpass -p "$PASSWORD" ssh -tt -o StrictHostKeyChecking=no \
    "$USERNAME@$server" bash <<EOF
# stop on first error
set -e

# send SSH password into sudo
echo "$PASSWORD" | sudo -S bash -c '
  # only create if missing
  if ! id ansible &>/dev/null; then
    useradd -m ansible
  fi

  # set ansible user password
  echo "ansible:$ANSIBLE_PASSWORD" | chpasswd

  # passwordless sudo for ansible
  echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible
  chmod 440 /etc/sudoers.d/ansible

  # install your public key
  mkdir -p /home/ansible/.ssh
  echo "$PUBLIC_KEY" > /home/ansible/.ssh/authorized_keys
  chmod 700 /home/ansible/.ssh
  chmod 600 /home/ansible/.ssh/authorized_keys
  chown -R ansible:ansible /home/ansible/.ssh
'

echo "✔  $server configured successfully"
EOF

  if [ $? -ne 0 ]; then
    echo "✘  $server failed"
  fi
  echo "--------------------------------"
done

echo "All done!"
