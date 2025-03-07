Troubleshooting steps and configurations applied to resolve the "node does not exist" error when setting up HTTP checks on ports 8080, 8081, and 8082 using Nagios and the NCPA agent on Oracle Linux 8.10. This includes the additional points requested: adding services in a services folder with `hostname.cfg`, adding hosts similarly, specifying the correct plugin path, and setting permissions for the script to `nagios:nagios`.

---

# Troubleshooting and Configuration Documentation for NCPA HTTP Checks with Nagios

This document outlines the troubleshooting steps and configurations applied to resolve the "node does not exist" error encountered while setting up HTTP checks on ports 8080, 8081, and 8082 using Nagios and the NCPA agent on an Oracle Linux 8.10 virtual machine (VM). The VM was already being monitored for CPU and memory, indicating that the NCPA agent was partially functional, but HTTP checks failed due to configuration issues.

---

## Table of Contents
1. [Issue Overview](#issue-overview)
2. [Troubleshooting Steps](#troubleshooting-steps)
   - [Verify NCPA Service Status](#verify-ncpa-service-status)
   - [Check Port and Configuration](#check-port-and-configuration)
   - [Validate Firewall and Connectivity](#validate-firewall-and-connectivity)
   - [Verify Custom Plugin and Token](#verify-custom-plugin-and-token)
   - [Correct Command Syntax](#correct-command-syntax)
   - [Review Logs for Errors](#review-logs-for-errors)
3. [Configuration](#configuration)
   - [NCPA Agent Configuration](#ncpa-agent-configuration)
   - [Custom Plugin Setup](#custom-plugin-setup)
   - [Nagios Configuration](#nagios-configuration)
4. [Final Solution](#final-solution)

---

## Issue Overview

The user encountered a "node does not exist" error when executing the command:

```
/usr/local/nagios/libexec/check_ncpa.py -H <target_host> -M 'agent/plugin/...'
```

This error indicated that the NCPA agent on the target host was not responding as expected for HTTP checks, despite successful CPU and memory monitoring. The root causes were identified as misconfigurations in the NCPA agent (port, token, and plugin setup) and issues with the Nagios command syntax and firewall settings.

---

## Troubleshooting Steps

### Verify NCPA Service Status

- **Objective**: Ensure the NCPA service is running on the target host.
- **Command**:
  ```bash
  sudo systemctl status ncpa
  ```
- **Action**:
  - If the service was stopped, it was started and enabled to run on boot:
    ```bash
    sudo systemctl start ncpa
    sudo systemctl enable ncpa
    ```
- **Outcome**: Confirmed the service was active and running.

### Check Port and Configuration

- **Objective**: Verify that the NCPA agent is listening on the correct port (default: 5693).
- **Commands**:
  - Check listening ports:
    ```bash
    sudo netstat -tuln | grep 5693
    ```
  - Review configuration file `/usr/local/ncpa/etc/ncpa.cfg`:
    ```ini
    [api]
    port = 5693
    community_string = your_token
    ```
- **Action**:
  - If the port was incorrect, updated `ncpa.cfg` and restarted the service:
    ```bash
    sudo systemctl restart ncpa
    ```
- **Outcome**: Ensured the agent was listening on port 5693 with the correct token.

### Validate Firewall and Connectivity

- **Objective**: Ensure the firewall allows traffic on port 5693 and test connectivity from the Nagios server.
- **Commands**:
  - Check firewall settings:
    ```bash
    sudo firewall-cmd --list-ports
    ```
  - Open port 5693 if not already allowed:
    ```bash
    sudo firewall-cmd --zone=public --add-port=5693/tcp --permanent
    sudo firewall-cmd --reload
    ```
  - Test connectivity:
    ```bash
    curl -k "https://<target_host>:5693/api/agent?token=your_token"
    ```
- **Outcome**: Confirmed port 5693 was open and accessible from the Nagios server.

### Verify Custom Plugin and Token

- **Objective**: Ensure the custom plugin exists, has correct permissions, and the token matches the configuration.
- **Commands**:
  - Check plugin at the correct path:
    ```bash
    ls -l /usr/local/ncpa/plugins/check_http_port.sh
    ```
  - Set permissions to `nagios:nagios` and make executable:
    ```bash
    sudo chown nagios:nagios /usr/local/ncpa/plugins/check_http_port.sh
    sudo chmod +x /usr/local/ncpa/plugins/check_http_port.sh
    ```
  - Verify token in `/usr/local/ncpa/etc/ncpa.cfg`:
    ```ini
    [api]
    community_string = your_token
    ```
- **Outcome**: Plugin was correctly placed and permissions were set; token matched the Nagios command.

### Correct Command Syntax

- **Objective**: Use the proper syntax for the `check_ncpa.py` command to query the plugin.
- **Correct Command**:
  ```bash
  /usr/local/nagios/libexec/check_ncpa.py -H <target_host> -t your_token -P 5693 -M 'agent/plugin/check_http_port.sh/<port>'
  ```
- **Outcome**: Fixed syntax errors (e.g., incorrect flags or missing token) that caused the "node does not exist" error.

### Review Logs for Errors

- **Objective**: Identify detailed error messages in logs.
- **Commands**:
  - NCPA logs on the target host:
    ```bash
    sudo tail -f /var/log/ncpa/ncpa.log
    ```
  - Nagios logs on the server:
    ```bash
    tail -f /usr/local/nagios/var/nagios.log
    ```
- **Outcome**: Logs revealed initial connectivity and permission issues, which were resolved.

---

## Configuration

### NCPA Agent Configuration

- **File**: `/usr/local/ncpa/etc/ncpa.cfg`
- **Key Settings**:
  ```ini
  [api]
  port = 5693
  community_string = your_token
  ```
- **Action**:
  - Updated the port to 5693 and set a secure `your_token` value.
  - Restarted the service:
    ```bash
    sudo systemctl restart ncpa
    ```

### Custom Plugin Setup

- **Plugin Script**: `check_http_port.sh`
- **Correct Path**: `/usr/local/ncpa/plugins/check_http_port.sh`
- **Permissions**:
  - Set ownership to `nagios:nagios`:
    ```bash
    sudo chown nagios:nagios /usr/local/ncpa/plugins/check_http_port.sh
    ```
  - Made executable:
    ```bash
    sudo chmod +x /usr/local/ncpa/plugins/check_http_port.sh
    ```
- **Note**: The script `check_http_port.sh` is assumed to accept a port number as an argument and return a status compatible with Nagios.

### Nagios Configuration

Nagios configurations were organized into separate directories for hosts and services, using `hostname.cfg` files for clarity.

#### Hosts Configuration
- **Directory**: `/usr/local/nagios/etc/hosts/`
- **File**: `/usr/local/nagios/etc/hosts/oracle_linux_host.cfg`
- **Content**:
  ```plaintext
  define host {
      use             linux-server
      host_name       oracle_linux_host
      alias           Oracle Linux 8.10
      address         <target_host_ip>
  }
  ```
- **Action**: Created the `hosts` directory and added `oracle_linux_host.cfg`.

#### Services Configuration
- **Directory**: `/usr/local/nagios/etc/services/`
- **File**: `/usr/local/nagios/etc/services/oracle_linux_host.cfg`
- **Content**:
  ```plaintext
  define service {
      use                 generic-service
      host_name           oracle_linux_host
      service_description HTTP Check Port 8080
      check_command       check_ncpa_http_port!your_token!8080
  }

  define service {
      use                 generic-service
      host_name           oracle_linux_host
      service_description HTTP Check Port 8081
      check_command       check_ncpa_http_port!your_token!8081
  }

  define service {
      use                 generic-service
      host_name           oracle_linux_host
      service_description HTTP Check Port 8082
      check_command       check_ncpa_http_port!your_token!8082
  }
  ```
- **Action**: Created the `services` directory and added `oracle_linux_host.cfg` with services for ports 8080, 8081, and 8082.

#### Command Definition
- **File**: `/usr/local/nagios/etc/objects/commands.cfg`
- **Content**:
  ```plaintext
  define command {
      command_name    check_ncpa_http_port
      command_line    $USER1$/check_ncpa.py -H $HOSTADDRESS$ -t $ARG1$ -P 5693 -M 'agent/plugin/check_http_port.sh/$ARG2$'
  }
  ```
- **Note**: `$USER1$` is typically `/usr/local/nagios/libexec`, and `$ARG1$` is the token, `$ARG2$` is the port number.

#### Directory Inclusion
- **File**: `/usr/local/nagios/etc/nagios.cfg`
- **Updated Lines**:
  ```plaintext
  cfg_dir=/usr/local/nagios/etc/hosts
  cfg_dir=/usr/local/nagios/etc/services
  ```
- **Action**: Added these lines to include the new directories, then restarted Nagios:
  ```bash
  sudo systemctl restart nagios
  ```

---

## Final Solution

The "node does not exist" error was resolved by:

1. Ensuring the NCPA service was running on the target host.
2. Verifying and correcting the port (5693) and token in `/usr/local/ncpa/etc/ncpa.cfg`.
3. Setting up the custom plugin at `/usr/local/ncpa/plugins/check_http_port.sh` with `nagios:nagios` ownership and executable permissions.
4. Opening port 5693 in the firewall and confirming connectivity from the Nagios server.
5. Correcting the `check_ncpa.py` command syntax and configuring Nagios with separate `hosts` and `services` directories using `oracle_linux_host.cfg` files.

After applying these steps, the HTTP checks for ports 8080, 8081, and 8082 were fully operational.

---

This documentation provides a comprehensive record of the troubleshooting and configuration process. Save this content in a `.md` file (e.g., `ncpa_http_checks_troubleshooting.md`) for future reference. Let me know if additional details are needed!
