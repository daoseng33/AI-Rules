# Image Generation

Paid image generation costs money or plan credits per call. Make images
yourself first: HTML/CSS/SVG rendered locally (headless Chrome), Pillow
composites, and assets already in the project. Call a paid image tool (OpenAI
`gpt-image-*`, Gemini, Codex's built-in image generation, Claude Code's
media-pipeline `image-generation` skill / CLI / `create_asset`) only when the
user explicitly asks for one in the current request. This overrides any skill
that says to generate images automatically.
