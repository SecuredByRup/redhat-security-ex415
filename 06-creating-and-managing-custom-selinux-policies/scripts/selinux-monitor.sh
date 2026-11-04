#!/bin/bash

echo "=== SELinux Policy Monitoring Report ==="
echo "Generated: $(date)"
echo

echo "=== Current SELinux Status ==="
sestatus
echo

echo "=== Active Policy Modules ==="
semodule -l | grep -E "(mywebapp|custom)" || echo "No custom modules found"
echo

echo "=== Recent AVC Denials ==="
ausearch -m AVC -ts today 2>/dev/null | tail -20 || echo "No recent denials"
echo

echo "=== File Contexts for Our Application ==="
ls -laZ /opt/mywebapp/
echo

echo "=== Process Contexts ==="
ps auxZ | grep mywebapp || echo "Application not running"
echo

echo "=== Network Connections ==="
netstat -tlnp | grep :8080 || echo "No connections on port 8080"
echo

echo "=== Service Status ==="
systemctl status mywebapp --no-pager
