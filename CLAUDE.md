# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Coder template that provisions AI-powered development workspaces based on Ubuntu 22.04 LTS. It includes Claude Code, Chrome DevTools MCP, GitHub MCP, Context7 MCP, and Code Canvas for visual code exploration. The template creates containerized workspaces with automated GitHub authentication and persistent storage.

## Essential Commands

### Template Deployment
```bash
# Deploy template to Coder instance (requires VPN/local network access)
coder templates push bufo-ide-template --directory . --yes

# Create a test workspace
coder create test-workspace --template bufo-ide-template

# Update an existing workspace to latest template
coder update <workspace-name> --template bufo-ide-template
```

### Local Development & Validation
```bash
# Validate Terraform configuration (do this before deploying)
terraform fmt && terraform validate

# Note: Docker build testing locally doesn't work reliably
# The image is built by Coder during template push/workspace creation
# The best way to test is by creating a test workspace (see Testing Workflow below)
```

### Testing Workflow
```bash
# 1. Make changes to template
vim main.tf  # or build/Dockerfile

# 2. Validate Terraform locally first
terraform fmt && terraform validate

# 3. Deploy to Coder (this builds the Docker image on Coder host)
coder templates push bufo-ide-template --directory . --yes

# 4. Create test workspace to verify changes
coder create test-workspace --template bufo-ide-template

# 5. Verify functionality in test workspace
coder ssh test-workspace
# Check: GitHub auth, Claude Code, MCP servers, extensions, startup script

# 6. Delete test workspace when done
coder delete test-workspace

# 7. If changes work, push to Git
git add . && git commit -m "Update template" && git push origin main
```

**Important**: The Docker build happens on the Coder host during template deployment, not locally. Testing requires deploying to Coder and creating a test workspace.

### Accessing Coder
```bash
# Login to Coder instance
coder login https://coder.bufothefrog.com

# SSH into a workspace
coder ssh <workspace-name>

# View workspace logs
coder logs <workspace-name>
```

## Architecture

### Terraform Structure

The template is defined in [main.tf](main.tf) with this architecture:

1. **Docker volumes** (persistent storage):
   - `coder-{workspace-id}-home` - Per-workspace home directory (isolated)
   - `coder-claude-{user-id}` - Shared Claude credentials across all user workspaces

2. **Docker image** (`docker_image.workspace`):
   - Built from [build/Dockerfile](build/Dockerfile)
   - Based on Ubuntu 22.04 LTS
   - Includes: Node.js 20.x, Chrome, Claude Code CLI, git, vim, gcc, make, jq, tree
   - Uses `no_cache = true` to force rebuilds when needed
   - Build triggers on Dockerfile changes via SHA hash

3. **Docker container** (`docker_container.workspace`):
   - Only runs when workspace is started (`count = data.coder_workspace.me.start_count`)
   - Mounts both home volume and shared Claude credentials volume
   - Injects `GITHUB_TOKEN` environment variable from Coder OAuth

4. **Coder agent** (`coder_agent.main`):
   - Configures git credentials with GitHub OAuth token
   - Runs startup script that:
     - Sets up git credential helper
     - Configures MCP servers (Chrome DevTools, GitHub, Context7)
     - Creates Claude Code global permissions at `~/.claude/settings.json`
     - Generates `~/WELCOME.md` guide
     - Ensures project directory exists

5. **Registry modules**:
   - `git-clone` - Auto-clones repository if `repo_url` parameter provided
   - `code-server` - Installs VS Code in browser with extensions and settings

### Volume Architecture

**Per-User Shared Volume** (authentication persists across workspaces):
```
coder-claude-{user-id}/ → /home/coder/.claude
  ├── settings.json        # Global permissions config
  ├── credentials.json     # Claude auth tokens
  └── session.json         # Session data
```

**Per-Workspace Volume** (isolated data):
```
coder-{workspace-id}-home/ → /home/coder
  └── <all workspace files and projects>
```

This design means users authenticate to Claude once and it works in all their workspaces.

### MCP Server Configuration

