#!/usr/bin/env bash

set -euo pipefail

PROJECT="Chat.z.ai.xcodeproj"
SCHEME="Chat.z.ai"
DERIVED_DATA="build/DerivedData"
IPA_DIR="build/ipa"
IPA_PATH="$IPA_DIR/Chat.z.ai-unsigned.ipa"

printf '\n==> Preparing project\n'
ruby scripts/setup_schemes.rb
ruby scripts/sign_app.rb

printf '\n==> Building app bundle\n'
rm -rf build
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_IDENTITY="" \
  clean build

printf '\n==> Packaging IPA\n'
APP_PATH=$(find "$DERIVED_DATA" -type d -name '*.app' | head -n 1)
if [[ -z "$APP_PATH" ]]; then
  echo "No .app bundle found in $DERIVED_DATA"
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
