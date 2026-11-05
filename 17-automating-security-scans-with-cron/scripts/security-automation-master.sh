#!/bin/bash

# Master Security Automation Script
# Coordinates all security scanning, hardening checks, and alerting locally

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
MASTER_LOG="$LOG_DIR/security-automation.log"

# Ensure log directory exists
mkdir -p $LOG_DIR

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> $MASTER_LOG
}

# Function to run script with error handling
run_script() {
    local script_name="$1"
    local script_path="$SCRIPT_DIR/$script_name"
    
    if [ -f "$script_path" ] && [ -x "$script_path" ]; then
        log_message "Starting $script_name"
        $script_path
        local exit_code=$?
        if [ $exit_code -eq 0 ]; then
            log_message "$script_name completed successfully"
        else
            log_message "$script_name failed with exit code $exit_code"
        fi
        return $exit_code
    else
        log_message "Script $script_name not found or not executable"
        return 1
    fi
}

# Main execution
log_message "=== Starting Security Automation Suite ==="

# Run system hardening check first
run_script "system-hardening-check.sh"

# Wait a moment, then run OpenSCAP scan
sleep 10
run_script "oscap-scan.sh"

# Wait for scans to complete, then check for alerts
sleep 10
run_script "email-alerts.sh"

log_message "=== Security Automation Suite Completed ==="

# Clean up old local reports older than 30 days
find "$SCRIPT_DIR/../reports" -name "*.txt" -mtime +30 -delete 2>/dev/null
find "$SCRIPT_DIR/../reports" -name "*.xml" -mtime +30 -delete 2>/dev/null
find "$SCRIPT_DIR/../reports" -name "*.html" -mtime +30 -delete 2>/dev/null

log_message "Old reports cleaned up"
