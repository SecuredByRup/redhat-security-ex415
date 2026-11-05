#!/bin/bash
# AIDE SIEM Integration Script
# Exports AIDE results in JSON format for SIEM consumption

LOG_DIR="/var/log/aide"
SIEM_OUTPUT="$LOG_DIR/aide-siem-$(date +%Y%m%d-%H%M%S).json"

# Function to convert AIDE output to JSON
convert_to_json() {
    local report_file="$1"
    local json_file="$2"
    
    echo "{" > $json_file
    echo "  \"timestamp\": \"$(date -Iseconds)\"," >> $json_file
    echo "  \"hostname\": \"$(hostname)\"," >> $json_file
    echo "  \"event_type\": \"file_integrity_check\"," >> $json_file
    echo "  \"tool\": \"AIDE\"," >> $json_file
    
    if [ -f "$report_file" ]; then
        local changes=$(grep -c "^changed:\|^added:\|^removed:" $report_file)
        echo "  \"changes_detected\": $changes," >> $json_file
        echo "  \"status\": \"$([ $changes -eq 0 ] && echo 'clean' || echo 'violations_detected')\"," >> $json_file
        
        echo "  \"details\": {" >> $json_file
        echo "    \"modified_files\": [" >> $json_file
        grep "^changed:" $report_file | sed 's/^changed: //' | sed 's/.*/"&"/' | paste -sd ',' >> $json_file
        echo "    ]," >> $json_file
        
        echo "    \"added_files\": [" >> $json_file
        grep "^added:" $report_file | sed 's/^added: //' | sed 's/.*/"&"/' | paste -sd ',' >> $json_file
        echo "    ]," >> $json_file
        
        echo "    \"removed_files\": [" >> $json_file
        grep "^removed:" $report_file | sed 's/^removed: //' | sed 's/.*/"&"/' | paste -sd ',' >> $json_file
        echo "    ]" >> $json_file
        echo "  }" >> $json_file
    else
        echo "  \"changes_detected\": 0," >> $json_file
        echo "  \"status\": \"clean\"," >> $json_file
        echo "  \"details\": {}" >> $json_file
    fi
    
    echo "}" >> $json_file
}

# Find the latest AIDE report
LATEST_REPORT=$(ls -t $LOG_DIR/aide-report-*.log 2>/dev/null | head -1)

if [ -n "$LATEST_REPORT" ]; then
    convert_to_json "$LATEST_REPORT" "$SIEM_OUTPUT"
    echo "SIEM export completed: $SIEM_OUTPUT"
else
    echo "No AIDE reports found"
fi
