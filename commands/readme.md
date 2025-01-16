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

sudo setfacl -m u:secelabition@uncw.edu:rwx /home/olatlabin
sudo setfacl -m u:secelabition@uncw.edu:rwx /home/secelabition

ls -ld /home/chimera

sudo chown -R sebelanger@uncw.edu:uncw-sa /home/chimera
sudo chmod -R 770 /home/chimera

I wanted to provide you with an update on this task:

I have successfully assigned the correct permissions to sebelanger@uncw.edu for the /home/belangerx and /home/secelabanger directories.
Regarding the permissions for secelabition@uncw.edu, there is some ambiguity that needs clarification. I am awaiting a scheduled meeting to discuss and finalize the required access permissions for the /home/olatlabin and /home/secelabition directories.
I will proceed with the necessary updates as soon as the meeting resolves the open questions. Please let me know if you have any additional concerns or requirements in the meantime.


