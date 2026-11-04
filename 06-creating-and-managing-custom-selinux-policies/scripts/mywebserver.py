#!/usr/bin/env python3
import http.server
import socketserver
import os

PORT = 8080
DIRECTORY = "/opt/mywebapp/content"

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

# Create content directory
os.makedirs(DIRECTORY, exist_ok=True)

# Create a simple HTML file
with open(f"{DIRECTORY}/index.html", "w") as f:
    f.write("<html><body><h1>My Custom Web App</h1></body></html>")

with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
    print(f"Server running on port {PORT}")
    httpd.serve_forever()
