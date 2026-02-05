# Xcode Cloud Troubleshooting — Branch Detection Issue

## Problem
Xcode Cloud cannot see the `main` branch when trying to Start Build. The "Start Build" dialog shows "There are no branches available" despite `main` existing on the remote GitHub repository.

## Current Status (2026-02-05)
- Workflow name: "GridWatchZero" (newly created, old "GridWatch" workflow deleted)
- Repository: `https://github.com/remeadows/GridWatchZero.git`
- Branch `main` is confirmed on remote: `git ls-remote origin main` returns `fa0afb4`
- Workflow Start Condition: Branch Changes → `main`
- Warning tooltip: `"main" may only exist locally. To use it in your workflow, it must be pushed to your remote repository.`
- This is FALSE — `main` has been pushed and has multiple commits

## What Has Been Tried
1. ❌ Pushed empty commit to `main` to trigger Xcode Cloud detection
2. ❌ Changed workflow from "Specific Branches" to "Any Branches" — still no branches
3. ❌ Deleted old "GridWatch" workflow (stuck on `master`) and created new "GridWatchZero" workflow
4. ❌ Revoked and re-authorized Xcode Cloud GitHub App at `github.com/settings/installations`
5. ✅ Verified GitHub App has read/write access to `remeadows/GridWatchZero` repo
6. ✅ Verified `main` exists on remote via `git ls-remote origin main`
7. ❌ Multiple page refreshes and waiting — no change

## Diagnostics to Run

### 1. Check GitHub API directly
Verify GitHub can list branches for this repo:
```bash
# List remote branches
gh api repos/remeadows/GridWatchZero/branches --jq '.[].name'

# Check if main specifically exists
gh api repos/remeadows/GridWatchZero/branches/main

# Check default branch setting
gh api repos/remeadows/GridWatchZero --jq '.default_branch'
```

### 2. Check if `master` branch still exists on remote
The old workflow was on `master`. If `master` was renamed to `main`, there might be a ghost reference:
```bash
git ls-remote origin
gh api repos/remeadows/GridWatchZero/branches --jq '.[].name'
```

### 3. Check GitHub App webhook delivery
Go to: `https://github.com/settings/installations` → Xcode Cloud → Configure
- Check "Recent Deliveries" if visible
- Look for failed webhook deliveries that might indicate connection issues

### 4. Verify repo isn't a fork
Xcode Cloud has known issues with forked repos. Check:
```bash
gh api repos/remeadows/GridWatchZero --jq '.fork'
# Should return "false"
```

### 5. Check if the repo was transferred/renamed
The repo was previously `ProjectPlaguev1`. If it was renamed rather than created fresh, Xcode Cloud might have cached the old repo ID:
```bash
gh api repos/remeadows/GridWatchZero --jq '{id: .id, name: .name, full_name: .full_name, default_branch: .default_branch, created_at: .created_at}'
```

### 6. Check App Store Connect Settings
In App Store Connect → Xcode Cloud → Settings:
- Is the correct GitHub account connected?
- Is the source code management (SCM) provider showing as GitHub?
- Try disconnecting and reconnecting the SCM provider entirely

## Potential Solutions to Try

### A. Delete ALL Xcode Cloud workflows and re-onboard
1. Go to App Store Connect → Xcode Cloud → Manage Workflows
2. Delete every workflow
3. Go back to Xcode IDE → Product → Xcode Cloud → Create Workflow
4. Walk through the setup wizard from scratch — this forces a fresh SCM connection

### B. Create workflow from Xcode IDE instead of App Store Connect
1. Open project in Xcode
2. Go to Product → Xcode Cloud → Create Workflow
3. If "Xcode Cloud" doesn't appear under Product, go to:
   - Report Navigator (Cmd+9) → Cloud tab
   - Or: Source Control → Xcode Cloud
4. The IDE-based wizard may have better repo detection than the web UI

### C. Push a tag and try building from tag instead
```bash
git tag v1.0.3
git push origin v1.0.3
```
Then in Start Build, switch to the "Tags" tab instead of "Branches"

### D. Verify the Xcode project has the correct remote
```bash
cd /Users/russmeadows/Dev/Games/GridWatchZero
git remote -v
# Should show: origin https://github.com/remeadows/GridWatchZero.git
```

### E. Check if GitHub rate limiting is blocking API calls
```bash
gh api rate_limit --jq '.resources.core'
```

### F. Nuclear option: Uninstall Xcode Cloud GitHub App entirely
1. Go to `github.com/settings/installations`
2. Click Xcode Cloud → "Uninstall"
3. Wait 5 minutes
4. Go back to App Store Connect → Xcode Cloud
5. It should prompt to reconnect GitHub — walk through full authorization flow
6. Create new workflow

## Key Files & URLs
- **Repo**: https://github.com/remeadows/GridWatchZero
- **App Store Connect**: https://appstoreconnect.apple.com → Grid Watch Zero → Xcode Cloud
- **GitHub App Settings**: https://github.com/settings/installations
- **Bundle ID**: `WarSignal.GridWatchZero`
- **Team ID**: `B2U8T6A2Y3`
- **Xcode Scheme**: `GridWatchZero` (shared, in `xcshareddata/xcschemes/`)
- **CI Script**: `ci_scripts/ci_post_clone.sh`
- **Issue Tracker**: `project/ISSUES.md` → TODO-001
