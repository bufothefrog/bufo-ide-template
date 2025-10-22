# Deployment Information

## Coder Instance Details

**URL**: `https://coder.bufothefrog.com`

**Infrastructure**:
- Docker Compose deployment on `192.168.1.16:7080`
- PostgreSQL 17 database backend
- Persistent volumes at `/mnt/ssd-cluster/data/coder/`
  - Home directories: `/mnt/ssd-cluster/data/coder/home`
  - Database: `/mnt/ssd-cluster/data/coder/postgres`

**GitHub OAuth**:
- Configured as `CODER_EXTERNAL_AUTH_0_ID: github`
- Client credentials in environment variables
- Workspaces automatically receive `GITHUB_TOKEN` env var

## Template Configuration

**Template Name**: `bufo-template`

**Default Resources**:
- CPU: 4 cores
- Memory: 8192 MB (8 GB)

**Docker Setup**:
- Docker socket mounted: `/var/run/docker.sock`
- Docker GID added to Coder container for permission management

## Editor Configuration

**Primary Editor**: code-server (VS Code in browser)

**VSCodium Compatibility**:
- Template supports both VS Code and VSCodium config paths:
  - `~/.config/Code/`
  - `~/.config/VSCodium/`
  - `~/.config/Code - OSS/`
- Extensions from Open VSX Registry (not Microsoft Marketplace)
- MCP config automatically created in all supported paths

## MCP Servers

Pre-configured in workspace startup script:

1. **Chrome DevTools MCP**
   - Package: `chrome-devtools-mcp@latest`
   - Browser automation and DevTools Protocol access

2. **GitHub MCP**
   - Package: `@github/github-mcp-server`
   - Uses GitHub OAuth token from Coder
   - Full GitHub API access

## Automated Deployment

When you push to `main` branch:
1. GitHub Actions validates Terraform and Dockerfile
2. If validation passes, deploys to `https://coder.bufothefrog.com`
3. Updates the `bufo-template` template
4. Existing workspaces continue running (update on rebuild)

**Required GitHub Secrets**:
- `CODER_URL`: `https://coder.bufothefrog.com`
- `CODER_SESSION_TOKEN`: Long-lived API token

## Manual Deployment

```bash
# From template directory
export CODER_URL="https://coder.bufothefrog.com"
coder login $CODER_URL
coder templates push bufo-template --directory . --yes
```

## Workspace Creation

When users create a workspace from this template:

1. **Parameters prompted**:
   - Git repository URL (optional)
   - Clone destination (default: `/home/coder/project`)

2. **Provisioning process**:
   - Docker volume created for persistent home directory
   - Custom image built from `build/Dockerfile`
   - Container started with resource limits
   - Coder agent connects workspace to Coder
   - Startup script runs:
     - Configures git with GitHub credentials
     - Sets up MCP servers for Claude Code
     - Clones repository (if specified)
     - Creates welcome guide at `~/WELCOME.md`

3. **Access methods**:
   - code-server (VS Code in browser)
   - SSH via Coder CLI
   - Direct terminal access

## Troubleshooting

### Template push fails
- Verify you're logged in: `coder login https://coder.bufothefrog.com`
- Check token validity: `coder tokens ls`
- Ensure Docker daemon is accessible to Coder container

### Workspace build fails
- Check Docker resources on host
- Verify `/var/run/docker.sock` is mounted in Coder container
- Review build logs in Coder UI

### GitHub authentication not working
- Verify GitHub OAuth is configured in Coder
- Check that user has authenticated GitHub in Coder profile
- Confirm `GITHUB_TOKEN` env var is set in workspace

### Extensions not installing
- Verify extension exists on Open VSX Registry
- Check code-server logs for download errors
- Some Microsoft-specific extensions may not be available

## Notes

- Rocky Linux 10 base requires special handling for Google's SHA-1 signed Chrome repository key
- Chrome is installed but requires display for version check (normal in headless environment)
- Puppeteer/Playwright NOT pre-installed to save ~500MB image size
- Users can install via `npm install -g puppeteer` if needed for custom scripts
