# Create and Configure a User on RHEL 8

## Step 1: Create a New User
```bash
ssh admin_user@server_ip
sudo useradd -m -s /bin/bash appuser
sudo passwd appuser
```

## Step 2: Assign Necessary Permissions
```bash
sudo usermod -aG wheel appuser
sudo visudo -f /etc/sudoers.d/appuser
```
_Add the following line:_
```bash
appuser ALL=(ALL) NOPASSWD: /path/to/application
```

## Step 3: Configure File and Directory Permissions
```bash
sudo chown -R appuser:appuser /opt/app
sudo chmod -R 755 /opt/app
```

## Step 4: Enable SSH Access (if needed)
```bash
sudo usermod -s /bin/bash appuser
su - appuser
mkdir -p ~/.ssh && chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

## Step 5: Allow the User to Run the Application
```bash
su - appuser
cd /opt/app
./run_application.sh
```

## Step 6: Validate and Document Changes
```bash
id appuser
sudo -l -U appuser
```

## Troubleshooting
- If the user cannot log in via SSH:
```bash
sudo cat /etc/ssh/sshd_config | grep PermitRootLogin
sudo systemctl restart sshd
```
- If the application fails to start:
```bash
tail -f /var/log/app.log
