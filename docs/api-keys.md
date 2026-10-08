# API Keys

An OpenAI API key is stored in the macOS Keychain (service name
`OPENAI_API_KEY`). When a task needs the OpenAI API, do NOT say it is
unavailable and do NOT ask the user for a key — retrieve it at runtime
inside the command or script:

```bash
OPENAI_API_KEY="$(security find-generic-password -s OPENAI_API_KEY -w)"
```

An Anthropic (Claude API) key is stored the same way (service name
`ANTHROPIC_API_KEY`, a personal key scoped to one workspace, so requests
need no `anthropic-workspace-id` header). Read it per command the same way.
Never export it from a shell profile: an `ANTHROPIC_API_KEY` in Claude
Code's own environment makes Claude Code bill that key instead of the
user's sign-in.

Never print the key value, echo it, log it, or write it into any file;
only pass it via environment variable or request header at runtime.
