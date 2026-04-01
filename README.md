# Chat.z.ai iOS App

Unofficial iOS client with an unsigned IPA-focused build pipeline for CI and local automation.

## Why this repo is structured this way

- The repository intentionally supports **unsigned** builds to produce test artifacts in CI.
- The checked-in `Chat.z.ai.xcodeproj/project.pbxproj` may be a placeholder in some branches.
- `scripts/setup_schemes.rb` can rebuild a minimal valid Xcode project and regenerate schemes when needed.

## Prerequisites

- macOS + Xcode
- Ruby 3.x
- Bundler

## Local workflow

```bash
bundle install
ruby scripts/setup_schemes.rb
ruby scripts/sign_app.rb
./scripts/build_and_deploy.sh
```

Output IPA:

- `build/ipa/Chat.z.ai-unsigned.ipa`

## CI workflow

GitHub Actions builds unsigned IPA artifacts on push/PR using:

- project/scheme repair
- centralized unsigned signing
- deterministic IPA packaging from the built `.app`

See `.github/workflows/build-ipa.yml`.

## Rake shortcuts

```bash
rake setup   # install gems
rake build   # build unsigned ipa
rake clean   # remove build artifacts
```

## Note

This project uses unofficial endpoints and behavior may change at any time.
