# API Keys

An OpenAI API key is stored in the macOS Keychain (service name
`OPENAI_API_KEY`). When a task needs the OpenAI API, do NOT say it is
unavailable and do NOT ask the user for a key — retrieve it at runtime
inside the command or script:

```bash
OPENAI_API_KEY="$(security find-generic-password -s OPENAI_API_KEY -w)"
```

Never print the key value, echo it, log it, or write it into any file;
only pass it via environment variable or request header at runtime.
