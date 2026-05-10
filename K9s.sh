#!/bin/bash

# Variables
K9S_VERSION="v0.40.10"  # Update to latest version
INSTALL_DIR="/usr/local/bin"
TMP_DIR="/tmp/k9s"

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" == "arm64" ]; then
    K9S_FILE="k9s_Darwin_arm64.tar.gz"
else
    K9S_FILE="k9s_Darwin_x86_64.tar.gz"
fi

# Check if already installed
if [ -f "$INSTALL_DIR/k9s" ]; then
    echo "K9s already installed."
    exit 0
fi

# Create temp directory
mkdir -p $TMP_DIR
cd $TMP_DIR

# Download K9s binary
curl -L -o k9s.tar.gz "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/${K9S_FILE}"

# Extract and install
tar -xzf k9s.tar.gz
chmod +x k9s
mv k9s $INSTALL_DIR/

# Clean up
rm -rf $TMP_DIR

echo "K9s installed successfully for $ARCH architecture."
exit 0