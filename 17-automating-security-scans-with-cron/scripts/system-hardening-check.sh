#!/bin/bash

# System Hardening Check Script
# Performs various security checks on the system and saves locally

# Variables
CHECK_DATE=$(date +"%Y%m%d_%H%M%S")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
REPORT_DIR="$SCRIPT_DIR/../reports"
REPORT_FILE="$REPORT_DIR/hardening-check-$CHECK_DATE.txt"

# Create directories if they don't exist
mkdir -p $LOG_DIR
mkdir -p $REPORT_DIR

# Initialize report
cat > $REPORT_FILE << REPORT_HEADER
System Hardening Security Check Report
======================================
Date: $(date)
Hostname: $(hostname)
System: $(uname -a)

REPORT_HEADER

echo "Starting system hardening checks..." >> $REPORT_FILE

# Check 1: Password Policy
echo "=== PASSWORD POLICY CHECKS ===" >> $REPORT_FILE
echo "Checking /etc/login.defs for password aging..." >> $REPORT_FILE
grep -E "PASS_MAX_DAYS|PASS_MIN_DAYS|PASS_WARN_AGE" /etc/login.defs >> $REPORT_FILE 2>&1

# Check 2: SSH Configuration
echo -e "\n=== SSH CONFIGURATION CHECKS ===" >> $REPORT_FILE
echo "Checking SSH security settings..." >> $REPORT_FILE
if [ -f /etc/ssh/sshd_config ]; then
    echo "Root login setting:" >> $REPORT_FILE
    grep -i "PermitRootLogin" /etc/ssh/sshd_config >> $REPORT_FILE 2>&1
    echo "Password authentication setting:" >> $REPORT_FILE
    grep -i "PasswordAuthentication" /etc/ssh/sshd_config >> $REPORT_FILE 2>&1
    echo "Protocol version:" >> $REPORT_FILE
    grep -i "Protocol" /etc/ssh/sshd_config >> $REPORT_FILE 2>&1
fi

# Check 3: Firewall Status
echo -e "\n=== FIREWALL STATUS ===" >> $REPORT_FILE
echo "Checking firewall status..." >> $REPORT_FILE
systemctl is-active firewalld >> $REPORT_FILE 2>&1
if systemctl is-active --quiet firewalld; then
    echo "Active firewall zones:" >> $REPORT_FILE
    firewall-cmd --list-all-zones >> $REPORT_FILE 2>&1
fi

# Check 4: Failed Login Attempts
echo -e "\n=== FAILED LOGIN ATTEMPTS ===" >> $REPORT_FILE
echo "Recent failed login attempts (last 10):" >> $REPORT_FILE
lastb -n 10 >> $REPORT_FILE 2>&1

# Check 5: World-Writable Files
echo -e "\n=== WORLD-WRITABLE FILES CHECK ===" >> $REPORT_FILE
echo "Searching for world-writable files in critical directories..." >> $REPORT_FILE
find /etc /bin /sbin /usr/bin /usr/sbin -type f -perm -002 2>/dev/null >> $REPORT_FILE

# Check 6: SUID/SGID Files
echo -e "\n=== SUID/SGID FILES ===" >> $REPORT_FILE
echo "SUID files:" >> $REPORT_FILE
find / -type f -perm -4000 2>/dev/null | head -20 >> $REPORT_FILE
echo "SGID files:" >> $REPORT_FILE
find / -type f -perm -2000 2>/dev/null | head -20 >> $REPORT_FILE

# Check 7: System Updates
echo -e "\n=== SYSTEM UPDATES ===" >> $REPORT_FILE
echo "Available security updates:" >> $REPORT_FILE
dnf check-update --security 2>/dev/null | tail -10 >> $REPORT_FILE

# Check 8: Running Services
echo -e "\n=== RUNNING SERVICES ===" >> $REPORT_FILE
echo "Currently running services:" >> $REPORT_FILE
systemctl list-units --type=service --state=running >> $REPORT_FILE

# Check 9: Network Connections
echo -e "\n=== NETWORK CONNECTIONS ===" >> $REPORT_FILE
echo "Active network connections:" >> $REPORT_FILE
netstat -tuln >> $REPORT_FILE 2>&1

# Check 10: User Accounts
echo -e "\n=== USER ACCOUNTS ===" >> $REPORT_FILE
echo "User accounts with login shells:" >> $REPORT_FILE
grep -v "/sbin/nologin\|/bin/false" /etc/passwd >> $REPORT_FILE

# Summary
echo -e "\n=== SUMMARY ===" >> $REPORT_FILE
echo "Hardening check completed at $(date)" >> $REPORT_FILE
echo "Report saved to: $REPORT_FILE" >> $REPORT_FILE

# Log completion
echo "$(date): System hardening check completed - Report: $REPORT_FILE" >> $LOG_DIR/hardening-check.log