MCP servers are configured in the startup script ([main.tf:209-234](main.tf#L209-L234)) by writing to:
- `~/.config/Code/User/globalStorage/anthropic.claude-code/mcp_config.json`
- `~/.config/VSCodium/User/globalStorage/anthropic.claude-code/mcp_config.json`
- `~/.config/Code - OSS/User/globalStorage/anthropic.claude-code/mcp_config.json`

**Active MCP servers**:
1. **chrome-devtools**: `chrome-devtools-mcp@latest` - Browser automation via Chrome DevTools Protocol
2. **github**: `@github/github-mcp-server` - GitHub API access using `$GITHUB_TOKEN` from Coder OAuth
3. **context7**: `@upwired/context7` - Enhanced context management for codebases

All use `npx -y` for zero-install execution.

### Build System

[build/Dockerfile](build/Dockerfile) uses a single-stage Ubuntu 22.04 LTS build:
- Base: `ubuntu:22.04`
- Package manager: `apt-get` (more reliable than Rocky Linux's DNF)
- Chrome: Installed via official Google APT repository
- Node.js: From NodeSource APT repository (v20.x)
- Claude Code CLI: Installed with 3 retry attempts for reliability
- User: `coder` with passwordless sudo
- Build version: `v2.2` (env var used to force rebuilds)

**Key Dockerfile principle**: Combine RUN commands and clean package manager caches in same layer to reduce image size.

### GitHub Authentication Flow

1. Coder provides GitHub OAuth via `data.coder_external_auth.github`
2. Access token exported as `GITHUB_TOKEN` environment variable ([main.tf:191](main.tf#L191))
3. Git credential helper configured to use token ([main.tf:205](main.tf#L205)):
   ```bash
   git config --global credential.helper '!f() { echo "username=oauth2"; echo "password=$GITHUB_TOKEN"; }; f'
   ```
4. GitHub MCP server reads same `$GITHUB_TOKEN` environment variable ([main.tf:222-224](main.tf#L222-L224))

This provides seamless authentication for both git operations and Claude Code's GitHub integration.

## Template Parameters

When creating workspaces, users can specify:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `repo_url` | string | `""` | GitHub repository URL to auto-clone (empty = manual clone) |
| `repo_dest` | string | `"/home/coder/project"` | Destination path for cloned repository |
| `cpu` | number | `4` | CPU cores (1-16, adjustable in UI) |
| `memory_mb` | number | `8192` | Memory in MB (2048-32768, adjustable in UI) |

The `folder` parameter in the code-server module ([main.tf:474](main.tf#L474)) ensures VS Code opens at `repo_dest` by default.

## Common Modifications

### Adding VS Code Extensions

Edit [main.tf:477-481](main.tf#L477-L481):
```hcl
extensions = [
  "yzhang.markdown-all-in-one",
  "Anthropic.claude-code",
  "alex-c.code-canvas-app",
  "your-extension-id"  # Must be from Open VSX Registry
]
```

### Adding System Packages

Edit [build/Dockerfile](build/Dockerfile) RUN commands:
```dockerfile
RUN apt-get update && \
    apt-get install -y python3 python3-pip your-package && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### Adding MCP Servers

Edit the startup script in [main.tf:212-232](main.tf#L212-L232) to add to `mcpServers` object:
```json
"your-mcp": {
  "command": "npx",
  "args": ["-y", "your-package"],
  "env": {
    "API_KEY": "$YOUR_ENV_VAR"
  }
}
```

### Changing Default Resources

Edit variables in [main.tf:57-75](main.tf#L57-L75):
```hcl
variable "cpu" {
  default = 8  # Change default CPU
}

variable "memory_mb" {
  default = 16384  # Change default memory
}
```

### Modifying Privacy Settings

VS Code privacy settings configured in [main.tf:492-498](main.tf#L492-L498). These disable telemetry, experiments, and automatic updates.

## Important Notes

### Claude Code Permissions
Global permissions are pre-configured at `~/.claude/settings.json` ([main.tf:244-273](main.tf#L244-L273)) to allow all standard tools without prompts. This file is only created if it doesn't exist, preserving user customizations across workspace rebuilds.

### Shared Credentials Volume
The `docker_volume.claude_credentials` ([main.tf:98-114](main.tf#L98-L114)) is shared across all workspaces for a single user (keyed by `data.coder_workspace_owner.me.id`). This means:
- Authenticate to Claude once, use everywhere
- Credentials persist even when workspaces are deleted/rebuilt
- Each user has their own isolated credentials volume

### Template Caching
Docker images are cached per workspace ID via `name = "coder-${data.coder_workspace.me.id}"`. The `triggers` block forces rebuilds when Dockerfile contents change. Set `no_cache = true` ([main.tf:122](main.tf#L122)) to prevent stale Docker layer issues.

### GitHub OAuth Requirement
The template requires Coder to be configured with GitHub OAuth (`CODER_EXTERNAL_AUTH_0_TYPE=github`). Without it, the `GITHUB_TOKEN` will be empty and git operations will fail.

### VSCodium Compatibility
The startup script creates MCP configurations for multiple editor paths to support code-server, VSCodium, and VS Code desktop installations.

## Migration from Rocky Linux
Version 2.0.0 switched from Rocky Linux to Ubuntu 22.04 LTS for better repository reliability. See [CHANGELOG.md](CHANGELOG.md) for details. Workspaces update safely via `coder update <workspace-name>` - home volumes are preserved.

## Deployment Context

- **Coder Instance**: `https://coder.bufothefrog.com` (private, requires VPN/local network)
- **Docker Host**: Template provisions workspaces as Docker containers on the Coder host
- **Storage**: Home volumes stored at `/mnt/ssd-cluster/data/coder/home` on host
- **Database**: PostgreSQL 17 storing Coder state

See [DEPLOYMENT.md](DEPLOYMENT.md) for comprehensive infrastructure details and troubleshooting.
