FROM ubuntu:20.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    xvfb \
    x11vnc \
    xfce4 \
    xfce4-terminal \
    supervisor \
    novnc \
    net-tools \
    libnotify4 \
    libnss3 \
    libxss1 \
    libgtk-3-0 \
    libgbm1 \
    libasound2 \
    firefox \
    gnome-keyring \
    libsecret-1-0 \
    libx11-xcb1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install VS Code
RUN wget -q https://update.code.visualstudio.com/latest/linux-deb-x64/stable -O /tmp/vscode.deb \
    && apt-get update \
    && apt-get install -y /tmp/vscode.deb \
    && rm /tmp/vscode.deb

# Create desktop shortcut directory
RUN mkdir -p /root/Desktop

# Setup noVNC
RUN mkdir -p /opt/novnc/utils/websockify \
    && wget -qO- https://github.com/novnc/noVNC/archive/v1.3.0.tar.gz | tar xz --strip 1 -C /opt/novnc \
    && wget -qO- https://github.com/novnc/websockify/archive/v0.10.0.tar.gz | tar xz --strip 1 -C /opt/novnc/utils/websockify

# Copy index.html to redirect to vnc.html
COPY index.html /opt/novnc/

# Copy VS Code launcher script
COPY create-vscode-launcher.sh /tmp/
RUN chmod +x /tmp/create-vscode-launcher.sh && /tmp/create-vscode-launcher.sh

# Create the startup script
COPY start-vnc-session.sh /usr/bin/
RUN chmod +x /usr/bin/start-vnc-session.sh

# Create supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set working directory
WORKDIR /workspace

# Expose ports - use PORT env var for Render compatibility
EXPOSE 8080 5900
ENV PORT=8080

# Start supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"] 