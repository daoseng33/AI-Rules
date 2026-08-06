# CLAUDE.md

@RTK.md

## Mandatory Requirements

- Use Traditional Chinese for all responses by default. Switch languages only when the user explicitly requests it.
- Before making changes, running tools, writing code, or planning implementation, first read the project's AI rules and follow them as the highest-priority project-level guidance.
- Prefer `rtk` for noisy developer commands like git, rg, npm, cargo, pytest.
For PowerShell cmdlets, filesystem operations, commands involving Unicode paths, quoting-heavy scripts, or when exact output matters, use native shell commands directly or `rtk proxy` only when helpful.

## Response Format

When finishing a task, summarize:

1. What changed
2. Files changed
3. Tests added or updated
4. How to verify manually
5. Known limitations
6. Suggested next task

## Git Control

### Commit Prefix

- `feat:` New feature (MINOR)
- `fix:` Bug fix (PATCH)
- `docs:` Documentation only
- `style:` Formatting only
- `refactor:` Code restructuring without behavior changes
- `test:` Test changes
- `chore:` Maintenance
- `build:` Build system changes
- `ci:` CI/CD changes
- `perf:` Performance improvements
- `revert:` Revert previous commit

### Commit Body

- Use `-` bullet points.
- Maximum 3 bullet points.

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
