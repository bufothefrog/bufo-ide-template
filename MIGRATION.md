# Migration Guide: Rocky Linux → Ubuntu 22.04

Guide for migrating existing Rocky Linux workspaces to the new Ubuntu 22.04 template.

## Understanding Your Data

### What's Safe (Persists Across Migration)

✅ **All files in `/home/coder`** - Your entire home directory is on a persistent volume
- Projects and repositories
- Configuration files (`.bashrc`, `.vimrc`, etc.)
- SSH keys
- Claude Code authentication (now shared!)

### What Needs Reinstalling

⚠️ **System packages** - Any packages installed via `dnf`
- Custom system tools
- Development libraries
- Language runtimes (if not in home directory)

⚠️ **Global npm packages** - Packages installed with `npm install -g`
- Will be reinstalled from package.json if in your projects

## Migration Options

### Option 1: In-Place Update (Recommended)

**Best for:** Production workspaces with important data

Your data is completely safe because it lives on persistent volumes that survive workspace rebuilds.

```bash
# Simply update your workspace
coder update <workspace-name>

# The system will:
# 1. Stop the old Rocky Linux container
# 2. Build new Ubuntu 22.04 image (~3 minutes)
# 3. Start new container with your existing data
# 4. Mount your existing home directory
# 5. Mount shared Claude credentials
```

**What happens:**
- ✅ All your files remain intact
- ✅ Git repos remain configured
- ✅ Claude Code auth preserved (shared across workspaces!)
- ⚠️ You may need to reinstall custom system packages

**After migration:**
```bash
# Reinstall any custom system packages (Ubuntu uses apt, not dnf)
sudo apt-get update
sudo apt-get install <your-packages>

# Reinstall global npm packages if needed
npm install -g <your-packages>
```

### Option 2: Fresh Start

**Best for:** Testing, experimental workspaces, or if you want a clean slate

```bash
# Delete old workspace (backups any important files first!)
coder delete <workspace-name>

# Create new workspace with Ubuntu template
coder create <workspace-name> --template bufo-ide-template

# Clone your repos
git clone https://github.com/your/repo
```

## New Features After Migration

### 1. Shared Claude Credentials

🎉 **One login, all workspaces!**

After migration, you only need to authenticate Claude Code **once**:

```bash
# In ANY workspace, run:
claude login

# Now ALL your workspaces are authenticated!
```

**How it works:**
- One shared volume per user: `coder-claude-{user-id}`
- Mounted to `/home/coder/.claude` in every workspace
- Authentication tokens shared across all your workspaces
- No more re-authenticating in every workspace!

**Volume structure:**
```
coder-claude-{user-id}/
├── settings.json       # Shared permissions config
├── credentials.json    # Shared auth tokens
└── session.json        # Shared session data
```

### 2. Claude Code CLI with Retry Logic

The CLI installation now has retry logic, so it should install reliably:
- 3 attempts with 5-second delays
- Explicit npm registry configuration
- Continues even if CLI install fails (VS Code extension still works)

### 3. Ubuntu Package Manager

Switch from `dnf` to `apt-get`:

**Old (Rocky Linux):**
```bash
sudo dnf install python3-pip
```

**New (Ubuntu):**
```bash
sudo apt-get update
sudo apt-get install python3-pip
```

## Troubleshooting

### Claude Code Authentication Not Working

```bash
# Check if credentials exist
ls -la ~/.claude/

# Check volume mounting
df -h | grep claude

# Re-authenticate if needed
claude login
```

### Missing System Packages

```bash
# Search for packages
apt-cache search <package-name>

# Install
sudo apt-get install <package>
```

### npm Global Packages Missing

```bash
# List what was globally installed
npm list -g --depth=0

# Reinstall as needed
npm install -g <package>
```

## Rollback (If Needed)

If you need to rollback to Rocky Linux:

```bash
# Check out previous version
git checkout <previous-commit-sha>

# Push old template
coder templates push bufo-ide-template --directory . --yes

# Update workspace
coder update <workspace-name>
```

**Note:** You'll lose the shared Claude credentials feature.

## FAQ

### Q: Will I lose my git configuration?
**A:** No, git config is in `~/.gitconfig` which persists.

### Q: What about my SSH keys?
**A:** SSH keys in `~/.ssh/` are preserved.

### Q: Do I need to re-authenticate with GitHub?
**A:** No, Coder's GitHub OAuth continues to work.

### Q: Can I test the migration without affecting my main workspace?
**A:** Yes! Create a new test workspace with the new template first:
```bash
coder create test-workspace --template bufo-ide-template
```

### Q: What if multiple workspaces are using Claude at the same time?
**A:** This works fine! The shared credentials volume is read-only for authentication data, so concurrent access is safe.

### Q: Can I have per-workspace Claude settings?
**A:** Currently, settings are shared. If you need different settings per workspace, you can:
1. Copy `~/.claude/` to a backup location
2. Modify for that workspace
3. Switch back when needed

(Future enhancement: Add a parameter to enable/disable shared credentials)

## Benefits of Migrating

✅ More reliable builds (Ubuntu vs Rocky Linux repository issues)  
✅ Shared Claude authentication across all workspaces  
✅ Claude Code CLI with retry logic  
✅ Better package availability (Ubuntu ecosystem)  
✅ LTS support until 2027  
✅ Consistent with most CI/CD environments  

## Timeline

- **Rocky Linux template**: Deprecated
- **Ubuntu template**: Current (v2.1)
- **Support**: Both will work, but Ubuntu is recommended

No forced migration - upgrade at your convenience!
