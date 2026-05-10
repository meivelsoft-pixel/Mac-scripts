#!/bin/bash
#
# GitHub CLI Installer Script (Intune Safe, User Scoped)
# Installs GitHub CLI into user's ~/.local/bin
#

GH_VERSION="2.47.0"   # Desired release version (no "v")
CONSOLE_USER=$(stat -f "%Su" /dev/console)
USER_HOME=$(dscl . -read /Users/$CONSOLE_USER NFSHomeDirectory | awk '{print $2}')
INSTALL_DIR="$USER_HOME/.local/bin"
TMP_DIR=$(mktemp -d)

echo "Logged-in user: $CONSOLE_USER"
echo "User home: $USER_HOME"

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" == "arm64" ]; then
    GH_FILE="gh_${GH_VERSION}_macOS_arm64.zip"
else
    GH_FILE="gh_${GH_VERSION}_macOS_amd64.zip"
fi

# Check if already installed
if [ -f "$INSTALL_DIR/gh" ]; then
    echo "GitHub CLI already installed at $INSTALL_DIR/gh"
    exit 0
fi

# Create install directory
mkdir -p "$INSTALL_DIR"

# Download GitHub CLI
echo "Downloading GitHub CLI $GH_VERSION for $ARCH..."
curl -L --fail -o "$TMP_DIR/gh.zip" \
  "https://github.com/cli/cli/releases/download/v${GH_VERSION}/${GH_FILE}"

# Extract and install
cd "$TMP_DIR"
unzip gh.zip

# Find extracted folder dynamically
EXTRACTED_DIR=$(find . -type d -name "gh_${GH_VERSION}_macOS_*" | head -n 1)

if [ -z "$EXTRACTED_DIR" ]; then
    echo "ERROR: Could not find extracted GitHub CLI folder."
    exit 1
fi

mv "$EXTRACTED_DIR/bin/gh" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/gh"
chown "$CONSOLE_USER" "$INSTALL_DIR/gh"

# Persist PATH update
ZSHRC="$USER_HOME/.zshrc"
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
if ! grep -qxF "$PATH_LINE" "$ZSHRC" 2>/dev/null; then
    echo "$PATH_LINE" >> "$ZSHRC"
    chown "$CONSOLE_USER" "$ZSHRC"
fi

# Clean up
rm -rf "$TMP_DIR"

# Verify installation
export PATH="$INSTALL_DIR:$PATH"
if command -v gh >/dev/null 2>&1; then
    echo "GitHub CLI v${GH_VERSION} installed successfully in $INSTALL_DIR"
    exit 0
else
    echo "ERROR: GitHub CLI installation failed."
    exit 1
fi
#!/bin/bash
#
# GitHub CLI Installer Script (Intune Safe, User Scoped)
# Installs GitHub CLI into user's ~/.local/bin
#

GH_VERSION="2.47.0"   # Desired release version (no "v")
CONSOLE_USER=$(stat -f "%Su" /dev/console)
USER_HOME=$(dscl . -read /Users/$CONSOLE_USER NFSHomeDirectory | awk '{print $2}')
INSTALL_DIR="$USER_HOME/.local/bin"
TMP_DIR=$(mktemp -d)

echo "Logged-in user: $CONSOLE_USER"
echo "User home: $USER_HOME"

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" == "arm64" ]; then
    GH_FILE="gh_${GH_VERSION}_macOS_arm64.zip"
else
    GH_FILE="gh_${GH_VERSION}_macOS_amd64.zip"
fi

# Check if already installed
if [ -f "$INSTALL_DIR/gh" ]; then
    echo "GitHub CLI already installed at $INSTALL_DIR/gh"
    exit 0
fi

# Create install directory
mkdir -p "$INSTALL_DIR"

# Download GitHub CLI
echo "Downloading GitHub CLI $GH_VERSION for $ARCH..."
curl -L --fail -o "$TMP_DIR/gh.zip" \
  "https://github.com/cli/cli/releases/download/v${GH_VERSION}/${GH_FILE}"

# Extract and install
cd "$TMP_DIR"
unzip gh.zip

# Find extracted folder dynamically
EXTRACTED_DIR=$(find . -type d -name "gh_${GH_VERSION}_macOS_*" | head -n 1)

if [ -z "$EXTRACTED_DIR" ]; then
    echo "ERROR: Could not find extracted GitHub CLI folder."
    exit 1
fi

mv "$EXTRACTED_DIR/bin/gh" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/gh"
chown "$CONSOLE_USER" "$INSTALL_DIR/gh"

# Persist PATH update
ZSHRC="$USER_HOME/.zshrc"
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
if ! grep -qxF "$PATH_LINE" "$ZSHRC" 2>/dev/null; then
    echo "$PATH_LINE" >> "$ZSHRC"
    chown "$CONSOLE_USER" "$ZSHRC"
fi

# Clean up
rm -rf "$TMP_DIR"

# Verify installation
export PATH="$INSTALL_DIR:$PATH"
if command -v gh >/dev/null 2>&1; then
    echo "GitHub CLI v${GH_VERSION} installed successfully in $INSTALL_DIR"
    exit 0
else
    echo "ERROR: GitHub CLI installation failed."
    exit 1
fi
