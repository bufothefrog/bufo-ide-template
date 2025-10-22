# Recent Changes

## Package Additions

### System Packages (Dockerfile)
- Added `tree` command for directory visualization
- Already includes: `git`, `vim`, `jq`, `curl`, `wget`, `gcc`, `make`, etc.

### Node.js Global Packages (Dockerfile)
- Added `@anthropic/claude-code` - Claude Code CLI for terminal usage
  - Provides the `claude` command in terminal
  - Same functionality as VS Code extension but in CLI
  - Pre-authenticated when using workspace
  - Can run commands like: `claude "help me debug this code"`

## VSCodium Compatibility

### MCP Configuration (main.tf)
MCP servers are now configured for multiple editor paths:
- `~/.config/Code/` (VS Code)
- `~/.config/VSCodium/` (VSCodium)
- `~/.config/Code - OSS/` (Open Source builds)

### Extensions
All extensions are pulled from **Open VSX Registry** (not Microsoft Marketplace):
- Compatible with both VS Code and VSCodium
- Pre-installed extensions:
  - `yzhang.markdown-all-in-one`
  - `Anthropic.claude-code`
  - `alex-c.code-canvas-app`

## Automated CI/CD

### Validation Workflow (`.github/workflows/validate.yml`)
Runs on every push and pull request:
- Terraform format check (`terraform fmt -check`)
- Terraform validation (`terraform validate`)
- Dockerfile build test
- Best practices verification

### Deployment Workflow (`.github/workflows/deploy.yml`)
Automatically deploys to `https://coder.bufothefrog.com` on push to `main`:
- Installs Coder CLI
- Authenticates with Coder instance
- Pushes template using `coder templates push`
- Reports deployment status
- Can also be triggered manually via GitHub Actions UI

## Documentation

### README.md
- Clarified automated CI/CD workflow
- Added Claude Code CLI documentation
- Added VSCodium compatibility notes
- Updated with your Coder instance URL
- Token generation instructions

### DEPLOYMENT.md (New)
Technical documentation including:
- Infrastructure details (Docker Compose, PostgreSQL)
- MCP server configuration
- Deployment process details
- Troubleshooting guide

## Required GitHub Secrets

To enable automated deployment, add these secrets to your GitHub repository:

```
CODER_URL = https://coder.bufothefrog.com
CODER_SESSION_TOKEN = <your-token>
```

Generate token with:
```bash
coder login https://coder.bufothefrog.com
coder tokens create --lifetime 720h
```

## Next Steps

1. Commit and push to GitHub:
   ```bash
   git add .
   git commit -m "Add tree, Claude CLI, VSCodium support, and CI/CD"
   git push origin main
   ```

2. Add GitHub Secrets (see above)

3. Test the workflow by making a small change and pushing to `main`

## Usage Examples

### Claude Code CLI in Terminal
```bash
# Ask Claude a question
claude "explain this bash script"

# Get help with debugging
claude "why is my Node.js app crashing?"

# Generate code
claude "write a Python script to parse JSON"
```

### MCP Servers
The GitHub and Chrome DevTools MCP servers will be automatically available in:
- VS Code extension (if using code-server with VS Code)
- VSCodium (if using locally)
- Claude Code CLI (terminal usage)

### Tree Command
```bash
# Visualize directory structure
tree -L 2

# Show hidden files
tree -a

# Show only directories
tree -d
```
