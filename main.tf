terraform {
  required_providers {
    coder  = { source = "coder/coder" }
    docker = { source = "kreuzwerker/docker" }
  }
}

provider "coder"  {}
provider "docker" {}

# --- Template Metadata ---
locals {
  template_name         = "bufo-template"
  template_display_name = "Bufo IDE Template"
  template_description  = "AI-powered dev environment with Chrome/GitHub MCP, Code Canvas. Auto GitHub auth, repo clone at creation."
  template_icon         = "/emojis/1f438.png"
}

# --- Workspace context ---
data "coder_workspace"       "me" {}
data "coder_workspace_owner" "me" {}
data "coder_provisioner"     "me" {}

# --- External Authentication ---
# This tells Coder that GitHub auth is available for this template
data "coder_external_auth" "github" {
  id       = "github"
  optional = true  # Changed to optional to fix UI parsing
}

locals {
  username = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
}

# --- Template Parameters (visible in Coder UI when creating workspace) ---
data "coder_parameter" "repo_url" {
  name         = "repo_url"
  display_name = "Git Repository"
  description  = "GitHub repository URL to clone (e.g., https://github.com/user/repo or leave empty)"
  type         = "string"
  default      = ""
  mutable      = false
  icon         = "/icon/github.svg"
  order        = 1
}

data "coder_parameter" "repo_dest" {
  name         = "repo_dest"
  display_name = "Clone Destination"
  description  = "Path where repository will be cloned"
  type         = "string"
  default      = "/home/coder/project"
  mutable      = false
  order        = 2
}

variable "cpu" {
  type        = number
  default     = 4
  description = "CPU cores allocated to workspace"
  validation {
    condition     = var.cpu >= 1 && var.cpu <= 16
    error_message = "CPU must be between 1 and 16 cores"
  }
}

variable "memory_mb" {
  type        = number
  default     = 8192
  description = "Memory (MB) allocated to workspace"
  validation {
    condition     = var.memory_mb >= 2048 && var.memory_mb <= 32768
    error_message = "Memory must be between 2048 MB and 32768 MB"
  }
}

# --- Persistent home volume per workspace ---
resource "docker_volume" "home" {
  name = "coder-${data.coder_workspace.me.id}-home"
  
  labels {
    label = "coder.workspace.id"
    value = data.coder_workspace.me.id
  }
  
  labels {
    label = "coder.workspace.name"
    value = data.coder_workspace.me.name
  }
  
  lifecycle { 
    ignore_changes = all 
  }
}

# --- Custom workspace image ---
resource "docker_image" "workspace" {
  name = "coder-${data.coder_workspace.me.id}"
  
  build {
    context = "./build"
    build_args = { 
      USER = "coder" 
    }
  }
  
  # Rebuild if build context changes
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "build/*") : filesha1(f)]))
  }
}

# --- Workspace container (runs when workspace starts) ---
resource "docker_container" "workspace" {
  count    = data.coder_workspace.me.start_count
  image    = docker_image.workspace.name
  name     = "coder-${data.coder_workspace_owner.me.name}-${lower(data.coder_workspace.me.name)}"
  hostname = data.coder_workspace.me.name

  # Resource limits
  memory     = var.memory_mb * 1024 * 1024
  cpu_shares = var.cpu * 1024

  # Persistent home directory
  volumes {
    container_path = "/home/coder"
    volume_name    = docker_volume.home.name
    read_only      = false
  }

  # Environment variables
  env = [
    "CODER_AGENT_TOKEN=${coder_agent.main.token}",
    "HOME=/home/coder",
    "USER=coder",
  ]

  # Allow container to reach host services if needed
  host { 
    host = "host.docker.internal" 
    ip   = "host-gateway" 
  }

  # Run the Coder agent init script
  entrypoint = ["sh", "-c", coder_agent.main.init_script]
  
  # Keep container running
  command = ["sleep", "infinity"]
}

