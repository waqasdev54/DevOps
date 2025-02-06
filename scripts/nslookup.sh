#!/bin/bash

# Define array of server names without quotes
servers=(
    google.com
    facebook.com
    github.com
    microsoft.com
    amazon.com
)

# Create output file with timestamp
timestamp=$(date +"%Y%m%d_%H%M%S")
output_file="nslookup_results_${timestamp}.txt"

echo "Starting NSLookup for defined servers"
echo "Results will be saved to $output_file"
echo "----------------------------------------" > "$output_file"
echo "NSLookup Results - Generated on $(date)" >> "$output_file"
echo "----------------------------------------" >> "$output_file"

# Loop through the array of servers
for server in "${servers[@]}"; do
    echo -n "Looking up $server... "
    echo -e "\nServer: $server" >> "$output_file"
    
    # Perform nslookup and capture the output
    result=$(nslookup "$server" 2>&1)
    if [ $? -eq 0 ]; then
        # Extract IP addresses and append to output file
        echo "$result" | grep "Address:" | grep -v "#" >> "$output_file"
        echo "Done"
    else
        echo "Failed" >> "$output_file"
        echo "Failed"
    fi
done

echo -e "\nLookup completed! Results saved to $output_file"
