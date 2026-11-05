#!/bin/bash

# Master Security Script
# Description: Orchestrates all security scripts based on schedule type

SCRIPT_DIR="/opt/security-scripts"
LOG_FILE="/var/log/master_security.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Function to log messages
log_message() {
    echo "[$DATE] $1" | tee -a "$LOG_FILE"
}

# Function to run daily security tasks
run_daily_tasks() {
    log_message "Running daily security tasks..."

    if [ -x "$SCRIPT_DIR/security_audit.sh" ]; then
        log_message "Executing security audit..."
        "$SCRIPT_DIR/security_audit.sh"
    fi

    if [ -x "$SCRIPT_DIR/port_security.sh" ]; then
        log_message "Executing port security check..."
        "$SCRIPT_DIR/port_security.sh"
    fi
}

# Function to run weekly security tasks
run_weekly_tasks() {
    log_message "Running weekly security tasks..."

    if [ -x "$SCRIPT_DIR/patch_management.sh" ]; then
        log_message "Executing patch management..."
        "$SCRIPT_DIR/patch_management.sh"
    fi

    run_daily_tasks
}

# Function to send email notification (if mail is configured)
send_notification() {
    local subject="$1"
    local message="$2"

    if command -v mail >/dev/null 2>&1; then
        echo "$message" | mail -s "$subject" root
        log_message "Email notification sent: $subject"
    else
        log_message "Mail not configured - notification skipped"
    fi
}

# Main execution based on argument
case "$1" in
    "daily")
        log_message "=== Daily Security Tasks Started ==="
        run_daily_tasks
        send_notification "Daily Security Report" "Daily security tasks completed. Check logs for details."
        log_message "=== Daily Security Tasks Completed ==="
        ;;
    "weekly")
        log_message "=== Weekly Security Tasks Started ==="
        run_weekly_tasks
        send_notification "Weekly Security Report" "Weekly security tasks completed. Check logs for details."
        log_message "=== Weekly Security Tasks Completed ==="
        ;;
    *)
        echo "Usage: $0 {daily|weekly}"
        echo "  daily  - Run daily security checks"
        echo "  weekly - Run weekly security maintenance"
        exit 1
        ;;
esac
