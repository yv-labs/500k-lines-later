# Adapters

The canonical content lives in `rules/` and `skills/`. Adapters are thin wrappers so other tools
load the same guidance. Nothing here is hand-maintained duplicate content: the generated files are
produced by `scripts/install.sh --<tool>` from the canonical rules; the static ones are pointers.

| Folder | What it is | Generated? |
|---|---|---|
| `cursor/` | notes only — Cursor reads `rules/` and `skills/` as-is | — |
| `claude-code/` | `CLAUDE.md` pointer (same as repo root) | static |
| `codex/` | nothing extra — Codex reads `AGENTS.md` + `.agents/skills/` | — |
| `copilot/` | `copilot-instructions.md` (condensed always-on) + `.github/instructions/*.instructions.md` | instructions generated from glob-scoped rules |
| `gemini/` | `GEMINI.md` pointer | static |
| `windsurf/` | `.windsurf/rules/*.md` | generated (frontmatter mapped, long rules split) |

If you add a tool, add a converter case to `scripts/install.sh` and a `docs/<tool>-setup.md`; do not
hand-copy rule bodies into the adapter folder.
