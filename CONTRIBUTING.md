# Contributing to Captain's Log

Thanks for your interest in contributing! Captain's Log is a pirate-themed macOS menu bar app that gamifies dev velocity.

## Quick Start

```bash
git clone https://github.com/JungHoonGhae/captains-log.git
cd captains-log
swift build
.build/debug/CaptainsLog
```

**Requirements**: Swift 5.9+, macOS 13 (Ventura)+

## How to Contribute

### Bug Reports & Feature Requests

Use [GitHub Issues](https://github.com/JungHoonGhae/captains-log/issues) with the provided templates.

### Code Contributions

1. Fork the repo
2. Create a branch from `main`
   - `feature/your-feature` for new features
   - `fix/your-fix` for bug fixes
3. Make your changes
4. Test locally: `swift build && .build/debug/CaptainsLog`
5. Open a PR against `main`

## Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add Japanese localization
fix: ship clipping at low water levels
docs: update install instructions
refactor: extract wave drawing into separate method
chore: update CI workflow
```

## Project Structure

```
Sources/CaptainsLog/
  main.swift              # Entry point, NSStatusItem + NSPopover setup
  ContentView.swift       # Main SwiftUI view (fleet, ships, settings)
  WaterAnimationView.swift # Canvas-drawn galleon + water animation (30fps)
  GitTracker.swift        # Git/GitHub data model, repo scanning
  NotificationManager.swift # macOS notifications on rank change
  Strings.swift           # Multi-language localization (7 languages)
Formula/
  captains-log.rb         # Homebrew formula
.github/
  workflows/
    ci.yml                # Build check on push/PR
    release.yml           # Tag-triggered release pipeline
```

## Code Style

- SwiftUI for all UI
- Canvas API for animations (not SpriteKit)
- No external dependencies (pure Swift + AppKit/SwiftUI)
- Localization via `L10n` enum in `Strings.swift` — no `.lproj` bundles

### Adding a New Language

1. Add a case to `Language` enum in `Strings.swift`
2. Add translations to every `s(...)` call (follow existing parameter order)
3. Test with the in-app language picker

## Release Process

Releases are automated via GitHub Actions:

1. Tag a version: `git tag v0.x.0 && git push origin v0.x.0`
2. CI builds a universal binary (arm64 + x86_64)
3. GitHub Release is created with the tarball
4. Update Homebrew formula SHA256 in both this repo and [homebrew-captains-log](https://github.com/JungHoonGhae/homebrew-captains-log)

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
