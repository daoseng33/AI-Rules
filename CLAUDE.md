# CLAUDE.md

@docs/RTK.md

## Mandatory Requirements

- Use Traditional Chinese for all responses by default. Switch languages only when the user explicitly requests it.
- Before making changes, running tools, writing code, or planning implementation, first read the project's AI rules and follow them as the highest-priority project-level guidance.
- Prefer `rtk` for noisy developer commands like git, rg, npm, cargo, pytest.
For PowerShell cmdlets, filesystem operations, commands involving Unicode paths, quoting-heavy scripts, or when exact output matters, use native shell commands directly or `rtk proxy` only when helpful.

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

Topic-specific rules live under `docs/`. Read the relevant doc before
working in its domain:

- [docs/RTK.md](docs/RTK.md) — rtk CLI proxy reference (auto-imported above)
- [docs/git-conventions.md](docs/git-conventions.md) — commit prefix and
  body format; read before any commit

## Response Format

When finishing a task, summarize:

1. What changed
2. Files changed
3. Tests added or updated
4. How to verify manually
5. Known limitations
6. Suggested next task

## Think Before Coding

**Don't assume silently. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly, then proceed on them.
- If multiple interpretations exist, say which one you picked and why.
- If a simpler approach exists, say so. Push back when warranted.
- Stop and ask only when the ambiguity would lead to materially different
  work. Otherwise decide, name the call, and keep going.

## Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## Safe Value Access

**Avoid hardcoded values. Prefer safe value access.**

- No magic numbers or magic strings: extract them into named constants,
  enums, or configuration.
- Prefer safe access over assumptions: optional binding / default values
  instead of force-unwrapping or unchecked indexing.
- Secrets, URLs, and environment-specific values come from config or
  environment variables, never inline literals.

## Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

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
