# Changelog

All notable changes to Captain's Log are documented here.

## [0.4.0] - 2026-03-11

### Added
- **Navigator v2**: Weather system (Clear → Cloudy → Rainy → Stormy → Hurricane) driven by water level; wave animation overhaul; improved UX layout
- **Captain speech bubble**: Contextual pirate quips from your captain that react to your current rank and activity
- **Pipeline visualization**: Dirty → Committed → Pushed progress indicators in the Navigator card
- **Death screen**: Davy Jones' locker scene when water level hits 100 — skull, ocean floor, "Commit to Resurrect" prompt
- **Instant popover refresh**: Data refreshes immediately on popover open instead of waiting for the next 60-second tick
- **Homebrew tap auto-update**: Release workflow now automatically updates the `JungHoonGhae/homebrew-captains-log` tap via GitHub API — no manual step required after tagging
- **Gamification unit tests**: 20 XCTest cases covering `calculateWaterLevel`, `PirateRank` transitions, `ShipType` classification, and `RepoConfig` JSON roundtrip

### Changed
- CI pipeline now runs `swift test` in addition to `swift build`
- Navigator gamification thresholds tuned for smoother rank progression
- Death/resurrection UX clarified with stronger visual feedback

### Fixed
- Concurrency guards added to CI and release workflows to cancel stale runs on the same branch

## [0.3.0] - 2026-03-04

### Added
- Multi-language support: English, Korean, Japanese, Chinese, Spanish, French, German (7 languages total)
- Pirates of the Caribbean-inspired Korean localization
- Community health files: CONTRIBUTING.md, issue templates, PR templates, funding config
- Thumbnail and social-preview images in README

### Changed
- README restructured to org-wide documentation patterns
- Buy Me a Coffee support link added
- Homebrew formula updated to v0.3.0

## [0.2.0] - 2024-12-15

### Added
- GitHub push event tracking via `gh` CLI
- Sleep mode — off-duty hours excluded from inactivity timer (configurable per-day schedule)
- Launch at Login via `SMAppService`
- Draggable cards with persisted order (`cardOrder` in config)
- Fleet card: summary by ship class
- 4 ship list view styles: Classic, Compact, Grid, Fleet

### Changed
- Homebrew formula updated to v0.2.0

## [0.1.0] - 2024-11-20

### Added
- Initial release
- macOS menu bar app with pirate rank system
- Water level gamification (0–100) driving rank, emoji, and weather
- Canvas-drawn galleon with wave animation
- Local git commit tracking via `git log`
- Auto-scan for git repos on first launch
- 5 pirate ranks: Captain, First Mate, Deckhand, Castaway, Davy Jones
- 6 ship classifications per repo: Flagship, Warship, Galleon, Sloop, Dinghy, Shipwreck
- Homebrew formula for distribution
