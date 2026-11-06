#!/bin/bash

echo "=== Comprehensive Log Analysis ==="
echo "Analysis Date: $(date)"
echo ""

analyze_log() {
    local logfile=$1
    local description=$2
    
    if [ -f "$logfile" ]; then
        echo "=== $description ==="
        echo "File: $logfile"
        echo "Last modified: $(stat -c %y $logfile)"
        echo "Size: $(stat -c %s $logfile) bytes"
        echo ""
        echo "Recent entries:"
        sudo tail -10 "$logfile"
        echo ""
    else
        echo "$description: Log file not found ($logfile)"
        echo ""
    fi
}

analyze_log "/var/log/auth.log" "Authentication Log"
analyze_log "/var/log/secure" "Security Log (RHEL/CentOS)"
analyze_log "/var/log/syslog" "System Log"
analyze_log "/var/log/messages" "System Messages"
analyze_log "/var/log/kern.log" "Kernel Log"

echo "=== Security-Specific Analysis ==="
echo "Failed login attempts in the last 24 hours:"
sudo grep -i "failed\|failure" /var/log/auth.log 2>/dev/null | tail -10 || sudo grep -i "failed\|failure" /var/log/secure 2>/dev/null | tail -10

echo ""
echo "Root access attempts:"
sudo grep -i "root" /var/log/auth.log 2>/dev/null | tail -5 || sudo grep -i "root" /var/log/secure 2>/dev/null | tail -5
