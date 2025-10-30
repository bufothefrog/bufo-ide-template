# Deployment & Technical Reference

Comprehensive technical documentation for the Bufo IDE Template, including infrastructure details, deployment procedures, and advanced configuration.

## Infrastructure

### Coder Instance

**URL**: `https://coder.bufothefrog.com`
**Access**: Private (VPN/local network only)
**Host**: `192.168.1.16:7080`

**Docker Compose Stack**:
```yaml
coder:
  image: ghcr.io/coder/coder:v2.27.0
  environment:
    CODER_ACCESS_URL: https://coder.bufothefrog.com
    CODER_EXTERNAL_AUTH_0_ID: github
    CODER_EXTERNAL_AUTH_0_TYPE: github
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - /mnt/ssd-cluster/data/coder/home:/home/coder

database:
  image: postgres:17
  volumes:
    - /mnt/ssd-cluster/data/coder/postgres:/var/lib/postgresql/data
```

**Persistent Storage**:
- Home directories: `/mnt/ssd-cluster/data/coder/home`
- Database: `/mnt/ssd-cluster/data/coder/postgres`
- Per-workspace volumes: `coder-{workspace-id}-home`

### Template Configuration

**Name**: `bufo-ide-template`
**Display Name**: Bufo IDE Template (Ubuntu 22.04)
**Icon**: 🐸 (frog emoji)

**Default Resources**:
- CPU: 4 cores (adjustable 1-16)
- Memory: 8192 MB / 8 GB (adjustable 2-32 GB)

**Base Image**: Ubuntu 22.04 LTS
- Built from `build/Dockerfile`
- Cached per workspace ID
- Rebuilds on Dockerfile changes via `BUILD_VERSION` env var
- Uses APT package manager for reliability

## Editor Configuration

### code-server (Primary)

**Version**: Latest from Coder registry module
**Access**: Browser-based VS Code
**Extensions Source**: Open VSX Registry

**Pre-installed Extensions**:
- `yzhang.markdown-all-in-one` - Markdown editing
- `Anthropic.claude-code` - Claude AI assistant
- `alex-c.code-canvas-app` - Visual code exploration

**Settings**:
```json
{
  "window.autoDetectColorScheme": true,
  "workbench.preferredLightColorTheme": "Default Light Modern",
  "workbench.preferredDarkColorTheme": "Default Dark Modern",
  "editor.minimap.enabled": false,
  "workbench.startupEditor": "none",
  "keyboard.dispatch": "keyCode"
}
```

### VSCodium Compatibility

MCP configuration is automatically created for all these paths:
- `~/.config/Code/User/globalStorage/anthropic.claude-code/`
- `~/.config/VSCodium/User/globalStorage/anthropic.claude-code/`
- `~/.config/Code - OSS/User/globalStorage/anthropic.claude-code/`

This ensures Claude Code works whether users access via:
- Browser (code-server with VS Code)
- Local VSCodium installation
- VS Code desktop

### Global Permissions Configuration

Claude Code permissions are automatically configured globally at `~/.claude/settings.json` with full access to all tools:

**Allowed Tools**:
- `Bash` - All shell commands
- `Read`, `Edit`, `Write` - File operations
- `Grep`, `Glob` - Search and pattern matching
- `WebSearch`, `WebFetch` - Web access
- `Task` - Agent spawning
- `NotebookEdit` - Jupyter notebooks
- `SlashCommand`, `Skill` - Custom commands and skills
- `KillShell`, `BashOutput` - Background process management
- `TodoWrite`, `ExitPlanMode` - Planning tools

**Configuration** (`main.tf:204-233`):
```json
{
  "permissions": {
    "allow": [
      "Bash", "Read", "Edit", "Write", "Grep", "Glob",
      "WebSearch", "WebFetch", "Task", "NotebookEdit",
      "SlashCommand", "KillShell", "BashOutput", "Skill",
      "TodoWrite", "ExitPlanMode"
    ],
    "deny": [],
    "ask": []
  }
}
```

This global configuration applies to both the Claude Code CLI and VSCode extension, eliminating permission prompts for standard operations.

