# Install

Everything here is Markdown. Installing means copying files into the paths your tool reads.
`scripts/install.sh` does the copying; this page explains what goes where and why.

## The two kinds of files

| Kind | File shape | Loaded | Lives at |
|---|---|---|---|
| **Rule** | `*.mdc` with frontmatter (`description`, `globs`, `alwaysApply`) | Cursor decides per rule: every turn / when a matching file is open / when the agent judges it relevant | project `.cursor/rules/` (committed, shared with the team) |
| **Skill** | folder with `SKILL.md` (frontmatter `name`, `description`) + optional supporting files | the agent reads the description at session start and pulls the full skill when the situation matches | project `.cursor/skills/<name>/` **or** `.agents/skills/<name>/` (open standard, also read by Codex/Claude Code) **or** user-level `~/.cursor/skills/<name>/` |

## Project-level vs user-level

- **Project-level** (`.cursor/rules/`, `.cursor/skills/`, `.agents/skills/`) is committed to the
  repo. Everyone on the team and every CI/cloud agent gets the same guidance. **All 23 rules and
  5 of the 6 skills belong here.**
- **User-level** (`~/.cursor/skills/`, `~/.agents/skills/`, and personal rules in Cursor
  Settings) follows *you* across every repo. Only one skill in this pack is user-level by design:
  `continuous-improvement-retrospective`, because its job is to make the retrospective reflex happen
  in every project, including ones that haven't adopted the rules yet. Caveat: `~/.cursor/skills/`
  reaches Cursor Cloud Agents only if you turn on *Settings → Agents → Sync Skills for Cloud Agents*;
  `~/.agents/skills/` and `~/.claude/skills/` are never copied to cloud/remote sessions. Commit a
  project copy too if you rely on those.

## Install paths by tool

| Tool | Rules | Skills | Entry file |
|---|---|---|---|
| Cursor | `.cursor/rules/*.mdc` | `.cursor/skills/<name>/` or `.agents/skills/<name>/` | — (rules are the entry) |
| Claude Code | always-on condensed in `AGENTS.md` (imported by `CLAUDE.md`; `--full-rules` for full texts); 10 scoped rules → `.claude/rules/*.md` with `paths:`; 3 on-demand rules → skills | `.claude/skills/<name>/` | `CLAUDE.md` (`@AGENTS.md`) |
| Codex | `AGENTS.md` (condensed; `--full-rules` for full texts) + scoped/on-demand rules installed **as skills** | `.agents/skills/<name>/` (`.codex/skills/` is legacy) | `AGENTS.md` |
| GitHub Copilot | `.github/copilot-instructions.md` + `.github/instructions/*.instructions.md` | `.agents/skills/<name>/` | `AGENTS.md` |
| Gemini CLI | `GEMINI.md` (from `adapters/gemini/`) | `.agents/skills/<name>/` | `GEMINI.md` → `AGENTS.md` |
| Windsurf / Devin Desktop | `.devin/rules/*.md` (preferred) or `.windsurf/rules/*.md` | Cascade skills / manual rule | `AGENTS.md` (native) |

Status per tool (production-tested vs docs-verified): [`compatibility.md`](compatibility.md).

## Using `scripts/install.sh`

```bash
./scripts/install.sh --cursor   /path/to/repo   # rules + skills + AGENTS.md
./scripts/install.sh --claude   /path/to/repo   # .claude/rules (10 paths-scoped) + .claude/skills (5 + 3 rules-as-skills) + CLAUDE.md + AGENTS.md
./scripts/install.sh --claude   /path/to/repo --full-rules   # + 10 always-on bodies as .claude/rules/*.md (launch-loaded)
./scripts/install.sh --codex    /path/to/repo   # .agents/skills (5 skills + 13 rules-as-skills) + AGENTS.md
./scripts/install.sh --codex    /path/to/repo --full-rules   # + full always-on rule texts appended to AGENTS.md
./scripts/install.sh --agents-md /path/to/repo  # AGENTS.md + .agents/skills only
./scripts/install.sh --copilot  /path/to/repo   # .github/copilot-instructions.md + instructions/*.instructions.md
./scripts/install.sh --gemini   /path/to/repo   # GEMINI.md + .agents/skills
./scripts/install.sh --windsurf /path/to/repo   # .windsurf/rules/*.md (split under the 12K cap) + AGENTS.md
./scripts/install.sh --devin    /path/to/repo   # same, into .devin/rules/ (current Devin Desktop)
./scripts/install.sh --user                     # the user-level skill → ~/.cursor/skills + ~/.agents/skills + ~/.claude/skills
./scripts/install.sh --pack starter --cursor /path/to/repo   # only the 5 Starter rules
```

The script never overwrites an existing file without `--force`; it prints every path it writes.

## After installing

1. Fill in `.cursor/rules/project-context.mdc` (the install script copies the template there under
   its real name). It is the one always-on rule that is unique to your project; the rest are generic.
2. Copy `templates/RETROSPECTIVE_AND_PLAYBOOK.template.md` → `docs/RETROSPECTIVE_AND_PLAYBOOK.md`.
3. Make sure your plan/task doc has a per-task Implementation Log block (template in the next
   release; the shape is: files touched · key decisions · date · deferred work).
4. Read [`the-loop.md`](the-loop.md) once.

## Adopting a skill on its own

Each `skills/<name>/` folder is self-sufficient: `SKILL.md` + `README.md` + `companion-rules/` (copies
of the rules it depends on). `cp -R skills/<name> your-repo/.cursor/skills/` and
`cp skills/<name>/companion-rules/*.mdc your-repo/.cursor/rules/` gives you a working unit.

## Uninstall

Delete the copied files. There is no state anywhere else.
