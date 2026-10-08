# The loop — how a rule pack became self-updating

This document is the "why" behind the repo. The rules and skills are outputs; the loop is the
mechanism. It needs three things that most projects already have and one they usually don't.

## The three things you already have

1. **A plan with per-task logs.** Every task in the implementation plan has an *Implementation
   Log* block: files touched, decisions, date, and — critically — **deferred work**. The log is the
   authoritative status; a summary table at the top of the plan is explicitly declared stale.
2. **A CI pipeline that is the only verdict.** Lint, typecheck, tests, build, IaC validate and
   deploy run in CI. Local runs are for editing. This matters for the loop because it makes every
   failure *legible*: a CI log line is evidence you can cite in a finding; "it worked on my machine"
   is not.
3. **A retrospective document.** One file, one table-ish section per theme, every row a finding
   with an ID (`F-<letter><n>`), what broke, root cause, and **which rule or skill it maps to**.

## The one thing you usually don't

4. **An always-on rule that makes the retrospective mandatory after every task.** This is
   [`rules/continuous-improvement.mdc`](../rules/continuous-improvement.mdc). It tells the agent:
   when a task ends, reflect; if there was any friction signal, record a finding and *extend an
   existing* rule or skill; if the lesson isn't project-specific, carry it to a user-level skill.
   Because it is always-on, it fires without anyone remembering to ask.

## The loop, step by step

```
┌────────────────────────────────────────────────────────────────────────┐
│ 1. Task starts. Always-on rules are already in context.                 │
│ 2. Agent reads the task + referenced design docs, searches before       │
│    creating, builds the minimum.                                        │
│ 3. Branch pushed → CI is the gate. Agent reads the log, not its memory. │
│ 4. PR merged → pipeline deploys → agent shows an artifact.              │
│ 5. Implementation Log updated (files, decisions, DEFERRED work).        │
│ 6. Retrospective reflex (continuous-improvement.mdc):                    │
│      · trivial, nothing learned → one line, no file changes             │
│      · any friction signal → finding ID + extend a rule/skill           │
│ 7. If the lesson is general → user-level skill / personal rule.         │
│ 8. Next task starts with the smarter rules.                             │
└────────────────────────────────────────────────────────────────────────┘
```

### Friction signals that trigger a finding

A user correction ("no", "again", "revert", "why") · a whack-a-mole loop · a fix that broke
something else · an environment/tooling gotcha · a "claimed done" that wasn't · a drift / version
/ sync surprise · a new reusable pattern.

### What "extend, never fork" means

A new lesson goes into the rule that already owns the topic as a new section with the finding ID
inline. Over the reference build this produced one rule with 11 revisions and 8 inline finding refs
(`cicd-first.mdc`) and another with 16 inline refs (`terraform-infra.mdc`). Neither was ever split
or duplicated; both read as a single coherent doctrine with scars.

## Three case studies (anonymized)

### A. "Green CI, red deploy"
A build step that only ran in the deploy buildspec (not in CI) failed on merge with `command not
found` because the tool was a transitive dependency without a `node_modules/.bin` symlink. Finding
→ two guards added to `cicd-first.mdc`: every tool a `package.json` script invokes must be a
declared devDependency, and if a deploy-only step is worth gating, also run it in CI. A second
finding the same week (`terraform validate` passing on a 330-char description that `plan` rejected)
landed in the same rule as "validate ≠ plan; the pipeline's plan is the real gate".

### B. The three-root-cause E2E flake
A journey suite failed in rotating ways across browsers. Each "fix" moved the failure. Systematic
mode revealed three stacked causes: CDN MIME-type masking, a WAF rate limit tripping under
parallel shards, and a genuine UI race. The lesson produced `systematic-debugging.mdc` ("symptoms
shifting from A to B is the signal to look for a second cause, not to celebrate"), the
`debugging-with-evidence-ledger` skill (ledger per variant), and the `e2e-flake-triage` skill
(flaky-passed-on-retry is not green; quarantine with owner + deadline).

### C. The delegate that said "no changes needed"
A subagent asked to fix an accessibility colour-contrast issue reported nothing to do — on pages
that *were* failing, on a different axe rule its narrow heuristic never covered. Other delegates
reported edits that never persisted. `parallel-delegation.mdc` was born: hand delegates the exact
failing evidence, partition writes to disjoint files, and read the full `git diff` before
building on any "done".

## Adopting the loop in your project

1. Copy the Starter pack (`rules/README.md#packs`) and fill in `project-context.mdc`.
2. Copy `templates/RETROSPECTIVE_AND_PLAYBOOK.template.md` to `docs/` and start at `F-A1`.
3. Give every task in your plan an Implementation Log block (template coming in the next release).
4. Make CI the only verdict. If you can't yet, at least make the agent cite the CI log when it
   claims done.
5. Install the user-level `continuous-improvement-retrospective` skill so the reflex follows you
   across repos.
6. Resist the urge to write rules in advance. Let findings create them.

## What the loop does *not* do

It does not make the agent infallible. It makes the **same mistake expensive to repeat**. The
reference build still accumulated 133 findings — but very few were repeats, and the ones that were
got a sharper rule the second time.
