# phase-retrospective

> Mine your agent transcripts for every correction and rework loop, give each lesson an ID, and turn it into a rule or skill so it never has to be said twice.

## What it does

- Gathers agent transcripts, Implementation Logs, review reports, and the current rules/skills.
- Mines them in parallel with subagents, choosing the model by complexity: a high-reasoning model for transcript synthesis, a fast model for mechanical extraction.
- Greps for friction signals (`no,|don't|wrong|revert|again|actually|stop|broke|waste|why did`).
- Catalogs findings with stable IDs (`F-A1`, `F-B2`, …) and one-line evidence, grouped into buckets.
- Maps each finding to a rule edit, a skill, or an update, keeps a traceability table, and validates frontmatter and cross-references.
- Is **user-invoked only** (`disable-model-invocation: true`), so it runs when you ask for it rather than whenever the agent thinks it fits.

## When to use it

- You ask for a post-mortem, or to "capture the mistakes / learnings."
- A phase or multi-session effort just ended.
- You want to harden the rules/skills before continuing.
- The same class of mistake keeps recurring.

**When not to use it:** after a small task with nothing new. The one-line check from the `continuous-improvement` rule (or the user-level `continuous-improvement-retrospective` skill) covers that.

## Where it goes

| Tool | Path | Scope |
|---|---|---|
| Cursor (project) | `.cursor/skills/phase-retrospective/` | Good default: the retrospective doc it writes lives in the repo. |
| Open standard (project) | `.agents/skills/phase-retrospective/` | Same, for tools that read the open agent-skills layout. |
| Cursor (user-level) | `~/.cursor/skills/phase-retrospective/` | Also reasonable: the procedure is application-agnostic. |
| Claude Code | `.claude/skills/phase-retrospective/` | Project. |
| Codex | `.agents/skills/phase-retrospective/` | Project. Codex reads `.agents/skills/` (repo root and parents); `.codex/skills/` is legacy. |

Cursor auto-discovers skills at session start. Because this skill sets `disable-model-invocation: true`, the agent won't load it on its own; invoke it explicitly (for example `/phase-retrospective`).

## How it helps

- **Turned 143 transcripts into 57 findings in one pass.** The first deep run (2026-06-16) produced the initial catalog and, the same day, the `cloud-first-verification` and `cicd-first` rules plus three skills.
- **Made lessons traceable.** Every finding carries an ID and evidence. The catalog grew to 139 rows, and 113 of them sit in an explicit finding → rule/skill traceability table.
- **Kept the guidance from sprawling.** Its "extend, don't fork" mapping step is why no new rule file was created after 2026-07-03; later lessons deepened existing rules instead.
- **Fixed rules that no longer matched reality.** Step 5 corrects stale statements, e.g. a progress table showing ~94 tasks "Not Started" while ~100 Implementation Logs were complete.

## Works best with

| Companion | Why |
|---|---|
| `continuous-improvement.mdc` | The always-on per-task reflex. It catches friction as it happens; this skill is the deep pass it points to for large phases or recurring classes. |
| `templates/RETROSPECTIVE_AND_PLAYBOOK.template.md` | The catalog this skill writes into: phase sections, finding rows with IDs, and the traceability table. |

Copies of these rules are bundled in `./companion-rules/` so this folder is self-sufficient; the canonical versions live in `/rules/` and `scripts/sync-companions.sh` keeps them in sync.

## Provenance

| | |
|---|---|
| Born | 2026-06-16 |
| Revisions | 1 |
| Findings absorbed | F-H1, F-H4 (uses F-A1, F-B2 as ID examples) |
| The incident that created it | Early in the build, lessons were captured only when the user demanded a post-mortem. The first one became a deep retrospective that mined 143 agent transcripts into 57 catalogued findings, and that procedure was saved as this skill so the next deep pass would be repeatable. |
| Lines / words | 56 / 418 at harvest (this copy adds Overview, When-to-Use, and Anti-rationalization sections) |

## Install

```bash
cp -R skills/phase-retrospective <your-repo>/.cursor/skills/
cp -R skills/phase-retrospective <your-repo>/.agents/skills/
```

Then copy the companion rules: `cp skills/phase-retrospective/companion-rules/*.mdc <your-repo>/.cursor/rules/`

## Example

```text
You:   /phase-retrospective — the payments-reporting phase is done. Capture what went wrong.
Agent: Gathering: 18 transcripts, 9 Implementation Logs, current rules/skills.
       Mining in parallel: deep model on transcripts, fast model on log status + CI state.
       Findings:
       | F-K1 | migration ran after the code that reads it → 500s for 20 min | → cicd-first (extend) |
       | F-K2 | subagent "done" with no diff persisted                       | → parallel-delegation |
       | F-K3 | CI tool version differs locally vs CI                        | → local-environment-hygiene |
       Edits applied to 3 existing rules (no new files). Frontmatter valid, refs resolve.
```

---

<sub>Part of the YV Labs rules & skills pack · Vidh Yasa · MIT · [all skills](../README.md)</sub>
