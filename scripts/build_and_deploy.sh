#!/usr/bin/env bash

set -euo pipefail

PROJECT="Chat.z.ai.xcodeproj"
SCHEME="Chat.z.ai"
DERIVED_DATA="build/DerivedData"
IPA_DIR="build/ipa"
IPA_PATH="$IPA_DIR/Chat.z.ai-unsigned.ipa"
APP_PRODUCTS_DIR="$DERIVED_DATA/Build/Products/Release-iphoneos"
APP_PATH="$APP_PRODUCTS_DIR/Chat.z.ai.app"

printf '\n==> Preparing project\n'
ruby scripts/setup_schemes.rb

printf '\n==> Building app bundle\n'
rm -rf build
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGN_STYLE=Manual \
  DEVELOPMENT_TEAM="" \
  PROVISIONING_PROFILE_SPECIFIER="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_IDENTITY="" \
  clean build

printf '\n==> Packaging IPA\n'
if [[ ! -d "$APP_PATH" ]]; then
  echo "Expected app bundle not found at: $APP_PATH"
  exit 1
fi

APP_BINARY_NAME=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$APP_PATH/Info.plist")
APP_BINARY_PATH="$APP_PATH/$APP_BINARY_NAME"
if [[ ! -f "$APP_BINARY_PATH" ]]; then
  echo "Parse Error 303 prevention: main binary is missing at $APP_BINARY_PATH"
  exit 1
fi

rm -rf "$IPA_DIR"
mkdir -p "$IPA_DIR/Payload"
cp -R "$APP_PATH" "$IPA_DIR/Payload/"
(
  cd "$IPA_DIR"
  /usr/bin/zip -qry "$(basename "$IPA_PATH")" Payload
)

printf '\nUnsigned IPA created at: %s\n' "$IPA_PATH"
