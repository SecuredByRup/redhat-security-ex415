#!/bin/bash

SUDO_LOG="/var/log/sudo.log"
SECURE_LOG="/var/log/secure"

echo "=== SUDO LOG ANALYSIS REPORT ==="
echo "Generated on: $(date)"
echo ""

if [ -f "$SUDO_LOG" ]; then
    echo "=== Recent sudo commands from $SUDO_LOG ==="
    tail -20 "$SUDO_LOG"
    echo ""
    
    echo "=== Command frequency analysis ==="
    if [ -s "$SUDO_LOG" ]; then
        awk '{print $NF}' "$SUDO_LOG" | sort | uniq -c | sort -nr | head -10
    else
        echo "No entries in sudo.log yet"
    fi
    echo ""
fi

echo "=== Recent sudo activity from system logs ==="
grep "sudo:" "$SECURE_LOG" | tail -15
echo ""

echo "=== Failed sudo attempts ==="
grep -i "failed\|denied\|incorrect" "$SECURE_LOG" | grep sudo | tail -10
echo ""

echo "=== Unique users using sudo ==="
grep "sudo:" "$SECURE_LOG" | awk '{print $5}' | sort | uniq -c
echo ""

echo "=== Most common sudo commands ==="
grep "COMMAND=" "$SECURE_LOG" | sed 's/.*COMMAND=//' | sort | uniq -c | sort -nr | head -10
