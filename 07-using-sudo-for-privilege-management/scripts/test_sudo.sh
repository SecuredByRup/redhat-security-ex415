#!/bin/bash

echo "=== Testing sudo privileges for current user ==="
echo "Current user: $(whoami)"
echo "Groups: $(groups)"
echo ""

echo "=== Available sudo commands ==="
sudo -l
echo ""

echo "=== Testing specific commands ==="
echo "1. Testing systemctl status:"
sudo systemctl status sshd 2>&1 | head -5

echo ""
echo "2. Testing log access:"
sudo tail -n 5 /var/log/messages 2>&1 | head -5

echo ""
echo "3. Testing restricted command (should fail):"
sudo passwd root 2>&1 | head -2
