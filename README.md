# Chat.z.ai iOS App

Unofficial iOS client scaffold for chat.z.ai with unsigned IPA automation.

## Requirements

- macOS + Xcode
- Ruby 3+
- Bundler

## Setup

```bash
bundle install
```

## Build unsigned IPA

```bash
rake build
# or
./scripts/build_and_deploy.sh
```

## Useful tasks

```bash
rake schemes   # regenerate/open project + schemes
rake sign      # force unsigned sign settings
rake clean
```

## CI

GitHub Actions (`.github/workflows/build-ipa.yml`) builds an unsigned IPA on pushes to `main` and uploads it as an artifact.

## Notes

- `scripts/setup_schemes.rb` repairs/regenerates `Chat.z.ai.xcodeproj` when corrupted.
- This uses an unofficial endpoint and may break at runtime.
