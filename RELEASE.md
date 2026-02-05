# RELEASE.md — Grid Watch Zero

## Versioning Strategy

| Version Component | Where Set | How Updated |
|-------------------|-----------|-------------|
| **Marketing Version** (e.g., `1.0`) | `MARKETING_VERSION` in project.pbxproj | Manually in Xcode for each release |
| **Build Number** (e.g., `42`) | `CURRENT_PROJECT_VERSION` in project.pbxproj | Auto-set by Xcode Cloud via `ci_scripts/ci_post_clone.sh` |
| **Git Tag** (e.g., `v1.0.42`) | Git | Created manually after TestFlight validation |

**Bundle ID**: `WarSignal.GridWatchZero`
**Team ID**: `B2U8T6A2Y3`

---

## Branch Strategy

- **`main`** — Always deployable. All CI runs against this branch.
- **Feature branches** — Created from `main`, merged back via Pull Request.
- **No long-lived release branches.** Single active version at a time.

---

## Git Tag Convention

```
v{MARKETING_VERSION}.{build}
```

Examples: `v1.0.3`, `v1.1.0`, `v2.0.1`

- **Release tags**: `v1.0.3` — triggers Xcode Cloud TestFlight deployment (when configured)
- **Pre-release tags**: `v1.1.0-beta.1` — optional, for tracking beta milestones

---

## CI/CD Architecture

| System | Purpose | Trigger |
|--------|---------|---------|
| **Xcode Cloud** | Build, test, archive, TestFlight deploy | Push to main, PR, version tags |
| **GitHub Actions** | SwiftLint, PR checks | PR to main (Swift files only) |

### Xcode Cloud Workflows

| Workflow | Trigger | Action |
|----------|---------|--------|
| Build on Push | Push to `main` | Build for iOS (iPhone + iPad) |
| PR Validation | Pull request to `main` | Build + run tests |
| TestFlight Deploy | Tag `v*` | Archive → App Store Connect → TestFlight |

### GitHub Actions Workflows

| Workflow | Trigger | Action |
|----------|---------|--------|
| SwiftLint | PR to `main` (*.swift changes) | Lint Swift code |

---

## Release Checklist

### Pre-Release

- [ ] All milestone issues closed
- [ ] `project/PROJECT_STATUS.md` updated with session log
- [ ] `project/ISSUES.md` reviewed — no open Critical issues
- [ ] `CLAUDE.md` and `SKILLS.md` in sync (cross-reference rule)
- [ ] CI build passes (Xcode Cloud green)
- [ ] SwiftLint passes (GitHub Actions green)
- [ ] TestFlight build tested on **physical device**
- [ ] Screenshots current (if UI changed)
- [ ] App Store metadata updated if needed (see `project/APP_STORE_METADATA.md`)

### Release Steps

1. Merge all PRs to `main`
2. Verify CI is green
3. Update `MARKETING_VERSION` in Xcode if incrementing (e.g., `1.0` → `1.1`)
4. Create and push git tag:
   ```bash
   git tag v1.x.y
   git push origin v1.x.y
   ```
5. Xcode Cloud triggers TestFlight deployment (when configured)
6. Validate on TestFlight
7. Submit for App Store review via App Store Connect

### Post-Release

- [ ] Create GitHub Release with changelog at the tag
- [ ] Add session log entry to `project/PROJECT_STATUS.md`
- [ ] Close the release milestone (if using GitHub milestones)

### Hotfix Process

1. Branch from `main`: `git checkout -b hotfix/description`
2. Fix, test, PR back to `main`
3. Tag with next build number after merge

---

## Manual Setup: Xcode Cloud

> These steps must be done once in Xcode / App Store Connect. They cannot be automated via files.

### Enable Xcode Cloud

1. **In Xcode**: Product → Xcode Cloud → Create Workflow
2. **Grant access**: Connect App Store Connect to `github.com/remeadows/GridWatchZero`
3. **Verify scheme**: Xcode Cloud should detect the shared scheme `GridWatchZero`

### Create Workflows

**Workflow 1 — Build on Push to Main**
- Trigger: Push to `main`
- Action: Build for iOS
- Environment: Latest Xcode, latest iOS SDK

**Workflow 2 — PR Validation**
- Trigger: Pull request to `main`
- Action: Build + run tests (when test targets exist)
- Report: Build status on PR

**Workflow 3 — TestFlight Deploy**
- Trigger: Tag matching `v*`
- Action: Archive → Upload to App Store Connect → Distribute to TestFlight
- Auto-distribute to internal testing group

### Code Signing

Xcode Cloud manages code signing automatically when `CODE_SIGN_STYLE = Automatic`.

Verify after first build:
- [ ] Provisioning profile includes iCloud Key-Value Storage entitlement
- [ ] Provisioning profile includes Game Center entitlement
- [ ] Signed `.ipa` installs and runs correctly via TestFlight

---

## Manual Setup: Test Targets

> Test targets must be created in Xcode. They cannot be added via file creation alone.

### Create Unit Test Target

1. In Xcode: File → New → Target → Unit Testing Bundle
2. Product Name: `GridWatchZeroTests`
3. Target to Test: `GridWatchZero`
4. Language: Swift

### Create UI Test Target

1. In Xcode: File → New → Target → UI Testing Bundle
2. Product Name: `GridWatchZeroUITests`
3. Target to Test: `GridWatchZero`

### Priority Unit Tests

| Test Class | What to Test |
|------------|-------------|
| `GameEngineTests` | Tick processing, resource flow, threat progression |
| `DefenseSystemTests` | Category rates, damage reduction caps, risk reduction |
| `CampaignLevelTests` | All 20 levels load, victory conditions, grace periods |
| `SaveMigrationTests` | V1→V6 migration, corrupt save handling |
| `CertificateMaturityTests` | 40hr/60hr maturity, bonus calculation, multiplier range |

### Testing Notes

- `GameEngine` is `@MainActor` — tests need `@MainActor` annotation
- Use `UserDefaults(suiteName: "test")` to isolate test saves
- `ENABLE_TESTABILITY = YES` is already set in Debug configuration
- After creating test targets, update the shared scheme to include them

---

## Build Number Automation

The `ci_scripts/ci_post_clone.sh` script handles build number automation:

- **Xcode Cloud**: Uses `CI_BUILD_NUMBER` environment variable (unique per build)
- **Local development**: Unaffected — continues using the value in `project.pbxproj`
- **No manual edits needed** to `project.pbxproj` for build numbers after Xcode Cloud is enabled
