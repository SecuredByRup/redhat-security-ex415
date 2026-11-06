#!/bin/bash

LOGFILE="/var/log/security_monitor.log"
ALERT_THRESHOLD=5

log_message() {
    echo "$(date): $1" | sudo tee -a "$LOGFILE"
}

# Function to monitor failed login attempts
monitor_failed_logins() {
    # Safely get count and ensure a single clean integer output
    FAILED_LOGINS=$(sudo journalctl -u sshd --since "5 minutes ago" 2>/dev/null | grep -c "Failed password" || echo 0)
    FAILED_LOGINS=$(echo "$FAILED_LOGINS" | tail -n1 | tr -d '[:space:]')
    
    if [ "$FAILED_LOGINS" -gt "$ALERT_THRESHOLD" ]; then
        log_message "ALERT: $FAILED_LOGINS failed login attempts in the last 5 minutes"
        
        # Extract and log suspicious IPs
        SUSPICIOUS_IPS=$(sudo journalctl -u sshd --since "5 minutes ago" | grep "Failed password" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort | uniq)
        log_message "Suspicious IPs: $SUSPICIOUS_IPS"
    fi
}

# Function to monitor audit events
monitor_audit_events() {
    # Check for recent privilege escalation attempts
    PRIV_ESC=$(sudo ausearch -k privilege_escalation --start "5 minutes ago" 2>/dev/null | wc -l)
    PRIV_ESC=$(echo "$PRIV_ESC" | tr -d '[:space:]')
    if [ "$PRIV_ESC" -gt 0 ]; then
        log_message "ALERT: $PRIV_ESC privilege escalation attempts detected"
    fi
    
    # Check for file changes
    FILE_CHANGES=$(sudo ausearch -k passwd_changes -k shadow_changes -k sudoers_changes --start "5 minutes ago" 2>/dev/null | wc -l)
    FILE_CHANGES=$(echo "$FILE_CHANGES" | tr -d '[:space:]')
    if [ "$FILE_CHANGES" -gt 0 ]; then
        log_message "ALERT: $FILE_CHANGES critical file changes detected"
    fi
}

# Main monitoring loop
log_message "Security monitoring started"

while true; do
    monitor_failed_logins
    monitor_audit_events
    sleep 300  # Check every 5 minutes
done
