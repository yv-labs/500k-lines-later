# Codex setup

Codex reads `AGENTS.md` (project root and parent directories) and discovers skills in `.agents/skills/`
— at the repo root and in every directory from your working directory upward. User-level skills live
in `~/.agents/skills/`. Codex has **no concept of a scoped or on-demand rule**, so the pack maps
onto Codex like this:

| Pack tier | In Cursor | In Codex |
|---|---|---|
| 10 always-on rules | `.cursor/rules/*.mdc`, every turn | condensed to 13 bullets in `AGENTS.md` (every turn); full bodies with `--full-rules` |
| 10 scoped standards | auto-attach by file glob | **installed as skills** with the same names; the trigger is the rule's description + its globs |
| 3 on-demand rules | agent-requested by description | **installed as skills**, same names |
| 5 project skills | `.cursor/skills/` | `.agents/skills/` |
| 1 user-level skill | `~/.cursor/skills/` | `~/.agents/skills/` |

So a full Codex install is **18 skill folders** (5 + 13) plus `AGENTS.md`. That is everything in the
pack, in the shapes Codex can actually load.

```bash
./scripts/install.sh --codex your-repo               # 18 skills + AGENTS.md (condensed rules)
./scripts/install.sh --codex your-repo --full-rules  # same, plus the full always-on texts appended to AGENTS.md
./scripts/install.sh --user                          # the user-level skill → ~/.agents/skills (and ~/.cursor/skills)
```

Then **start a new Codex session** in the repo — skills are discovered at startup.

## What you get

- `AGENTS.md`: the 13 condensed every-turn rules + skill index. Its skill links point at
  `.agents/skills/…` in *your* repo (the installer rewrites them). `--full-rules` appends the full
  always-on bodies, including the `project-context` template for you to fill in — roughly 9K tokens
  per turn, the same budget Cursor spends; without the flag you get the summary only.
- `.agents/skills/<rule-name>/SKILL.md` for each scoped/on-demand rule: frontmatter `name` =
  rule name, `description` = the rule's description plus "Use when creating or editing files
  matching: `<globs>`", body = the rule verbatim. Codex shows name + description at startup and
  reads the body when it decides the skill applies — the Codex-native equivalent of glob attachment.
- The 5 project skills, unchanged (`companion-rules/` stripped — you have the rules as skills).

## Differences to know

- **How Codex "invokes" a skill — two paths.** *Implicit:* Codex gives the model each skill's name,
  description and file path at startup; when the task matches, the model opens that `SKILL.md` with
  its file tools (there is no separate loader — a skill is working when the model goes straight to
  the catalogued path, not a search). *Explicit:* typing `$name` in the composer injects the **full
  skill body** into the turn; no disk read happens (verified 2026-10-07 with `$terraform-infra` and
  `$typescript-standards`).
- `disable-model-invocation: true` (used by `phase-retrospective`) is a Cursor/Claude Code field. Codex
  ignores it; the equivalent is an `agents/openai.yaml` next to `SKILL.md` with
  `policy: { allow_implicit_invocation: false }`. Invoke explicitly with `$phase-retrospective`.
- **Descriptions get shortened in crowded catalogs.** The startup skills list has one budget
  (≈2% of context, or 8,000 chars) shared by **every** skill in the session — this pack's 19 plus
  Codex's bundled and plugin skills (~40 on a Codex desktop with Figma/Google plugins). Codex
  water-fills that budget character by character, so short descriptions stay whole and long ones
  are cut at whatever level is left (≈430 chars on a 59-skill machine, measured 2026-10-07). The
  full `SKILL.md` is unaffected; only the catalog text is shorter. The pack keeps every description
  ≤400 chars with the trigger words first (`validate.sh` enforces it). If you still see
  "Skill descriptions were shortened…", disable plugins you don't use.
- If you let Codex run the installer itself, its default `workspace-write` sandbox protects
  `.agents/`, `.codex/`, `.git` and `~`: the copy raises an approval prompt — approve it. With
  `approval_policy = never` the write fails with a misleading "outside of the project" error.
  Copy skill folders — repo-local **symlinked** skills have a known discovery bug.
- `.codex/skills/` is a legacy location some older builds read; current docs list `.agents/skills/`.
  Cursor reads both, so `.agents/skills/` is the one path that works everywhere.

Status: **tested** 2026-10-07 (codex-cli 0.159.0-alpha.12.1 inside Codex desktop), two-session
protocol — install PASS, all 19 pack skills in the startup catalog (19/19), the 6 skills loaded on
explicit invocation (6/6), `AGENTS.md` auto-loaded, verification rule pushed back on "run `npm test`
and call it done" unprompted. Codex's own startup instructions confirm the invocation mechanism:
*"filesystem skills should be read from the filesystem"* — there is no separate loader. Four
descriptions were shortened by 7–29 chars in that run (59-skill catalog) and have since been trimmed.
See [`compatibility.md`](compatibility.md).

<sub>YV Labs · Vidh Yasa · MIT</sub>
