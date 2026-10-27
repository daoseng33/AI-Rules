# API Keys

An OpenAI API key and an Anthropic (Claude API) key are stored in the OS
credential store: the macOS Keychain or the Windows Credential Manager, named
`OPENAI_API_KEY` and `ANTHROPIC_API_KEY`. When a task needs one of these
APIs, do NOT say it is unavailable and do NOT ask the user for a key —
retrieve it at runtime inside the command or script, as shown below for each
OS. Read each key per command the same way. In Bash, a bare assignment is not
exported: use the variable in a request header, or prefix the command that
reads it (`OPENAI_API_KEY="$(...)" python app.py`). When a key is missing,
tell the user to add it themselves; never ask them to paste it into the chat.

The Anthropic key is a personal key scoped to one workspace, so requests need
no `anthropic-workspace-id` header. Never export it from a shell profile or
store it as a persistent environment variable (Windows: `setx` or System
Properties): an `ANTHROPIC_API_KEY` in Claude Code's own environment makes
Claude Code bill that key instead of the user's sign-in.

## macOS

Each key is a generic password whose service name is the key's name:

```bash
OPENAI_API_KEY="$(security find-generic-password -s OPENAI_API_KEY -w)"
```

## Windows

Each key is a generic credential whose target (the "Internet or network
address") is the key's name. `cmdkey` cannot read a password back, so read it
with `~/.ai-rules/scripts/get-secret.ps1` under PowerShell 7 (`pwsh`):

- Bash (Git Bash, e.g. Claude Code's Bash tool):

  ```bash
  OPENAI_API_KEY="$(pwsh -NoProfile -NonInteractive -File ~/.ai-rules/scripts/get-secret.ps1 OPENAI_API_KEY)"
  ```

- PowerShell (e.g. Claude Code's PowerShell tool, Codex):

  ```powershell
  $env:OPENAI_API_KEY = pwsh -NoProfile -NonInteractive -File "$HOME\.ai-rules\scripts\get-secret.ps1" OPENAI_API_KEY
  ```

The script exits 2 when the credential does not exist, 3 when it has no
password, and 1 on any other failure, with the reason on stderr. The user adds
a key in Control Panel > Credential Manager > Windows Credentials > Add a
generic credential, or in PowerShell with
`cmdkey /generic:OPENAI_API_KEY /user:api /pass`, which prompts for the value
(Git Bash would rewrite the bare `/pass` into a path). If `pwsh` is missing,
tell the user to install PowerShell 7 (`winget install Microsoft.PowerShell`).

## Never Expose the Key

Never print the key value, echo it, log it, or write it into any file;
only pass it via environment variable or request header at runtime. Both
retrieval commands print the key to stdout, so run them only inside an
assignment like the ones above, never on their own.
