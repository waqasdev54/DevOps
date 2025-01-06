# Create service account
useradd SVCRBNwClsc

# Add to wheel group 
usermod -aG wheel SVCRBNwClsc

# Check if user exists in wheel group
groups SVCRBNwClsc | grep wheel