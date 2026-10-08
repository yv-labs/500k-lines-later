---
name: phase-retrospective
description: Structured retrospective that mines agent transcripts and implementation logs for mistakes and learnings, then turns them into updated rules and skills. Use when the user asks to capture mistakes/learnings; when reviewing what went wrong across a phase or multi-session implementation; when hardening rules/skills before continuing; for a post-mortem; when a class of mistake keeps recurring.
disable-model-invocation: true
license: MIT
metadata:
  author: YV Labs by Vidh Yasa
  source: https://github.com/yv-labs/500k-lines-later
  provenance: see README.md in this folder
---

# Phase Retrospective → Rules & Skills

## Overview

Turn a project's history into durable guidance. The output is a findings catalogue plus
concrete edits to `.cursor/rules/` and `.cursor/skills/`. This is the deep, transcript-mining
pass; the lightweight per-task reflex is the `continuous-improvement` rule.

## When to Use
- The user asks for a post-mortem, "capture the mistakes," or "harden the rules before we continue."
- A phase or multi-session effort just ended, or the same class of mistake has recurred.

**When NOT to use:** a single small task with nothing new learned — the one-line post-task check
from the `continuous-improvement` rule is enough. (This skill is user-invoked only.)

## Workflow

```
- [ ] 1. Gather sources (transcripts, impl logs, review reports, current rules/skills)
- [ ] 2. Mine for mistakes/learnings (parallel subagents, by complexity)
- [ ] 3. Categorize findings with IDs + evidence
- [ ] 4. Map each finding to a rule update or a skill
- [ ] 5. Apply edits (prefer principle-based, non-restrictive guidance)
- [ ] 6. Validate (lint frontmatter, check references, confirm no contradictions)
```

**1. Gather sources.** Agent transcripts live under the project's
`agent-transcripts/<uuid>.jsonl`. Also read the implementation plan's per-task logs, any
review/verification reports, and the existing `.cursor/rules/` + `.cursor/skills/`.

**2. Mine in parallel, choosing the model by complexity.** Launch subagents concurrently:
- **High-reasoning model** (e.g. Opus) for transcript synthesis — finding user corrections,
  rework loops, wasted effort, frustration signals across many large files.
- **Fast model** (e.g. Composer) for mechanical extraction — implementation-log status,
  CI/CD/infra state, config inventory.
Grep transcripts for signals: `no,|don't|wrong|revert|again|actually|stop|broke|waste|why did`.

**3. Categorize.** Give every finding a stable ID (`F-A1`, `F-B2`, …) and a one-line evidence
note (which transcript / what happened). Suggested buckets: local-testing waste, CI/CD
timing, AWS/infra, architecture/schema, tooling/config churn, duplication/process,
workflow/communication, ground-truth doc mismatches.

**4. Map findings → rules/skills.** Each finding becomes either:
- an **always-on rule** (a constraint/principle that should always hold), or
- a **skill** (an invokable workflow), or
- an update to an existing rule/skill.
Maintain a traceability table (finding ID → rule/skill).

**5. Apply edits.** Follow the `create-rule` and `create-skill` conventions: rules are focused
(~one concern, concise) with correct frontmatter; skills have third-person WHAT+WHEN
descriptions. **Encode principles, not brittle prescriptions** — capture the lesson without
banning legitimate future approaches. Fix any rule/doc statements that no longer match reality.

**6. Validate.** Confirm every `.mdc` has valid frontmatter (`description`, `globs` for
file-scoped, `alwaysApply`), every `SKILL.md` has `name` + `description`, internal references
resolve, and no two rules contradict each other. List exactly what changed.

## Output
A `RETROSPECTIVE_AND_PLAYBOOK.md` (or similar) with the full categorized findings + a
findings→rules/skills traceability table, and the corresponding rule/skill edits applied.

## Anti-rationalization

| If you catch yourself thinking… | Do this instead |
|---|---|
| "This lesson deserves its own new rule." | Extend an existing rule/skill unless it's a genuinely new concern. |
| "Ban the approach that failed." | Encode the principle, not a brittle prohibition. |
| "The finding is obvious; no need for an ID or evidence." | Give it a stable ID + one-line evidence so it's traceable. |
| "It felt one-off, so it doesn't need a mapping." | Map every finding to a rule/skill — unmapped lessons recur. |
