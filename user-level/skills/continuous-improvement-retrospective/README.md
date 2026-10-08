# continuous-improvement-retrospective

> Don't wait to be asked for a post-mortem: after every task, turn what just went wrong into guidance, in every repo you work in.

## What it does

- Runs a short retrospective at the end of **every** task or phase, in any repository.
- Calibrates depth: a trivial task gets a one-line check with no file changes; a substantial task or any friction signal gets the full reflex.
- Lists the friction signals that must be captured: a user correction, a rework loop, a fix that regressed something, a tooling gotcha, a version/drift surprise, a "claimed done" miss, or a new reusable pattern.
- Follows 5 steps: reflect → evolve (extend an existing rule/skill, don't fork) → record with an ID → generalize cross-project → validate.
- Hands off to `phase-retrospective` when a large phase or recurring class needs the deep, transcript-mining pass.

## When to use it

- A task or phase is finishing or just finished, in any repo.
- The user corrected you ("no / again / revert / why did you").
- A fix broke something else, or you went around a whack-a-mole loop.
- You hit an environment, tooling, version, or sync surprise.
- You found a pattern worth reusing.

**When not to use it:** never skip it entirely. For a trivial task the one-line check *is* the job; for a deep multi-session post-mortem, use `phase-retrospective`.

## Where it goes

| Tool | Path | Scope |
|---|---|---|
| Cursor (user-level) | `~/.cursor/skills/continuous-improvement-retrospective/` | **Recommended.** User-level by design: it's the portable version of the project rule and should follow you into every repo. |
| Open standard (user-level) | `~/.agents/skills/continuous-improvement-retrospective/` | Same, for tools that read the open agent-skills layout. |
| Cursor (project) | `.cursor/skills/continuous-improvement-retrospective/` | Add a project copy too if you use Cloud Agents or remote workers; user-level skills aren't copied to them. |
| Open standard (project) | `.agents/skills/continuous-improvement-retrospective/` | Same reason as above. |
| Claude Code | `.claude/skills/continuous-improvement-retrospective/` | Project (or that tool's user-level skills directory). |
| Codex | `.codex/skills/continuous-improvement-retrospective/` | Project (or that tool's user-level skills directory). |

Cursor auto-discovers skills at session start; the agent decides when to load this one by matching its `description` against the task.

## How it helps

- **Stopped lessons from evaporating.** For roughly the first ten weeks, lessons were captured only when the user demanded a post-mortem. The finding that created this skill (F-I9) says that without a standing mechanism, "hard-won lessons evaporate and the same loops recur."
- **Grew the catalog without being asked.** After the reflex went live on 2026-06-27, the retrospective doc grew from 67 to 139 findings in four weeks, with 19 per-phase retrospective sections.
- **Kept rules and lessons in lockstep.** 22 of the 31 commits that touched the retrospective doc changed a rule or skill in the same commit.
- **Deepened instead of sprawling.** "Extend, don't fork" is why no new rule file was created after 2026-07-03.

## Works best with

| Companion | Why |
|---|---|
| `continuous-improvement.mdc` (project rule) | The always-applied project version of this reflex. The rule makes it mandatory in one repo; this skill carries it into every other repo. |
| `phase-retrospective` (skill) | The deep pass for large phases or recurring classes: parallel transcript mining, finding IDs, and a traceability table. |

Copies of these rules are bundled in `./companion-rules/` so this folder is self-sufficient; the canonical versions live in `/rules/` and `scripts/sync-companions.sh` keeps them in sync.

## Provenance

| | |
|---|---|
| Born | ~2026-06-27 (directory mtime; personal skill, not in git) |
| Revisions | n/a (outside version control) |
| Findings absorbed | F-I9 |
| The incident that created it | Reliability-phase lessons "only got institutionalized because the user explicitly asked for a post-mortem." The fix made retrospection a mandatory, automatic post-task reflex: an always-applied project rule plus this cross-project personal skill. The rule that mandates retrospectives was itself the output of a retrospective. |
| Lines / words | 42 / 405 at harvest (this copy adds Overview, When-to-Use, and Anti-rationalization sections) |

## Install

```bash
cp -R user-level/skills/continuous-improvement-retrospective ~/.cursor/skills/
cp -R user-level/skills/continuous-improvement-retrospective ~/.agents/skills/
```

Then copy the companion rules: `cp user-level/skills/continuous-improvement-retrospective/companion-rules/*.mdc <your-repo>/.cursor/rules/`

## Example

```text
You:   Great, the rate limiter works now. Thanks.
Agent: [loads continuous-improvement-retrospective — "a task is finishing"]
       Friction signal: you corrected me twice ("again, it's still 429").
       Reflect: I raised the limit before checking which IP CI egresses from; root cause
       was a single NAT IP sharing one bucket.
       Evolve: extended the existing systematic-debugging rule ("identify the traffic
       path before tuning a limit"), no new rule.
       Record: F-M3 added to RETROSPECTIVE_AND_PLAYBOOK.md → systematic-debugging.
       Generalize: not project-specific → added to ~/.cursor/skills/ notes. Frontmatter valid.
```

---

<sub>Part of the YV Labs rules & skills pack · Vidh Yasa · MIT · [all skills](../../../skills/README.md)</sub>
