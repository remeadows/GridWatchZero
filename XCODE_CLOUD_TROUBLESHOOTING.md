# Xcode Cloud Troubleshooting — Branch Detection Issue

## RESOLVED (2026-02-05)

**Build 1 successful** — Xcode Cloud is fully operational on `main` branch with zero warnings and zero errors.

## Problem (Original)
Xcode Cloud could not see the `main` branch when trying to Start Build. The "Start Build" dialog showed "There are no branches available" despite `main` existing on the remote GitHub repository.

## Root Cause
Two issues combined to prevent Xcode Cloud from working:

1. **Stale SCM binding in App Store Connect**: The product-level Xcode Cloud connection had cached state from previous workflow configurations. The Settings → Repositories page showed `remeadows/GridWatchZero` but with "LAST ACCESSED: —" (never accessed), confirming the data pipeline was broken even though the repo was registered.

2. **`.gitignore` blocking files required by Xcode Cloud**: `Package.resolved` and the `xcshareddata/swiftpm/` directory were gitignored. Per [Apple documentation](https://developer.apple.com/documentation/xcode/making-dependencies-available-to-xcode-cloud), Xcode Cloud requires `Package.resolved` to be committed. Additionally, a blanket `*.xcworkspace` ignore rule could interfere with project structure detection.

## Resolution Steps
1. Uninstalled Xcode Cloud GitHub App from `github.com/settings/installations`
2. Re-added Xcode Cloud from App Store Connect (re-authorized GitHub connection)
3. Used "Delete Xcode Cloud Data" in App Store Connect → Settings to fully reset
4. Fixed `.gitignore`:
   - Removed `Package.resolved` from ignore list
   - Removed `*.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/` from ignore list
   - Removed blanket `*.xcworkspace` ignore rule
5. Pushed `.gitignore` fix to `main` (commit `206c59d`)
6. Re-onboarded Xcode Cloud from Xcode IDE (Report Navigator → Cloud tab → Create Workflow)
7. Build 1 completed successfully with green status

## What Was Tried (Before Fix)
1. ❌ Pushed empty commit to `main` to trigger detection
2. ❌ Changed workflow from "Specific Branches" to "Any Branches"
3. ❌ Deleted old "GridWatch" workflow and created new "GridWatchZero" workflow
4. ❌ Revoked and re-authorized Xcode Cloud GitHub App (not the same as full uninstall)
5. ❌ Multiple page refreshes and waiting
6. ✅ Verified GitHub API showed all branches correctly (main, CLAUDE_UPDATE, swift)
7. ✅ Verified repo is not a fork, was created from scratch, single GitHub account

## Key Lesson
Revoking/re-authorizing the GitHub App is **not** the same as uninstalling it. Re-authorization preserves cached state on Apple's side. A full uninstall + "Delete Xcode Cloud Data" + re-onboarding from the Xcode IDE was required to clear the stale SCM binding.

## Key Files & URLs
- **Repo**: https://github.com/remeadows/GridWatchZero
- **App Store Connect**: https://appstoreconnect.apple.com → Grid Watch Zero → Xcode Cloud
- **GitHub App Settings**: https://github.com/settings/installations
- **Bundle ID**: `WarSignal.GridWatchZero`
- **Team ID**: `B2U8T6A2Y3`
- **Xcode Scheme**: `GridWatchZero` (shared, in `xcshareddata/xcschemes/`)
- **CI Script**: `ci_scripts/ci_post_clone.sh`
- **Issue Tracker**: `project/ISSUES.md` → TODO-001
