# Rules

23 Cursor rules. 22 ship verbatim (scrubbed); the 23rd — the project-context rule — ships as a
fill-in template because it is the one rule that is unique to *your* project.

These are not style guides. Each one is a **catalogued failure mode, a verification reflex, or an
environment fact**, written as a principle (not a script) so the agent stays free to design. Finding
IDs (`F-N2`, `F-I3`, …) are provenance: every one maps to a row in a retrospective that explains
what broke and why. See [`docs/provenance.md`](../docs/provenance.md).

## How Cursor loads them

| Scope | Frontmatter | When the agent sees it | Cost |
|---|---|---|---|
| **Always-on** | `alwaysApply: true` | every turn, every file | the 10 always-on rules total ~695 lines ≈ 9K tokens per turn — budget for it |
| **Glob-scoped** | `globs: "**/*.tf"` etc. | attached to the result when the agent **reads or edits** a matching file (or you `@`-attach one) | free until triggered |
| **On-demand** | no globs, `alwaysApply: false` | when the agent decides the `description` is relevant | free until triggered |

Two glob facts verified on Cursor 3.8.11 (2026-10-07), both worth knowing before you write your own:
- **Braces never match.** `**/*.{ts,tsx}` silently attaches to nothing; `**/*.ts,**/*.tsx` works.
  The reference build ran four brace-glob rules for months without noticing — they simply never
  fired. `scripts/validate.sh` now rejects `{` in `globs:`.
- **Skill descriptions are shown to the agent cut at ~150 characters** (`...`). The first sentence
  of a `description:` has to carry the trigger on its own; the "Use when…" tail is for Claude Code
  and Codex, which show more.

Install: `cp rules/*.mdc <your-repo>/.cursor/rules/` then copy
`project-context.template.mdc` → `project-context.mdc` and fill it in. Or pick a pack below.

## Packs (start small)

| Pack | Rules | Why start here |
|---|---|---|
| **Starter (5)** | `project-context` (filled in), `implementation-workflow`, `no-duplication`, `systematic-debugging`, `continuous-improvement` | Definition of Done + search-before-create + anti-loop + the retro reflex. This alone starts the self-learning loop. |
| **Verification (5)** | `cloud-first-verification`, `cicd-first`, `git-workflow`, `local-environment-hygiene`, `parallel-delegation` | "Done" means a pipeline said so and a diff proves it. The highest-churn rules in the reference build live here. |
| **Standards (10, glob-scoped)** | `typescript-standards`, `react-frontend`, `tailwind-design-system`, `lambda-api`, `database-schema`, `terraform-infra`, `testing-quality`, `testing-standards`, `accessibility-standards`, `static-analysis-and-logging` | Zero cost until the agent opens a matching file. Adopt the ones that match your stack. |
| **On-demand (3)** | `aws-services`, `performance-optimization`, `security-compliance` | Reference material the agent pulls when relevant. |

## Catalog

`Lines` = this published (scrubbed, generalized) copy; the harvested originals totalled 1,751.
`Revs` = commits that touched the file in the reference build. `*` = entered git in a single import
on 2026-06-09, so its real birth is earlier than its git history. `F-refs` = finding IDs cited inline.
`tailwind-design-system.mdc` is best read as a worked example of a token rule — swap in your tokens.

### Always-on (10)

| Rule | Lines | Revs | F-refs | Born | Purpose | Money quote |
|---|---:|---:|---:|---|---|---|
| [`project-context.template.mdc`](project-context.template.mdc) | 76 | 4 | 0 | * | Your business constraints + the "guardrails, not cages" philosophy. **Template — fill in.** | "If a rule blocks a clearly better solution, it's a guardrail bug: do the better thing, then update the rule." |
| [`implementation-workflow.mdc`](implementation-workflow.mdc) | 52 | 3 | 5 | * | Read task → search existing code → build the minimum → Definition of Done | "Never claim done from a local run alone." |
| [`no-duplication.mdc`](no-duplication.mdc) | 39 | 2 | 3 | * | Search before creating; shared layers; minimal-code mandate | "Search across ALL phases, not just the current one." |
| [`git-workflow.mdc`](git-workflow.mdc) | 98 | 9 | 0 | * | Two long-lived branches, one feature branch at a time, push mechanics | "This single-track flow is the default, not a cage … pause and ask the user for explicit confirmation." |
| [`cicd-first.mdc`](cicd-first.mdc) | 174 | **11** | 8 | 2026-06-16 | The pipeline is the only deploy path; catalog of pipeline-semantics traps | "CI is NOT the deploy buildspec — a deploy-only step can pass CI and still fail the deploy." |
| [`cloud-first-verification.mdc`](cloud-first-verification.mdc) | 96 | 5 | 3 | 2026-06-16 | All pass/fail signals come from CI; local is for editing | "The ONLY sanctioned verification path is the pipeline." |
| [`local-environment-hygiene.mdc`](local-environment-hygiene.mdc) | 78 | 4 | 0 | 2026-06-27 | One clone, version parity with CI, verify the push really landed | "A correct-looking local tree means nothing if the push didn't fully reach the remote." |
| [`systematic-debugging.mdc`](systematic-debugging.mdc) | 42 | 1 | 0 | 2026-06-27 | Anti-loop: switch to systematic mode after 2 failed fixes; keep an attempt ledger | "Symptoms shifting from A to B after a change is the signal to look for a second cause, not to celebrate." |
| [`continuous-improvement.mdc`](continuous-improvement.mdc) | 39 | 1 | 0 | 2026-06-27 | Mandatory post-task retrospective that evolves rules/skills | "This is mandatory and automatic; it is how the rules/skills (and the agent) keep getting smarter." |
| [`parallel-delegation.mdc`](parallel-delegation.mdc) | 36 | 1 | 0 | 2026-07-03 | Delegating to subagents: ground-truth evidence in, verified diffs out | "A 'done' report is a claim, not a fact." |

