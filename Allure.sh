#!/bin/bash
# ---------------------------------------------------------------------------
# Allure + Java Installer for macOS (User-based, No Homebrew)
# Works on Intel + Apple Silicon (M1/M2/M3)
# Deployable via Microsoft Intune (run as user)
# ---------------------------------------------------------------------------

set -e

LOG_DIR="$HOME/Library/Logs"
LOG_FILE="$LOG_DIR/allure_install.log"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

ALLURE_VERSION="2.34.0"
INSTALL_DIR="$HOME/.local/allure-${ALLURE_VERSION}"
BIN_DIR="$HOME/.local/bin"
JDK_DIR="$HOME/.local/jdk-17"
TMP_DIR="/tmp/allure_install_$$"

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
  JDK_TAR_URL="https://corretto.aws/downloads/latest/amazon-corretto-17-aarch64-macos-jdk.tar.gz" 
else
  JDK_TAR_URL="https://corretto.aws/downloads/latest/amazon-corretto-17-x64-macos-jdk.tar.gz"
fi

# Install Java locally if missing
if ! command -v java &>/dev/null; then
  mkdir -p "$TMP_DIR" "$JDK_DIR"
  curl -sL -o "$TMP_DIR/jdk.tar.gz" "$JDK_TAR_URL"
  tar -xzf "$TMP_DIR/jdk.tar.gz" -C "$JDK_DIR" --strip-components=1
fi

# Detect profile file
PROFILE_FILE="$HOME/.zshrc"
[ -n "$BASH_VERSION" ] && PROFILE_FILE="$HOME/.bash_profile"
[ -z "$ZSH_VERSION$BASH_VERSION" ] && PROFILE_FILE="$HOME/.profile"

# Configure Java environment variables if profile is writable
if [ -w "$PROFILE_FILE" ] || [ ! -e "$PROFILE_FILE" ]; then
  {
    echo "export JAVA_HOME=\"$JDK_DIR\""
    echo "export PATH=\"\$PATH:$JDK_DIR/bin\""
  } >> "$PROFILE_FILE"
fi

# Update current session PATH
export JAVA_HOME="$JDK_DIR"
export PATH="$PATH:$JDK_DIR/bin"

# Download and install Allure
mkdir -p "$TMP_DIR"
curl -sL -o "$TMP_DIR/allure.tgz" "https://github.com/allure-framework/allure2/releases/download/${ALLURE_VERSION}/allure-${ALLURE_VERSION}.tgz"
mkdir -p "$INSTALL_DIR"
tar -xzf "$TMP_DIR/allure.tgz" -C "$INSTALL_DIR" --strip-components=1

# Add Allure to PATH if profile is writable
mkdir -p "$BIN_DIR"
ln -sf "${INSTALL_DIR}/bin/allure" "$BIN_DIR/allure"

if [ -w "$PROFILE_FILE" ] || [ ! -e "$PROFILE_FILE" ]; then
  echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$PROFILE_FILE"
fi

# Cleanup
rm -rf "$TMP_DIR"

# Verify
if "$BIN_DIR/allure" --version &>/dev/null; then
  "$BIN_DIR/allure" --version
  exit 0
else
  exit 1
fi
