# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2025-10-23

### Major Changes - Breaking

- **BREAKING**: Switched base image from Rocky Linux to Ubuntu 22.04 LTS
  - Rocky Linux had repository reliability issues in production
  - Ubuntu provides better mirror availability and stability
  - Package manager changed from `dnf` to `apt-get`

### Removed

- Removed Docker-in-Docker (DinD) support for security
  - Eliminates privileged container requirements
  - Prevents potential root escape vectors
  - Template is now safe for multi-tenant environments

- Removed Claude Code CLI pre-installation
  - Was causing npm install failures during build
  - Users can install manually if needed: `npm install -g @anthropic/claude-code`
  - Claude Code VS Code extension is still pre-installed

### Added

- Force rebuild capability with `BUILD_VERSION` environment variable
- `no_cache = true` flag for Docker builds to prevent stale layers
- Improved build reliability with Ubuntu's APT package manager

### Fixed

- Fixed repository sync failures that blocked workspace creation
- Fixed Docker build cache issues preventing Dockerfile updates
- Improved build time from 90+ seconds (with failures) to ~2m47s (reliable)

### Technical Details

**Build System Changes:**
- Base image: `rockylinux/rockylinux:9` → `ubuntu:22.04`
- Package manager: `dnf` → `apt-get`
- User group: `wheel` → `sudo`
- Chrome repo: RPM-based → DEB-based
- Node.js repo: `rpm.nodesource.com` → `deb.nodesource.com`

**Removed Components:**
- Docker-in-Docker sidecar container
- Docker CLI tools
- Docker storage volume
- Claude Code CLI global installation

**What Still Works:**
- ✅ Claude Code VS Code extension
- ✅ Chrome DevTools MCP integration
- ✅ GitHub MCP with OAuth
- ✅ Code Canvas extension
- ✅ Automatic GitHub authentication
- ✅ Repository auto-cloning
- ✅ Persistent home volumes
- ✅ All VS Code extensions

## [1.0.0] - 2025-10-22

### Initial Release

- Rocky Linux 10 base image
- Claude Code CLI and extension
- Chrome DevTools MCP
- GitHub MCP integration
- Code Canvas extension
- Automatic GitHub OAuth
- Pre-commit hooks for validation
