# Coding Principles

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
