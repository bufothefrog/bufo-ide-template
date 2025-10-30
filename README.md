# Bufo IDE Template for Coder (Ubuntu 22.04 LTS)

AI-powered development workspaces with Claude Code, Chrome DevTools MCP, and GitHub integration. Built on Ubuntu 22.04 LTS for maximum stability and reliability. Includes code-server, automated validation, and seamless GitHub authentication.

## Features

- **Ubuntu 22.04 LTS** with modern tooling (`git`, `vim`, `jq`, `tree`, `gcc`, `make`)
- **code-server** (VS Code in browser) with VSCodium compatibility
- **Claude Code CLI** (`claude` command) for terminal AI assistance
- **Shared Claude credentials** - Authenticate once, use in all workspaces! 🎉
- **Global permissions** pre-configured for seamless Claude Code operation
- **Pre-configured MCP servers**: Chrome DevTools, GitHub & Context7
- **Code Canvas** for visual code exploration
- **Automatic GitHub authentication** via Coder OAuth
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

**More issues?** See [DEPLOYMENT.md](DEPLOYMENT.md#troubleshooting) for comprehensive troubleshooting.

## Advanced Configuration

For detailed technical information:
- **Infrastructure details** → [DEPLOYMENT.md](DEPLOYMENT.md)
- **MCP server configuration** → [DEPLOYMENT.md](DEPLOYMENT.md#mcp-servers)
- **VSCodium compatibility** → [DEPLOYMENT.md](DEPLOYMENT.md#editor-configuration)
- **Workspace lifecycle** → [DEPLOYMENT.md](DEPLOYMENT.md#workspace-creation)

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
