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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install VS Code
RUN wget -q https://update.code.visualstudio.com/latest/linux-deb-x64/stable -O /tmp/vscode.deb \
    && dpkg -i /tmp/vscode.deb || apt-get -f install -y \
    && rm /tmp/vscode.deb

# Setup noVNC
RUN mkdir -p /opt/novnc/utils/websockify \
    && wget -qO- https://github.com/novnc/noVNC/archive/v1.3.0.tar.gz | tar xz --strip 1 -C /opt/novnc \
    && wget -qO- https://github.com/novnc/websockify/archive/v0.10.0.tar.gz | tar xz --strip 1 -C /opt/novnc/utils/websockify

# Create the startup script
COPY start-vnc-session.sh /usr/bin/
RUN chmod +x /usr/bin/start-vnc-session.sh

# Create supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set working directory
WORKDIR /workspace

# Expose ports
# 8080: noVNC web interface
# 5900: VNC port
EXPOSE 8080 5900

# Start supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"] 