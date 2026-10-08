---
name: continuous-improvement-retrospective
description: Cross-project post-task reflex, installed user-level so it applies in every repo. After any task or phase, run a brief retrospective and evolve the rules and skills. Use automatically when a task or phase is finishing; after any user correction, rework loop, fix that broke something else, environment/tooling gotcha, or drift/version surprise; when a reusable pattern is discovered.
license: MIT
metadata:
  author: YV Labs by Vidh Yasa
  source: https://github.com/yv-labs/500k-lines-later
  provenance: see README.md in this folder
---

# Continuous Improvement (post-task reflex)

## Overview

A lightweight, always-run reflex: at the end of every task/phase, convert what just happened
into durable guidance. This is the portable version of a project's `continuous-improvement`
rule — it travels across repos so the rules/skills you reuse keep evolving with the work.

## When to Use
- A task or phase is finishing or has just completed, in any repo.
- Any friction signal occurred (listed below), even mid-task.

**When NOT to use:** never skip it entirely — but for a trivial task with nothing new, the
one-line check below is the whole job. For a deep multi-session post-mortem, use
`phase-retrospective` instead.

## Calibrate depth (avoid noise)
- **Trivial task, nothing new** → quick mental check; no file changes; note it in one line.
- **Substantial task, OR any friction signal** → capture it (workflow below).

**Always capture** if any occurred: a user correction ("no / again / revert / why did you"),
a rework or whack-a-mole loop, a fix that regressed something else, an environment/tooling
gotcha, a version/drift/sync surprise, a "claimed done" miss, or a new reusable pattern.

## Workflow
```
- [ ] 1. Reflect: what broke/was corrected; approach that FAILED vs WORKED; root cause; what we missed; the lesson
- [ ] 2. Evolve: extend an EXISTING rule/skill if possible; create new only for a genuinely new concern
- [ ] 3. Record: add the finding to the project's retrospective/playbook doc (ID + mapped rule/skill)
- [ ] 4. Generalize: if not project-specific, carry it cross-project (~/.cursor/skills/ or a Settings User Rule)
- [ ] 5. Validate: frontmatter valid, no contradiction with existing rules, no duplicate rule created
```

## Principles
- **Principle-based, not locking.** Capture the lesson without banning legitimate future
  approaches or hard-coding a brittle script. Guide; don't cage.
- **No duplication.** Prefer reconciling/extending over forking a near-identical rule.
- **Proportional.** A moment of reflection, not a second project. Don't derail the task.
- **Follow the authoring conventions.** Rules: focused, concise, correct frontmatter,
  concrete examples (see the `create-rule` skill). Skills: third-person WHAT+WHEN
  description, under 500 lines, progressive disclosure (see the `create-skill` skill).

## When to go deeper
For a large phase, multi-session effort, or a recurring class of mistakes, run the full
transcript-mining retrospective (the project's `phase-retrospective` skill if present):
parallel mining, categorized findings with IDs + evidence, and a findings→rules/skills
traceability table.

## Anti-rationalization

| If you catch yourself thinking… | Do this instead |
|---|---|
| "The user didn't ask for a post-mortem." | Run the reflex anyway — waiting to be asked is how lessons evaporate. |
| "I'll remember this next time." | Write it into a rule/skill and the retrospective doc with an ID. |
| "Quick, I'll add a new rule for this." | Extend an existing rule/skill first; no near-duplicates. |
| "Nothing new happened, but let me write something." | Trivial task → one-line note, no file changes. |
