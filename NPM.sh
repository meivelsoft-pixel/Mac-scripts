#!/bin/bash

# Log file
LOG_FILE="$HOME/Library/Logs/npm_nvm_install.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "===== NPM/NVM Installation Started ====="
echo "Date: $(date)"
echo "User: $(whoami)"

# Set NVM directory
export NVM_DIR="$HOME/.nvm"

# Install NVM if not already present
if [ ! -d "$NVM_DIR" ]; then
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
else
    echo "NVM already installed."
fi

# Load NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Remove incompatible .npmrc prefix if present
if grep -q 'prefix=' "$HOME/.npmrc" 2>/dev/null; then
    echo "Removing prefix setting from .npmrc to avoid nvm conflicts..."
    sed -i.bak '/^prefix=/d' "$HOME/.npmrc"
fi

# Use or install latest LTS Node.js
echo "Installing latest LTS version of Node.js..."
nvm install --lts
nvm use --lts

# Set npm global directory to user space (via PATH only)
NPM_GLOBAL_DIR="$HOME/.npm-global"
mkdir -p "$NPM_GLOBAL_DIR"

# Update PATH for current session
export PATH="$NPM_GLOBAL_DIR/bin:$PATH"

# Detect user's shell profile
if [ -f "$HOME/.zshrc" ]; then
    PROFILE_FILE="$HOME/.zshrc"
elif [ -f "$HOME/.bash_profile" ]; then
    PROFILE_FILE="$HOME/.bash_profile"
elif [ -f "$HOME/.bashrc" ]; then
    PROFILE_FILE="$HOME/.bashrc"
else
    PROFILE_FILE="$HOME/.profile"
    touch "$PROFILE_FILE"
fi

# Export line to add
EXPORT_LINE="export PATH=\"$NPM_GLOBAL_DIR/bin:\$PATH\""

# Add export line if not already present
if ! grep -Fxq "$EXPORT_LINE" "$PROFILE_FILE"; then
    echo "Adding npm global bin to PATH in $PROFILE_FILE"
    if [ ! -w "$PROFILE_FILE" ]; then
        echo "Shell profile not writable. Fixing permissions..."
        chmod u+w "$PROFILE_FILE"
    fi
    echo "$EXPORT_LINE" >> "$PROFILE_FILE"
else
    echo "PATH already configured in $PROFILE_FILE"
fi

# Confirm installation
echo "Node.js version: $(node -v)"
echo "NPM version: $(npm -v)"
echo "NPM global bin path: $NPM_GLOBAL_DIR/bin"

echo "===== NPM/NVM Installation Completed Successfully ====="
