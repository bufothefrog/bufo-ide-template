# Quick Start Guide

## First Time Setup

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd bufo-ide-template

# 2. Install pre-commit hooks (one-time)
./setup-hooks.sh

# 3. Login to Coder
coder login https://coder.bufothefrog.com
```

## Daily Workflow

```bash
# 1. Make changes to template
vim main.tf
# or
vim build/Dockerfile

# 2. Commit (hooks validate automatically)
git add .
git commit -m "Your change description"

# If hooks fail:
# - Fix the errors shown
# - Commit again (hooks re-run)

# 3. Deploy to Coder (when ready)
coder templates push bufo-template --directory . --yes

# 4. Test the template
coder create test-workspace --template bufo-template

# 5. Push to GitHub
git push origin main
```

## What Gets Validated?

Pre-commit hooks automatically check:
- ✅ Terraform formatting (`terraform fmt`)
- ✅ Terraform configuration validity
- ✅ Dockerfile linting (hadolint)
- ✅ Docker build success
- ✅ YAML syntax (GitHub Actions)
- ✅ Shell script validation
- ✅ Trailing whitespace and line endings
- ✅ Coder provider requirement

## Quick Commands

```bash
# Run all hooks manually (without committing)
pre-commit run --all-files

# Skip hooks (not recommended)
git commit --no-verify -m "Emergency fix"

# Update hook versions
pre-commit autoupdate

# Test Docker build manually
cd build && docker build -t test .

# Validate Terraform manually
terraform fmt
terraform validate

# Deploy without committing
coder templates push bufo-template --directory . --yes
```

## Troubleshooting

### Hook fails on first run
- Normal! Hooks download dependencies on first run
- Run again: `pre-commit run --all-files`

### Docker build fails
- Check Docker is running: `docker ps`
- Test manually: `cd build && docker build -t test .`

### Can't reach Coder
- Ensure you're on VPN or local network
- Test: `ping coder.bufothefrog.com`
- Re-login: `coder login https://coder.bufothefrog.com`

### Terraform validation fails
- Ensure Terraform is installed: `terraform version`
- Check syntax in the error message
- Format files: `terraform fmt`

## Repository Structure

```
bufo-ide-template/
├── main.tf                    # Template configuration
├── build/Dockerfile           # Workspace image
├── .pre-commit-config.yaml    # Hook configuration
├── setup-hooks.sh             # Setup script
├── README.md                  # Full documentation
├── DEPLOYMENT.md              # Technical details
├── CHANGES.md                 # Recent changes
└── QUICKSTART.md              # This file
```

## Need More Help?

- Full docs: See [README.md](README.md)
- Deployment info: See [DEPLOYMENT.md](DEPLOYMENT.md)
- Recent changes: See [CHANGES.md](CHANGES.md)