## MCP Servers

### Chrome DevTools MCP

**Package**: `chrome-devtools-mcp@latest`
**Installation**: Automatic via npx

**Capabilities**:
- Navigate and interact with web pages
- Inspect DOM elements
- Monitor network requests
- Debug JavaScript
- Take screenshots
- Extract data

**Configuration** (`main.tf:188-191`):
```json
{
  "command": "npx",
  "args": ["-y", "chrome-devtools-mcp@latest"]
}
```

### GitHub MCP

**Package**: `@github/github-mcp-server`
**Authentication**: Coder OAuth token (automatic)

**Capabilities**:
- Browse and search repositories
- Create and manage issues
- Create and review pull requests
- Monitor GitHub Actions workflows
- Analyze security findings
- Access discussions and notifications

**Configuration** (`main.tf:193-199`):
```json
{
  "command": "npx",
  "args": ["-y", "@github/github-mcp-server"],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "$GITHUB_TOKEN"
  }
}
```

### Adding Custom MCP Servers

Edit the startup script in `main.tf` (lines 181-234):

```bash
cat > ~/.config/Code/User/globalStorage/anthropic.claude-code/mcp_config.json << 'MCP_EOF'
{
  "mcpServers": {
    "chrome-devtools": { ... },
    "github": { ... },
    "your-custom-mcp": {
      "command": "npx",
      "args": ["-y", "your-mcp-package"],
      "env": {
        "API_KEY": "$YOUR_ENV_VAR"
      }
    }
  }
}
MCP_EOF
```

## Deployment Workflow

### Pre-commit Hooks (Local Validation)

**Configuration**: `.pre-commit-config.yaml`

**Hooks Enabled**:

1. **Terraform** (`antonbabenko/pre-commit-terraform`)
   - `terraform_fmt` - Format files to canonical style
   - `terraform_validate` - Validate configuration
   - `terraform_docs` - Generate documentation

2. **Dockerfile** (`hadolint/hadolint`)
   - Lint Dockerfile for best practices
   - Ignores DNF-specific rules (DL3008, DL3018)

3. **General** (`pre-commit/pre-commit-hooks`)
   - Trim trailing whitespace
   - Fix end of files
   - Check YAML syntax
   - Check for large files (>1MB)
   - Check for merge conflicts
   - Normalize line endings

4. **Shell Scripts** (`shellcheck-py/shellcheck-py`)
   - Validate shell script syntax
   - Check for common errors

5. **Custom Coder Checks** (local hooks)
   - Verify Coder provider exists
   - Test Docker build
   - Check for TODO markers (warning only)

**Setup**:
```bash
./setup-hooks.sh  # One-time setup
```

**Usage**:
```bash
# Automatic on commit
git commit -m "message"

# Manual run
pre-commit run --all-files

# Update hooks
pre-commit autoupdate

# Skip (emergency only)
git commit --no-verify -m "message"
```

### Manual Deployment

**Required**: VPN or local network access to `coder.bufothefrog.com`

**Process**:
```bash
# 1. Login (if not already)
coder login https://coder.bufothefrog.com

# 2. Push template
coder templates push bufo-ide-template --directory . --yes

# 3. Verify deployment
coder templates list | grep bufo-ide-template
```

**What Happens**:
1. Template files uploaded to Coder
2. Terraform plan executed
3. Template version created
4. Existing workspaces continue running
5. New workspaces use new template
6. Workspace rebuilds apply updates

### Optional CI Validation

**File**: `.github/workflows/validate.yml`
**Trigger**: Push or PR to `main`

**Checks**:
- Terraform format (`terraform fmt -check`)
- Terraform validation (`terraform validate`)
- Dockerfile build test
- Required provider check
- Syntax checks

**Note**: This workflow validates but does NOT deploy (Coder instance is private).

## Workspace Lifecycle

### Creation Process

1. **User initiates**:
   ```bash
   coder create my-workspace --template bufo-ide-template
   ```

2. **Parameters prompted**:
   - `repo_url`: GitHub repository to clone (optional)
   - `repo_dest`: Clone destination (default `/home/coder/project`)

