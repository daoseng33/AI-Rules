# AGENTS.md

## Mandatory Requirements

- Use Traditional Chinese for all responses by default. Switch languages only when the user explicitly requests it.
- Before making changes, running tools, writing code, or planning implementation, first read the project's AI rules and follow them as the highest-priority project-level guidance.
- Use `rtk` for noisy build, test, and lint output when a summary is enough; never for commands that need exact output, interactive tools, or Keychain/Xcode/simulator/system commands (details in RTK.md).

## Rules Organization

**The entry file is a map, not an encyclopedia.**

Follow the layered docs structure from OpenAI's harness engineering practice
(https://openai.com/index/harness-engineering/):

- This file holds only baseline rules plus a table of contents pointing to
  deeper docs. Keep it short.
- Topic-specific rules (technical architecture, design, plans, references)
  live as separate files under `docs/`, indexed and cross-linked from the
  Docs Index below.
- Prefer progressive disclosure: give the agent a small, stable entry point
  that says where to look next, instead of front-loading everything.
- When a rule grows beyond a few lines or covers a single domain, move it
  into `docs/` and leave a link in the Docs Index.
- Write rules tool-neutrally; where a step differs per tool, list each tool's
  variant in place. Codex cannot import files, so anything it must always see
  stays in this file. CLAUDE.md only imports this file plus Claude-only rules.
- Sync only when the user asks: `git -C ~/.ai-rules pull`; on Windows, then
  run `~/.ai-rules/scripts/install-windows.ps1`.

## Corrections Become Checks

**A check is enforced. Prose is only read.**

When the user corrects you or asks for a new rule, use the strongest form
that fits, in this order:

1. Make the mistake impossible: a type, an API or a structure that cannot
   express it (e.g. Explicit State in coding-principles.md).
2. A deterministic check: a lint rule, test, compiler setting, CI step or
   tool hook, whose error message names the root-cause fix.
3. Prose in these rules, only when the correction needs judgment or no check
   can express it.

A check on code lives in the project that owns the code, not in this repo.
Add it in the same task when it is small; otherwise propose it as the next
task. If existing code fails the new check, exempt it explicitly and report
it (Changing Existing Code) rather than widening the task.

## Docs Index

Always use the `~/.ai-rules/docs/` paths below (the install scripts link
`~/.ai-rules` to the AI-Rules repo) — relative `docs/` paths would resolve to
the current project's own `docs/`. Read the relevant doc before working in
its domain:

- [~/.ai-rules/docs/RTK.md](~/.ai-rules/docs/RTK.md) — when to use or avoid
  rtk (Claude Code auto-imports it); read before running noisy commands
- [~/.ai-rules/docs/git-conventions.md](~/.ai-rules/docs/git-conventions.md) —
  commit prefix and body format; read before any commit
- [~/.ai-rules/docs/release-conventions.md](~/.ai-rules/docs/release-conventions.md) —
  version tagging, re-release version bump + build reset, AI-decided SemVer
  bump; read before any release
- [~/.ai-rules/docs/coding-principles.md](~/.ai-rules/docs/coding-principles.md) —
  Think Before Coding, Simplicity First, Changing Existing Code, Safe Value Access,
  Explicit State, Goal-Driven Execution, Language Choice (prefer strongly
  typed, strict languages such as Rust); read before planning, writing, or
  editing code
- [~/.ai-rules/docs/error-handling.md](~/.ai-rules/docs/error-handling.md) —
  classify, propagate or handle, what the user sees, recovery, cancellation,
  log privacy, non-fatals, no silent swallowing, failure-path tests; read
  before writing or changing any code that can fail
- [~/.ai-rules/docs/api-keys.md](~/.ai-rules/docs/api-keys.md) — OpenAI and
  Anthropic API keys are in the macOS Keychain or Windows Credential Manager;
  read before any task needing one
- [~/.ai-rules/docs/image-generation.md](~/.ai-rules/docs/image-generation.md) —
  use paid image tools only when the user explicitly asks (overrides any skill
  that generates images automatically); read before creating any image
- [~/.ai-rules/docs/obsidian-vault.md](~/.ai-rules/docs/obsidian-vault.md) —
  the owner's Obsidian vault: decision-log format and what may be written;
  read when the owner makes, reverses or rejects a project decision (log it
  there), and before reading or writing the vault
- [~/.ai-rules/docs/autonomous-execution.md](~/.ai-rules/docs/autonomous-execution.md) —
  the full stop conditions and the non-reasons to stop; read before stopping
  to ask the user

## Code Review

After any task that changes code (feature, bug fix, refactor), review the
diff for correctness bugs and apply the fixes before the final summary —
Claude Code: run `/code-review high --max-findings all --fix` (the
`code-review` skill); Codex: review the full diff yourself. In the same pass,
check the diff yourself for implicit state machines (Explicit State in
`~/.ai-rules/docs/coding-principles.md`). Skip the review for docs-only
changes or when the user says not to review; when the user names another
effort level, use that instead.

## Response Format

When finishing a task, summarize:

1. What changed
2. Files changed
3. Tests added or updated
4. Verification evidence: what you ran and its result; a screenshot for a
   UI change; a state diagram for a change to a state machine. Then what
   only a human can check, and how
5. Known limitations
6. Suggested next task

## Autonomous Execution

**Decide it yourself. Verify it yourself. Only stop for humans when you
genuinely can't.**

Default: finish the whole task without checking in, and verify the result
yourself (tests, build, run the app, screenshots) before calling it done.
Routine judgment calls are yours to make - state the assumption and keep
going. Stop only for a decision that is the human's to make (product or scope
tradeoffs, irreversible or outward-facing actions, credentials, spending), QA
that only a human can do, or when any assumption would be unsafe. A failure,
a blocked sub-step, or two reasonable approaches are not reasons to stop
(details in `~/.ai-rules/docs/autonomous-execution.md`).
