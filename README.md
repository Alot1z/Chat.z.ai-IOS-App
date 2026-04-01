# Chat.z.ai iOS App

Unofficial iOS client for chat.z.ai with automated IPA building.

## Quick Start

### Prerequisites

- macOS with Xcode 12+
- Ruby 2.7+
- Bundler

### Setup

```bash
bundle install
```

### Build IPA

```bash
rake build
# or
./scripts/build_and_deploy.sh
```

## Manual Steps

1. Setup schemes:

```bash
ruby scripts/setup_schemes.rb
```

2. Build:

```bash
ipa build --project Chat.z.ai.xcodeproj --scheme Chat.z.ai
```

3. Install to device:

```bash
ios-deploy --debug --bundle Chat.z.ai.ipa
```

## GitHub Actions

Automatically builds unsigned IPA on every push to `main`.

## ⚠️ Warning

This app uses unofficial API endpoints and may break at any time. For best experience, use the official Kimi iOS app from App Store.
