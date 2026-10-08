# Gemini CLI setup

Gemini CLI reads `GEMINI.md` (project root and parents) and can be pointed at `AGENTS.md`.

```bash
cp AGENTS.md your-repo/
cp adapters/gemini/GEMINI.md your-repo/
cp -R skills/* your-repo/.agents/skills/
```

`GEMINI.md` in this pack is a short pointer to `AGENTS.md` plus the six non-negotiables, identical
in spirit to `CLAUDE.md`. Scoped standards are listed by name; paste in the ones you want enforced.
Gemini CLI supports `@file` includes in `GEMINI.md`, so you can also write
`@rules/terraform-infra.mdc` to pull a rule in verbatim.
