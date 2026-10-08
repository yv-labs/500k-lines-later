# Claude Code setup

Claude Code has three instruction surfaces, and the pack uses all three so nothing is dropped:

| Pack tier | In Cursor | In Claude Code |
|---|---|---|
| 10 always-on rules | `.cursor/rules/*.mdc`, every turn | condensed to 13 bullets in `AGENTS.md`, imported by `CLAUDE.md` (`@AGENTS.md`); full bodies as `.claude/rules/<name>.md` with `--full-rules` |
| 10 scoped standards | auto-attach by file glob | **`.claude/rules/<name>.md` with `paths:`** — Claude's native path-scoped rules; load only when Claude reads/edits a matching file |
| 3 on-demand rules | agent-requested by description | **installed as skills** in `.claude/skills/` (Claude has no description-triggered *rule*; skills are exactly that) |
| 5 project skills | `.cursor/skills/` | `.claude/skills/` |
| 1 user-level skill | `~/.cursor/skills/` | `~/.claude/skills/` |

```bash
./scripts/install.sh --claude your-repo               # rules + 8 skills + CLAUDE.md + AGENTS.md
./scripts/install.sh --claude your-repo --full-rules  # + the 10 always-on bodies as launch-loaded rules (~9K tokens/turn)
./scripts/install.sh --user                           # the user-level skill → ~/.claude/skills (and ~/.cursor, ~/.agents)
```

Then start a **new session** (or `/reload-skills`). Confirm with `/context all` — `CLAUDE.md` and the
imported `AGENTS.md` appear under *Memory files* (≈480 + 2.3k tokens); *Skills › Project* lists 7
(`phase-retrospective` is hidden from the model on purpose, see below) and *User* lists the reflex.
The whole pack costs about 3.8k tokens of launch context.

## What you get

- `CLAUDE.md` whose first line is `@AGENTS.md`. This is the form Claude's docs prescribe: a
  `CLAUDE.md` that *tells* Claude to read `AGENTS.md` only works if Claude decides to open the file;
  the `@` import loads it at launch. The import is inside the working directory, so no
  external-import approval dialog appears.
- `.claude/rules/<standard>.md` — one per scoped standard, frontmatter exactly
  `paths: "<globs>"` (a quoted comma-separated string), body = the rule verbatim. `paths:` is the
  only field Claude reads, so the Cursor `description`/`alwaysApply` keys are not carried over.
- `.claude/skills/<name>/SKILL.md` — the 5 skills unchanged, plus `aws-services`,
  `performance-optimization`, `security-compliance` as skills (`metadata.origin` names the rule).
  `companion-rules/` is stripped; you have the rules.
- `AGENTS.md` with skill links rewritten to `.claude/skills/…`.

## Differences to know

- **Path-scoped rules fire on Read/Write/Edit of a matching file**, not on every turn and not on
  `Grep`/`Bash`. Verified: creating `main.tf` with a shell `printf` loaded nothing; the Read tool on
  it injected `Contents of …/.claude/rules/terraform-infra.md:` right after the file. If you ask
  about Terraform without touching a `.tf` file, `terraform-infra` is not in context — open the
  file first (or mention it with `@`). Reading one `.tsx` loaded the 5 matching rules at once
  (typescript, react, tailwind, accessibility, static-analysis) and none of the other 5.
- **`paths:` syntax.** Official docs accept "a YAML list or a comma-separated string", but the
  YAML-list form has open reports of silently not loading ([#17204](https://github.com/anthropics/claude-code/issues/17204),
  [#19377](https://github.com/anthropics/claude-code/issues/19377)), and an unparseable frontmatter
  makes the rule load **unconditionally**. The installer writes the quoted CSV string; in the test
  run both comma lists and brace globs matched correctly in Claude Code (the pack has since
  dropped braces anyway, because Cursor never matches them — see `rules/README.md`).
- **`/context` does not show lazily loaded rules.** *Memory files* lists only what loaded at launch;
  a rule pulled in by a Read is counted under *Messages*. Use `/context` to prove a scoped rule did
  **not** load eagerly, and ask the agent to quote the rule's H1 to prove it did load.
- **Scoped rules are project-only.** `paths:` is not honoured under `~/.claude/rules/`
  ([#57722](https://github.com/anthropics/claude-code/issues/57722)); the installer never writes there.
- **Skills.** `disable-model-invocation: true` is enforced at the tool level: `phase-retrospective`
  is omitted from the model's skill list and `/context`, and the Skill tool refuses it with "cannot
  be used with Skill tool due to disable-model-invocation. Ask the user to run /phase-retrospective
  themselves". Typing `/phase-retrospective` loads the full body. Unknown frontmatter fields
  (`license`, `metadata`) are ignored without error. Skill listing truncates descriptions at 1,536
  chars; the pack's are ≤400 and were shown whole (0 chars lost).
- **A `CLAUDE.md` in the tree makes Claude ignore a bare `AGENTS.md`** (default
  `claude-md-or-agents-md`). That is why ours imports it. If you already have your own `CLAUDE.md`,
  add `@AGENTS.md` as its first line instead of installing ours (the installer never overwrites
  without `--force`).
- Personal skills (`~/.claude/skills/`) are not loaded in Cowork/cloud sessions — commit a project
  copy if you rely on the reflex there.
- Finding IDs (`F-N2`) and phase refs are kept as-is; they are provenance, not instructions.

Status: **tested** 2026-10-07 on Claude Code 2.1.293 with the two-session protocol in
[`compatibility-test.md`](compatibility-test.md): install PASS, 8/8 visible skills + 1 hidden by
design, explicit invocation 7/7, `@AGENTS.md` import loaded, path-scoped rules fired on Read (brace
and comma globs), verification rule pushed back unprompted. Row and evidence in
[`compatibility.md`](compatibility.md).

<sub>YV Labs · Vidh Yasa · MIT</sub>
