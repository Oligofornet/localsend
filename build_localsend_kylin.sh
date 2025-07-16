#!/bin/bash

# LocalSend Build Script for Kylin OS
# This script compiles LocalSend into a standalone executable for Kylin OS

set -e  # Exit on any error

echo "🚀 Starting LocalSend build for Kylin OS..."

# Set up environment variables
export PATH="$PWD/submodules/flutter/bin:$PATH"
source $HOME/.cargo/env

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check system architecture
ARCH=$(uname -m)
print_status "Detected architecture: $ARCH"

# Determine target architecture for Kylin OS
if [ "$ARCH" = "x86_64" ]; then
    TARGET_ARCH="x86_64"
    FLUTTER_TARGET="linux-x64"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    TARGET_ARCH="aarch64"
    FLUTTER_TARGET="linux-arm64"
else
    print_error "Unsupported architecture: $ARCH"
    exit 1
fi

print_status "Building for target architecture: $TARGET_ARCH"

# Create build directory
BUILD_DIR="build_kylin_${TARGET_ARCH}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

print_status "Created build directory: $BUILD_DIR"

# Step 1: Check Flutter doctor
print_status "Checking Flutter environment..."
flutter doctor -v

# Step 2: Enable Linux desktop support
print_status "Enabling Linux desktop support..."
flutter config --enable-linux-desktop

# Step 3: Navigate to app directory and get dependencies
print_status "Getting Flutter dependencies..."
cd app

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Step 4: Generate code (if needed)
print_status "Running code generation..."
if [ -f "pubspec.yaml" ] && grep -q "build_runner" pubspec.yaml; then
    flutter pub run build_runner build --delete-conflicting-outputs
fi

# Step 5: Build the Linux application
print_status "Building LocalSend for Linux..."
flutter build linux --release

# Step 6: Create standalone package
print_status "Creating standalone package..."
cd ..

# Copy the built application to our build directory
cp -r app/build/linux/x64/release/bundle/* "$BUILD_DIR/"

# Create a launcher script
cat > "$BUILD_DIR/localsend" << 'EOF'
#!/bin/bash
# LocalSend Launcher Script for Kylin OS

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set library path to include bundled libraries
export LD_LIBRARY_PATH="$SCRIPT_DIR/lib:$LD_LIBRARY_PATH"

# Launch LocalSend
exec "$SCRIPT_DIR/localsend_app" "$@"
EOF

chmod +x "$BUILD_DIR/localsend"

# Create desktop entry file
cat > "$BUILD_DIR/localsend.desktop" << EOF
[Desktop Entry]
Name=LocalSend
Comment=An open source cross-platform alternative to AirDrop
Exec=$PWD/$BUILD_DIR/localsend
Icon=$PWD/$BUILD_DIR/data/flutter_assets/assets/img/logo-512.png
Terminal=false
Type=Application
Categories=Network;FileTransfer;
StartupWMClass=localsend_app
EOF

# Step 7: Create installation script
cat > "$BUILD_DIR/install.sh" << 'EOF'
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
EOF

chmod +x "$BUILD_DIR/install.sh"

# Step 8: Create uninstall script
cat > "$BUILD_DIR/uninstall.sh" << 'EOF'
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
EOF

chmod +x "$BUILD_DIR/uninstall.sh"

# Step 9: Create README
cat > "$BUILD_DIR/README.md" << EOF
# LocalSend for Kylin OS

This is a standalone build of LocalSend compiled specifically for Kylin OS.

## System Requirements

- Kylin OS (compatible with Ubuntu 22.04+ libraries)
- Architecture: $TARGET_ARCH
- GTK 3.0 or later
- OpenGL support

## Installation

### Option 1: System-wide installation (recommended)
\`\`\`bash
sudo ./install.sh
\`\`\`

### Option 2: Run directly
\`\`\`bash
./localsend
\`\`\`

## Uninstallation

If you installed system-wide:
\`\`\`bash
sudo ./uninstall.sh
\`\`\`

## Features

- Cross-platform file sharing
- No internet connection required
- Secure local network communication
- Modern GTK-based interface
- Optimized for Kylin OS

## Build Information

- Built on: $(date)
- Architecture: $TARGET_ARCH
- Flutter Version: $(flutter --version | head -n1)
- Rust Version: $(rustc --version)

## Support

For issues and support, visit: https://github.com/Oligofornet/localsend
EOF

# Step 10: Create archive
print_status "Creating distribution archive..."
ARCHIVE_NAME="localsend-kylin-${TARGET_ARCH}-$(date +%Y%m%d).tar.gz"
tar -czf "$ARCHIVE_NAME" -C "$BUILD_DIR" .

# Step 11: Display build information
print_success "Build completed successfully!"
echo ""
echo "📦 Build Information:"
echo "   Target Architecture: $TARGET_ARCH"
echo "   Build Directory: $BUILD_DIR"
echo "   Archive: $ARCHIVE_NAME"
echo "   Archive Size: $(du -h "$ARCHIVE_NAME" | cut -f1)"
echo ""
echo "📋 Contents:"
ls -la "$BUILD_DIR"
echo ""
echo "🚀 To install on Kylin OS:"
echo "   1. Extract the archive: tar -xzf $ARCHIVE_NAME"
echo "   2. Run: sudo ./install.sh"
echo ""
echo "✅ Build process completed!"
