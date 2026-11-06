#!/bin/bash

echo "=== SUDO PRIVILEGE AUDIT ==="
echo "Date: $(date)"
echo ""

echo "=== Users with sudo access ==="
getent group sudo wheel | cut -d: -f4 | tr ',' '\n' | sort

echo ""
echo "=== Custom sudoers files ==="
ls -la /etc/sudoers.d/

echo ""
echo "=== Recent sudo usage summary ==="
grep "sudo:" /var/log/secure | tail -20 | awk '{print $1, $2, $3, $5, $6}' | sort | uniq -c
