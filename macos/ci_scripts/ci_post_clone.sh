#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# The default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.

cd ..
git clone https://github.com/5VNetwork/tm-plugin
git clone https://github.com/5VNetwork/system-proxy.git
git clone https://github.com/5VNetwork/installed_apps.git
git clone https://github.com/5VNetwork/google-sign-in.git

echo "🔧 Installing GitHub CLI..."
brew install gh
gh auth login --with-token <<< "$X_REPO"
gh release download latest \
  -R 5VNetwork/x \
  -p "tm-macos.xcframework.zip"

# unzip tm-macos.xcframework.zip
unzip tm-macos.xcframework.zip 
mv tm-macos.xcframework $CI_PRIMARY_REPOSITORY_PATH/macos/tm.xcframework

cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.

# Install Flutter using git.
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
flutter precache --macos

# Install Flutter dependencies.
flutter pub get

# Install CocoaPods using Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1 # disable homebrew's automatic updates.
brew install cocoapods

# Install CocoaPods dependencies.
cd macos && pod install # run `pod install` in the `ios` directory.

# Go back to the workspace root
cd "$CI_PRIMARY_REPOSITORY_PATH"

make mac_production

exit 0
