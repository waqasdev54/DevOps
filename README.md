# Creating and Configuring a Samba Share Folder

This guide provides all the commands necessary to create and configure a Samba share folder.

## Prerequisites

- A Debian/Ubuntu-based Linux system with sudo privileges.
- An active internet connection.

## Steps

### 1. Update the Package List

Update your system's package list to ensure you have access to the latest package versions.

```bash
sudo mkdir -p /srv/samba/share
sudo chmod 2775 /srv/samba/share

sudo tee -a /etc/samba/smb.conf <<EOF
[SharedFolder]
   path = /srv/samba/share
   browseable = yes
   writable = yes
   guest ok = yes
   create mask = 0664
   directory mask = 2775
EOF

sudo systemctl restart smbd


