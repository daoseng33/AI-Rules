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
├── AGENTS.md            Shared entry point: baseline rules + Docs Index (~100 lines)
├── CLAUDE.md            Claude Code entry point: imports AGENTS.md and docs/RTK.md
├── docs/                Topic rules, read before working in their domain
│   ├── RTK.md
│   ├── api-keys.md
│   ├── coding-principles.md
│   ├── error-handling.md
│   ├── git-conventions.md
│   ├── image-generation.md
│   └── release-conventions.md
└── scripts/
    ├── get-secret.ps1
    ├── install-macos.sh
    └── install-windows.ps1
```

## What the Rules Cover

**`AGENTS.md`** — loaded in every session:

| Section | Summary |
|---|---|
| Mandatory Requirements | Reply in Traditional Chinese; read the project's AI rules first; use `rtk` for noisy output |
| Rules Organization | The entry file is a map; topic rules live in `docs/`; write rules tool-neutrally |
| Docs Index | Each topic doc and when to read it |
| Code Review | After any code change, review the diff and apply fixes (Claude Code: `/code-review xhigh --fix`) |
| Response Format | Finish with: what changed, files, tests, how to verify, limitations, next task |
| Autonomous Execution | Decide and verify yourself; hand off to a human only for decisions, human-only QA, or unsafe assumptions |

**`docs/`** — read on demand:

| File | Read before | Summary |
|---|---|---|
| `coding-principles.md` | Planning or writing code | Think before coding, simplicity first, improving existing code with stated reasons and verification, safe value access, goal-driven execution and test scope, strict typed languages such as Rust |
| `error-handling.md` | Writing code that can fail | Classify errors, handle once, user-facing failures, retry, cancellation, log privacy, non-fatals, no silent swallowing, failure-path tests |
| `git-conventions.md` | Any commit | Commit prefixes; body as up to 3 `-` bullets |
| `release-conventions.md` | Any release | Tag every release, bump the version on re-release, AI picks the SemVer bump |
| `api-keys.md` | Tasks needing an API key | OpenAI and Anthropic keys come from the macOS Keychain or Windows Credential Manager at runtime, never printed |
| `image-generation.md` | Creating an image | Make images locally first; paid image tools only on explicit request |
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

## Update

- macOS: `git -C ~/.ai-rules pull`.
- Windows: `git -C ~/.ai-rules pull`, then re-run
  `~/.ai-rules/scripts/install-windows.ps1` (Codex uses a copy).
- A machine set up before `~/.ai-rules` existed (only `~/.claude/CLAUDE.md`
  linked to the clone) must run its install script once after pulling.
  Without `~/.ai-rules`, Claude Code's imports load nothing and it runs with no
  global rules.

## Verify

- Claude Code: start a new session, run `/context`, and check that
  `CLAUDE.md` and `AGENTS.md` are listed under Memory files.
- Codex: start a new session and ask what its global rules say about code
  review for Codex.

## Editing the Rules

- Shared rules go in `AGENTS.md` or `docs/`. Keep `AGENTS.md` around 100 lines
  and move single-domain rules into `docs/`.
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
