#!/bin/bash
# Grid Watch Zero - CI/CD GitHub Issues
# Creates 6 CI/CD issues on the GridWatchZero repo.
#
# NOTE: Labels are skipped — the fine-grained PAT lacks label write permission.
# After issues are created, add labels manually in the GitHub UI:
#   1. Go to https://github.com/remeadows/GridWatchZero/labels
#   2. Create: ci/cd (#0E8A16), infrastructure (#FBCA04), automation (#5319E7), testing (#BFD4F2)
#   3. Apply labels to issues via the issues page

set -e

REPO="remeadows/GridWatchZero"

echo "Creating CI/CD issues (6 total)..."
echo ""

# Issue 1: Xcode Cloud Build Pipeline
gh issue create --repo "$REPO" \
  --title "[CI/CD] Set up Xcode Cloud build pipeline" \
  --label "enhancement" \
  --body "$(cat <<'EOF'
## Summary
Set up Xcode Cloud as the primary CI/CD pipeline for Grid Watch Zero. Xcode Cloud integrates natively with App Store Connect and requires no external CI service.

**Labels to add**: `ci/cd`, `infrastructure`

## Why Xcode Cloud
- Native Apple integration (no third-party CI needed)
- Free tier: 25 compute hours/month
- Direct App Store Connect / TestFlight deployment
- Runs on Apple silicon (matches production hardware)

## Tasks

### Phase 1: Basic Build Verification
- [ ] Enable Xcode Cloud in App Store Connect for `WarSignal.GridWatchZero`
- [ ] Create workflow: **Build on Push to Main**
  - Trigger: Push to `main` branch
  - Action: Build for iOS (iPhone + iPad)
  - Environment: Latest Xcode, iOS 17+ SDK
- [ ] Add `ci_post_clone.sh` script if any pre-build steps needed (e.g., code generation)

### Phase 2: Pull Request Validation
- [ ] Create workflow: **PR Validation**
  - Trigger: Pull request to `main`
  - Action: Build + run any tests
  - Post: Report build status on PR

### Phase 3: TestFlight Deployment
- [ ] Create workflow: **TestFlight Deploy**
  - Trigger: Tag matching `v*` (e.g., `v1.0.3`)
  - Action: Archive → Upload to App Store Connect → TestFlight
  - Auto-increment build number based on tag
- [ ] Configure TestFlight internal testing group auto-distribution

## Configuration Notes
- Bundle ID: `WarSignal.GridWatchZero`
- Team ID: `B2U8T6A2Y3`
- Current build: 1.0(2)
- Signing: Automatic (managed by Xcode Cloud)
- No CocoaPods/SPM dependencies currently

## Acceptance Criteria
- [ ] Push to `main` triggers automated build
- [ ] Build failures surface as GitHub commit status checks
- [ ] Tagged releases auto-deploy to TestFlight

## References
- [Xcode Cloud Documentation](https://developer.apple.com/xcode-cloud/)
- [Configuring Xcode Cloud Workflows](https://developer.apple.com/documentation/xcode/configuring-your-first-xcode-cloud-workflow)
EOF
)"
echo "  ✅ Created: Xcode Cloud build pipeline"

# Issue 2: Automated Testing
gh issue create --repo "$REPO" \
  --title "[CI/CD] Add unit tests and UI test targets" \
  --label "enhancement" \
  --body "$(cat <<'EOF'
## Summary
Add XCTest unit test and UI test targets to the Xcode project. Currently Grid Watch Zero has zero automated tests. This is a prerequisite for meaningful CI/CD — builds pass but nothing is verified.

**Labels to add**: `ci/cd`, `testing`

## Priority Test Areas

### Unit Tests (GameEngine logic)
- [ ] `GameEngineTests` — Tick processing, resource flow math
  - Source production with prestige multipliers
  - Link bandwidth limiting and packet loss
  - Sink credit conversion
  - Threat level progression thresholds
- [ ] `DefenseSystemTests` — Defense stack calculations
  - Category rate tables (intel bonus, risk reduction, secondary bonus)
  - Damage reduction with tier caps
  - Risk reduction capping at 80%
  - Credit protection from intel milestones
- [ ] `CampaignLevelTests` — Level configuration validation
  - All 20 Normal Mode levels load correctly
  - All 20 Insane Mode levels apply correct modifiers
  - Victory condition checking
  - Grace period and starter firewall logic
- [ ] `SaveMigrationTests` — Save system integrity
  - V1→V6 migration paths
  - Corrupt save handling
  - Offline progress calculation (8hr cap, 50% efficiency)
- [ ] `CertificateMaturityTests` — Maturity timer math
  - Normal cert: 40hr maturity
  - Insane cert: 60hr maturity
  - Per-cert bonus calculation
  - Total multiplier range (1.0x to 9.0x)

### UI Tests (Critical Flows)
- [ ] `CampaignFlowUITests`
  - Launch → Title → Main Menu → Campaign Hub
  - Start Level 1 → Gameplay loads → Victory conditions visible
  - Level complete → Back to Hub → Level shows completed
- [ ] `ShopFlowUITests`
  - Open unit shop → Browse categories → Purchase unit → Equip

## Implementation Notes
- Add test targets via Xcode: File → New → Target → Unit Testing Bundle / UI Testing Bundle
- Use `@testable import GridWatchZero`
- GameEngine is `@MainActor` — tests need `@MainActor` or `MainActor.run {}`
- Mock `UserDefaults` with `UserDefaults(suiteName:)` to avoid polluting real saves

## Acceptance Criteria
- [ ] Unit test target exists and runs via `Cmd+U`
- [ ] UI test target exists with at least 1 smoke test
- [ ] Tests pass in Xcode Cloud CI pipeline
- [ ] README badge shows build/test status
EOF
)"
echo "  ✅ Created: Unit tests and UI test targets"

