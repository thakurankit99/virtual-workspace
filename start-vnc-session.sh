#!/bin/bash

# Debug info
echo "Starting container with PORT=${PORT}"

# Start Xvfb with more compatible settings
Xvfb :1 -screen 0 1024x768x16 -ac &

# Set display
export DISPLAY=:1

# Wait for Xvfb to initialize
sleep 2

# Create a simple desktop background
mkdir -p /root/.config/openbox
echo "xsetroot -solid darkgrey" > /root/.config/openbox/autostart
chmod +x /root/.config/openbox/autostart

# Use the lightest possible window manager
if command -v openbox &> /dev/null; then
    echo "Starting openbox..."
    openbox &
    sleep 1
    # Set a visible background color
    xsetroot -solid darkgrey
elif command -v fluxbox &> /dev/null; then
    fluxbox &
else
    echo "Installing ultra-lightweight window manager..."
    apt-get update && apt-get install -y --no-install-recommends openbox
    openbox &
    sleep 1
    # Set a visible background color
    xsetroot -solid darkgrey
fi

# Create an xterm shortcut for debugging
echo '[Desktop Entry]
Name=Terminal
Exec=xterm
Type=Application' > /root/Desktop/terminal.desktop
chmod +x /root/Desktop/terminal.desktop

# Install xterm if not present
if ! command -v xterm &> /dev/null; then
    apt-get update && apt-get install -y --no-install-recommends xterm
fi

# Wait for desktop to start
sleep 2

# Set VNC password
mkdir -p ~/.vnc
x11vnc -storepasswd vncpass ~/.vnc/passwd

# Start VNC server with more compatible settings
x11vnc -display :1 -rfbport 5900 -shared -forever -passwd vncpass -wait 5 &

# Create minimal VS Code desktop shortcut
mkdir -p /root/Desktop
echo '[Desktop Entry]
Name=VS Code
Exec=/usr/bin/code --no-sandbox --disable-gpu
Type=Application' > /root/Desktop/vscode.desktop
chmod +x /root/Desktop/vscode.desktop

# Create browser shortcut
echo '[Desktop Entry]
Name=Dillo Browser
Exec=dillo
Type=Application' > /root/Desktop/browser.desktop
chmod +x /root/Desktop/browser.desktop

# Ensure PORT is set
if [ -z "$PORT" ]; then
    export PORT=8080
    echo "PORT was not set, defaulting to 8080"
fi

echo "Starting noVNC on port ${PORT}"

# Start noVNC with minimal options - explicitly use PORT env var
exec /opt/novnc/utils/novnc_proxy --vnc localhost:5900 --listen "${PORT}" 