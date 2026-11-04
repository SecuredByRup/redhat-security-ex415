#!/bin/bash

# Simple sudo monitoring script
LOG_FILE="/var/log/secure"
ALERT_FILE="/tmp/sudo_alerts.log"

# Monitor for suspicious sudo activity
echo "=== Sudo Security Monitor ===" 
echo "Timestamp: $(date)"

# Check for failed sudo attempts in the last hour
FAILED_ATTEMPTS=$(grep "$(date '+%b %d %H')" "$LOG_FILE" | grep -c "sudo.*FAILED\|sudo.*incorrect password")

if [ "$FAILED_ATTEMPTS" -gt 5 ]; then
    echo "ALERT: $FAILED_ATTEMPTS failed sudo attempts in the last hour" | tee -a "$ALERT_FILE"
fi

# Check for root password changes
ROOT_PASSWD_CHANGES=$(grep "$(date '+%b %d')" "$LOG_FILE" | grep -c "passwd.*root")
if [ "$ROOT_PASSWD_CHANGES" -gt 0 ]; then
    echo "ALERT: Root password change attempts detected today" | tee -a "$ALERT_FILE"
fi

# Check for su command usage
SU_USAGE=$(grep "$(date '+%b %d')" "$LOG_FILE" | grep -c "sudo.*COMMAND=/bin/su")
if [ "$SU_USAGE" -gt 0 ]; then
    echo "INFO: su command used via sudo $SU_USAGE times today" | tee -a "$ALERT_FILE"
fi

echo "Monitoring complete."
