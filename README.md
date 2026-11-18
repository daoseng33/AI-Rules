# AI-Rules

One set of global rules for AI coding agents, shared by **Claude Code** and
**Codex** from a single source of truth.

## How It Works

| Tool | Global file it loads | What that file is |
|---|---|---|
| Claude Code | `~/.claude/CLAUDE.md` | This repo's `CLAUDE.md`, which imports `AGENTS.md` and `docs/RTK.md` |
| Codex | `~/.codex/AGENTS.md` | This repo's `AGENTS.md` (Codex has no import mechanism) |

`~/.ai-rules` points at this clone. Both tools read the topic docs on demand
through the Docs Index in `AGENTS.md`, which uses `~/.ai-rules/docs/...` paths
so the links resolve from any project.

## Repository Layout

```
AI-Rules/
├── AGENTS.md            Shared entry point: baseline rules + Docs Index
├── CLAUDE.md            Claude Code entry point: imports AGENTS.md and docs/RTK.md
├── docs/                Topic rules, read before working in their domain
│   ├── RTK.md
│   ├── api-keys.md
│   ├── autonomous-execution.md
│   ├── coding-principles.md
│   ├── error-handling.md
│   ├── git-conventions.md
│   ├── image-generation.md
│   ├── obsidian-vault.md
│   └── release-conventions.md
├── hooks/
│   ├── commit-msg       Git hook: an agent's commit needs a Verified: trailer
│   └── tests/           Its test suite
└── scripts/
    ├── get-secret.ps1
    ├── install-macos.sh
    └── install-windows.ps1
```

## What the Rules Cover

**`AGENTS.md`** — loaded in every session:

| Section | Summary |
|---|---|
| Mandatory Requirements | Reply in Traditional Chinese; read the project's AI rules first; use `rtk` for noisy output; ask before any call that costs money or plan credits |
| Rules Organization | The entry file is a map; topic rules live in `docs/`; write rules tool-neutrally; prune a rule when another replaces it or a check enforces it |
| Corrections Become Checks | Turn a correction into a type, lint rule, test or hook first; prose only when it needs judgment; a bug review missed goes in the project's Review Checklist |
| Docs Index | Each topic doc and when to read it |
| Code Review | After any code change, review the diff and apply fixes (Claude Code: `/code-review high --max-findings all --fix`); read the project's `Review Checklist` first |
| Response Format | Finish with: what changed, files, tests, verification evidence, limitations, next task |
| Autonomous Execution | Decide and verify yourself; hand off to a human only for decisions, human-only QA, unsafe assumptions, or a check still failing after three fix rounds (details in `docs/autonomous-execution.md`) |

**`docs/`** — read on demand:

| File | Read before | Summary |
|---|---|---|
| `coding-principles.md` | Planning or writing code | Think before coding, simplicity first, improving existing code with stated reasons and verification, safe value access, explicit state instead of implicit state machines, goal-driven execution, test scope and working under a Claude Code `/goal`, honest checks (never weaken a check to pass, how to treat a flaky test), strict typed languages such as Rust |
| `error-handling.md` | Writing code that can fail | Classify errors, handle once, user-facing failures, retry, cancellation, log privacy, non-fatals, no silent swallowing, failure-path tests |
| `git-conventions.md` | Any commit | Commit prefixes; body as up to 3 `-` bullets; a `Verified:` trailer on every commit saying how it was checked, enforced by the commit hook |
| `release-conventions.md` | Any release | Tag every release, bump the version on re-release, AI picks the SemVer bump |
| `api-keys.md` | Tasks needing an API key | OpenAI and Anthropic keys come from the macOS Keychain or Windows Credential Manager at runtime, never printed; ask before a paid call |
| `image-generation.md` | Creating an image | Make images locally first; ask before using a paid image tool |
| `obsidian-vault.md` | The owner makes a project decision, or reading or writing the vault | Decision-log format, what may be written to the owner's Obsidian vault, git backup around automated writes |
| `autonomous-execution.md` | Stopping to ask the user | The full stop conditions, the three-round limit on a failing check, and the non-reasons to stop |
| `RTK.md` | Noisy commands | When to use or avoid `rtk`, and how each tool integrates it |

## Install

### macOS

```bash
git clone https://github.com/daoseng33/AI-Rules.git ~/Workspace/AI-Rules
~/Workspace/AI-Rules/scripts/install-macos.sh
```

The script creates symlinks, so edits and `git pull` take effect in the next
session:

- `~/.ai-rules` → the clone
- `~/.claude/CLAUDE.md` → `CLAUDE.md`
- `~/.codex/AGENTS.md` → `AGENTS.md`
- `~/.claude/docs` → `docs/` (legacy path, see History)