# Issue 3: Build Number Automation
gh issue create --repo "$REPO" \
  --title "[CI/CD] Automate build number management" \
  --label "enhancement" \
  --body "$(cat <<'EOF'
## Summary
Automate build number (`CURRENT_PROJECT_VERSION`) incrementing so it doesn't require manual edits to `project.pbxproj`. Currently build bumps are done by hand (e.g., session log shows manual bump from 1 to 2).

**Labels to add**: `ci/cd`, `automation`

## Current State
- Marketing version: `1.0` (in `MARKETING_VERSION`)
- Build number: `2` (in `CURRENT_PROJECT_VERSION`, set in both Debug and Release)
- Manual process: Edit `project.pbxproj` → find `CURRENT_PROJECT_VERSION` → increment

## Options

### Option A: Xcode Cloud Build Number (Recommended)
Xcode Cloud can auto-set `CFBundleVersion` using the `CI_BUILD_NUMBER` environment variable:
```bash
# ci_scripts/ci_post_clone.sh
#!/bin/bash
if [ -n "$CI_BUILD_NUMBER" ]; then
    cd "$CI_PRIMARY_REPOSITORY_PATH"
    agvtool new-version -all "$CI_BUILD_NUMBER"
fi
```
- Pros: Zero config after setup, always unique, no merge conflicts
- Cons: Build numbers are Xcode Cloud run IDs (not sequential from 2)

### Option B: Git-Based Build Number
```bash
# Use git commit count as build number
BUILD_NUMBER=$(git rev-list --count HEAD)
agvtool new-version -all "$BUILD_NUMBER"
```
- Pros: Deterministic, reproducible, works locally
- Cons: Can conflict if branches diverge

### Option C: Tag-Based (Semantic)
Use git tags like `v1.0.3` where the patch number is the build:
```bash
VERSION_TAG=$(git describe --tags --abbrev=0)
BUILD=$(echo "$VERSION_TAG" | sed 's/v[0-9]*\.[0-9]*\.//')
```

## Acceptance Criteria
- [ ] Build number auto-increments on CI builds
- [ ] No manual `project.pbxproj` edits for build bumps
- [ ] App Store Connect accepts the build number without conflicts
- [ ] Local development builds still work without CI
EOF
)"
echo "  ✅ Created: Build number automation"

# Issue 4: Code Signing and Provisioning
gh issue create --repo "$REPO" \
  --title "[CI/CD] Configure code signing for CI builds" \
  --label "enhancement" \
  --body "$(cat <<'EOF'
## Summary
Ensure code signing works correctly in the Xcode Cloud environment for automated archive and TestFlight uploads.

**Labels to add**: `ci/cd`, `infrastructure`

## Current Signing Configuration
- Team: B2U8T6A2Y3
- Bundle ID: WarSignal.GridWatchZero
- Signing Style: Automatic
- Entitlements: `GridWatchZero/GridWatchZero.entitlements`
  - `com.apple.developer.ubiquity-kvstore-identifier` (iCloud Key-Value Store)

## Tasks
- [ ] Verify Xcode Cloud has access to signing certificates
  - Apple manages certificates automatically for Xcode Cloud
  - Confirm provisioning profile includes iCloud capability
- [ ] Test archive + export for App Store distribution
- [ ] Verify entitlements carry through CI build:
  - iCloud Key-Value Storage
  - No other special entitlements currently
- [ ] Document any manual App Store Connect steps that can't be automated

## Potential Issues
- iCloud entitlement may require specific provisioning profile config
- First Xcode Cloud build may prompt for Apple Developer Program agreement

## Acceptance Criteria
- [ ] CI can produce a signed `.ipa` suitable for TestFlight
- [ ] iCloud KV Store entitlement present in signed build
- [ ] No manual certificate management required
EOF
)"
echo "  ✅ Created: Code signing for CI"

