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
- **Automated CI/CD** for template validation and deployment

## Repository Structure

```
.
├── main.tf              # Terraform template configuration
├── build/
│   └── Dockerfile       # Custom workspace image definition
├── .github/
│   └── workflows/
│       ├── validate.yml # Pre-deployment validation
│       └── deploy.yml   # Automated deployment to Coder
└── README.md            # This file
```

## Quick Start

### Prerequisites

1. **Coder instance** with GitHub OAuth configured
2. **GitHub repository secrets** (for automated deployment):
   - `CODER_URL`: Your Coder instance URL (e.g., `https://coder.example.com`)
   - `CODER_SESSION_TOKEN`: Your Coder API token ([generate here](https://coder.com/docs/cli/tokens))

### Setting Up GitHub Secrets

1. Go to your repository **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add both secrets:
   - Name: `CODER_URL`, Value: `https://coder.bufothefrog.com`
   - Name: `CODER_SESSION_TOKEN`, Value: `your-token-here` (see below)

### Development Workflow

This repository is configured with **automated CI/CD** via GitHub Actions. Changes pushed to `main` are automatically validated and deployed.

#### Option 1: Automated Deployment (Recommended)

1. **Make changes** to `main.tf` or `build/Dockerfile`
2. **Commit and push** to `main` branch:
   ```bash
   git add main.tf build/Dockerfile
   git commit -m "Update template configuration"
   git push
   ```
3. **GitHub Actions automatically**:
   - ✅ Validates Terraform syntax and configuration
   - ✅ Checks Dockerfile build validity
   - ✅ Runs template best practices checks
   - ✅ Deploys to `https://coder.bufothefrog.com` if all tests pass
   - ❌ Reports errors and blocks deployment if validation fails

**No manual intervention required** - errors are caught before deployment!

#### Option 2: Manual Testing

Test locally before committing:

```bash
# Validate Terraform syntax
terraform fmt -check
terraform init -backend=false
terraform validate

# Test Docker build
cd build
docker build -t bufo-template-test .
cd ..

# Push to Coder manually
export CODER_URL="https://coder.bufothefrog.com"
coder login $CODER_URL
coder templates push bufo-template --directory . --yes
```

#### Generating a Coder API Token

To get your `CODER_SESSION_TOKEN`:

```bash
# Login to your Coder instance
coder login https://coder.bufothefrog.com

# Create a long-lived token (30 days)
coder tokens create --lifetime 720h

# Copy the token and add it to GitHub Secrets
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

## GitHub Actions Workflows

### Validation (`validate.yml`)

Runs on every push and PR to `main`:
- Terraform format check
- Terraform validation
- Dockerfile syntax check
- Template best practices verification

**Prevents broken templates from being deployed.**

### Deployment (`deploy.yml`)

Runs on push to `main` when template files change:
- Installs Coder CLI
- Authenticates with your Coder instance
- Pushes template using `coder templates push`
- Reports deployment status

Can also be triggered manually via **Actions** → **Deploy to Coder** → **Run workflow**

## Troubleshooting

### Deployment fails with authentication error

**Fix**: Verify your `CODER_SESSION_TOKEN` secret is valid:
```bash
coder login https://your-coder-instance.com
coder tokens create --lifetime 720h
```

Copy the new token to your GitHub secret.

### Validation fails on Dockerfile

**Fix**: Test Docker build locally:
```bash
cd build
docker build -t test .
```

Fix any errors, commit, and push.

### Template doesn't show in Coder

**Fix**: Check GitHub Actions logs for deployment errors. Ensure:
1. Secrets are configured correctly
2. Your Coder user has template creation permissions
3. The template name doesn't conflict with existing templates

### Workspace fails to start

**Fix**: Check the Coder workspace logs for errors. Common issues:
- Missing GitHub OAuth configuration in Coder
- Insufficient Docker resources
- Build context files missing

## Local Development

To iterate quickly without pushing to GitHub:

```bash
# Make changes to main.tf or Dockerfile
vim main.tf

# Validate
terraform fmt
terraform validate

# Push directly to Coder
export CODER_URL="https://your-coder-instance.com"
coder templates push bufo-template --directory . --yes

# Create test workspace
coder create test-workspace --template bufo-template
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