# --- Coder agent (connects workspace to Coder) ---
resource "coder_agent" "main" {
  os   = "linux"
  arch = data.coder_provisioner.me.arch

  # Configure git with user identity and GitHub token
  env = {
    GIT_AUTHOR_NAME     = local.username
    GIT_AUTHOR_EMAIL    = data.coder_workspace_owner.me.email
    GIT_COMMITTER_NAME  = local.username
    GIT_COMMITTER_EMAIL = data.coder_workspace_owner.me.email
    # Pass GitHub token to workspace for automatic authentication
    GITHUB_TOKEN        = data.coder_external_auth.github.access_token
  }

  # Startup script - configures git credentials and creates welcome guide
  startup_script = <<-EOT
    set -e
    
    # Configure git with GitHub credentials using credential helper
    git config --global user.name "${local.username}"
    git config --global user.email "${data.coder_workspace_owner.me.email}"
    git config --global init.defaultBranch main
    
    # Configure Git to use Coder's GitHub token for authentication
    # This credential helper returns the OAuth token for any git operation
    git config --global credential.helper '!f() { echo "username=oauth2"; echo "password=$GITHUB_TOKEN"; }; f'
    
    # Configure Claude Code MCP servers
    # Support both VS Code and VSCodium paths
    for config_dir in ~/.config/Code ~/.config/VSCodium ~/.config/Code\ -\ OSS; do
      if [ -d "$config_dir" ] || [ "$config_dir" = "$HOME/.config/Code" ]; then
        mkdir -p "$config_dir/User/globalStorage/anthropic.claude-code"
        cat > "$config_dir/User/globalStorage/anthropic.claude-code/mcp_config.json" << 'MCP_EOF'
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@github/github-mcp-server"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "$GITHUB_TOKEN"
      }
    }
  }
}
MCP_EOF
      fi
    done
    
    # Create welcome guide for first-time users
    REPO_MESSAGE=""
    if [ -n "${data.coder_parameter.repo_url.value}" ]; then
      REPO_MESSAGE="Your repository is being cloned to: \`${data.coder_parameter.repo_dest.value}\`

Git is configured with your GitHub credentials automatically."
    else
      REPO_MESSAGE="Start coding in: \`/home/coder/project\`

