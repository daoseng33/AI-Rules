# Git Conventions

## Commit Prefix

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

## Commit Body

- Use `-` bullet points.
- Maximum 3 bullet points.

## Verification Trailer

Every commit ends with a `Verified:` trailer that says how the change was
checked. It sits in the final trailer block, with any other trailer, and is
not one of the body's 3 bullets. `~/.ai-rules/hooks/commit-msg` rejects an
agent session's commit without a well-formed one and prints the format.

- `tests` — the automated tests covering the change ran and passed
- `build` — it compiled, type-checked or linted clean
- `run` — the app or command was run and the change was seen working
- `review` — the diff went through the code review in AGENTS.md
- `none (<reason>)` — nothing was run, e.g. `none (docs only)`

List every one that applies, comma-separated: `Verified: tests, run, review`.

The hook checks that a stamp is there, not that it is true, and some commits
never reach it. Those are yours to get right:

- Write only what happened for this change. A false stamp defeats the query
  below as surely as a missing one.
- A cherry-pick is not checked: it copies a commit as it stands.
  `git revert --no-edit` never reaches the hook, so stamp a revert yourself:
  `git revert --no-commit`, then commit with the trailer.
- A squash merge is written by the host, not by the hook. The squashed
  commit's message must end with one stamp for the whole change: check what
  the host will write, and pass the stamp in the merge body when it would be
  dropped or left in the middle of the message.

```bash
git log --grep='^Verified: none'             # commits nothing checked
git log --invert-grep --grep='^Verified: '   # commits with no stamp
```
