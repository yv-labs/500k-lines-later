# GitHub Copilot setup

Copilot (chat / coding agent) reads `.github/copilot-instructions.md` and, in newer versions,
`AGENTS.md`. Path-scoped instructions live in `.github/instructions/*.instructions.md` with an
`applyTo` glob — the closest thing to Cursor's glob-scoped rules.

```bash
cp AGENTS.md your-repo/
mkdir -p your-repo/.github/instructions
cp adapters/copilot/copilot-instructions.md your-repo/.github/
./scripts/install.sh --copilot your-repo        # generates .github/instructions/*.instructions.md from the glob-scoped rules
cp -R skills/* your-repo/.agents/skills/
```

## Mapping

| Pack tier | Copilot location |
|---|---|
| Always-on | `.github/copilot-instructions.md` (condensed) + `AGENTS.md` |
| Glob-scoped | `.github/instructions/<rule>.instructions.md` with `applyTo: "<glob>"` — the install script converts `globs:` → `applyTo:` and drops the rest of the frontmatter |
| On-demand | referenced by name in `copilot-instructions.md`; paste in if you want them enforced |
| Skills | `.agents/skills/` (read by the coding agent) |

## Notes

- `applyTo` takes a single glob or a comma-separated list; the script joins multi-glob rules with
  commas.
- Copilot does not read `description` to decide relevance; on-demand rules are effectively manual
  here.
