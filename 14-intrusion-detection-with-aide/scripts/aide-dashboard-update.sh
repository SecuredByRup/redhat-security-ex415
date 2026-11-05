#!/bin/bash
# AIDE Dashboard Update Script

DASHBOARD_DIR="/var/www/aide-dashboard"
LOG_DIR="/var/log/aide"
STATUS_FILE="$DASHBOARD_DIR/status.json"

# Generate status JSON
generate_status() {
    local latest_report=$(ls -t $LOG_DIR/aide-report-*.log 2>/dev/null | head -1)
    local status="unknown"
    local changes=0
    local last_check="never"
    
    if [ -n "$latest_report" ]; then
        changes=$(grep -c "^changed:\|^added:\|^removed:" $latest_report 2>/dev/null || echo 0)
        last_check=$(stat -c %y "$latest_report" | cut -d. -f1)
        
        if [ $changes -eq 0 ]; then
            status="clean"
        elif [ $changes -lt 5 ]; then
            status="warning"
        else
            status="critical"
        fi
    fi
    
    cat > $STATUS_FILE << EOF
{
    "status": "$status",
    "changes": $changes,
    "last_check": "$last_check",
    "hostname": "$(hostname)",
    "timestamp": "$(date -Iseconds)"
}
EOF
}

# Update dashboard
generate_status
echo "Dashboard updated: $(date)"
