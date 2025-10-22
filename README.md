# Bufo IDE Template for Coder

This repository contains a Coder template that provisions AI-powered development environments with Claude Code, Chrome DevTools MCP, and GitHub integration.

## Features

- **Rocky Linux 10** base image with modern tooling (`git`, `vim`, `jq`, `tree`, etc.)
- **code-server** (VS Code in browser) with VSCodium compatibility
- **Claude Code CLI** (`claude` command) pre-installed for terminal usage
- **Claude Code** with pre-configured MCP servers:
  - Chrome DevTools MCP (browser automation)
  - GitHub MCP (repository management)
- **Code Canvas** for visual code exploration
- **Automatic GitHub authentication** via Coder OAuth
- **Persistent home volumes** for workspace data
- **Customizable resources** (CPU, memory)
- **Auto-clone repositories** on workspace creation
- **Pre-commit hooks** for local validation before commits

## Repository Structure

```
.
├── main.tf                    # Terraform template configuration
├── build/
│   └── Dockerfile             # Custom workspace image definition
├── .github/
│   └── workflows/
│       └── validate.yml       # Optional CI validation
├── .pre-commit-config.yaml    # Pre-commit hooks configuration
├── setup-hooks.sh             # One-time setup script
└── README.md                  # This file
```

## Quick Start

### Prerequisites

1. **Coder instance** with GitHub OAuth configured (e.g., `https://coder.bufothefrog.com`)
2. **Coder CLI** installed locally ([install guide](https://coder.com/docs/install))
3. **Python 3** with pip (for pre-commit hooks)
4. **Docker** (for local validation)
5. **Terraform** (for template validation)

### Initial Setup

Run the setup script once to install pre-commit hooks:

```bash
./setup-hooks.sh
```

This will:
- Install the `pre-commit` tool
- Set up git hooks to validate changes before commit
- Run validation checks automatically

### Development Workflow

This repository uses **pre-commit hooks** for local validation before commits. Changes are validated locally, then deployed manually to your Coder instance.

#### Standard Workflow

1. **Make changes** to `main.tf` or `build/Dockerfile`

2. **Commit changes** (hooks run automatically):
   ```bash
   git add main.tf build/Dockerfile
   git commit -m "Update template configuration"
   ```

3. **Pre-commit hooks automatically**:
   - ✅ Format Terraform files
   - ✅ Validate Terraform configuration
   - ✅ Lint Dockerfile with hadolint
   - ✅ Test Docker build
   - ✅ Check YAML syntax
   - ✅ Validate shell scripts
   - ✅ Check for trailing whitespace and line endings
   - ❌ Block commit if any check fails

4. **Deploy to Coder** (manual):
   ```bash
   # If on VPN or local network
   coder login https://coder.bufothefrog.com
   coder templates push bufo-template --directory . --yes
   ```

5. **Push to GitHub**:
   ```bash
   git push origin main
   ```

**Errors are caught before commit** - no broken templates!

#### Skipping Hooks (Not Recommended)

If you need to commit without running hooks:

```bash
git commit --no-verify -m "Emergency fix"
```

#### Running Hooks Manually

Test all validations without committing:

```bash
pre-commit run --all-files
```

#### Updating Hooks

Keep pre-commit hooks up to date:

```bash
pre-commit autoupdate
```

## Customization

### Modifying Resources

Edit `main.tf` variables:

```hcl
variable "cpu" {
  default = 4  # Change default CPU cores
}

variable "memory_mb" {
  default = 8192  # Change default memory (MB)
}
```

### Adding Extensions (VS Code/VSCodium)

The template uses **code-server** which pulls extensions from **Open VSX Registry** (not Microsoft's marketplace). This makes it compatible with both VS Code and VSCodium.

Edit the `code_server` module in `main.tf`:

```hcl
extensions = [
  "yzhang.markdown-all-in-one",
  "Anthropic.claude-code",
  "alex-c.code-canvas-app",
  "your-extension-id"  # Add new extensions here
]
```

**Note**: Extensions must be available on [Open VSX Registry](https://open-vsx.org/). The MCP configuration automatically supports both VS Code and VSCodium config paths.

### Modifying Base Image

Edit `build/Dockerfile` to:
- Install additional packages
- Configure system settings
- Add development tools

Example:

```dockerfile
# Add Python
RUN dnf install -y python3 python3-pip && \
    dnf clean all
```

### Changing MCP Configuration

The Chrome DevTools and GitHub MCP servers are configured in `main.tf` (lines 181-197). To add more MCP servers:

```hcl
cat > ~/.config/Code/User/globalStorage/anthropic.claude-code/mcp_config.json << 'MCP_EOF'
{
  "mcpServers": {
    "chrome-devtools": { ... },
    "github": { ... },
    "your-mcp-server": {
      "command": "npx",
      "args": ["-y", "your-mcp-package"]
    }
  }
}
MCP_EOF
```

## Optional: GitHub Actions CI

The repository includes an optional GitHub Actions workflow (`.github/workflows/validate.yml`) that runs the same checks as pre-commit hooks in CI:

- Terraform format check
- Terraform validation
- Dockerfile build test
- Template best practices verification

This is useful if you want validation to run on GitHub as well, but **it's not required** since pre-commit hooks catch errors locally.

## Troubleshooting

### Pre-commit hook fails on Docker build

**Fix**: Ensure Docker is running and accessible:
```bash
docker ps
# If error, start Docker daemon
```

Test build manually:
```bash
cd build
docker build -t bufo-template-test .
```

### Pre-commit hook fails on Terraform

**Fix**: Ensure Terraform is installed:
```bash
terraform version
# If not found, install from: https://developer.hashicorp.com/terraform/downloads
```

### Template push fails

**Fix**: Ensure you're connected to your Coder instance:
```bash
# Check connection
coder login https://coder.bufothefrog.com

# Verify you can reach it (VPN/local network required)
ping coder.bufothefrog.com
```

### Pre-commit is slow

**Fix**: Hooks cache dependencies after first run. If still slow, you can disable specific hooks in `.pre-commit-config.yaml`

### Workspace fails to start

**Fix**: Check the Coder workspace logs for errors. Common issues:
- Missing GitHub OAuth configuration in Coder
- Insufficient Docker resources
- Build context files missing

## Quick Iteration

To iterate quickly on template changes:

```bash
# Make changes to main.tf or Dockerfile
vim main.tf

# Test locally (pre-commit runs same checks)
pre-commit run --all-files

# Push directly to Coder
coder login https://coder.bufothefrog.com
coder templates push bufo-template --directory . --yes

# Create test workspace
coder create test-workspace --template bufo-template

# When ready, commit and push to GitHub
git add .
git commit -m "Update template"
git push
```

## Template Variables

When creating a workspace, users can configure:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `repo_url` | GitHub repository to auto-clone | Empty (manual clone) |
| `repo_dest` | Clone destination path | `/home/coder/project` |

## Resources

- [Coder Documentation](https://coder.com/docs)
- [Coder Template Registry](https://registry.coder.com/)
- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [Chrome DevTools MCP](https://github.com/snaggle-ai/chrome-devtools-mcp)
- [GitHub MCP](https://github.com/github/github-mcp-server)

## License

This template is provided as-is for use with Coder workspaces.
