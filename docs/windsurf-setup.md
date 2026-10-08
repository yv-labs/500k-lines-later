# Windsurf / Devin Desktop setup

Workspace rules are `*.md` files with a `trigger` frontmatter, read from `.devin/rules/` (preferred,
takes precedence) or `.windsurf/rules/` (fallback). Root-level `AGENTS.md` is processed natively as an
always-on rule.

```bash
./scripts/install.sh --devin your-repo      # → .devin/rules/*.md   (current Devin Desktop)
./scripts/install.sh --windsurf your-repo   # → .windsurf/rules/*.md (older Windsurf builds)
cp AGENTS.md your-repo/
```

| Pack frontmatter | Generated frontmatter |
|---|---|
| `alwaysApply: true` | `trigger: always_on` |
| `globs: "…"` | `trigger: glob` + `globs: "…"` |
| neither | `trigger: model_decision` + `description:` |

Workspace rule files are capped at **12,000 characters** each (the single global rules file at 6,000).
The longest rules in this pack (`cicd-first`, `terraform-infra`) exceed that, so the install script
splits them into `-1.md`, `-2.md` at `##` headings; the split is lossless (the chunks concatenate back to
the original body).

Skills: Cascade has its own skills feature; if your build reads `.agents/skills/`, copy the pack's skills
there. Otherwise paste a `SKILL.md` body into a `trigger: manual` rule and invoke it with `@rule-name`.

Status: docs-verified (2026-10-07), not yet runtime-tested — see [`compatibility.md`](compatibility.md).