3. **Provisioning**:
   - Docker volume created: `coder-{workspace-id}-home`
   - Image built from `build/Dockerfile` (cached if unchanged)
   - Container started with resource limits
   - Coder agent installed and connected

4. **Startup script execution** (`main.tf:167-348`):
   ```bash
   # Git configuration
   git config --global user.name "..."
   git config --global user.email "..."
   git config --global credential.helper '!f() { ... }; f'

   # MCP server configuration
   for config_dir in ~/.config/{Code,VSCodium,Code\ -\ OSS}; do
     # Create mcp_config.json
   done

   # Welcome guide creation
   cat > ~/WELCOME.md << EOF
   # Welcome message
   EOF

   # Repository clone (if specified)
   git clone $repo_url $repo_dest
   ```

5. **Access available**:
   - code-server: `https://coder.bufothefrog.com/workspaces/{name}/apps/code-server`
   - Terminal: `coder ssh my-workspace`
   - Port forwarding: Automatic via Coder

### Workspace States

- **Starting**: Provisioning resources
- **Running**: Active and accessible
- **Stopped**: Paused, data persists in volume
- **Failed**: Build error, check logs

### Updating Workspaces

**Option 1**: Automatic on rebuild
```bash
coder stop my-workspace
coder start my-workspace  # Uses latest template
```

**Option 2**: Manual update
```bash
coder update my-workspace --template bufo-ide-template
```

## Advanced Customization

### Modifying Startup Script

The startup script in `main.tf` runs on every workspace start. Use it for:
- Installing user-specific tools
- Configuring development environments
- Cloning repositories
- Setting up credentials

**Example** - Add Python environment:
```hcl
startup_script = <<-EOT
  # ... existing script ...

  # Setup Python virtual environment
  python3 -m venv ~/venv
  source ~/venv/bin/activate
  pip install -r ~/requirements.txt
EOT
```

### Custom Dockerfile Patterns

**Add Language Runtimes**:
```dockerfile
# Python
RUN dnf install -y python3 python3-pip && dnf clean all

# Go
RUN wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz && \
    rm go1.21.0.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin
```

**Add Development Tools**:
```dockerfile
# Kubernetes tools
RUN curl -LO https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose
```

### Resource Tuning

Edit `main.tf` variables:

```hcl
variable "cpu" {
  type        = number
  default     = 8  # Increase for heavy workloads
  description = "CPU cores allocated to workspace"
  validation {
    condition     = var.cpu >= 1 && var.cpu <= 16
    error_message = "CPU must be between 1 and 16 cores"
  }
}

variable "memory_mb" {
  type        = number
  default     = 16384  # Increase for memory-intensive tasks
  description = "Memory (MB) allocated to workspace"
  validation {
    condition     = var.memory_mb >= 2048 && var.memory_mb <= 32768
    error_message = "Memory must be between 2048 MB and 32768 MB"
  }
}
```

## Troubleshooting

### Template Issues

#### Template push fails with authentication error
```bash
# Check login status
coder login https://coder.bufothefrog.com

# List tokens
coder tokens ls

# Create new token
coder tokens create --lifetime 720h
```

#### Template push fails with network error
```bash
# Verify connectivity (VPN/local network required)
ping coder.bufothefrog.com

# Check Coder is running
curl https://coder.bufothefrog.com/healthz
```

#### Terraform validation fails
```bash
# Check Terraform version
terraform version  # Should be 1.9.0+

# Format files
terraform fmt

# Initialize (no backend)
terraform init -backend=false

# Validate
terraform validate
```

### Build Issues

#### Docker build fails during template push
```bash
# Test build locally
cd build
docker build -t test .

# Check Docker daemon
docker ps

# Check disk space
df -h

# Clean Docker cache
docker system prune -a
```

#### Dockerfile linting fails
```bash
# Run hadolint locally
docker run --rm -i hadolint/hadolint < build/Dockerfile

# Fix common issues:
# - Pin package versions
# - Combine RUN commands
# - Use COPY instead of ADD
# - Add healthchecks
```