Clone any repo with: \`git clone https://github.com/user/repo\`"
    fi
    
    cat > ~/WELCOME.md << EOF
# 👋 Welcome to your Coder Workspace!

## ✅ GitHub Authentication

Your GitHub account is automatically connected! You can:
- Clone private repos: \`git clone https://github.com/user/private-repo\`
- Push changes: \`git push\`
- No manual authentication needed 🎉

Your GitHub token is injected via the GITHUB_TOKEN environment variable.

---

## 🤖 Claude Code Setup (One-time)

To activate Claude Code in this workspace:

1. Open the **Command Palette**:
   - Press \`Ctrl+Shift+P\` (Linux/Windows)
   - Press \`Cmd+Shift+P\` (Mac)

2. Type and select: **"Claude Code: Sign In"**

3. Choose: **Anthropic Max** (OAuth)

4. Complete the browser sign-in flow

✨ You only need to do this **once per workspace**

---

## 🌐 Chrome DevTools Integration (MCP)

**Google Chrome** is pre-installed with **Chrome DevTools MCP** configured!

Claude Code can now interact directly with Chrome DevTools Protocol:
- Navigate and interact with web pages
- Inspect DOM elements
- Monitor network requests
- Debug JavaScript
- Test web applications
- Automate browser workflows
- Take screenshots
- Extract data

**Example prompts for Claude:**
- "Open example.com and inspect the page structure"
- "Navigate to localhost:3000 and test the login form"
- "Monitor network requests on my app and show me the API calls"
- "Debug this JavaScript error in my app"
- "Take a screenshot of the current page"

---

## 🐙 GitHub MCP Integration

**GitHub MCP Server** is configured with your GitHub credentials!

Claude Code can now interact with GitHub:
- Browse and search repositories
- Create and manage issues
- Create and review pull requests
- Monitor GitHub Actions workflows
- Analyze code and security findings
- Access discussions and notifications

**Example prompts for Claude:**
- "Show me all open issues in my repository"
- "Create a pull request from my current branch"
- "Check the status of GitHub Actions on my PR"
- "List all Dependabot alerts in this repo"
- "Search for repositories about machine learning"

**Technical details:**
- **MCP Server**: \`@github/github-mcp-server\`
- **Authentication**: Uses your GitHub OAuth token from Coder
- **Capabilities**: Full GitHub API access via MCP

---

## 🎨 Code Canvas

**Code Canvas** extension is pre-installed for visual code exploration!

Features:
- View code flow on an infinite canvas
- Visualize file relationships
- Trace function calls and references
- Track real-time changes (great for AI edits)
- Layout algorithms for organizing files
- Token reference tracking

**How to use:**
- Open Command Palette: \`Ctrl+Shift+P\`
- Type: "Open Code Canvas"
- Or click the Code Canvas icon in bottom right

**Great for:**
- Understanding AI-generated code changes
- Exploring large codebases
- Tracking function dependencies
- Visualizing project structure

---

## 📝 Markdown Support

**Markdown All in One** extension is pre-installed!

Features:
- Keyboard shortcuts
- Table of contents
- Auto preview
- List editing
- Math support

---

## 📂 Your Project
$REPO_MESSAGE

---

## 🎨 Theme

Your IDE theme automatically follows your system (light/dark mode).

---

Happy coding! 🚀
EOF
    
    # Ensure project directory exists
    mkdir -p ~/project
    
    echo "[coder] ✅ Workspace ready! GitHub authenticated, Chrome DevTools + GitHub MCP configured. Open WELCOME.md for next steps."
  EOT

  # Connection to Docker container
  connection {
    type         = "docker"
    container_id = docker_container.workspace[0].id
  }
}

# ================================
# Modules (from Coder Registry)
# ================================

# Clone repository on first boot (conditional on repo_url)
module "git_clone" {
  count    = data.coder_parameter.repo_url.value != "" ? 1 : 0
  source   = "registry.coder.com/modules/git-clone/coder"
  version  = "1.0.3"
  agent_id = coder_agent.main.id
  url      = data.coder_parameter.repo_url.value
  base_dir = data.coder_parameter.repo_dest.value
}

# Install code-server with extensions and theme config
module "code_server" {
  source   = "registry.coder.com/modules/code-server/coder"
  version  = "1.0.10"
  agent_id = coder_agent.main.id

  # Auto-install extensions from Open VSX
  extensions = [
    "yzhang.markdown-all-in-one",
    "Anthropic.claude-code",
    "alex-c.code-canvas-app"
  ]

  # Auto-detect system theme and disable minimap
  settings = {
    "window.autoDetectColorScheme"       = true
    "workbench.preferredLightColorTheme" = "Default Light Modern"
    "workbench.preferredDarkColorTheme"  = "Default Dark Modern"
    "editor.minimap.enabled"             = false
    "workbench.startupEditor"            = "none"
    "keyboard.dispatch"                  = "keyCode"
  }
}

# ================================
# Metadata (shows in Coder UI)
# ================================

resource "coder_metadata" "workspace_info" {
  resource_id = coder_agent.main.id
  
  item {
    key   = "CPU"
    value = "${var.cpu} cores"
  }
  
  item {
    key   = "Memory"
    value = "${var.memory_mb} MB"
  }
  
  item {
    key   = "Repository"
    value = data.coder_parameter.repo_url.value != "" ? data.coder_parameter.repo_url.value : "None (manual clone)"
  }
  
  item {
    key   = "GitHub Auth"
    value = "Configured (check profile)"
  }
  
  item {
    key   = "Home Volume"
    value = docker_volume.home.name
  }
}

# Show GitHub authentication status
resource "coder_metadata" "github_auth" {
  resource_id = data.coder_external_auth.github.id
  
  item {
    key   = "Status"
    value = "GitHub OAuth configured"
  }
}
