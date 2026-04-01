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


## Resolving Pull Request Merge Conflicts

If a pull request (for example, PR #2) cannot be merged because it is out of date with `main`, resolve conflicts either on GitHub (simple text conflicts) or locally (recommended for complex conflicts).

### Option 1: Resolve in GitHub UI (simple conflicts)

1. Open the pull request.
2. Click **Resolve conflicts** (if available).
3. Edit each conflicted file to remove conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).
4. Keep the desired code (or combine both sides).
5. Mark each file as resolved and commit the merge.

### Option 2: Resolve locally (recommended)

```bash
git fetch origin
git checkout <your-pr-branch>
git merge origin/main
# resolve conflicts in your editor
git add <resolved-files>
git commit -m "Resolve merge conflicts with main"
git push origin <your-pr-branch>
```

### Alternative: Rebase onto main

```bash
git fetch origin
git checkout <your-pr-branch>
git rebase origin/main
# resolve conflicts as prompted
git rebase --continue
git push --force-with-lease origin <your-pr-branch>
```

Use rebase for cleaner history, but prefer merge when multiple contributors share the same branch to avoid force-push disruption.
