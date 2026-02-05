#!/bin/bash
# ci_scripts/ci_post_clone.sh
# Xcode Cloud post-clone hook for Grid Watch Zero
#
# This script runs after Xcode Cloud clones the repository,
# before the build begins. It automates build number management.
#
# Environment variables provided by Xcode Cloud:
#   CI_BUILD_NUMBER             - Unique build number for this run
#   CI_PRIMARY_REPOSITORY_PATH  - Path to the cloned repository
#   CI_XCODE_PROJECT            - Path to the .xcodeproj
#   CI_BRANCH                   - Branch being built
#   CI_TAG                      - Tag being built (if tag-triggered)

set -e

echo "=== Grid Watch Zero: Post-Clone Script ==="
echo "Branch: ${CI_BRANCH:-local}"
echo "Tag: ${CI_TAG:-none}"

# ─── Build Number Automation ─────────────────────────────────────────
# Uses Xcode Cloud's CI_BUILD_NUMBER to set CURRENT_PROJECT_VERSION.
# This ensures every CI build has a unique, auto-incremented number
# without manual project.pbxproj edits.
#
# Local builds are unaffected — they continue using the value in
# project.pbxproj (currently 2).

if [ -n "$CI_BUILD_NUMBER" ]; then
    echo "Setting build number to: $CI_BUILD_NUMBER"
    cd "$CI_PRIMARY_REPOSITORY_PATH"
    agvtool new-version -all "$CI_BUILD_NUMBER"
    echo "Build number set successfully."
else
    echo "Not running in Xcode Cloud — skipping build number automation."
fi

# ─── Alternative: Git-Based Build Number (commented out) ─────────────
# Uncomment to use git commit count instead of CI_BUILD_NUMBER.
# Pros: Deterministic, reproducible. Cons: Can conflict on branches.
#
# if [ -n "$CI_PRIMARY_REPOSITORY_PATH" ]; then
#     cd "$CI_PRIMARY_REPOSITORY_PATH"
#     BUILD_NUMBER=$(git rev-list --count HEAD)
#     echo "Setting git-based build number to: $BUILD_NUMBER"
#     agvtool new-version -all "$BUILD_NUMBER"
# fi

echo "=== Post-Clone Complete ==="
