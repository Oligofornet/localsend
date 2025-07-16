#!/bin/bash
# LocalSend Uninstallation Script for Kylin OS

set -e

INSTALL_DIR="/opt/localsend"
DESKTOP_FILE="/usr/share/applications/localsend.desktop"
BIN_LINK="/usr/local/bin/localsend"

echo "Uninstalling LocalSend..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root (use sudo)"
    exit 1
fi

# Remove installation directory
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo "Removed $INSTALL_DIR"
fi

# Remove desktop entry
if [ -f "$DESKTOP_FILE" ]; then
    rm "$DESKTOP_FILE"
    echo "Removed $DESKTOP_FILE"
fi

# Remove symbolic link
if [ -L "$BIN_LINK" ]; then
    rm "$BIN_LINK"
    echo "Removed $BIN_LINK"
fi

# Update desktop database
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database /usr/share/applications
fi

echo "LocalSend uninstalled successfully!"
