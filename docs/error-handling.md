# Error Handling

**Every failure is classified, handled once where something can be done
about it, shown to the user when it changes what they see, keep or pay for,
and visible to the developer when it was not expected. Nothing is swallowed
silently.**

These rules apply to every project and language (Swift/iOS, Kotlin/Android,
JS workers). A project's own docs add its concrete types, surfaces and codes;
where they are stricter, they win. "No error handling for impossible
scenarios" (coding-principles.md) still holds — but rare is not impossible:
a full disk, a failed migration, a server outage, clock skew and a locked
Keychain all happen and must be handled.

## Classify

- Put every caught error in one class: **cancelled**; **expected condition**
  (offline, timeout, quota or limit, permission denied, a documented
  refusal); **transient** (a retry may help); **permanent** (configuration,
  contract, corrupt data); **programmer error**.
- Classify with one shared helper per platform (cancellation, offline and
  timeout codes in one table). Clients never keep their own copies.
- Map library and transport errors to domain errors at the client boundary.
  `AFError`, OkHttp exceptions or a fetch `TypeError` never reach a caller.
- Keep the HTTP status and the server's machine-readable code on the domain
  error. Never collapse distinct statuses or refusal codes into one case.

## Propagate or Handle

- Catch an error only where you can show it, retry, fall back or compensate.
  Otherwise let it propagate.
- An operation whose failure the caller must react to says so in its
  signature (`throws`, `Result`, `Bool`) — best-effort writes included. Never
  announce success for a write that was not verified.
- Never delete, clear, filter out, overwrite or write back data because a
  read failed. Tell **absent** apart from **unreadable**, and act
  destructively only on a successful read.
- A failed write leaves the store unchanged: roll back on failure, and commit
  one user action in one transaction.
- Never advance a cursor, mark an item done or drop it from a queue unless
  processing it succeeded. Quarantine a poison item and record why, instead
  of retrying it forever or skipping it silently.

## What the User Sees

- A failure that changes what the user sees, keeps or is charged for gets a
  plain-language notice where it matters. Silence is allowed only when the
  outcome is identical to success from the user's side.
- A failed load is shown as a failed load (a neutral note with a retry), never
  as empty or default data.
- A message says what did not happen, what is still safe, and the next step.
  The advice matches the cause (never "retake the photo" for a server
  outage), and a button matches its text.
- Keep the user's input: a form, sheet or picker stays open until the
  operation succeeded.
- Use one surface per kind, from the app's existing set: inline for a failed
  save, a toast for a list action, an inline note with retry for a failed
  load or a degraded feature, an alert only for a decision or a trip to
  Settings.
- Never show "loading" and "failed" at once. A failed state offers a retry,
  or says why there is none.
- Confirm only after the operation completed. A state change the user did not
  cause (a forced sign-out, a setting that did not apply) is told once, with
  the way to fix it.
- Error copy follows the product's tone and is localized like any other copy.

## Recovery and Retry

- Retry automatically only idempotent operations, or ones carrying an
  idempotency key. Never auto-retry a request that spends, rotates or
  consumes something.
- Every retry has backoff and a cap. A permanent failure (a 4xx contract
  error) is never retried as if it were transient.
- When the server refunds or rolls back a failed request, re-sync the local
  mirror of that counter on every failure path.
- Clear a session only on responses that name the credential as dead. When an
  access token is rejected, force one refresh and one retry before failing.
- A failure that can heal is retried on a natural trigger (screen appears,
  foreground, reconnect), not only after a relaunch.
- When an optional step fails, fall back to the degraded path and log that it
  did.

## Cancellation

- Cancellation is never a failure: never shown, never logged as an error,
  never reported.
- Detect it with the shared helper, covering every form: `CancellationError`
  and `URLError.cancelled`; `CancellationException`; `AbortError`.
- Propagate it; never map it to a generic or server error. In Kotlin, rethrow
  `CancellationException` from any catch-all. Wrap callback APIs so that
  cancelling the task cancels the underlying work.

## Logging

- Log a caught failure once, at the layer that handles it, with the
  operation and the error's type, domain and code.
- Levels: **error** for unexpected failures of our own code or storage;
  **notice/warning** for expected external failures; **info** for notable
  success; **debug** for diagnostics.
- Only static text, enum-like codes, statuses, counts and ids that identify no
  one may be public. Error descriptions, user-typed text, ids derived from it,
  URLs carrying identifiers, tokens and health values are private or redacted.
  In OSLog, leave `\(error)` at its default (private) privacy.
- Never log a secret, even partially, and never print a config value to check
  it; check that it is present.

## Crashes and Non-Fatals

- Report every caught failure that is unexpected (not cancelled, not an
  expected condition) as a non-fatal: the operation, the error's domain and
  code, and a whitelisted detail (status, server code) — never the
  description or user data. A catch that only logs is a defect unless the log
  is all the failure can ever mean.
- A new subsystem adds its non-fatal operation codes in the same change that
  adds its catches. Codes are stable and never reused.
- Deduplicate by (operation, error domain, code), not by operation alone, and
  do not report expected conditions.
- Missing release configuration fails the build or is reported at launch; it
  never silently turns features off.
- Crash on purpose only for programmer errors. A startup failure caused by
  data, disk or a migration leads to a recovery screen, never a crash loop.
- A persisted-schema change ships with an explicit version or migration and a
  test that opens a store written by the previous release.

## Never Swallow Silently

`try?`, an empty catch, `runCatching {}.getOrNull()` and `.catch(() => {})`
are allowed only where "absent" is a complete, correct answer and the failure
needs no developer visibility: sleeps, cleanup of files nothing references,
parses with a defined fallback, previews and test fixtures. When that is not
self-evident, a one-line comment says why. Never use them on a write the user
asked for, on device or session setup, on reading state the user owns, or
where the absent value leads to a delete, clear, filter or overwrite.

## Tests

- Every user-visible failure branch has a test. A pure function mapping an
  error to copy, a route or a retry gets parameterized tests over every case;
  each kind of failure surface gets at least one UI or integration test.
- Every dependency that can fail has a test double or debug scenario for each
  failure the app tells apart: offline, timeout, server error, refusal,
  decode failure, local write failure.
- Error mapping and routing live outside view bodies, in one copy every
  screen calls.
- The crash and non-fatal reporter is injectable, so a test can assert that a
  failure was reported — and that the report carries no description.