It also writes two keys to the global git config, which install the
[commit hook](#commit-hook) for every repo on the machine.

### Windows (PowerShell)

```powershell
git clone https://github.com/daoseng33/AI-Rules.git $HOME\Workspace\AI-Rules
powershell -ExecutionPolicy Bypass -File $HOME\Workspace\AI-Rules\scripts\install-windows.ps1
```

File symlinks need admin rights on Windows, so the script instead:

- links `~/.ai-rules` (and the legacy `~/.claude/docs`) with directory
  junctions,
- writes `~/.claude/CLAUDE.md` as a one-line import of `~/.ai-rules/CLAUDE.md`,
- copies `AGENTS.md` to `~/.codex/AGENTS.md`.

Both scripts back up an existing file or directory as `<name>.bak.<timestamp>`
before replacing it (an existing link is replaced and its old target printed),
restore the previous state if a step fails, honor `CLAUDE_CONFIG_DIR` and
`CODEX_HOME`, warn when a `~/.codex/AGENTS.override.md` would shadow the
rules, and are safe to re-run, including from the `~/.ai-rules` path.

## Commit Hook

`hooks/commit-msg` rejects a commit made from an AI agent session unless its
message ends with a well-formed `Verified:` trailer
(`docs/git-conventions.md`). The message it prints gives the line to add.

- **Who it checks.** A session whose commands carry `AI_AGENT` or
  `CLAUDECODE`. Claude Code sets both. A commit made by hand passes.
- **Tools that commit for the agent.** A script or release tool run from an
  agent session (fastlane's `commit_version_bump`, `npm version`) is checked
  like any other commit and fails halfway without a stamp. Put the trailer in
  the message that tool writes, e.g. `Verified: none (version bump)`, or use
  the off switch below in that repo.
- **Codex.** Whether Codex sets either marker has not been checked. To mark
  its sessions yourself, add this to `~/.codex/config.toml` (not done by the
  install script, and not yet tried against a Codex session):

  ```toml
  [shell_environment_policy]
  set = { AI_AGENT = "codex" }
  ```

- **How it is installed.** As a config-based hook in the global git config
  (`hook.ai-rules-verified.event` and `.command`), so it applies to every
  repo and each repo's own `.git/hooks` keep running beside it. This needs
  Git 2.54 or later; an older Git ignores the keys, and the install script
  warns.
- **Switch it off in one repo:**
  `git config hook.ai-rules-verified.enabled false`.
- **Remove it:** `git config --global --remove-section hook.ai-rules-verified`.
- **What it does not check.** Whether the stamp is true; merge commits,
  rebases, cherry-picks and autosquash commits, which it lets through;
  `git revert --no-edit` and a host's squash merge, which never run it; and
  a commit an agent makes through a git MCP server or a GUI, whose process
  carries no marker.
- **Windows.** `install-windows.ps1` does not install the hook, and the hook
  is untested there. To try it, set the two keys by hand from Git Bash, with
  the same command `install-macos.sh` writes:

  ```bash
  git config --global hook.ai-rules-verified.event commit-msg
  git config --global hook.ai-rules-verified.command 'h="$HOME/.ai-rules/hooks/commit-msg"; [ -x "$h" ] || { echo "ai-rules: $h is missing or not executable; the Verified: trailer is not checked" >&2; exit 0; }; "$h"'
  ```

Run its tests with `hooks/tests/commit-msg-test.sh`. They install the hook
into a throwaway `HOME` and never touch the real git config. CI runs them on
every pull request and on `main`, on macOS and Ubuntu
(`.github/workflows/hook-tests.yml`).

## Update

- macOS: `git -C ~/.ai-rules pull`.
- Windows: `git -C ~/.ai-rules pull`, then re-run
  `~/.ai-rules/scripts/install-windows.ps1` (Codex uses a copy).
- A machine set up before `~/.ai-rules` existed (only `~/.claude/CLAUDE.md`
  linked to the clone) must run its install script once after pulling.
  Without `~/.ai-rules`, Claude Code's imports load nothing and it runs with no
  global rules.
- A macOS machine set up before the commit hook existed must run
  `install-macos.sh` once after pulling; until then no commit is checked.

## Verify

- Claude Code: start a new session, run `/context`, and check that
  `CLAUDE.md` and `AGENTS.md` are listed under Memory files.
- Codex: start a new session and ask what its global rules say about code
  review for Codex.

## Editing the Rules

- Shared rules go in `AGENTS.md` or `docs/`. Keep `AGENTS.md` short and move
  single-domain rules into `docs/`.
- Every new doc gets a Docs Index entry that says when to read it.
- When a step differs per tool, list each tool's variant in place. Put a rule
  only Claude Code needs in `CLAUDE.md`, after the imports. A rule only Codex
  needs stays in `AGENTS.md`, because Codex cannot import files.
- Commit messages follow `docs/git-conventions.md`.

## History

Codex rules used to live in the separate `daoseng33/codex-config` repo, now
archived. Topic docs used to live at `~/.claude/docs`; the install scripts
still link that path because some projects' rules reference it. Use
`~/.ai-rules/docs` in new references.
