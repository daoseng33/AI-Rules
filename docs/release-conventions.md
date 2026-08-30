# Release Conventions

## Version Tagging

- Immediately after every successful release (store submission / publish),
  create a version tag on the commit that produced the released artifact and
  push it to the remote.
- Follow the project's existing tag naming. For projects that release
  platforms separately, use `<platform>/v<version>` (e.g. `ios/v1.0.3`,
  `android/v1.0.3`); otherwise `v<version>`.
- A version number is released exactly once. An already-existing tag for the
  version being released signals a process error — never move or overwrite an
  existing tag.

## Re-release (rejection, hotfix re-submission)

- Any re-release bumps the version number and resets the build number to 1.
- Never reuse a version number or its tag for a different artifact.

## AI Decides the Version Bump

When the AI drives a release, it decides which SemVer part to bump from the
changes since the last release:

- **patch**: bug fixes, rejection fixes, metadata/config tweaks — no new
  features.
- **minor**: new features or behavior changes, backward compatible.
- **major**: breaking changes or major overhauls.

State the chosen version and the reasoning before releasing, then proceed.
When uncertain between two bumps, pick the smaller one and say why.
