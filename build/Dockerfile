# Ubuntu 22.04 LTS - stable and widely supported with excellent repository reliability
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    CHROME_BIN=/usr/bin/google-chrome-stable \
    BUILD_VERSION=v2.4

# Install core system packages using APT
# Ubuntu has more reliable repository mirrors than Rocky Linux
RUN apt-get update && \
    apt-get install -y \
        sudo \
        curl \
        wget \
        ca-certificates \
        git \
        vim \
        gnupg2 \
        unzip \
        xz-utils \
        zip \
        make \
        gcc \
        g++ \
        jq \
        tree \
        locales \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Google Chrome via APT with headless dependencies
# Using HTTPS for security
RUN curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y \
        google-chrome-stable \
        fonts-liberation \
        fonts-noto-cjk \
        fonts-noto-color-emoji \
        libx11-xcb1 \
        libxcomposite1 \
        libxdamage1 \
        libxrandr2 \
        libgbm1 \
        libdrm2 \
        libgtk-3-0 \
        libasound2 \
        libatk-bridge2.0-0 \
        libatk1.0-0 \
        libcups2 \
        libdbus-1-3 \
        libnspr4 \
        libnss3 \
        libxkbcommon0 \
        xdg-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x from NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI using native installer (recommended over npm)
# Uses temp HOME since /home/coder is volume-mounted at runtime
# Binary is copied to /usr/local/bin for system-wide access
RUN export HOME=/tmp/claude-install && \
    mkdir -p "$HOME" && \
    curl -fsSL https://claude.ai/install.sh | bash && \
    cp "$HOME/.local/bin/claude" /usr/local/bin/claude && \
    chmod 755 /usr/local/bin/claude && \
    rm -rf /tmp/claude-install

# Note: Browser automation is handled by Chrome DevTools MCP via Claude Code extension
# Puppeteer/Playwright are NOT installed to reduce image size (~500MB savings)
# If users need them for custom scripts, they can install via: npm install -g puppeteer

# Verify installations
RUN google-chrome-stable --version --no-sandbox 2>/dev/null || \
    echo "Chrome installed (version check requires display)" && \
    node --version && \
    npm --version && \
    claude --version && \
    echo "Claude Code installed via native installer"

# Create coder user with sudo privileges
RUN useradd -m -s /bin/bash coder && \
    usermod -aG sudo coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/coder && \
    chmod 0440 /etc/sudoers.d/coder

# Set working directory
WORKDIR /home/coder

# Switch to coder user for final setup
USER coder

# Default command
CMD ["/bin/bash"]
