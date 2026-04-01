# Chat.z.ai iOS App

An unofficial iOS client with a CI-friendly pipeline that produces **unsigned IPA artifacts** for testing and automation.

---

## What this repository is optimized for

This project prioritizes reproducible CI builds and local automation over distribution-ready signing.

- Builds are intentionally **unsigned**.
- The checked-in `Chat.z.ai.xcodeproj/project.pbxproj` can be a placeholder on some branches.
- `scripts/setup_schemes.rb` can regenerate a minimal valid project/scheme setup when needed.

---

## Prerequisites

- macOS with Xcode installed
- Ruby 3.x
- Bundler

---

## Quick start (local)

Run from the repository root:

```bash
bundle install
ruby scripts/setup_schemes.rb
ruby scripts/sign_app.rb
./scripts/build_and_deploy.sh
```

Expected artifact:

- `build/ipa/Chat.z.ai-unsigned.ipa`

---

## CI behavior

GitHub Actions builds unsigned IPA artifacts on pushes and pull requests.

Pipeline highlights:

1. Project/scheme repair if required
2. Centralized unsigned signing step
3. Deterministic IPA packaging from the built `.app`
4. Validation that the `.app` contains the expected main executable
5. Automatic upload of the generated `.ipa` to GitHub Releases on pushes to `main`

Workflow file:

- `.github/workflows/build-ipa.yml`

---

## Rake shortcuts

```bash
rake setup   # Install gems
rake build   # Build unsigned IPA
rake clean   # Remove build artifacts
```

---

## Troubleshooting

### CI step fails with `set -euo pipefail`

That line itself is usually not the root cause; it only makes the job stop on the **first failing command**.

To find the real failure quickly:

1. Open the failed GitHub Actions job.
2. Expand the step that shows `Run set -euo pipefail`.
3. Look for the **first command** in that step that prints an error before `Process completed with exit code 1`.
4. Re-run that command locally to verify the fix.

Common causes in this repository:

- Ruby/Bundler dependencies not installed
- Scheme/project metadata not regenerated (`ruby scripts/setup_schemes.rb`)
- Build/signing script failing before IPA packaging

---

## Disclaimer

This project uses unofficial endpoints, and behavior may change at any time.
