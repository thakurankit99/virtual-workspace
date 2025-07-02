#!/bin/bash

# Create Applications menu entry for VS Code
mkdir -p /usr/share/applications
cat > /usr/share/applications/code.desktop << EOF
[Desktop Entry]
Name=Visual Studio Code
Comment=Code Editing. Redefined.
GenericName=Text Editor
Exec=/usr/bin/code --no-sandbox --unity-launch %F
Icon=/usr/share/pixmaps/com.visualstudio.code.png
Type=Application
StartupNotify=true
StartupWMClass=Code
Categories=Utility;TextEditor;Development;IDE;
MimeType=text/plain;inode/directory;
Actions=new-empty-window;
Keywords=vscode;
EOF

# Create a desktop shortcut
mkdir -p /root/Desktop
cp /usr/share/applications/code.desktop /root/Desktop/
chmod +x /root/Desktop/code.desktop

# Create a script to launch VS Code
cat > /usr/local/bin/launch-vscode << EOF
#!/bin/bash
/usr/bin/code --no-sandbox --unity-launch
EOF

chmod +x /usr/local/bin/launch-vscode

echo "VS Code launcher created successfully" 