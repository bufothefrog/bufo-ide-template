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

## Pre-commit Hooks

### Configuration (`.pre-commit-config.yaml`)
Local validation hooks that run before each commit:
- **Terraform**: Format check, validation, docs generation
- **Dockerfile**: Linting with hadolint, build test
- **Shell scripts**: Validation with shellcheck
- **General**: YAML syntax, trailing whitespace, line endings
- **Coder-specific**: Provider check, template requirements

### Setup Script (`setup-hooks.sh`)
One-time setup that:
- Installs pre-commit framework (via pip)
- Configures git hooks
- Tests validation on existing files
- Provides usage instructions

### Optional CI (`.github/workflows/validate.yml`)
Optional GitHub Actions workflow for team validation:
- Runs same checks as pre-commit hooks
- Useful for PR reviews
- Not required since validation happens locally

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

## Deployment Model

This template uses **local validation + manual deployment**:

1. **Pre-commit hooks** validate changes before commit
2. **Manual deployment** to Coder instance (VPN/local network required):
   ```bash
   coder login https://coder.bufothefrog.com
   coder templates push bufo-template --directory . --yes
   ```
3. **Optional CI validation** via GitHub Actions (doesn't deploy)

**Why manual deployment?** The Coder instance at `https://coder.bufothefrog.com` is private (VPN/local network only), so GitHub Actions cannot reach it for automated deployment.

## Next Steps

1. **Setup pre-commit hooks** (one-time):
   ```bash
   ./setup-hooks.sh
   ```

2. **Commit and push to GitHub**:
   ```bash
   git add .
   git commit -m "Add tree, Claude CLI, VSCodium support, and pre-commit hooks"
   git push origin main
   ```

3. **Test the workflow** by making a small change:
   ```bash
   # Edit a file
   vim main.tf

   # Commit (hooks run automatically)
   git add main.tf
   git commit -m "Test change"

   # Deploy to Coder
   coder templates push bufo-template --directory . --yes
   ```

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
