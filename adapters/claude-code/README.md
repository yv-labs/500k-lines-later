# Claude Code

`./scripts/install.sh --claude your-repo` writes `CLAUDE.md` (`@AGENTS.md` import), `AGENTS.md`,
the 10 scoped standards as `.claude/rules/<name>.md` with `paths:`, and 8 skills into
`.claude/skills/` (5 procedures + 3 on-demand rules as skills). `--full-rules` adds the 10 always-on
bodies as launch-loaded rules. See [`docs/claude-code-setup.md`](../../docs/claude-code-setup.md).
