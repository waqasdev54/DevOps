cd /usr/local/ncpa/plugins/
nano check_http_port.sh
`#!/bin/bash

# Check if a port argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <port>"
    exit 3  # Nagios UNKNOWN status
fi

PORT=$1
URL="http://localhost:$PORT"

# Use curl to get the HTTP status code
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

if [ "$STATUS" -eq 200 ]; then
    echo "HTTP OK: Status code $STATUS on port $PORT"
    exit 0  # Nagios OK status
else
    echo "HTTP CRITICAL: Status code $STATUS on port $PORT"
    exit 2  # Nagios CRITICAL status
fi`

-----------
chmod +x /usr/local/ncpa/plugins/check_http_port.sh
ls -l /usr/local/ncpa/plugins/check_http_port.sh

If necessary 
chown nagios:nagios /usr/local/ncpa/plugins/check_http_port.sh

./check_http_port.sh 8080

