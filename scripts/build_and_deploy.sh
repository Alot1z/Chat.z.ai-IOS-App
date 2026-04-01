#!/bin/bash
# Chat.z.ai Build and Deploy Script
# Automates IPA generation and installation

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Chat.z.ai Build & Deploy Script ===${NC}"

echo -e "${YELLOW}Checking dependencies...${NC}"
if ! command -v ipa &> /dev/null; then
  echo -e "${RED}Shenzhen not found. Installing...${NC}"
  sudo gem install shenzhen
fi

if ! command -v ios-deploy &> /dev/null; then
  echo -e "${RED}ios-deploy not found. Installing...${NC}"
  sudo gem install ios-deploy
fi

echo -e "${YELLOW}Step 1: Setting up Xcode schemes...${NC}"
ruby scripts/setup_schemes.rb

echo -e "${YELLOW}Step 2: Configuring build settings...${NC}"
ruby scripts/sign_app.rb

echo -e "${YELLOW}Step 3: Building IPA...${NC}"
rm -rf build/

ipa build \
  --project Chat.z.ai.xcodeproj \
  --scheme Chat.z.ai \
  --configuration Release \
  --sdk iphoneos \
  --verbose || true

xcodebuild \
  -project Chat.z.ai.xcodeproj \
  -scheme Chat.z.ai \
  -sdk iphoneos \
  -configuration Release \
  -derivedDataPath build/ \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  clean build

IPA_PATH=$(find . -name "*.ipa" -type f 2>/dev/null | head -n 1)

if [ -z "$IPA_PATH" ]; then
  echo -e "${YELLOW}Creating IPA from app bundle...${NC}"
  mkdir -p build/ipa/Payload
  APP_PATH=$(find build -name "*.app" -type d 2>/dev/null | head -n 1)

  if [ -n "$APP_PATH" ]; then
    cp -R "$APP_PATH" build/ipa/Payload/
    (
      cd build/ipa
      zip -r Chat.z.ai-unsigned.ipa Payload
    )
    IPA_PATH="build/ipa/Chat.z.ai-unsigned.ipa"
  fi
fi

if [ ! -f "$IPA_PATH" ]; then
  echo -e "${RED}Error: IPA file not found${NC}"
  exit 1
fi

echo -e "${GREEN}IPA created: $IPA_PATH${NC}"

echo -e "${YELLOW}Step 4: IPA Information...${NC}"
ipa info "$IPA_PATH" || true

echo -e "${YELLOW}Step 5: Install to device? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  echo -e "${YELLOW}Installing to connected device...${NC}"
  ios-deploy --debug --bundle "$IPA_PATH"
else
  echo -e "${GREEN}Build complete. IPA location: $IPA_PATH${NC}"
fi

echo -e "${GREEN}=== Done! ===${NC}"
