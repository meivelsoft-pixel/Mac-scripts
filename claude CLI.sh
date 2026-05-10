#!/bin/bash

# Define log file in user home
LOGFILE="$HOME/claude_install.log"

# Function to log messages with timestamp
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') : $*" | tee -a "$LOGFILE"
}

# Trap errors and exits
error_exit() {
    log "ERROR: $1"
    exit 1
}
trap 'error_exit "Script terminated unexpectedly."' ERR

log "Starting Claude CLI installation..."

# Ensure local bin exists
mkdir -p "$HOME/.local/bin" || error_exit "Failed to create local bin directory"

# Download installer
curl -fsSL https://claude.ai/install.sh -o /tmp/install.sh || error_exit "Failed to download installer"

# Adjust install path
sed -i '' "s|/usr/local/bin|$HOME/.local/bin|g" /tmp/install.sh || error_exit "Failed to modify installer script"

# Run installer
bash /tmp/install.sh || error_exit "Installer script failed"

# Update PATH if not already present
if ! grep -q ".local/bin" "$HOME/.zshrc"; then
  echo 'export PATH=$HOME/.local/bin:$PATH' >> "$HOME/.zshrc"
  log "PATH updated in .zshrc"
fi

log "Claude CLI installation completed successfully."
exit 0

