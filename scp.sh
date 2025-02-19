# Define the list of server IPs
servers=(
    "1.2.3.4"
    "5.6.7.8"
    "9.10.11.12"
    # Add more server IPs as needed
)

# Define the username for SSH
username="sshuser"

# Loop through each server and copy the files
for server in "${servers[@]}"; do
    scp falcon-sensor-7.20* "$username@$server:/tmp"
done
