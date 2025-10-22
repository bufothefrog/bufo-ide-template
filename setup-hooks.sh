#!/bin/bash
# Setup script for pre-commit hooks
# Run this once after cloning the repository

set -e

echo "🔧 Setting up pre-commit hooks for Coder template..."

# Check if pre-commit is installed
if ! command -v pre-commit &> /dev/null; then
    echo "📦 Installing pre-commit..."

    # Try pip first
    if command -v pip3 &> /dev/null; then
        pip3 install --user pre-commit
    elif command -v pip &> /dev/null; then
        pip install --user pre-commit
    else
        echo "❌ Error: pip not found. Please install Python and pip first."
        echo "   On Rocky Linux: sudo dnf install python3-pip"
        exit 1
    fi
fi

# Check if Docker is available (needed for some hooks)
if ! command -v docker &> /dev/null; then
    echo "⚠️  Warning: Docker not found. Some hooks may not work."
    echo "   Docker build validation will be skipped."
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "⚠️  Warning: Terraform not found. Installing terraform-docs only..."
    echo "   Install Terraform from: https://developer.hashicorp.com/terraform/downloads"
fi

# Install the git hooks
echo "📝 Installing git hooks..."
pre-commit install

# Run hooks once to cache dependencies
echo "🚀 Running hooks for the first time (this may take a moment)..."
pre-commit run --all-files || echo "⚠️  Some hooks failed. This is expected on first run."

echo ""
echo "✅ Pre-commit hooks installed successfully!"
echo ""
echo "📚 Usage:"
echo "   - Hooks run automatically on 'git commit'"
echo "   - Run manually: pre-commit run --all-files"
echo "   - Skip hooks: git commit --no-verify (not recommended)"
echo "   - Update hooks: pre-commit autoupdate"
echo ""
echo "🎯 What gets checked:"
echo "   ✓ Terraform formatting and validation"
echo "   ✓ Dockerfile linting (hadolint)"
echo "   ✓ YAML syntax (GitHub Actions)"
echo "   ✓ Shell script validation"
echo "   ✓ Docker build test"
echo "   ✓ Coder provider check"
echo "   ✓ Trailing whitespace and line endings"
echo ""
