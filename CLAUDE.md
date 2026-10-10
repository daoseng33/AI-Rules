# CLAUDE.md

@docs/RTK.md

## Mandatory Requirements

- Use Traditional Chinese for all responses by default. Switch languages only when the user explicitly requests it.
- Before making changes, running tools, writing code, or planning implementation, first read the project's AI rules and follow them as the highest-priority project-level guidance.
- Prefer `rtk` for noisy developer commands like git, rg, npm, cargo, pytest.
For PowerShell cmdlets, filesystem operations, commands involving Unicode paths, quoting-heavy scripts, or when exact output matters, use native shell commands directly or `rtk proxy` only when helpful.

## Image Generation

Paid image APIs cost money per call. Make images yourself first: HTML/CSS/SVG
rendered locally (headless Chrome), Pillow composites, and assets already in
the project. Call a paid image API (OpenAI `gpt-image-*`, Gemini, the
media-pipeline `image-generation` skill / CLI / `create_asset`) only when the
user explicitly asks for one in the current request. This overrides any skill
that says to generate images automatically.

## Rules Organization

**CLAUDE.md is a map, not an encyclopedia.**

Follow the layered docs structure from OpenAI's harness engineering practice
(https://openai.com/index/harness-engineering/):

- CLAUDE.md holds only baseline rules plus a table of contents pointing to
  deeper docs. Keep it short (~100 lines).
- Topic-specific rules (technical architecture, design, plans, references)
  live as separate files under `docs/`, indexed and cross-linked from the
  CLAUDE.md table of contents.
- Prefer progressive disclosure: give the agent a small, stable entry point
  that says where to look next, instead of front-loading everything.
- When a rule grows beyond a few lines or covers a single domain, move it
  into `docs/` and leave a link in CLAUDE.md.

## Docs Index

Topic-specific rules live under `docs/` in the AI-Rules repo, exposed
globally via the `~/.claude/docs` symlink. Always use the `~/.claude/docs/`
paths below — relative `docs/` paths would wrongly resolve to the current
project's own `docs/` directory. Read the relevant doc before working in
its domain:

- [~/.claude/docs/RTK.md](~/.claude/docs/RTK.md) — rtk CLI proxy reference
  (auto-imported above)
- [~/.claude/docs/git-conventions.md](~/.claude/docs/git-conventions.md) —
  commit prefix and body format; read before any commit
- [~/.claude/docs/release-conventions.md](~/.claude/docs/release-conventions.md) —
  version tagging, re-release version bump + build reset, AI-decided SemVer
  bump; read before any release
- [~/.claude/docs/coding-principles.md](~/.claude/docs/coding-principles.md) —
  Think Before Coding, Simplicity First, Surgical Changes, Safe Value Access,
  Goal-Driven Execution; read before planning, writing, or editing code
- [~/.claude/docs/api-keys.md](~/.claude/docs/api-keys.md) — an OpenAI API
  key is available via macOS Keychain; read before any task that needs it

## Code Review

After finishing each feature, run `/code-review xhigh --fix` (the
`code-review` skill with args `xhigh --fix`) before the final summary.
Skip it only when the user says not to review; when the user names a
different effort level, use that level instead.

## Response Format

When finishing a task, summarize:

1. What changed
2. Files changed
3. Tests added or updated
4. How to verify manually
5. Known limitations
6. Suggested next task

## Autonomous Execution

**Decide it yourself. Only stop for humans when you genuinely can't.**

Default: finish the whole task without checking in. Routine judgment calls
(naming, file layout, which library is already in use, test structure) are
yours to make - state the assumption and keep going.

Stop and hand back to a human ONLY when:
- A human decision is required: product/scope tradeoffs, irreversible or
  outward-facing actions, credentials, spending, anything with no
  recoverable wrong answer.
- Manual QA is required: the result can only be judged by a human looking at
  it (visual/UX, device-specific behavior, third-party integration).
- Proceeding under any assumption would be unsafe, or would make the work
  useless if the assumption turns out wrong.

Not reasons to stop:
- "I want to confirm before continuing."
- "There are two reasonable approaches." → pick one, say which and why.
- "One sub-step is blocked." → finish everything else, then report what is
  left and why.
