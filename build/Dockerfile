# Ubuntu 22.04 LTS - stable and widely supported with excellent repository reliability
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    CHROME_BIN=/usr/bin/google-chrome-stable \
    BUILD_VERSION=v2

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
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Google Chrome via APT
RUN curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x from NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Note: Browser automation is handled by Chrome DevTools MCP via Claude Code extension
# Puppeteer/Playwright are NOT installed to reduce image size (~500MB savings)
# If users need them for custom scripts, they can install via: npm install -g puppeteer
# Claude Code CLI (@anthropic/claude-code) can be installed manually if needed: npm install -g @anthropic/claude-code

# Verify installations
RUN google-chrome-stable --version --no-sandbox 2>/dev/null || \
    echo "Chrome installed (version check requires display)" && \
    node --version && \
    npm --version

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
