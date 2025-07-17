# REQUIREMENTS
# (1) For Flutter: sudo apt install curl clang cmake libgtk-3-dev ninja-build
#     Project specific: sudo apt install libayatana-appindicator3-dev
# (2) For AppImage:
#     sudo apt install libfuse2
#     Download from https://github.com/AppImageCrafters/appimage-builder/releases
#     then sudo chmod +x appimage-builder-1.1.0-x86_64.AppImage && sudo mv appimage-builder-1.1.0-x86_64.AppImage /usr/local/bin/appimage-builder

# UNCOMMENT THESE LINES TO BUILD FROM LATEST COMMIT
# git reset --hard origin/main
# git pull

cd ..
rm -rf /tmp/build
cp localsend /tmp/build -r
pushd /tmp/build

git submodule update --init
alias flutter='submodules/flutter/bin/flutter'

flutter clean
flutter pub get
flutter pub run build_runner build -d
flutter build linux

rm -rf AppDir
rm -rf appimage-build

mkdir AppDir
cp -r build/linux/x64/release/bundle/* AppDir

# Copy logo to AppDir
mkdir -p AppDir/usr/share/icons/hicolor/32x32/apps
cp app/assets/img/logo-32.png AppDir/usr/share/icons/hicolor/32x32/apps/localsend.png
mkdir -p AppDir/usr/share/icons/hicolor/128x128/apps
cp app/assets/img/logo-128.png AppDir/usr/share/icons/hicolor/128x128/apps/localsend.png
mkdir -p AppDir/usr/share/icons/hicolor/256x256/apps
cp app/assets/img/logo-256.png AppDir/usr/share/icons/hicolor/256x256/apps/localsend.png

# Copy recipe and set version
cp scripts/appimage/AppImageBuilder_x86_64.yml AppImageBuilder.yml

# Get version from pubspec.yaml
VERSION=$(sed -n 's/^version: \([0-9]*\.[0-9]*\.[0-9]*\).*/\1/p' app/pubspec.yaml)
export VERSION

appimage-builder
sudo chmod +x LocalSend-*.AppImage

rm -rf AppDir
rm -rf appimage-build

popd
cd localsend
cp /tmp/build/LocalSend-*.AppImage .
