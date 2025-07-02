#!/bin/bash

# Start Xvfb with tiny resolution and minimal color depth
Xvfb :1 -screen 0 800x600x8 &

# Set display
export DISPLAY=:1

# Use the lightest possible window manager
if command -v openbox &> /dev/null; then
    openbox &
elif command -v fluxbox &> /dev/null; then
    fluxbox &
elif command -v icewm &> /dev/null; then
    icewm &
else
    echo "Installing ultra-lightweight window manager..."
    apt-get update && apt-get install -y --no-install-recommends openbox
    openbox &
fi

# Wait for desktop to start
sleep 2

# Set VNC password
mkdir -p ~/.vnc
x11vnc -storepasswd vncpass ~/.vnc/passwd

# Start VNC server with ultra-optimized settings
x11vnc -display :1 -rfbport 5900 -shared -forever -passwd vncpass -noxrecord -noxfixes -noxdamage -nopw -wait 5 -defer 5 -noscr -threads -noxrandr &

# Start noVNC with minimal options
/opt/novnc/utils/novnc_proxy --vnc localhost:5900 --listen ${PORT:-8080}

# Create minimal VS Code desktop shortcut
mkdir -p /root/Desktop
echo '[Desktop Entry]
Name=VS Code
Exec=/usr/bin/code --no-sandbox --disable-gpu --disable-software-rasterizer
Type=Application' > /root/Desktop/vscode.desktop
chmod +x /root/Desktop/vscode.desktop 