#!/bin/bash

# Start Xvfb
Xvfb :1 -screen 0 1920x1080x24 &

# Set display
export DISPLAY=:1

# Start xfce4 desktop
startxfce4 &

# Wait for xfce to start
sleep 2

# Set VNC password
mkdir -p ~/.vnc
x11vnc -storepasswd vncpass ~/.vnc/passwd

# Start VNC server
x11vnc -display :1 -rfbport 5900 -shared -forever -passwd vncpass &

# Start noVNC
/opt/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 8080 