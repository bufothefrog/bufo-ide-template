# Changelog

All notable changes to this Coder template will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-10-22

### Added
- Rocky Linux 10 base image with modern tooling
- Claude Code CLI (`@anthropic/claude-code`) for terminal AI assistance
- Chrome DevTools MCP server for browser automation
- GitHub MCP server with OAuth integration
- Code Canvas extension for visual code exploration
- `tree` command for directory visualization
- Pre-commit hooks for local validation
  - Terraform formatting and validation
  - Dockerfile linting with hadolint
  - Docker build testing
  - Shell script validation with shellcheck
  - YAML syntax checking
  - File hygiene checks
- Setup script (`setup-hooks.sh`) for one-time hook installation
- Persistent home volumes per workspace
- Automatic GitHub authentication via Coder OAuth
- Repository auto-clone on workspace creation

### Changed
- Base image to Rocky Linux 10 (from previous versions)
- Extension source to Open VSX Registry (VSCodium compatible)
- Deployment model to local validation + manual deployment
- MCP configuration to support VS Code, VSCodium, and Code-OSS paths

### Technical Details

**Infrastructure:**
- Docker Compose deployment with PostgreSQL 17 backend
- Google Chrome for browser automation (headless capable)
- Node.js 20.x with npm
- code-server (VS Code in browser)

**MCP Servers:**
- `chrome-devtools-mcp@latest` - Browser automation via DevTools Protocol
- `@github/github-mcp-server` - GitHub API access via Coder OAuth token

**Why Manual Deployment:**
The Coder instance at `https://coder.bufothefrog.com` is private (VPN/local network only),
so GitHub Actions cannot reach it for automated deployment. Pre-commit hooks provide
local validation before commit.

**VSCodium Compatibility:**
All extensions are from Open VSX Registry. MCP configuration supports multiple editor paths:
- `~/.config/Code/` (VS Code)
- `~/.config/VSCodium/` (VSCodium)
- `~/.config/Code - OSS/` (Open source builds)

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed infrastructure specifications and configuration.

---

## Usage Examples

### Claude Code CLI
```bash
claude "explain this bash script"
claude "debug my Node.js app"
claude "write a Python parser"
```

### Tree Command
```bash
tree -L 2         # Show 2 levels
tree -a           # Include hidden files
tree -d           # Directories only
```

### Pre-commit Hooks
```bash
pre-commit run --all-files    # Run manually
pre-commit autoupdate         # Update hook versions
git commit --no-verify        # Skip (not recommended)
```
