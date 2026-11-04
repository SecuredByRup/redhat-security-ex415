#!/usr/bin/env python3
import os

# 1. This should work - reading allowed content
try:
    with open('/opt/mywebapp/content/index.html', 'r') as f:
        print("SUCCESS: Read allowed file")
        print(f.read()[:50])
except Exception as e:
    print(f"FAILED: Could not read allowed file: {e}")

# 2. This should fail - reading unauthorized content
try:
    with open('/tmp/unauthorized.html', 'r') as f:
        print("SECURITY ISSUE: Read unauthorized file")
        print(f.read())
except Exception as e:
    print(f"GOOD: Blocked unauthorized access: {e}")
