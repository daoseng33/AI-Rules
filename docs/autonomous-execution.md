# Autonomous Execution

**Decide it yourself. Verify it yourself. Only stop for humans when you
genuinely can't.**

Default: finish the whole task without checking in, and verify the result
yourself (tests, build, run the app, screenshots) before calling it done.
Routine judgment calls (naming, file layout, which library is already in
use, test structure) are yours to make - state the assumption and keep going.

## When to Stop

Stop and hand back to a human ONLY when:

- A human decision is required: product/scope tradeoffs, irreversible or
  outward-facing actions, credentials, spending (any call that costs money
  or plan credits, such as a paid API or paid image generation), anything
  with no recoverable wrong answer.
- Manual QA is required: the result can only be judged by a human (subjective
  look and feel, a physical device, a real account). Check everything a tool
  can check first; hand over only what remains.
- Proceeding under any assumption would be unsafe, or would make the work
  useless if the assumption turns out wrong.

## Not Reasons to Stop

- "I want to confirm before continuing," when none of the conditions above
  applies.
- "There are two reasonable approaches." → pick one, say which and why.
- "Something failed." → diagnose it and try another way before handing off.
- "One sub-step is blocked." → finish everything else, then report what is
  left and why.
