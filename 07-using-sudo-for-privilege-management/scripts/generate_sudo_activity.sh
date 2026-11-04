#!/bin/bash

users=("alice" "bob" "charlie" "diana")

echo "Generating sudo activity for auditing..."

for user in "${users[@]}"; do
    echo "=== Testing as $user ==="
    
    # Successful commands
    sudo su - $user -c "sudo -l > /dev/null 2>&1"
    sudo su - $user -c "sudo ps aux > /dev/null 2>&1"
    
    # Failed commands (intentional)
    sudo su - $user -c "sudo passwd root 2>/dev/null" || true
    sudo su - $user -c "sudo su - 2>/dev/null" || true
    
    sleep 2
done

echo "Activity generation complete."
