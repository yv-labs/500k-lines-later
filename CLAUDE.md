@AGENTS.md

## Claude Code

The import above loads the canonical index (condensed every-turn rules + skill index). Claude Code
additions in this project:

- `.claude/rules/*.md` — the 10 scoped standards with `paths:` frontmatter. They load on their own
  when you read or edit a matching file (`terraform-infra` on `*.tf`, `react-frontend` on `*.tsx`,
  …). Do not paste them into context; let the path match pull them.
- `.claude/skills/` — the 5 procedure skills plus `aws-services`, `performance-optimization`,
  `security-compliance` (on-demand reference installed as skills). Invoke with `/name`;
  `phase-retrospective` is user-invoked only.
- User-level: `~/.claude/skills/continuous-improvement-retrospective` — the post-task reflex.

Non-negotiables, even if you read nothing else:

- The pipeline, not your machine, decides whether work is done. Push, then read the log.
- "Done" requires a shown artifact (CI log, deployed URL, request-id, live response).
- Search the whole repo before creating anything; extend, don't duplicate.
- After two failed fixes, stop and switch to systematic debugging with an attempt ledger.
- Treat every subagent's "done" as a claim; read the full diff.
- After each task, run the retrospective reflex and extend an existing rule or skill.
