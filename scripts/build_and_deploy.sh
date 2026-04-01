#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Chat.z.ai Build & Deploy ===${NC}"

echo -e "${YELLOW}Preparing project...${NC}"
ruby scripts/setup_schemes.rb
ruby scripts/sign_app.rb

rm -rf build/ipa

xcodebuild \
  -project Chat.z.ai.xcodeproj \
  -scheme Chat.z.ai \
  -configuration Release \
  -sdk iphoneos \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_IDENTITY="" \
  clean build

mkdir -p build/ipa/Payload
APP_PATH=$(find . -path "*Release-iphoneos/*.app" -type d | head -n 1)
if [ -z "$APP_PATH" ]; then
  echo -e "${RED}No .app bundle found after build.${NC}"
  exit 1
fi

cp -R "$APP_PATH" build/ipa/Payload/
(
  cd build/ipa
  zip -r Chat.z.ai-unsigned.ipa Payload >/dev/null
)

IPA_PATH="build/ipa/Chat.z.ai-unsigned.ipa"
echo -e "${GREEN}IPA created at ${IPA_PATH}${NC}"
ipa info "$IPA_PATH" || true

echo -e "${YELLOW}Install to connected device now? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  ios-deploy --debug --bundle "$IPA_PATH"
fi

echo -e "${GREEN}Done.${NC}"
