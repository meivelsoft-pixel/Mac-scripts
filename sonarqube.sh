#!/bin/bash

# SonarScanner CLI Install Script for macOS (No Homebrew)
# Installs into logged-in user's home directory

# ---- CONFIG ----
SCANNER_VERSION="5.0.1.3006"
SCANNER_BASE_URL="https://binaries.sonarsource.com/Distribution/sonar-scanner-cli"
SCANNER_FILE="sonar-scanner-cli-${SCANNER_VERSION}-macosx.zip"
INSTALL_DIR_NAME="sonarscanner"

# ---- GET LOGGED IN USER ----
CURRENT_USER=$(stat -f "%Su" /dev/console)
USER_HOME=$(dscl . -read /Users/$CURRENT_USER NFSHomeDirectory | awk '{print $2}')

if [ -z "$CURRENT_USER" ]; then
    echo "No logged in user detected. Exiting."
    exit 1
fi

echo "Installing SonarScanner CLI for user: $CURRENT_USER"
echo "User home directory: $USER_HOME"

# ---- SET INSTALL PATH ----
INSTALL_PATH="$USER_HOME/$INSTALL_DIR_NAME"
TMP_ZIP="/tmp/$SCANNER_FILE"

# ---- DOWNLOAD ----
echo "Downloading SonarScanner CLI..."
curl -L -o "$TMP_ZIP" "$SCANNER_BASE_URL/$SCANNER_FILE"

if [ $? -ne 0 ]; then
    echo "Download failed."
    exit 1
fi

# ---- UNZIP ----
echo "Extracting..."
unzip -q "$TMP_ZIP" -d /tmp

EXTRACTED_DIR="/tmp/sonar-scanner-${SCANNER_VERSION}-macosx"

# ---- CLEAN OLD INSTALL ----
if [ -d "$INSTALL_PATH" ]; then
    echo "Removing previous installation..."
    rm -rf "$INSTALL_PATH"
fi

# ---- MOVE TO USER HOME ----
mv "$EXTRACTED_DIR" "$INSTALL_PATH"
chown -R "$CURRENT_USER" "$INSTALL_PATH"

# ---- ADD TO PATH (zsh or bash) ----
if [ -f "$USER_HOME/.zshrc" ]; then
    PROFILE_FILE="$USER_HOME/.zshrc"
elif [ -f "$USER_HOME/.bash_profile" ]; then
    PROFILE_FILE="$USER_HOME/.bash_profile"
else
    PROFILE_FILE="$USER_HOME/.zshrc"
    touch "$PROFILE_FILE"
fi

# Add only if not already present
grep -qxF "export PATH=\"$INSTALL_PATH/bin:\$PATH\"" "$PROFILE_FILE" || \
echo "export PATH=\"$INSTALL_PATH/bin:\$PATH\"" >> "$PROFILE_FILE"

chown "$CURRENT_USER" "$PROFILE_FILE"

# ---- CLEANUP ----
rm -f "$TMP_ZIP"
rm -rf "/tmp/sonar-scanner-${SCANNER_VERSION}-macosx"

echo "SonarScanner CLI installation completed."
echo "Installed to: $INSTALL_PATH"
echo "Restart terminal or run: source $PROFILE_FILE"
exit 0