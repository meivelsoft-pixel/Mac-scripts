#!/bin/bash
#set -x
#####################################################
##
## Script to install NVM (Node Version Manager) on Apple Silicon Mac
## To be run as the logged-in user (not sudo)
## This will install without homebrew 
##
#####################################################

log="/tmp/nvm_install.log"
exec 1>> "$log" 2>&1

echo ""
echo "##############################################################"
echo "# $(date) | Starting NVM installation script"
echo "##############################################################"
echo ""

# NVM install script URL (official)
NVM_INSTALL_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh"

# Download and run NVM install script
echo "$(date) | Downloading and running NVM install script..."
curl -o- "$NVM_INSTALL_URL" | bash

if [ $? -ne 0 ]; then
    echo "$(date) | Error: Failed to install NVM."
    exit 1
fi

# Load NVM into current shell session
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    # shellcheck disable=SC1090
    . "$NVM_DIR/nvm.sh"
    echo "$(date) | NVM loaded successfully."
else
    echo "$(date) | Error: NVM script not found after installation."
    exit 1
fi

# Verify NVM installation
if command -v nvm &>/dev/null; then
    NVM_VERSION=$(nvm --version)
    echo "$(date) | NVM installed successfully. Version: $NVM_VERSION"
else
    echo "$(date) | Error: NVM command not found after installation."
    exit 1
fi

echo "$(date) | NVM installation script completed."
exit 0
