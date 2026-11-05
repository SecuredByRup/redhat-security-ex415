#!/bin/bash

# Comprehensive Security Audit Script
# Description: Performs various security checks and generates a report

LOG_FILE="/var/log/security_audit.log"
REPORT_FILE="/var/log/security_audit_report.txt"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Function to log messages
log_message() {
    echo "[$DATE] $1" | tee -a "$LOG_FILE"
}

# Function to add to report
add_to_report() {
    echo "$1" >> "$REPORT_FILE"
}

# Function to check file permissions
check_file_permissions() {
    log_message "Checking critical file permissions..."
    add_to_report "=== FILE PERMISSIONS AUDIT ==="

    CRITICAL_FILES=("/etc/passwd" "/etc/shadow" "/etc/group" "/etc/gshadow")

    for file in "${CRITICAL_FILES[@]}"; do
        if [ -f "$file" ]; then
            PERMS=$(stat -c "%a" "$file")
            OWNER=$(stat -c "%U:%G" "$file")
            add_to_report "$file: Permissions=$PERMS, Owner=$OWNER"

            if [[ "$file" == *"shadow"* ]] && [[ "$PERMS" != "000" ]] && [[ "$PERMS" != "640" ]]; then
                add_to_report "WARNING: $file has insecure permissions!"
            fi
        fi
    done
}

# Function to check for SUID/SGID files
check_suid_sgid() {
    log_message "Checking for SUID/SGID files..."
    add_to_report "=== SUID/SGID FILES ==="

    find / -type f \( -perm -4000 -o -perm -2000 \) -exec ls -la {} \; 2>/dev/null | head -20 >> "$REPORT_FILE"
}

# Function to check user accounts
check_user_accounts() {
    log_message "Auditing user accounts..."
    add_to_report "=== USER ACCOUNT AUDIT ==="

    add_to_report "Accounts with UID 0 (root privileges):"
    awk -F: '$3 == 0 {print $1}' /etc/passwd >> "$REPORT_FILE"

    add_to_report "Accounts without passwords:"
    awk -F: '$2 == "" {print $1}' /etc/shadow >> "$REPORT_FILE"

    add_to_report "Recently active users (last 30 days):"
    lastlog -t 30 | grep -v "Never" >> "$REPORT_FILE"
}

# Function to check network security
check_network_security() {
    log_message "Checking network security..."
    add_to_report "=== NETWORK SECURITY AUDIT ==="

    add_to_report "Listening services:"
    netstat -tuln | grep LISTEN >> "$REPORT_FILE"

    add_to_report "Firewall status:"
    if command -v firewall-cmd >/dev/null 2>&1; then
        firewall-cmd --state >> "$REPORT_FILE"
        firewall-cmd --list-all >> "$REPORT_FILE"
    elif command -v ufw >/dev/null 2>&1; then
        ufw status >> "$REPORT_FILE"
    fi
}

# Function to check system logs for security events
check_security_logs() {
    log_message "Checking security logs..."
    add_to_report "=== SECURITY LOG ANALYSIS ==="

    add_to_report "Recent failed login attempts:"
    grep "Failed password" /var/log/secure 2>/dev/null | tail -10 >> "$REPORT_FILE"

    add_to_report "Recent sudo usage:"
    grep "sudo:" /var/log/secure 2>/dev/null | tail -10 >> "$REPORT_FILE"
}

# Function to check system integrity
check_system_integrity() {
    log_message "Checking system integrity..."
    add_to_report "=== SYSTEM INTEGRITY CHECK ==="

    add_to_report "World-writable files (sample):"
    find / -type f -perm -002 2>/dev/null | head -10 >> "$REPORT_FILE"

    add_to_report "Disk usage:"
    df -h >> "$REPORT_FILE"
}

# Function to generate summary
generate_summary() {
    log_message "Generating audit summary..."
    add_to_report "=== AUDIT SUMMARY ==="
    add_to_report "Audit completed on: $DATE"
    add_to_report "Report location: $REPORT_FILE"
    add_to_report "Log location: $LOG_FILE"

    ISSUES=$(grep -c "WARNING\|CRITICAL" "$REPORT_FILE" 2>/dev/null || echo "0")
    add_to_report "Potential security issues found: $ISSUES"
}

# Main execution
main() {
    log_message "=== Security Audit Started ==="

    # Clear previous report
    > "$REPORT_FILE"

    check_file_permissions
    check_suid_sgid
    check_user_accounts
    check_network_security
    check_security_logs
    check_system_integrity
    generate_summary

    log_message "=== Security Audit Completed ==="
    log_message "Report saved to: $REPORT_FILE"
}

# Execute main function
main
