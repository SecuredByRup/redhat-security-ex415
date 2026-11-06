#!/bin/bash

echo "=== Automated Threat Response System ==="
echo "Scan initiated: $(date)"
echo ""

# Function to block suspicious IP addresses
block_suspicious_ips() {
    echo "=== Checking for suspicious IP addresses ==="
    
    # Extract failed SSH attempts and get IP addresses
    SUSPICIOUS_IPS=$(sudo journalctl -u sshd --since "1 hour ago" | grep -i "failed" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort | uniq -c | sort -nr | head -5)
    
    if [ ! -z "$SUSPICIOUS_IPS" ]; then
        echo "Suspicious IP addresses found:"
        echo "$SUSPICIOUS_IPS"
        echo ""
        
        # Note: In a real environment, you might want to automatically block these IPs
        echo "Recommended action: Review and consider blocking these IPs"
    else
        echo "No suspicious IP addresses detected"
    fi
    echo ""
}

# Function to check for privilege escalation
check_privilege_escalation() {
    echo "=== Checking for privilege escalation attempts ==="
    
    PRIV_ESC=$(sudo ausearch -k privilege_escalation --start today 2>/dev/null | wc -l)
    
    if [ "$PRIV_ESC" -gt 0 ]; then
        echo "WARNING: $PRIV_ESC privilege escalation attempts detected!"
        echo "Recent attempts:"
        sudo ausearch -k privilege_escalation --start today 2>/dev/null | tail -5
    else
        echo "No privilege escalation attempts detected"
    fi
    echo ""
}

# Function to check file integrity
check_file_integrity() {
    echo "=== Checking critical file changes ==="
    
    PASSWD_CHANGES=$(sudo ausearch -k passwd_changes --start today 2>/dev/null | wc -l)
    SHADOW_CHANGES=$(sudo ausearch -k shadow_changes --start today 2>/dev/null | wc -l)
    
    if [ "$PASSWD_CHANGES" -gt 0 ] || [ "$SHADOW_CHANGES" -gt 0 ]; then
        echo "WARNING: Critical system files have been modified!"
        echo "Password file changes: $PASSWD_CHANGES"
        echo "Shadow file changes: $SHADOW_CHANGES"
        
        if [ "$PASSWD_CHANGES" -gt 0 ]; then
            echo "Recent passwd changes:"
            sudo ausearch -k passwd_changes --start today 2>/dev/null | tail -3
        fi
    else
        echo "No unauthorized changes to critical files detected"
    fi
    echo ""
}

# Execute all checks
block_suspicious_ips
check_privilege_escalation
check_file_integrity

echo "=== Threat Response Complete ==="
echo "Scan completed: $(date)"
