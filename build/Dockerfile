# Rocky Linux 9 base - stable LTS release with better repository support
FROM rockylinux/rockylinux:9

# Set environment variables
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    CHROME_BIN=/usr/bin/google-chrome-stable

# Install core system packages using DNF
# Using Rocky 9 for stability and reliable repository access
# Avoiding dnf update to prevent repository sync issues
RUN dnf install -y \
        sudo \
        curl \
        wget \
        ca-certificates \
        git \
        vim \
        gnupg2 \
        unzip \
        xz \
        zip \
        make \
        gcc \
        gcc-c++ \
        jq \
        tree \
    && dnf clean all && \
    rm -rf /var/cache/dnf/*

# Install Google Chrome via DNF (auto-resolves dependencies)
# Rocky 9 handles Google's GPG key more reliably
RUN curl -fsSL https://dl.google.com/linux/linux_signing_key.pub -o /tmp/linux_signing_key.pub && \
    rpm --import /tmp/linux_signing_key.pub && \
    echo "[google-chrome]" > /etc/yum.repos.d/google-chrome.repo && \
    echo "name=Google Chrome" >> /etc/yum.repos.d/google-chrome.repo && \
    echo "baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64" >> /etc/yum.repos.d/google-chrome.repo && \
    echo "enabled=1" >> /etc/yum.repos.d/google-chrome.repo && \
    echo "gpgcheck=1" >> /etc/yum.repos.d/google-chrome.repo && \
    echo "gpgkey=https://dl.google.com/linux/linux_signing_key.pub" >> /etc/yum.repos.d/google-chrome.repo && \
    dnf install -y google-chrome-stable && \
    rm -f /tmp/linux_signing_key.pub && \
    dnf clean all && \
    rm -rf /var/cache/dnf/*

# Install Node.js 20.x from NodeSource
RUN curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - && \
    dnf install -y nodejs && \
    dnf clean all && \
    rm -rf /var/cache/dnf/*

# Install Claude Code CLI globally
# This provides the 'claude' command for terminal usage
RUN npm install -g @anthropic/claude-code

# Note: Browser automation is handled by Chrome DevTools MCP via Claude Code
# Puppeteer/Playwright are NOT installed to reduce image size (~500MB savings)
# If users need them for custom scripts, they can install via: npm install -g puppeteer

# Verify installations
RUN google-chrome-stable --version --no-sandbox 2>/dev/null || \
    echo "Chrome installed (version check requires display)" && \
    node --version && \
    npm --version && \
    claude --version

# Create coder user with sudo privileges
RUN useradd -m -s /bin/bash -G wheel coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/coder && \
    chmod 0440 /etc/sudoers.d/coder

# Set working directory
WORKDIR /home/coder

# Switch to coder user for final setup
USER coder

# Default command
CMD ["/bin/bash"]
