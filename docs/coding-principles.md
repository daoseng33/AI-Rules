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
- No error handling for impossible scenarios. Rare is not impossible: a full
  disk, an outage or a failed migration must be handled — see error-handling.md.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## Changing Existing Code

**Existing code may be improved. Every change needs a stated reason, a
predictable improvement, and proof that nothing broke.**

- Change existing code when you can name the concrete gain: a bug, a risk,
  duplication, a rule violation (e.g. error-handling.md), or code that makes
  the task harder than it should be. Taste alone is not a reason: match the
  existing style, even if you'd do it differently.
- Verify rigorously: tests pass before and after. If the code you touch has
  no tests, first add tests that pin its current behavior (for styling and
  scaffolding, follow Test scope under Goal-Driven Execution instead).
- Keep improvements outside the task in their own commit, and list each one
  in the final summary with its reason and expected effect.
- Delete dead code only after confirming nothing references it (search,
  build, tests).
- If an improvement would outgrow the task (many files, a public API, a data
  format), propose it as the next task instead.
- Remove imports/variables/functions that your changes made unused.

The test: every changed line traces to the user's request or to a stated,
verified improvement.

## Safe Value Access

**Avoid hardcoded values. Prefer safe value access.**

- No magic numbers or magic strings: extract them into named constants,
  enums, or configuration.
- Prefer safe access over assumptions: optional binding / default values
  instead of force-unwrapping or unchecked indexing.
- Secrets, URLs, and environment-specific values come from config or
  environment variables, never inline literals.

## Explicit State

**Model state as one value. Make invalid combinations unrepresentable.**

An implicit state machine is state spread over several fields, whose legal
combinations and transitions are written down nowhere. Treat code as one when:

- Two or more booleans or optionals together decide behavior, and some
  combination must never occur (`isLoading` with `error`, `isConnected`
  without a `session`).
- The same status string or flag is compared in several places, and no single
  place says which transitions are legal.
- Calls are only valid in an order that nothing enforces (B only after A).

Then:

- Use one sum type (an enum with associated data, a tagged union) with one
  case per state. Data that exists only in one state lives in that case.
- Handle it with an exhaustive `switch`/`match` and no catch-all default, so
  a new state fails to compile until every site handles it.
- Change state in one place, which rejects illegal transitions.
- Where the language has no sum types, use one status enum and keep the
  per-state data behind a constructor that validates the combination.

Boundaries:

- One boolean with two real states is fine. Flags that are independent and
  may combine freely are not a state machine.
- No state-machine library or framework unless the project already uses one.
- Model new code this way from the start. In review, fix what the diff adds
  or widens. An implicit state machine that was already there is reported in
  the final summary and proposed as the next task, unless it caused the bug
  being fixed (see Changing Existing Code).

## Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

Test scope: write the test first for logic, data handling, and bug fixes. For
visual styling, scaffolding, and prototypes, verify by running the app and
checking screenshots instead of adding test scaffolding, unless the project's
rules require tests.

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## Language Choice

**Prefer strongly typed, strict languages.**

- When the language is yours to choose (a new project, tool, or script),
  prefer a strongly typed language with strict compile-time rules, such as
  Rust.
- When the platform dictates the language, use its strictest option and
  settings (e.g. TypeScript with `strict` over JavaScript).
- In an existing project, keep the project's language.
