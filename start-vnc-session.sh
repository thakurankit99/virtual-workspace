#!/bin/bash

# Start Xvfb
Xvfb :1 -screen 0 1920x1080x24 &

# Set display
export DISPLAY=:1

# Create VS Code desktop shortcut
mkdir -p /root/Desktop
cat > /root/Desktop/vscode.desktop << EOF
[Desktop Entry]
Name=Visual Studio Code
Comment=Code Editing. Redefined.
GenericName=Text Editor
Exec=/usr/bin/code --no-sandbox --unity-launch %F
Icon=/usr/share/pixmaps/com.visualstudio.code.png
Type=Application
StartupNotify=false
StartupWMClass=Code
Categories=TextEditor;Development;IDE;
MimeType=text/plain;inode/directory;
Actions=new-empty-window;
Keywords=vscode;
EOF

chmod +x /root/Desktop/vscode.desktop

# Verify VS Code installation
if ! command -v code &> /dev/null; then
    echo "VS Code not found, attempting to reinstall..."
    apt-get update
    apt-get install -y wget
    wget -q https://update.code.visualstudio.com/latest/linux-deb-x64/stable -O /tmp/vscode.deb
    apt-get install -y /tmp/vscode.deb
    rm /tmp/vscode.deb
fi

# Start xfce4 desktop
startxfce4 &

# Wait for xfce to start
sleep 2

# Set VNC password
mkdir -p ~/.vnc
x11vnc -storepasswd vncpass ~/.vnc/passwd

# Start VNC server
x11vnc -display :1 -rfbport 5900 -shared -forever -passwd vncpass &

# Start noVNC - use PORT env var for Render compatibility
/opt/novnc/utils/novnc_proxy --vnc localhost:5900 --listen ${PORT:-8080} 