#!/bin/bash

# Get the currently logged in user
CURRENT_USER=$(stat -f "%Su" /dev/console)
USER_HOME=$(dscl . -read /Users/"$CURRENT_USER" NFSHomeDirectory | awk '{print $2}')

echo "Installing Flutter SDK for user: $CURRENT_USER"
echo "User home directory: $USER_HOME"

FLUTTER_VERSION="3.29.3"
INSTALL_DIR="$USER_HOME/flutter"

# Check if Flutter is already installed for the user and correct version
if [ -d "$INSTALL_DIR" ] && [ -x "$INSTALL_DIR/bin/flutter" ]; then
    INSTALLED_VERSION=$("$INSTALL_DIR/bin/flutter" --version --machine | grep frameworkVersion | awk -F '"' '{print $4}')
    if [[ "$INSTALLED_VERSION" == "$FLUTTER_VERSION" ]]; then
        echo "Flutter $FLUTTER_VERSION already installed at $INSTALL_DIR"
        exit 0
    else
        echo "Different Flutter version ($INSTALLED_VERSION) found, reinstalling..."
        rm -rf "$INSTALL_DIR"
    fi
fi

# Download Flutter SDK
cd /tmp || exit 1

FLUTTER_SDK_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.29.3-stable.zip"

echo "Downloading Flutter SDK $FLUTTER_VERSION..."
curl -o flutter_sdk.zip "$FLUTTER_SDK_URL"
if [ $? -ne 0 ]; then
    echo "Error downloading Flutter SDK."
    exit 1
fi

# Extract Flutter SDK into user home directory
unzip -q flutter_sdk.zip -d "$USER_HOME"
if [ $? -ne 0 ]; then
    echo "Error extracting Flutter SDK."
    exit 1
fi

mv "$USER_HOME/flutter" "$INSTALL_DIR"

# Clean up
rm flutter_sdk.zip

# Change ownership to user (since script runs as root)
chown -R "$CURRENT_USER":staff "$INSTALL_DIR"

# Set Flutter path in user's shell profile
# Detect shell profile file (.zshrc preferred for macOS 10.15+)
if [ -f "$USER_HOME/.zshrc" ]; then
    PROFILE_FILE="$USER_HOME/.zshrc"
elif [ -f "$USER_HOME/.bash_profile" ]; then
    PROFILE_FILE="$USER_HOME/.bash_profile"
else
    # Create .zshrc if none exists
    PROFILE_FILE="$USER_HOME/.zshrc"
    touch "$PROFILE_FILE"
    chown "$CURRENT_USER":staff "$PROFILE_FILE"
fi

# Add Flutter path export if not already added
if ! grep -q 'export PATH=$HOME/flutter/bin:$PATH' "$PROFILE_FILE"; then
    echo 'export PATH=$HOME/flutter/bin:$PATH' >> "$PROFILE_FILE"
    echo "Added Flutter path to $PROFILE_FILE"
else
    echo "Flutter path already present in $PROFILE_FILE"
fi

# Done
echo "Flutter SDK $FLUTTER_VERSION installed at $INSTALL_DIR for user $CURRENT_USER."

# Optionally, notify user to restart shell or source profile to activate Flutter in current session
echo "Please restart your terminal or run 'source $PROFILE_FILE' to update your PATH."

exit 0
