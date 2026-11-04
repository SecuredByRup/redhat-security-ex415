#!/bin/bash
# AIDE Report Parser Script

REPORT_FILE="/tmp/aide-report.txt"
LOG_FILE="/var/log/aide/aide-parsed.log"

echo "=== AIDE Security Report Analysis ===" | sudo tee -a $LOG_FILE
echo "Report generated on: $(date)" | sudo tee -a $LOG_FILE
echo "========================================" | sudo tee -a $LOG_FILE

# Check if AIDE found any changes
if sudo aide --check 2>&1 | grep -q "found differences"; then
    echo "ALERT: File system changes detected!" | sudo tee -a $LOG_FILE
    
    # Extract and categorize changes
    sudo aide --check 2>&1 | grep "^changed:" | while read line; do
        echo "MODIFIED: $line" | sudo tee -a $LOG_FILE
    done
    
    sudo aide --check 2>&1 | grep "^removed:" | while read line; do
        echo "DELETED: $line" | sudo tee -a $LOG_FILE
    done
    
    sudo aide --check 2>&1 | grep "^added:" | while read line; do
        echo "ADDED: $line" | sudo tee -a $LOG_FILE
    done
    
else
    echo "INFO: No file system changes detected." | sudo tee -a $LOG_FILE
fi

echo "========================================" | sudo tee -a $LOG_FILE
echo "" | sudo tee -a $LOG_FILE
