# Bufo IDE Template for Coder (Ubuntu 22.04 LTS)

AI-powered development workspaces with Claude Code, Chrome DevTools MCP, and GitHub integration. Built on Ubuntu 22.04 LTS for maximum stability and reliability. Includes code-server, automated validation, and seamless GitHub authentication.

## Features

- **Ubuntu 22.04 LTS** with modern tooling (`git`, `vim`, `jq`, `tree`, `gcc`, `make`)
- **code-server** (VS Code in browser) with VSCodium compatibility
- **Claude Code CLI** (`claude` command) for terminal AI assistance
- **Shared Claude credentials** - Authenticate once, use in all workspaces (chat history stays per-workspace)! 🎉
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