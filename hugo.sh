#!/bin/sh

#############################################
# RESOLVE LOGGED-IN USER (INTUNE SAFE)
#############################################
USER="$(/usr/bin/stat -f%Su /dev/console 2>/dev/null)"
[ -z "$USER" ] && exit 0
[ "$USER" = "root" ] && exit 0

HOME="/Users/$USER"
export HOME

#############################################
# PATHS
#############################################
INSTALL_DIR="$HOME/.local/bin"
TMP_DIR="$HOME/.local/share/hugo"
HUGO_BIN="$INSTALL_DIR/hugo"

#############################################
# ARCH DETECTION
#############################################
ARCH="$(uname -m)"

#############################################
# PREP
#############################################
mkdir -p "$INSTALL_DIR" "$TMP_DIR" || exit 0
cd "$TMP_DIR" || exit 0

#############################################
# SELECT DOWNLOAD URL
#############################################
if [ "$ARCH" = "arm64" ]; then
    # Apple Silicon → pinned ARM-safe version
    HUGO_VERSION="0.153.0"
    ARCHIVE="hugo_${HUGO_VERSION}_darwin-arm64.tar.gz"
    DOWNLOAD_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${ARCHIVE}"
else
    # Intel → latest available amd64
    DOWNLOAD_URL="$(
        curl -fsSL https://api.github.com/repos/gohugoio/hugo/releases/latest |
        awk -F\" '/browser_download_url/ && /darwin-amd64\.tar\.gz/ {print $4; exit}'
    )"
fi

[ -z "$DOWNLOAD_URL" ] && exit 0

#############################################
# DOWNLOAD
#############################################
curl -fL "$DOWNLOAD_URL" -o hugo.tar.gz || exit 0

#############################################
# EXTRACT
#############################################
tar -xzf hugo.tar.gz || exit 0

#############################################
# LOCATE HUGO BINARY (IMPORTANT)
#############################################
FOUND_HUGO="$(find "$TMP_DIR" -type f -name hugo | head -n 1)"
[ -z "$FOUND_HUGO" ] && exit 0

#############################################
# INSTALL
#############################################
rm -f "$HUGO_BIN"
mv "$FOUND_HUGO" "$HUGO_BIN" || exit 0
chmod 755 "$HUGO_BIN"

#############################################
# REMOVE GATEKEEPER QUARANTINE
#############################################
xattr -d com.apple.quarantine "$HUGO_BIN" 2>/dev/null || true

#############################################
# ENSURE PATH
#############################################
for PROFILE in "$HOME/.zprofile" "$HOME/.bash_profile"; do
    [ -f "$PROFILE" ] || continue
    grep -q "$INSTALL_DIR" "$PROFILE" && continue
    printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$PROFILE"
done

#############################################
# CLEANUP
#############################################
rm -rf "$TMP_DIR"

#############################################
# VERIFY (SILENT)
#############################################
"$HUGO_BIN" version >/dev/null 2>&1 || true

exit 0