#### Image size too large
```bash
# Check layer sizes
docker history bufo-ide-template-test

# Optimization tips:
# - Use multi-stage builds
# - Clean package managers: dnf clean all
# - Remove unnecessary files
# - Combine RUN commands to reduce layers
```

### Workspace Issues

#### Workspace fails to start
```bash
# View build logs in Coder UI
coder logs my-workspace

# Common issues:
# - Dockerfile syntax error
# - Missing base image
# - Resource limits exceeded
# - Volume mount failure
```

#### GitHub authentication not working
```bash
# Check in workspace
echo $GITHUB_TOKEN  # Should output token

# Verify Coder OAuth
# Settings → External Authentication → GitHub → Authenticated

# Re-authenticate if needed
# Coder UI → Profile → External Auth → GitHub → Connect
```

#### Extensions not installing
```bash
# Check code-server logs
cat ~/.local/share/code-server/logs/*.log

# Verify Open VSX access
curl https://open-vsx.org/api/yzhang/markdown-all-in-one

# Manual install
code-server --install-extension yzhang.markdown-all-in-one
```

#### MCP servers not appearing in Claude Code
```bash
# Check MCP config exists
cat ~/.config/Code/User/globalStorage/anthropic.claude-code/mcp_config.json

# Verify npx works
npx -y chrome-devtools-mcp@latest --version

# Check Claude Code extension installed
code-server --list-extensions | grep anthropic.claude-code

# Reload window
# Command Palette → Developer: Reload Window
```

#### Performance issues
```bash
# Check resource usage
docker stats coder-{user}-{workspace}

# Increase resources in template
# Edit main.tf variables (cpu, memory_mb)

# Check disk I/O
iostat -x 1

# Optimize workspace
# - Close unused applications
# - Disable unnecessary extensions
# - Reduce concurrent builds
```

### Pre-commit Hook Issues

#### Hooks fail on first run
```bash
# Normal - dependencies downloading
# Run again
pre-commit run --all-files
```

#### Docker build hook fails
```bash
# Check Docker is running
docker ps

# Test build manually
cd build && docker build -t test .

# Skip Docker hook temporarily
SKIP=check-docker-build git commit -m "message"
```

#### Hooks are slow
```bash
# Skip specific slow hooks
SKIP=terraform_validate,check-docker-build git commit -m "message"

# Or disable in .pre-commit-config.yaml
# Comment out slow hooks
```

#### Can't install pre-commit
```bash
# Check Python/pip
python3 --version
pip3 --version

# Install pip if missing (Ubuntu)
sudo apt-get update && sudo apt-get install -y python3-pip

# Install pre-commit
pip3 install --user pre-commit

# Add to PATH
export PATH=$PATH:~/.local/bin
```

## Technical Notes

### Ubuntu 22.04 LTS Benefits

- **APT reliability**: Excellent mirror availability worldwide
- **LTS support**: Supported until 2027 with security updates
- **Package availability**: Vast ecosystem of .deb packages
- **Chrome integration**: Native .deb repository support

### Security

- **GitHub token**: Injected as env var, not stored in image
- **Credential helper**: Uses ephemeral token from Coder OAuth
- **Volume isolation**: Each workspace has dedicated volume
- **Network isolation**: Workspaces can be network-isolated if needed

### Performance

- **Image caching**: Docker images cached per workspace ID
- **Volume persistence**: Data persists across workspace rebuilds
- **Build optimization**: Multi-RUN commands combined to reduce layers
- **No Puppeteer**: Saves ~500MB, install if needed: `npm install -g puppeteer`

### Compatibility

- **VS Code extensions**: Must be on Open VSX Registry
- **MCP servers**: Any npm package with Claude Code MCP protocol
- **Git operations**: Work transparently with GitHub OAuth token
- **Browser access**: Chrome DevTools Protocol via MCP

## Additional Resources

- [Coder Template Documentation](https://coder.com/docs/templates)
- [Claude Code MCP Documentation](https://docs.anthropic.com/claude-code/mcp)
- [Open VSX Registry](https://open-vsx.org/)
- [Pre-commit Framework](https://pre-commit.com/)
- [Ubuntu Documentation](https://help.ubuntu.com/)
