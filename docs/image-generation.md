# Image Generation

Paid image APIs cost money per call. Make images yourself first: HTML/CSS/SVG
rendered locally (headless Chrome), Pillow composites, and assets already in
the project. Call a paid image API (OpenAI `gpt-image-*`, Gemini, the
media-pipeline `image-generation` skill / CLI / `create_asset`) only when the
user explicitly asks for one in the current request. This overrides any skill
that says to generate images automatically.
