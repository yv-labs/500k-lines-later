# <Project> — Retrospective & Engineering Playbook

> **Purpose.** A complete, no-omissions record of the mistakes, dead-ends, rework and learnings
> from this project, plus the durable engineering principles that came out of them. Findings here
> are encoded into `.cursor/rules/` (always-on guidance) and `.cursor/skills/` (invokable
> workflows) so this project — and the next one — never repeats them.
>
> **How to use this file.** Each finding has an ID (e.g. `F-A1`), evidence, and the rule/skill that
> now addresses it. When a new class of mistake appears, **add a finding here first, then update
> the matching rule or skill.** The always-on `continuous-improvement.mdc` rule makes the agent do
> this after every task; the `phase-retrospective` skill does the deep pass at the end of a phase.

Source: <agent transcripts / Implementation Logs / review reports>. Cross-referenced against
<the live environment>.

---

## 0. Ground truth corrections (docs/rules that did not match reality)

Factual mismatches between what the rules/docs said and what was actually built. These cause
repeated confusion; correct the rule, then record it here.

| ID | What the rule/doc said | Reality | Fix |
|----|------------------------|---------|-----|
| **F-0.1** | <claim> | <what is actually true> | <which rule/doc was corrected> |

---

## A. <Cross-cutting theme — e.g. "Local verification waste">

<One paragraph: what this theme is and why it mattered.>

| ID | Finding | Evidence |
|----|---------|----------|
| **F-A1** | **<short bold title>** — <what happened, with a quote from the user or the log if there is one> | <transcript id / CI build id / commit> |
| **F-A2** | … | … |

**Principle:** <the one-paragraph durable lesson> → `<rule>.mdc`, skill `<skill>`.

---

## B. <Cross-cutting theme — e.g. "CI/CD introduced too late">

| ID | Finding | Evidence |
|----|---------|----------|
| **F-B1** | … | … |

**Principle:** … → `<rule>.mdc`.

---

<!-- Keep adding cross-cutting themes (C, D, E…) while the project is young. Once the loop is
     running, most new sections are PER PHASE (below): one letter per phase that produced
     findings. Phases that produced none get no section — don't pad. -->

## <Letter>. Phase <n> — <phase name> (<one-line what it was>)

| ID | Finding | Root cause | Fix / rule |
|----|---------|------------|------------|
| **F-<Letter>1** | **<title>** — <symptom as observed> | <the actual cause, including stacked causes if more than one> | <what changed in code/IaC> → `<rule>.mdc` §<section> |

**Principle:** …

---

## Findings → Rules / Skills traceability

Append a row every time a rule or skill is created or extended because of a finding. This table is
what lets anyone audit "why does this sentence exist in the rule?".

| Rule / Skill | Status | Findings addressed |
|--------------|--------|--------------------|
| `<rule>.mdc` (new, alwaysApply) | ✅ created | F-A1..A7, F-C1 |
| `<rule>.mdc` (updated: <section added>) | ✅ | F-N2 |
| Skill `<skill>` | ✅ created | F-I1, F-I4 |
| Personal skill `<skill>` (`~/.cursor/skills/`, cross-project) | ✅ created | F-I9 |

---

## Appendix — finding block (copy-paste)

Use this when adding a single finding mid-task (the `continuous-improvement.mdc` reflex):

```markdown
| **F-<Letter><n>** | **<title>** — <symptom; include the literal error or the user's words> | <root cause(s); if a fix moved the symptom, list the second cause too> | <change made> → `<rule>.mdc` §<section> / skill `<skill>` |
```

Checklist before you save it:
- [ ] Does the ID follow the section's letter and the next free number?
- [ ] Is the evidence something another person could open (build id, commit, transcript id)?
- [ ] Did you **extend an existing** rule/skill rather than create a near-duplicate?
- [ ] Did you add the traceability row?
- [ ] Is the lesson project-specific? If not, also carry it to a user-level skill or personal rule.

## Appendix — theme letters used in this project

| Letter | Theme / phase | Added |
|---|---|---|
| 0 | Ground-truth corrections | <date> |
| A | <theme> | <date> |
| B | <theme> | <date> |
