#!/bin/bash

# Ensure required environment variables are set
if [[ -z "$SSH_USER" ]]; then
    echo "Error: SSH_USER environment variable is not set."
    exit 1
fi

if [[ -z "$SSH_PASSWORD" ]]; then
    echo "Error: SSH_PASSWORD environment variable is not set."
    exit 1
fi

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo "Error: sshpass is not installed. Please install it first."
    echo "For Debian/Ubuntu: sudo apt-get install sshpass"
    echo "For RHEL/CentOS: sudo yum install sshpass"
    exit 1
fi

# Configure the list of servers to check
SERVERS=(
    "server1.example.com"
    "server2.example.com"
    "server3.example.com"
    # Add more servers as needed
)

# Create a temporary file for the Tomcat check script
TEMP_SCRIPT=$(mktemp)
cat > "$TEMP_SCRIPT" << 'EOF'
TOMCAT_BIN_PATH=$(find / -name "catalina.sh" 2>/dev/null | head -n 1)
# Verify if catalina.sh was found
if [[ -z "$TOMCAT_BIN_PATH" ]]; then
    echo "catalina.sh not found. Please check if Tomcat is installed correctly."
    exit 1
fi
# Get the version of Tomcat
TOMCAT_VERSION=$("$TOMCAT_BIN_PATH" version 2>&1 | grep "Server version" | awk -F/ '{print $2}' | awk '{print $1}')
echo "Apache Tomcat version: $TOMCAT_VERSION"
# Get the version of Java
JAVA_VERSION=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
echo "Java version: $JAVA_VERSION"
# Check the configuration of sun.io.useCanonCaches
JAVA_OPTS=$(ps aux | grep '[j]ava' | grep -o 'sun.io.useCanonCaches=[^ ]*')
if [[ -z "$JAVA_OPTS" ]]; then
    echo "The property sun.io.useCanonCaches is not explicitly configured."
else
    echo "Current configuration of sun.io.useCanonCaches: $JAVA_OPTS"
fi
# Function to compare versions
compare_versions() {
    # Returns 1 if the first version is greater, 2 if it is smaller, 0 if they are equal
    if [[ "$1" == "$2" ]]; then
        echo 0
        return
    fi
    IFS='.' read -r -a version1 <<< "$1"
    IFS='.' read -r -a version2 <<< "$2"
    for i in {0..2}; do
        if [[ -z "${version1[i]}" ]]; then
            version1[i]=0
        fi
        if [[ -z "${version2[i]}" ]]; then
            version2[i]=0
        fi
        if (( version1[i] > version2[i] )); then
            echo 1
            return
        elif (( version1[i] < version2[i] )); then
            echo 2
            return
        fi
    done
    echo 0
}
# Determine vulnerability
if [[ $(compare_versions "$TOMCAT_VERSION" "9.0.98") -eq 2 ]] || \
   ([[ $(compare_versions "$TOMCAT_VERSION" "10.1.0") -eq 1 ]] && [[ $(compare_versions "$TOMCAT_VERSION" "10.1.34") -eq 2 ]]) || \
   ([[ $(compare_versions "$TOMCAT_VERSION" "11.0.0") -eq 1 ]] && [[ $(compare_versions "$TOMCAT_VERSION" "11.0.2") -eq 2 ]]); then
    echo "The Tomcat version is vulnerable."
    if [[ "$JAVA_VERSION" == 1.8* || "$JAVA_VERSION" == 11* ]]; then
        if [[ "$JAVA_OPTS" != "sun.io.useCanonCaches=false" ]]; then
            echo "The system is vulnerable. It is required to set sun.io.useCanonCaches=false."
        else
            echo "The configuration of sun.io.useCanonCaches is adequate."
        fi
    elif [[ "$JAVA_VERSION" == 17* ]]; then
        if [[ "$JAVA_OPTS" == "sun.io.useCanonCaches=true" ]]; then
            echo "The system is vulnerable. It is required to set sun.io.useCanonCaches=false."
        else
            echo "The configuration of sun.io.useCanonCaches is adequate."
        fi
    else
        echo "No additional configuration is required for this version of Java."
    fi
else
    echo "The Tomcat version is not vulnerable."
fi
EOF

# Function to check a single server
check_server() {
    local server=$1
    echo "=========================================="
    echo "Checking server: $server"
    echo "=========================================="

    # Use timeout to prevent hanging on connection issues (15 seconds timeout)
    timeout 15 sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 "$SSH_USER@$server" "bash -s" < "$TEMP_SCRIPT"
    
    local status=$?
    if [ $status -eq 124 ]; then
        echo "Error: Connection to server $server timed out"
    elif [ $status -ne 0 ]; then
        echo "Error: Failed to check server $server (exit code: $status)"
    fi
    echo ""
    
    # Always return 0 to continue with next server regardless of any errors
    return 0
}

# Use command line arguments if provided, otherwise use the predefined SERVERS array
if [ $# -gt 0 ]; then
    # Override servers with command line arguments
    SERVERS=("$@")
fi

# If SERVERS array is empty and no arguments were provided, check if we should read from a file
if [ ${#SERVERS[@]} -eq 0 ]; then
    read -p "Enter the path to the file containing server list (one server per line): " SERVER_LIST_FILE
    
    if [ -f "$SERVER_LIST_FILE" ]; then
        # Read servers from file into the array
        mapfile -t SERVERS < "$SERVER_LIST_FILE"
    else
        echo "Error: No servers specified and file $SERVER_LIST_FILE does not exist."
        rm "$TEMP_SCRIPT"
        exit 1
    fi
fi

# Track success and failure counts
SUCCESS_COUNT=0
FAILURE_COUNT=0
TOTAL_SERVERS=${#SERVERS[@]}

# Process each server
for server in "${SERVERS[@]}"; do
    # Skip empty lines and comments
    if [[ -n "$server" && ! "$server" =~ ^[[:space:]]*# ]]; then
        check_server "$server"
        if [ $? -eq 0 ]; then
            ((SUCCESS_COUNT++))
        else
            ((FAILURE_COUNT++))
        fi
    fi
done

# Clean up the temporary script
rm "$TEMP_SCRIPT"

# Display summary
echo "=========================================="
echo "Summary"
echo "=========================================="
echo "Total servers: $TOTAL_SERVERS"
echo "Successfully checked: $SUCCESS_COUNT"
echo "Failed to check: $FAILURE_COUNT"
echo "All servers processed."
