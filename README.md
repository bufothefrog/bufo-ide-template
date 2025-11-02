# Bufo IDE Template for Coder (Ubuntu 22.04 LTS)

AI-powered development workspaces with Claude Code, Chrome DevTools MCP, and GitHub integration. Built on Ubuntu 22.04 LTS for maximum stability and reliability. Includes code-server, automated validation, and seamless GitHub authentication.

## Features

- **Ubuntu 22.04 LTS** with modern tooling (`git`, `vim`, `jq`, `tree`, `gcc`, `make`)
- **code-server** (VS Code in browser) with VSCodium compatibility
- **Claude Code CLI** (`claude` command) for terminal AI assistance
- **Shared Claude credentials** - Authenticate once, use in all workspaces! 🎉
- **Default workspace folder** - VS Code opens at your project location automatically
- **Privacy-focused defaults** - Microsoft telemetry and experiments disabled
- **Global permissions** pre-configured for seamless Claude Code operation
- **Pre-configured MCP servers**: Chrome DevTools, GitHub & Context7
- **Code Canvas** for visual code exploration
- **Automatic GitHub authentication** via Coder OAuth (HTTPS)
- **Auto-generated SSH keys** for secure git operations (persists across rebuilds)
- **Git auto-fetch** - automatically fetches updates every 60 seconds
- **Persistent home volumes** per workspace

## Quick Start

### Prerequisites

- Coder instance with GitHub OAuth configured
- [Coder CLI](https://coder.com/docs/install) installed locally

### Setup (One-Time)

```bash
# 1. Clone repository
git clone <your-repo-url>
cd bufo-ide-template

# 2. Login to Coder
coder login https://coder.bufothefrog.com
```

### Daily Workflow

```bash
# 1. Make changes
vim main.tf

# 2. Commit changes
git add .
git commit -m "Update template"

# 3. Deploy to Coder
coder templates push bufo-ide-template --directory . --yes

# 4. Test
coder create test-workspace --template bufo-ide-template

# 5. Push to GitHub
git push origin main
```

## Quick Commands

```bash
# Deploy template to Coder
coder templates push bufo-ide-template --directory . --yes

# Test Docker build
cd build && docker build -t test .

# Validate Terraform
terraform fmt && terraform validate
```

## Common Tasks

### Modify Resources

Edit default CPU/memory in `main.tf`:

```hcl
variable "cpu" {
  default = 4  # Change default CPU cores
}

variable "memory_mb" {
  default = 8192  # Change default memory (MB)
}
```

### Add Extensions

Edit `main.tf` (extensions from [Open VSX Registry](https://open-vsx.org/)):

```hcl
extensions = [
  "yzhang.markdown-all-in-one",
  "Anthropic.claude-code",
  "alex-c.code-canvas-app",
  "your-extension-id"
]
```

### Add System Packages

Edit `build/Dockerfile`:

```dockerfile
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

## Troubleshooting

### Docker build fails
```bash
docker ps  # Check Docker is running
cd build && docker build -t test .
```

### Can't reach Coder
```bash
# Ensure VPN/local network access
ping coder.bufothefrog.com
coder login https://coder.bufothefrog.com
```

### Terraform validation fails
```bash
terraform version  # Check installed
terraform fmt      # Auto-fix formatting
```

**More issues?** See [CLAUDE.md](CLAUDE.md#troubleshooting) for comprehensive troubleshooting.

## SSH Key Setup (One-Time)

SSH keys are auto-generated when you create a workspace and persist in your home volume.

**To enable SSH git operations:**

1. View your public key in the workspace:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```

2. Add to GitHub: https://github.com/settings/ssh/new

3. Convert your git remotes to SSH:
   ```bash
   git remote set-url origin git@github.com:user/repo.git
   ```

**Benefits:**
- More secure than HTTPS
- No password prompts
- SSH keys persist across workspace rebuilds

## Advanced Configuration

For detailed technical information, see [CLAUDE.md](CLAUDE.md):
- **Architecture overview** → [CLAUDE.md](CLAUDE.md#architecture)
- **MCP server configuration** → [CLAUDE.md](CLAUDE.md#mcp-server-configuration)
- **Common modifications** → [CLAUDE.md](CLAUDE.md#common-modifications)
- **Troubleshooting** → [CLAUDE.md](CLAUDE.md#troubleshooting)

## Template Variables

When creating a workspace:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `repo_url` | GitHub repository to auto-clone | Empty (manual clone) |
| `repo_dest` | Clone destination path | `/home/coder/project` |

## Migrating from Rocky Linux?

See [MIGRATION.md](MIGRATION.md) for comprehensive migration guide.

**TL;DR:** Just run `coder update <workspace-name>` - your data is safe!

## Resources

- [Coder Documentation](https://coder.com/docs)
- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [Chrome DevTools MCP](https://github.com/snaggle-ai/chrome-devtools-mcp)
- [GitHub MCP](https://github.com/github/github-mcp-server)
- [Migration Guide](MIGRATION.md)
