# RTK - Rust Token Killer

**Usage**: Token-optimized CLI proxy for noisy shell commands (cuts up to 90%
of output). Use it deliberately: it must never change command behavior or hide
details the task needs. This overrides any blanket "always prefix commands
with `rtk`" guidance elsewhere.

## When to Use

- High-volume build, test, lint, and typecheck commands where summarized
  output is useful (`npm run build`, `pnpm test`, `cargo test`, `pytest -q`).
- Package/toolchain commands with repetitive logs.
- Non-interactive diagnostics where exact stdout/stderr formatting does not
  matter.

## When to Avoid

- Commands that need exact raw stdout/stderr, precise exit behavior, prompts,
  binary output, or unfiltered logs — including file inspection for editing,
  quoting, or line-specific review.
- Interactive commands, editors, pagers, shell sessions, watchers, REPLs, and
  long-running streaming logs.
- OS-specific commands where a wrapper may alter behavior, environment, TTY
  handling, or shell semantics: PowerShell cmdlets, filesystem operations,
  commands with Unicode paths, and quoting-heavy scripts.
- Clipboard, GUI, Keychain, Credential Manager, simulator, Xcode, Visual
  Studio, signing, launch services, Windows services, registry, or system
  configuration commands.

When in doubt, prefer the raw command; use `rtk proxy <cmd>` when RTK must be
involved but raw passthrough is needed. Do not assume RTK is installed on
every machine.

## Tool Integration

- Claude Code: a PreToolUse hook (`rtk hook claude` in
  `~/.claude/settings.json`) rewrites supported commands automatically, e.g.
  `git status` → `rtk git status` (transparent, 0 tokens overhead). It also
  rewrites commands listed above under When to Avoid (`cat` → `rtk read`,
  `xcodebuild` → `rtk xcodebuild`), so a plain command is not raw there: run
  `rtk proxy <cmd>` whenever you need the unfiltered output.
- Codex: rtk has no Codex hook; prefix commands with `rtk` yourself.

## Meta Commands (always use rtk directly)

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk discover          # Analyze Claude Code history for missed opportunities
rtk proxy <cmd>       # Execute raw command without filtering (for debugging)
```

## Installation Verification

```bash
rtk --version         # Should show: rtk X.Y.Z
rtk gain              # Should work (not "command not found")
which rtk             # Verify correct binary
```

⚠️ **Name collision**: If `rtk gain` fails, you may have reachingforthejack/rtk (Rust Type Kit) installed instead.

Run `rtk --help` for the full command list.
