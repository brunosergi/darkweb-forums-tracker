# FILE: playwright-mcp/Dockerfile
FROM mcr.microsoft.com/playwright/mcp:latest

USER root

# Install VNC and minimal GUI
RUN apt-get update && apt-get install -y \
    curl wget ca-certificates \
    xvfb x11vnc fluxbox \
    websockify \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC for web browser access
RUN cd /opt && \
    wget -qO- https://github.com/novnc/noVNC/archive/v1.4.0.tar.gz | tar xz && \
    mv noVNC-1.4.0 noVNC && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

# Create directories
RUN mkdir -p /screenshots /app/browser-data/sessions && \
    chown -R 1000:1000 /screenshots /app/browser-data

# Create startup script
RUN cat > /app/start-with-vnc.sh << 'EOF'
#!/bin/bash
echo "🖥️ Starting VNC-enabled Playwright MCP..."

# Start virtual display
Xvfb :99 -screen 0 1280x720x24 &
export DISPLAY=:99

# Wait for display to be ready
sleep 2

# Start window manager
fluxbox &

# Wait for window manager
sleep 2

# Start VNC server (no password for simplicity)
x11vnc -display :99 -nopw -listen 0.0.0.0 -xkb -rfbport 5900 -forever -shared -bg

# Start noVNC web interface
websockify --web /opt/noVNC 6080 localhost:5900 &

echo "✅ VNC server ready on port 5900"
echo "🌐 Connect via VNC client to: localhost:5900"
echo "🌐 Web VNC available at: http://localhost:6080"

# Start Playwright MCP (GUI mode - remove --no-sandbox for VNC)
exec node cli.js --browser chromium --host 0.0.0.0 --port ${PLAYWRIGHT_MCP_PORT:-8831} \
    --viewport-size "${PLAYWRIGHT_VIEWPORT_SIZE:-1280,720}" \
    --image-responses omit --ignore-https-errors \
    --user-data-dir /app/browser-data/sessions \
    --output-dir /screenshots
EOF

RUN chmod +x /app/start-with-vnc.sh

USER 1000
WORKDIR /app

EXPOSE 8831 5900 6080

ENV DEBUG=pw:browser,pw:network,pw:page

ENTRYPOINT ["/app/start-with-vnc.sh"]