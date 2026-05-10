#!/bin/bash

# ========================================
# Install DevToys with Logging
# ========================================

APP_NAME="DevToys"
APP_PATH="/Applications/${APP_NAME}.app"
DOWNLOAD_URL="https://github.com/DevToys-app/DevToys/releases/download/v2.0.8.0/devtoys_osx_arm64.zip"  # update if you have direct .dmg/.zip link
TMP_DIR="/tmp/devtoys"
ZIP_FILE="${TMP_DIR}/${APP_NAME}.zip"
LOG_FILE="/var/log/devtoys-install.log"

# Redirect all output to log file as well as stdout
exec > >(tee -a "$LOG_FILE") 2>&1

echo "========== $(date) =========="
echo "Starting $APP_NAME installation script..."

# Create temp directory
mkdir -p "$TMP_DIR"
rm -rf "${TMP_DIR:?}/"*

# Check if already installed
if [ -d "$APP_PATH" ]; then
    echo "$APP_NAME is already installed. Skipping installation."
    echo "========== $(date) =========="
    exit 0
fi

echo "Downloading $APP_NAME..."
curl -L -o "$ZIP_FILE" "$DOWNLOAD_URL"

if [[ $? -ne 0 || ! -f "$ZIP_FILE" ]]; then
    echo "Error: Failed to download $APP_NAME."
    echo "========== $(date) =========="
    exit 1
fi

echo "Extracting..."
unzip -q "$ZIP_FILE" -d "$TMP_DIR"

# Find the .app file (it may be inside a subfolder)
APP_FOUND=$(find "$TMP_DIR" -name "${APP_NAME}.app" -type d | head -n 1)

if [ -z "$APP_FOUND" ]; then
    echo "Error: ${APP_NAME}.app not found in extracted files."
    echo "========== $(date) =========="
    exit 1
fi

echo "Installing to /Applications..."
cp -R "$APP_FOUND" /Applications/

# Set correct permissions
chown -R root:wheel "$APP_PATH"

echo "$APP_NAME installed successfully."

# Cleanup
rm -rf "$TMP_DIR"

echo "Script complete."
echo "========== $(date) =========="
exit 0
