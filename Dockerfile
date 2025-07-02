FROM ubuntu:20.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install absolute minimal dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    xvfb \
    x11vnc \
    openbox \
    supervisor \
    novnc \
    net-tools \
    libnss3 \
    libgtk-3-0 \
    libgbm1 \
    dbus-x11 \
    libsecret-1-0 \
    gnupg \
    xterm \
    x11-xserver-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add Microsoft GPG key for VS Code
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg

# Install VS Code with minimal dependencies
RUN wget -q https://update.code.visualstudio.com/latest/linux-deb-x64/stable -O /tmp/vscode.deb \
    && apt-get update \
    && apt-get install -y --no-install-recommends /tmp/vscode.deb \
    && rm /tmp/vscode.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install lightweight browser (Dillo)
RUN apt-get update && apt-get install -y --no-install-recommends \
    dillo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Setup minimal noVNC
RUN mkdir -p /opt/novnc/utils/websockify \
    && wget -qO- https://github.com/novnc/noVNC/archive/v1.3.0.tar.gz | tar xz --strip 1 -C /opt/novnc \
    && wget -qO- https://github.com/novnc/websockify/archive/v0.10.0.tar.gz | tar xz --strip 1 -C /opt/novnc/utils/websockify \
    && rm -rf /opt/novnc/docs /opt/novnc/tests /opt/novnc/utils/websockify/tests \
    && find /opt/novnc -type f -name "*.html" ! -name "vnc.html" -delete \
    && find /opt/novnc -type d -name "examples" -exec rm -rf {} + 2>/dev/null || true

# Copy index.html to redirect to vnc.html
COPY index.html /opt/novnc/

# Create minimal desktop directory
RUN mkdir -p /root/Desktop

# Create browser shortcut
RUN echo '[Desktop Entry]\nName=Dillo Browser\nExec=dillo\nType=Application' > /root/Desktop/browser.desktop \
    && chmod +x /root/Desktop/browser.desktop

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