# Issue 5: GitHub Actions alternative/supplement
gh issue create --repo "$REPO" \
  --title "[CI/CD] Add GitHub Actions for non-build automation" \
  --label "enhancement" \
  --body "$(cat <<'EOF'
## Summary
Add GitHub Actions workflows for tasks that don't require Xcode builds — linting, documentation checks, and project hygiene. These complement Xcode Cloud (which handles actual iOS builds).

**Labels to add**: `ci/cd`, `automation`

## Proposed Workflows

### 1. SwiftLint on PR
```yaml
name: SwiftLint
on: pull_request
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: norio-nomura/action-swiftlint@3.2.1
```
- Catches style issues before code review
- No macOS runner needed (SwiftLint has Linux support)

### 2. Documentation Freshness Check
- Verify CLAUDE.md, SKILLS.md, GO.md are in sync
- Check that PROJECT_STATUS.md was updated if code files changed
- Could be a simple shell script checking file modification dates

### 3. PR Template
- [ ] Create `.github/pull_request_template.md` with:
  - Summary section
  - Files changed
  - Testing done
  - CLAUDE.md/SKILLS.md cross-reference check

### 4. Issue Templates
- [ ] Create `.github/ISSUE_TEMPLATE/bug_report.md`
- [ ] Create `.github/ISSUE_TEMPLATE/feature_request.md`
- [ ] Create `.github/ISSUE_TEMPLATE/ci-cd.md`

## Why GitHub Actions + Xcode Cloud
| Task | GitHub Actions | Xcode Cloud |
|------|---------------|-------------|
| Lint | ✅ Fast, free | ❌ Overkill |
| Build | ❌ Needs macOS runner ($) | ✅ Free tier |
| Test | ⚠️ Expensive | ✅ Apple silicon |
| Deploy | ❌ Can't sign | ✅ Native |
| PR checks | ✅ Fast | ⚠️ Slower |

## Acceptance Criteria
- [ ] SwiftLint runs on PRs
- [ ] PR template exists
- [ ] Issue templates exist
- [ ] GitHub Actions badge in README
EOF
)"
echo "  ✅ Created: GitHub Actions for non-build automation"

# Issue 6: Release Process Documentation
gh issue create --repo "$REPO" \
  --title "[CI/CD] Document release process and versioning strategy" \
  --label "documentation" \
  --body "$(cat <<'EOF'
## Summary
Document the end-to-end release process from code merge to App Store, including versioning strategy, tagging conventions, and the checklist for each release.

**Labels to add**: `ci/cd`

## Current State (Manual Process)
1. Merge feature branch to main
2. Manually bump build number in project.pbxproj
3. Open Xcode → Product → Archive
4. Upload to App Store Connect
5. Configure TestFlight testing
6. Submit for App Store review

## Proposed Versioning Strategy

### Semantic Versioning
- `MAJOR.MINOR` for marketing version (e.g., `1.0`, `1.1`, `2.0`)
- Build number auto-incremented by CI

### Git Tagging
- Release tags: `v1.0.2`, `v1.1.0`
- Pre-release tags: `v1.1.0-beta.1`
- Tag triggers Xcode Cloud TestFlight deployment

### Branch Strategy
- `main` — stable, always builds
- Feature branches — PR into main
- No long-lived release branches (single active version)

## Deliverables
- [ ] `RELEASE.md` document with step-by-step process
- [ ] Git tag naming convention documented
- [ ] Pre-release checklist:
  - [ ] All issues for milestone closed
  - [ ] PROJECT_STATUS.md updated
  - [ ] ISSUES.md reviewed (no open criticals)
  - [ ] Build succeeds on CI
  - [ ] TestFlight tested on physical device
  - [ ] Screenshots current (if UI changed)
  - [ ] App Store metadata updated (if needed)
- [ ] Post-release checklist:
  - [ ] Tag created and pushed
  - [ ] GitHub Release created with changelog
  - [ ] SESSION log entry added

## Acceptance Criteria
- [ ] RELEASE.md exists with clear step-by-step
- [ ] Versioning strategy documented and agreed
- [ ] First automated release completed successfully
EOF
)"
echo "  ✅ Created: Release process documentation"

echo ""
echo "════════════════════════════════════════════════════"
echo "  All 6 CI/CD issues created successfully! 🎉"
echo "════════════════════════════════════════════════════"
echo ""
echo "View them at: https://github.com/remeadows/GridWatchZero/issues"
echo ""
echo "OPTIONAL: Create custom labels at:"
echo "  https://github.com/remeadows/GridWatchZero/labels"
echo "  ci/cd (#0E8A16) | infrastructure (#FBCA04)"
echo "  automation (#5319E7) | testing (#BFD4F2)"
