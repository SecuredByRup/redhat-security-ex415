#!/bin/bash
for file in *.txt; do
    if [ -f "$file" ]; then
        gpg --trust-model always --encrypt --armor \
            --recipient rupal.student@example.com \
            --output "${file}.encrypted" \
            "$file"
        echo "Encrypted: $file"
    fi
done
