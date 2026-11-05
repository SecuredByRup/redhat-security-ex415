#!/bin/bash

# Port Security Hardening Script
# Description: Identifies open ports and disables unused services

LOG_FILE="/var/log/port_security.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Function to log messages
log_message() {
    echo "[$DATE] $1" | tee -a "$LOG_FILE"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_message "ERROR: This script must be run as root"
        exit 1
    fi
}

# Function to scan open ports
scan_ports() {
    log_message "Starting port scan..."

    # Get listening ports
    netstat -tuln > /tmp/open_ports.txt

    # Display current listening ports
    log_message "Current listening ports:"
    cat /tmp/open_ports.txt | grep LISTEN | tee -a "$LOG_FILE"
}

# Function to disable common unused services
disable_unused_services() {
    log_message "Checking for unused services to disable..."

    # List of commonly unused services
    SERVICES=("telnet" "rsh" "rlogin" "vsftpd" "xinetd")

    for service in "${SERVICES[@]}"; do
        if systemctl is-active --quiet "$service"; then
            log_message "Disabling service: $service"
            systemctl stop "$service"
            systemctl disable "$service"
        else
            log_message "Service $service is already inactive"
        fi
    done
}

# Function to configure firewall rules
configure_firewall() {
    log_message "Configuring firewall rules..."

    # Ensure firewalld is running
    systemctl start firewalld
    systemctl enable firewalld

    # Remove unnecessary services from public zone
    REMOVE_SERVICES=("dhcpv6-client" "cockpit")

    for service in "${REMOVE_SERVICES[@]}"; do
        if firewall-cmd --list-services | grep -q "$service"; then
            log_message "Removing $service from firewall"
            firewall-cmd --permanent --remove-service="$service"
        fi
    done

    # Reload firewall
    firewall-cmd --reload
    log_message "Firewall configuration updated"
}

# Main execution
main() {
    log_message "=== Port Security Script Started ==="
    check_root
    scan_ports
    disable_unused_services
    configure_firewall
    log_message "=== Port Security Script Completed ==="
}

# Execute main function
main
