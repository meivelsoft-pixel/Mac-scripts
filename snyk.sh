#!/bin/bash
set -euo pipefail
 
BIN_DIR="$HOME/bin"
BIN="$BIN_DIR/snyk"
VERSION="1.1304.0"
LOGFILE="$HOME/snyk_install.log"
 
mkdir -p "$BIN_DIR"
 
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}
 
log "Starting Snyk validation"
 
# Already installed?
if [[ -x "$BIN" ]]; then
    INSTALLED_VERSION=$("$BIN" --version 2>/dev/null || true)
 
    if [[ "$INSTALLED_VERSION" == "$VERSION" ]]; then
        log "Snyk already installed ($VERSION). Exiting."
        exit 0
    fi
fi
 
ARCH=$(uname -m)
 
if [[ "$ARCH" == "arm64" ]]; then
    FILE="snyk-macos-arm64"
else
    FILE="snyk-macos"
fi
 
URL="https://github.com/snyk/cli/releases/download/v$VERSION/$FILE"
 
log "Downloading Snyk $VERSION"
curl -L "$URL" -o "$BIN"
 
chmod +x "$BIN"
 
if ! grep -q "$BIN_DIR" <<< "$PATH"; then
    echo 'export PATH=$PATH:$HOME/bin' >> "$HOME/.zshrc"
fi
 
log "Installed version: $("$BIN" --version)"
exit 0