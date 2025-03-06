cd /usr/local/ncpa/plugins/
nano check_http_port.sh
````
#!/bin/bash
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
fi
````

-----------
chmod +x /usr/local/ncpa/plugins/check_http_port.sh
ls -l /usr/local/ncpa/plugins/check_http_port.sh

If necessary 
chown nagios:nagios /usr/local/ncpa/plugins/check_http_port.sh

./check_http_port.sh 8080

**Nagios Server Commands **

````
wget -O /usr/local/nagios/libexec/check_ncpa.py https://raw.githubusercontent.com/NagiosEnterprises/ncpa/master/client/check_ncpa.py
chmod +x /usr/local/nagios/libexec/check_ncpa.py
nano /usr/local/nagios/etc/objects/commands.cfg

define command {
    command_name    check_ncpa_http_port
    command_line    $USER1$/check_ncpa.py -H $HOSTADDRESS$ -t $ARG1$ -P 5693 -M 'agent/plugin/check_http_port.sh/$ARG2$' -k
}

nano /usr/local/nagios/etc/objects/hosts.cfg

define host {
    use             linux-server
    host_name       oracle_linux_host
    alias           Oracle Linux 8.10
    address         <oracle_linux_ip>
}

define service {
    use                 generic-service
    host_name           oracle_linux_host
    service_description HTTP Check Port 8080
    check_command       check_ncpa_http_port!mytoken!8080
}

define service {
    use                 generic-service
    host_name           oracle_linux_host
    service_description HTTP Check Port 8081
    check_command       check_ncpa_http_port!mytoken!8081
}

define service {
    use                 generic-service
    host_name           oracle_linux_host
    service_description HTTP Check Port 8082
    check_command       check_ncpa_http_port!mytoken!8082
}

````

````
define command {
    command_name    check_ncpa_http_port
    command_line    $USER1$/check_ncpa.py -H $HOSTADDRESS$ -t $ARG1$ -P 5693 -M '/plugins/check_http_port.sh' -a '$ARG2$' -k 
}
````

**Testing**

````
./check_ncpa.py -H 10.51.1.229 -t <your_token> -P 5693 -M 'agent/plugin/check_http_port.sh/8080'
````

