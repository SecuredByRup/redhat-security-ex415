#!/bin/bash

# Security Patch Management Script
# Description: Automates security patch installation and system updates

LOG_FILE="/var/log/patch_management.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
REBOOT_REQUIRED=false

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

# Function to backup important files before patching
backup_system() {
    log_message "Creating system backup..."

    BACKUP_DIR="/backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    # Backup critical configuration files
    cp -r /etc/passwd /etc/shadow /etc/group "$BACKUP_DIR/" 2>/dev/null
    cp -r /etc/ssh/ "$BACKUP_DIR/" 2>/dev/null

    log_message "Backup created in $BACKUP_DIR"
}

# Function to update package repositories
update_repositories() {
    log_message "Updating package repositories..."

    if command -v yum >/dev/null 2>&1; then
        yum clean all
        yum makecache
    elif command -v dnf >/dev/null 2>&1; then
        dnf clean all
        dnf makecache
    elif command -v apt >/dev/null 2>&1; then
        apt update
    fi

    log_message "Package repositories updated"
}

# Function to install security updates
install_security_updates() {
    log_message "Installing security updates..."

    if command -v yum >/dev/null 2>&1; then
        yum update --security -y | tee -a "$LOG_FILE"

        if yum history list | head -2 | grep -q kernel; then
            REBOOT_REQUIRED=true
        fi

    elif command -v dnf >/dev/null 2>&1; then
        dnf upgrade --security -y | tee -a "$LOG_FILE"

        if dnf history list | head -2 | grep -q kernel; then
            REBOOT_REQUIRED=true
        fi

    elif command -v apt >/dev/null 2>&1; then
        apt upgrade -y | tee -a "$LOG_FILE"

        if [ -f /var/run/reboot-required ]; then
            REBOOT_REQUIRED=true
        fi
    fi

    log_message "Security updates installation completed"
}

# Function to verify installed patches
verify_patches() {
    log_message "Verifying installed patches..."

    if command -v yum >/dev/null 2>&1; then
        yum history list | head -5 | tee -a "$LOG_FILE"
    elif command -v dnf >/dev/null 2>&1; then
        dnf history list | head -5 | tee -a "$LOG_FILE"
    elif command -v apt >/dev/null 2>&1; then
        apt list --upgradable | tee -a "$LOG_FILE"
    fi
}

# Function to clean up after patching
cleanup_system() {
    log_message "Cleaning up system..."

    if command -v yum >/dev/null 2>&1; then
        yum clean all
    elif command -v dnf >/dev/null 2>&1; then
        dnf clean all
    elif command -v apt >/dev/null 2>&1; then
        apt autoremove -y
        apt autoclean
    fi

    log_message "System cleanup completed"
}

# Function to handle reboot if required
handle_reboot() {
    if [ "$REBOOT_REQUIRED" = true ]; then
        log_message "REBOOT REQUIRED: System will reboot in 5 minutes"
        log_message "Cancel with: shutdown -c"
        shutdown -r +5 "System reboot required for security updates"
    else
        log_message "No reboot required"
    fi
}

# Main execution
main() {
    log_message "=== Patch Management Script Started ==="
    check_root
    backup_system
    update_repositories
    install_security_updates
    verify_patches
    cleanup_system
    handle_reboot
    log_message "=== Patch Management Script Completed ==="
}

# Execute main function
main
