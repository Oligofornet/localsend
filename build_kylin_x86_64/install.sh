#!/bin/bash
# LocalSend Installation Script for Kylin OS

set -e

INSTALL_DIR="/opt/localsend"
DESKTOP_FILE="/usr/share/applications/localsend.desktop"
BIN_LINK="/usr/local/bin/localsend"

echo "Installing LocalSend to $INSTALL_DIR..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root (use sudo)"
    exit 1
fi

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Copy application files
cp -r * "$INSTALL_DIR/"

# Make executable
chmod +x "$INSTALL_DIR/localsend"
chmod +x "$INSTALL_DIR/localsend_app"

# Create desktop entry
sed "s|$PWD/$BUILD_DIR|$INSTALL_DIR|g" localsend.desktop > "$DESKTOP_FILE"

# Create symbolic link for command line access
ln -sf "$INSTALL_DIR/localsend" "$BIN_LINK"

# Update desktop database
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database /usr/share/applications
fi

echo "LocalSend installed successfully!"
echo "You can now run 'localsend' from the command line or find it in your applications menu."
