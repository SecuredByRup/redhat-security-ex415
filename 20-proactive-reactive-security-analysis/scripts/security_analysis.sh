#!/bin/bash

echo "=== Security Analysis Report ==="
echo "Generated on: $(date)"
echo ""

echo "=== Failed Authentication Attempts ==="
sudo ausearch -m USER_AUTH -sv no --start today 2>/dev/null | grep -c "type=USER_AUTH" || echo "No failed authentication attempts found"

echo ""
echo "=== Privilege Escalation Attempts ==="
sudo ausearch -k privilege_escalation --start today 2>/dev/null | wc -l

echo ""
echo "=== File Deletion Events ==="
sudo ausearch -k file_deletion --start today 2>/dev/null | wc -l

echo ""
echo "=== Network Activity Summary ==="
sudo ausearch -k network_activity --start today 2>/dev/null | wc -l

echo ""
echo "=== Recent Sudo Usage ==="
sudo ausearch -k sudo_usage --start today 2>/dev/null | tail -10

echo ""
echo "=== System File Changes ==="
sudo ausearch -k passwd_changes -k shadow_changes --start today 2>/dev/null
