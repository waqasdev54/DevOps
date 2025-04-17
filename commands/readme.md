sudo subscription-manager repos --enable ansible-2.9-for-rhel-8-x86_64-rpms

##command to setup static ip in linux

sudo vi /etc/sysconfig/network-scripts/ifcfg-eth0

# Add/modify these lines:
BOOTPROTO=static
IPADDR=192.168.1.100
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=8.8.8.8

# Restart network
sudo systemctl restart NetworkManager
ip addr 

subscription manager redhat 

# Step 1: Register the system with Red Hat Subscription Management
sudo subscription-manager register

# Step 2: Attach a subscription automatically
sudo subscription-manager attach --auto

# Optional: List available subscriptions (if needed to attach manually)
# sudo subscription-manager list --available
# sudo subscription-manager attach --pool=<POOL_ID>

# Step 3: Refresh subscription data
sudo subscription-manager refresh

# Step 4: List all available repositories
sudo subscription-manager repos --list

# Step 5: Enable the desired repository (replace <repo-id> with the actual ID)
sudo subscription-manager repos --enable=<repo-id>

# Step 6: Verify enabled repositories
sudo subscription-manager repos --list-enabled

# Example: Enable common repositories for RHEL 8
sudo subscription-manager repos --enable=rhel-8-baseos-rpms
sudo subscription-manager repos --enable=rhel-8-appstream-rpms


#16Jan

sudo chown -R sebelanger@uncw.edu:uncw-sa /home/belangerx
sudo chown -R sebelanger@uncw.edu:uncw-sa /home/secelabanger


getfacl /home/olatlabin
getfacl /home/secelabition

sudo setfacl -m u:username.edu:rwx /home/olatlabin
sudo setfacl -m u:username.edu:rwx /home/secelabition

ls -ld /home/chimera

sudo chown -R usrname:uncw-sa /home/chimera
sudo chmod -R 770 /home/chimera

Important Links for Upcomming tasks

**Group Policies Removal**
https://learn.microsoft.com/en-us/powershell/module/grouppolicy/remove-gpo?view=windowsserver2025-ps

**Postfix Configuration for SMTP**
https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-postfix-as-a-send-only-smtp-server-on-ubuntu-22-04



**reason **


CVE-2023-41993 is a critical vulnerability in WebKit, affecting systems with WebKitGTK, specifically the webkit2gtk3 package, which could allow remote code execution via malicious web content. After investigation, it was confirmed that our Oracle Linux system does not have webkit2gtk3 or any WebKit-related packages installed, as verified by the command rpm -qa | grep webkit, which returned no output. Since the vulnerability requires the presence of WebKitGTK to be exploitable, our system is not affected. No remediation is necessary, and the system remains secure against this CVE. Regular updates via sudo yum update will continue to be applied to address other potential vulnerabilities.

reference 
https://access.redhat.com/security/cve/cve-2023-41993