### Glob-scoped (10)

| Rule | Globs | Lines | Revs | F-refs | Born | Purpose | Money quote |
|---|---|---:|---:|---:|---|---|---|
| [`typescript-standards.mdc`](typescript-standards.mdc) | `**/*.ts,**/*.tsx` | 48 | 2 | 1 | * | Strict TS, imports, naming, exhaustive switches | "A TS `interface` does **not** implicitly satisfy `Record<string, unknown>`." |
| [`react-frontend.mdc`](react-frontend.mdc) | `**/*.tsx` | 125 | 4 | 0 | * | Component, state, query-key, scroll-restoration conventions | "If programmatic scroll reaches the footer but the user can't, suspect scroll hijacking, not CSS." |
| [`tailwind-design-system.mdc`](tailwind-design-system.mdc) | `**/*.tsx,**/*.css` | 75 | 1 | 0 | * | Design tokens and styling conventions — the one rule that never needed to change | "Never hardcode hex values — always reference tokens." |
| [`accessibility-standards.mdc`](accessibility-standards.mdc) | `**/*.tsx` | 59 | 1 | 0 | 2026-07-03 | axe-core / WCAG AA violation → fix patterns, applied at author time | "axe on a page that renders blank passes **vacuously** — there are no elements to violate." |
| [`lambda-api.mdc`](lambda-api.mdc) | `**/*.ts` | 89 | 2 | 0 | * | Handler pattern, RBAC, response shape, cold-start hygiene | "Function-per-domain, not function-per-route." |
| [`database-schema.mdc`](database-schema.mdc) | `**/*.ts,**/*.sql` | 91 | 4 | 7 | * | Schema, migrations, concurrency and fixed-width IDs | "Race bugs pass sequential tests and only fail under a concurrent burst; assert the **durable DB invariant**, not just the HTTP status." |
| [`terraform-infra.mdc`](terraform-infra.mdc) | `**/*.tf` | 165 | 6 | **16** | * | IaC standards + operational hygiene from real incidents | "`plan` clean is necessary but not sufficient." |
| [`testing-quality.mdc`](testing-quality.mdc) | `**/*.test.ts,**/*.test.tsx,**/*.spec.ts,**/*.spec.tsx` | 104 | 4 | 6 | * | Test stack, CI gates, load-test interpretation, SDK mocking | "A CloudWatch 'no data' row is a capture bug, not a healthy zero." |
| [`testing-standards.mdc`](testing-standards.mdc) | tests + e2e | 63 | 3 | 0 | 2026-06-17 | No time-bombs, clean runner exit, no whack-a-mole | "Flaky-passed-on-retry is NOT green." |
| [`static-analysis-and-logging.mdc`](static-analysis-and-logging.mdc) | ts, tsx, buildspec, eslint | 42 | 1 | 0 | 2026-06-17 | Lint every package from day one; structured logging only | "A perpetual warning pile trains everyone to ignore red." |

### On-demand (3)

| Rule | Lines | Revs | F-refs | Born | Purpose | Money quote |
|---|---:|---:|---:|---|---|---|
| [`aws-services.mdc`](aws-services.mdc) | 52 | 3 | 0 | * | AWS service conventions (auth, Lambda, API GW, S3, messaging, CI) | "Treat the design doc as the canonical inventory; don't assume a fixed count." |
| [`performance-optimization.mdc`](performance-optimization.mdc) | 68 | 2 | 0 | * | Frontend / Lambda / DB performance; field-vs-lab gating | "FIELD is the SLO, LAB is a regression detector." |
| [`security-compliance.mdc`](security-compliance.mdc) | 80 | 3 | 1 | * | Sensitive-data handling, authZ, probe correctness, data-protection law mapping | "An intermittently passing/failing security test is itself a defect." |

## Anatomy of a rule in this pack

```
---
description: <one line the agent uses to decide relevance>
globs: "<optional glob>"
alwaysApply: <true|false>
---
# <Title>

## <Principle stated first>
<Why, in 2-4 lines. Then the catalogued failure it prevents, with its finding ID.>

## <Next principle> …
```

What you will **not** find: long checklists the agent must follow mechanically, banned-approach
lists, or style nits that a linter should own. The project-context rule's first section explains
the stance: *guardrails, not cages*.

## Adapting a rule to your stack

- Keep the principle; rewrite the example. The examples use a neutral `orders / customers /
  suppliers` domain — swap in yours.
- Placeholders: `<project>`, `<prefix>`, `<account-id>`, `<region>`, `<env>`, `<repo>`,
  `<api-package>/`, `<infra>/`, `<terraform-modules>/`.
- If a rule fights a clearly better approach in your context, change the rule and record why in
  your retrospective — that is the loop working, not failing.
