# Bufo IDE Template for Coder

AI-powered development workspaces with Claude Code, Chrome DevTools MCP, and GitHub integration. Pre-configured with Rocky Linux 10, code-server, and automated validation.

## Features

- **Rocky Linux 10** with modern tooling (`git`, `vim`, `jq`, `tree`, `gcc`, `make`)
- **code-server** (VS Code in browser) with VSCodium compatibility
- **Claude Code CLI** (`claude` command) for terminal AI assistance
- **Pre-configured MCP servers**: Chrome DevTools & GitHub
- **Code Canvas** for visual code exploration
- **Automatic GitHub authentication** via Coder OAuth
- **Persistent home volumes** per workspace
- **Pre-commit hooks** for local validation

## Quick Start

### Prerequisites

- Coder instance with GitHub OAuth configured
- [Coder CLI](https://coder.com/docs/install) installed locally
- Python 3, Docker, and Terraform (for validation)

### Setup (One-Time)

```bash
# 1. Clone and setup
git clone <your-repo-url>
cd bufo-ide-template
./setup-hooks.sh

# 2. Login to Coder
coder login https://coder.bufothefrog.com
```

### Daily Workflow

```bash
# 1. Make changes
vim main.tf

# 2. Commit (hooks validate automatically)
git add .
git commit -m "Update template"

# 3. Deploy to Coder
coder templates push bufo-template --directory . --yes

# 4. Test
coder create test-workspace --template bufo-template

# 5. Push to GitHub
git push origin main
```

## What Gets Validated

Pre-commit hooks automatically check:
- ✅ Terraform formatting & validation
- ✅ Dockerfile linting (hadolint)
- ✅ Docker build success
- ✅ YAML syntax
- ✅ Shell script validation
- ✅ File hygiene (whitespace, line endings)

**Errors are caught before commit** - no broken templates!

## Quick Commands

```bash
# Run hooks manually
pre-commit run --all-files

# Update hook versions
pre-commit autoupdate

# Deploy without committing
coder templates push bufo-template --directory . --yes

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
RUN dnf install -y python3 python3-pip && \
    dnf clean all
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

## Resources

- [Coder Documentation](https://coder.com/docs)
- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [Chrome DevTools MCP](https://github.com/snaggle-ai/chrome-devtools-mcp)
- [GitHub MCP](https://github.com/github/github-mcp-server)
