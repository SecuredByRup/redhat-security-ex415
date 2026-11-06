#!/bin/bash

# Email Alert Script for Security Scans
# Sends email notifications based on local scan results

# Variables
ADMIN_EMAIL="root@localhost"
HOSTNAME=$(hostname)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
REPORT_DIR="$SCRIPT_DIR/../reports"

# Function to send email
send_alert() {
    local subject="$1"
    local body="$2"
    local attachment="$3"
    
    if [ -n "$attachment" ] && [ -f "$attachment" ]; then
        echo "$body" | mail -s "$subject" -a "$attachment" "$ADMIN_EMAIL"
    else
        echo "$body" | mail -s "$subject" "$ADMIN_EMAIL"
    fi
}

# Check for recent OpenSCAP scan results
check_oscap_results() {
    local latest_summary=$(ls -t $REPORT_DIR/scan-summary-*.txt 2>/dev/null | head -1)
    
    if [ -f "$latest_summary" ]; then
        local failed_count=$(grep "Failed Rules:" "$latest_summary" | awk '{print $3}')
        local scan_status=$(grep "Status:" "$latest_summary" | awk '{print $2}')
        
        if [ "$scan_status" = "FAILED" ]; then
            local subject="[CRITICAL] OpenSCAP Scan Failed on $HOSTNAME"
            local body="OpenSCAP security scan failed on $HOSTNAME.
            
Please check the system immediately.

Summary:
$(cat $latest_summary)"
            send_alert "$subject" "$body" "$latest_summary"
            
        elif [ "$failed_count" -gt 10 ]; then
            local subject="[WARNING] High Number of Failed Security Rules on $HOSTNAME"
            local body="OpenSCAP scan completed but found $failed_count failed security rules.

This exceeds the threshold of 10 failed rules.

Summary:
$(cat $latest_summary)"
            send_alert "$subject" "$body" "$latest_summary"
        fi
    fi
}

# Check for system hardening issues
check_hardening_results() {
    local latest_hardening=$(ls -t $REPORT_DIR/hardening-check-*.txt 2>/dev/null | head -1)
    
    if [ -f "$latest_hardening" ]; then
        local world_writable=$(grep -A 10 "WORLD-WRITABLE FILES" "$latest_hardening" | wc -l)
        local failed_logins=$(grep -A 10 "FAILED LOGIN ATTEMPTS" "$latest_hardening" | grep -v "^$" | wc -l)
        
        if [ "$world_writable" -gt 5 ] || [ "$failed_logins" -gt 15 ]; then
            local subject="[WARNING] System Hardening Issues Detected on $HOSTNAME"
            local body="System hardening check detected potential security issues:
- World-writable files found: $world_writable
- Recent failed login attempts: $failed_logins

Please review the attached report."
            send_alert "$subject" "$body" "$latest_hardening"
        fi
    fi
}

# Main execution
echo "$(date): Starting email alert checks" >> $LOG_DIR/email-alerts.log

check_oscap_results
check_hardening_results

echo "$(date): Email alert checks completed" >> $LOG_DIR/email-alerts.log
